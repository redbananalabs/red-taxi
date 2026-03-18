using MediatR;
using Microsoft.EntityFrameworkCore;
using RedTaxi.Domain.Entities;
using RedTaxi.Domain.Events;
using RedTaxi.Domain.Interfaces;
using RedTaxi.Infrastructure.Persistence;
using RedTaxi.Shared.DTOs;

namespace RedTaxi.Application.Bookings.Commands;

public record CreateReturnBookingCommand(int OriginalBookingId, DateTime ReturnPickupDateTime) : IRequest<BookingDto>;

public class CreateReturnBookingCommandHandler : IRequestHandler<CreateReturnBookingCommand, BookingDto>
{
    private readonly TenantDbContext _db;
    private readonly ICurrentUserService _currentUser;
    private readonly IPricingService _pricing;
    private readonly IPublisher _publisher;

    public CreateReturnBookingCommandHandler(
        TenantDbContext db, ICurrentUserService currentUser, IPricingService pricing, IPublisher publisher)
    {
        _db = db;
        _currentUser = currentUser;
        _pricing = pricing;
        _publisher = publisher;
    }

    public async Task<BookingDto> Handle(CreateReturnBookingCommand request, CancellationToken ct)
    {
        var original = await _db.Bookings
            .AsNoTracking()
            .Include(b => b.Vias)
            .FirstOrDefaultAsync(b => b.Id == request.OriginalBookingId, ct)
            ?? throw new KeyNotFoundException($"Booking {request.OriginalBookingId} not found.");

        // Create return booking with swapped addresses
        var returnBooking = new Booking
        {
            PickupAddress = original.DestinationAddress ?? original.PickupAddress,
            PickupPostCode = original.DestinationPostCode ?? string.Empty,
            DestinationAddress = original.PickupAddress,
            DestinationPostCode = original.PickupPostCode,
            Details = original.Details != null ? $"[Return] {original.Details}" : "[Return]",
            PassengerName = original.PassengerName,
            Passengers = original.Passengers,
            PhoneNumber = original.PhoneNumber,
            Email = original.Email,
            PickupDateTime = request.ReturnPickupDateTime,
            IsASAP = false,
            Scope = original.Scope,
            AccountNumber = original.AccountNumber,
            VehicleType = original.VehicleType,
            ChargeFromBase = original.ChargeFromBase,
            IsSchoolRun = original.IsSchoolRun,
            DateCreated = DateTime.UtcNow,
            ActionByUserId = _currentUser.UserId ?? 0,
            BookedByName = _currentUser.UserName,
        };

        // Recalculate price for the reversed route
        var (driverPrice, accountPrice, mileage, mileageText, durationText) =
            await _pricing.CalculatePriceAsync(returnBooking, ct);

        returnBooking.Price = driverPrice;
        returnBooking.PriceAccount = accountPrice;
        returnBooking.Mileage = mileage;
        returnBooking.MileageText = mileageText;
        returnBooking.DurationText = durationText;

        _db.Bookings.Add(returnBooking);
        await _db.SaveChangesAsync(ct);
        await _publisher.Publish(new BookingCreatedEvent(returnBooking.Id), ct);

        var result = await _db.Bookings
            .AsNoTracking()
            .Include(x => x.Vias)
            .Include(x => x.UserProfile)
            .FirstAsync(x => x.Id == returnBooking.Id, ct);

        string? accountName = null;
        if (result.AccountNumber.HasValue)
        {
            accountName = await _db.Accounts
                .Where(a => a.AccountNumber == result.AccountNumber)
                .Select(a => a.CompanyName)
                .FirstOrDefaultAsync(ct);
        }

        return BookingMapper.ToDto(result, accountName);
    }
}
