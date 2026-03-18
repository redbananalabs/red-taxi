using MediatR;
using Microsoft.EntityFrameworkCore;
using RedTaxi.Domain.Entities;
using RedTaxi.Domain.Enums;
using RedTaxi.Domain.Events;
using RedTaxi.Domain.Interfaces;
using RedTaxi.Infrastructure.Persistence;
using RedTaxi.Shared.DTOs;

namespace RedTaxi.Application.Bookings.Commands;

public record GenerateBlockBookingsCommand(int ParentBookingId) : IRequest<List<BookingDto>>;

public class GenerateBlockBookingsCommandHandler : IRequestHandler<GenerateBlockBookingsCommand, List<BookingDto>>
{
    private readonly TenantDbContext _db;
    private readonly ICurrentUserService _currentUser;
    private readonly IPricingService _pricing;
    private readonly IPublisher _publisher;

    public GenerateBlockBookingsCommandHandler(
        TenantDbContext db, ICurrentUserService currentUser, IPricingService pricing, IPublisher publisher)
    {
        _db = db;
        _currentUser = currentUser;
        _pricing = pricing;
        _publisher = publisher;
    }

    public async Task<List<BookingDto>> Handle(GenerateBlockBookingsCommand request, CancellationToken ct)
    {
        var parent = await _db.Bookings
            .AsNoTracking()
            .Include(b => b.Vias)
            .FirstOrDefaultAsync(b => b.Id == request.ParentBookingId, ct)
            ?? throw new KeyNotFoundException($"Booking {request.ParentBookingId} not found.");

        if (string.IsNullOrWhiteSpace(parent.RecurrenceRule))
            throw new InvalidOperationException("Parent booking has no recurrence rule configured.");

        // Parse recurrence rule: "Frequency;Days;EndDate"
        // e.g. "Weekly;Monday,Wednesday,Friday;2026-09-01" or "Daily;;Never"
        var parts = parent.RecurrenceRule.Split(';');
        if (parts.Length < 1)
            throw new InvalidOperationException("Invalid recurrence rule format.");

        var frequency = Enum.Parse<RecurrenceFrequency>(parts[0], ignoreCase: true);

        var recurrenceDays = new List<DayOfWeek>();
        if (parts.Length > 1 && !string.IsNullOrWhiteSpace(parts[1]))
        {
            foreach (var dayName in parts[1].Split(',', StringSplitOptions.TrimEntries | StringSplitOptions.RemoveEmptyEntries))
            {
                if (Enum.TryParse<DayOfWeek>(dayName, ignoreCase: true, out var dow))
                    recurrenceDays.Add(dow);
            }
        }

        DateTime endDate;
        if (parts.Length > 2 && !string.IsNullOrWhiteSpace(parts[2]) &&
            !parts[2].Equals("Never", StringComparison.OrdinalIgnoreCase))
        {
            endDate = DateTime.Parse(parts[2]);
        }
        else
        {
            // Default: 6 months from pickup or configurable
            var config = await _db.CompanyConfigs.AsNoTracking().FirstOrDefaultAsync(ct);
            var months = config?.DefaultBlockBookingMonths ?? 6;
            endDate = parent.PickupDateTime.AddMonths(months);
        }

        // Generate dates starting from the day after the parent booking
        var dates = GenerateDates(parent.PickupDateTime, endDate, frequency, recurrenceDays);

        var createdBookings = new List<BookingDto>();

        foreach (var date in dates)
        {
            var newPickup = new DateTime(date.Year, date.Month, date.Day,
                parent.PickupDateTime.Hour, parent.PickupDateTime.Minute, parent.PickupDateTime.Second);

            var booking = new Booking
            {
                PickupAddress = parent.PickupAddress,
                PickupPostCode = parent.PickupPostCode,
                DestinationAddress = parent.DestinationAddress,
                DestinationPostCode = parent.DestinationPostCode,
                Details = parent.Details,
                PassengerName = parent.PassengerName,
                Passengers = parent.Passengers,
                PhoneNumber = parent.PhoneNumber,
                Email = parent.Email,
                PickupDateTime = newPickup,
                IsASAP = false,
                Scope = parent.Scope,
                AccountNumber = parent.AccountNumber,
                VehicleType = parent.VehicleType,
                ChargeFromBase = parent.ChargeFromBase,
                IsSchoolRun = parent.IsSchoolRun,
                RecurrenceID = parent.Id,
                DateCreated = DateTime.UtcNow,
                ActionByUserId = _currentUser.UserId ?? 0,
                BookedByName = _currentUser.UserName,
            };

            // Copy vias
            foreach (var via in parent.Vias.OrderBy(v => v.ViaSequence))
            {
                booking.Vias.Add(new BookingVia
                {
                    Address = via.Address,
                    PostCode = via.PostCode,
                    ViaSequence = via.ViaSequence,
                });
            }

            // Calculate price
            var (driverPrice, accountPrice, mileage, mileageText, durationText) =
                await _pricing.CalculatePriceAsync(booking, ct);

            booking.Price = driverPrice;
            booking.PriceAccount = accountPrice;
            booking.Mileage = mileage;
            booking.MileageText = mileageText;
            booking.DurationText = durationText;

            _db.Bookings.Add(booking);
        }

        await _db.SaveChangesAsync(ct);

        // Publish events and map to DTOs
        var generatedIds = await _db.Bookings
            .AsNoTracking()
            .Where(b => b.RecurrenceID == parent.Id)
            .OrderBy(b => b.PickupDateTime)
            .Include(b => b.Vias)
            .Include(b => b.UserProfile)
            .ToListAsync(ct);

        string? accountName = null;
        if (parent.AccountNumber.HasValue)
        {
            accountName = await _db.Accounts
                .Where(a => a.AccountNumber == parent.AccountNumber)
                .Select(a => a.CompanyName)
                .FirstOrDefaultAsync(ct);
        }

        foreach (var b in generatedIds)
        {
            await _publisher.Publish(new BookingCreatedEvent(b.Id), ct);
            createdBookings.Add(BookingMapper.ToDto(b, accountName));
        }

        return createdBookings;
    }

    private static List<DateTime> GenerateDates(
        DateTime start, DateTime end, RecurrenceFrequency frequency, List<DayOfWeek> days)
    {
        var dates = new List<DateTime>();
        var current = start.Date.AddDays(1); // start from the next day

        while (current <= end.Date)
        {
            switch (frequency)
            {
                case RecurrenceFrequency.Daily:
                    dates.Add(current);
                    current = current.AddDays(1);
                    break;

                case RecurrenceFrequency.Weekly:
                    if (days.Count == 0 || days.Contains(current.DayOfWeek))
                        dates.Add(current);
                    current = current.AddDays(1);
                    break;

                case RecurrenceFrequency.Fortnightly:
                    // Every 2 weeks from start date on selected days
                    var weeksSinceStart = (int)(current - start.Date).TotalDays / 7;
                    if (weeksSinceStart % 2 == 0 && (days.Count == 0 || days.Contains(current.DayOfWeek)))
                        dates.Add(current);
                    current = current.AddDays(1);
                    break;

                default:
                    current = current.AddDays(1);
                    break;
            }
        }

        return dates;
    }
}
