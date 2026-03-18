using FluentValidation;
using MediatR;
using Microsoft.EntityFrameworkCore;
using RedTaxi.Domain.Entities;
using RedTaxi.Domain.Enums;
using RedTaxi.Domain.Events;
using RedTaxi.Domain.Interfaces;
using RedTaxi.Infrastructure.Persistence;
using RedTaxi.Shared.DTOs;

namespace RedTaxi.Application.Bookings.Commands;

// ── Command ──────────────────────────────────────────────────────────────────
public record CreateBookingCommand(BookingCreateDto Dto) : IRequest<BookingDto>;

// ── Validator ────────────────────────────────────────────────────────────────
public class CreateBookingCommandValidator : AbstractValidator<CreateBookingCommand>
{
    public CreateBookingCommandValidator()
    {
        RuleFor(x => x.Dto.PickupAddress).NotEmpty().MaximumLength(250);
        RuleFor(x => x.Dto.PickupDateTime).GreaterThan(DateTime.MinValue);
        RuleFor(x => x.Dto.Passengers).GreaterThan(0);
    }
}

// ── Handler ──────────────────────────────────────────────────────────────────
public class CreateBookingCommandHandler : IRequestHandler<CreateBookingCommand, BookingDto>
{
    private readonly TenantDbContext _db;
    private readonly ICurrentUserService _currentUser;
    private readonly IPricingService _pricing;
    private readonly IPublisher _publisher;

    public CreateBookingCommandHandler(
        TenantDbContext db,
        ICurrentUserService currentUser,
        IPricingService pricing,
        IPublisher publisher)
    {
        _db = db;
        _currentUser = currentUser;
        _pricing = pricing;
        _publisher = publisher;
    }

    public async Task<BookingDto> Handle(CreateBookingCommand request, CancellationToken ct)
    {
        var dto = request.Dto;

        var booking = new Booking
        {
            PickupAddress = dto.PickupAddress,
            PickupPostCode = dto.PickupPostCode ?? string.Empty,
            DestinationAddress = dto.DestinationAddress,
            DestinationPostCode = dto.DestinationPostCode,
            Details = dto.Details,
            PassengerName = dto.PassengerName,
            Passengers = dto.Passengers,
            PhoneNumber = dto.PhoneNumber,
            Email = dto.Email,
            PickupDateTime = dto.PickupDateTime,
            ArriveBy = dto.ArriveBy,
            IsASAP = dto.IsASAP,
            Scope = (BookingScope)dto.Scope,
            AccountNumber = dto.AccountNumber,
            VehicleType = (VehicleType)dto.VehicleType,
            ChargeFromBase = dto.ChargeFromBase,
            IsSchoolRun = dto.IsSchoolRun,
            DateCreated = DateTime.UtcNow,
            ActionByUserId = _currentUser.UserId ?? 0,
            BookedByName = _currentUser.UserName,
        };

        // Add vias
        if (dto.Vias is { Count: > 0 })
        {
            foreach (var via in dto.Vias)
            {
                booking.Vias.Add(new BookingVia
                {
                    Address = via.Address,
                    PostCode = via.PostCode,
                    ViaSequence = via.ViaSequence,
                });
            }
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
        await _db.SaveChangesAsync(ct);

        // Publish domain event
        await _publisher.Publish(new BookingCreatedEvent(booking.Id), ct);

        // Handle return journey
        if (dto.IsReturn && dto.ReturnPickupDateTime.HasValue && !string.IsNullOrWhiteSpace(dto.DestinationAddress))
        {
            var returnBooking = new Booking
            {
                PickupAddress = dto.DestinationAddress,
                PickupPostCode = dto.DestinationPostCode ?? string.Empty,
                DestinationAddress = dto.PickupAddress,
                DestinationPostCode = dto.PickupPostCode,
                Details = dto.Details != null ? $"[Return] {dto.Details}" : "[Return]",
                PassengerName = dto.PassengerName,
                Passengers = dto.Passengers,
                PhoneNumber = dto.PhoneNumber,
                Email = dto.Email,
                PickupDateTime = dto.ReturnPickupDateTime.Value,
                IsASAP = false,
                Scope = (BookingScope)dto.Scope,
                AccountNumber = dto.AccountNumber,
                VehicleType = (VehicleType)dto.VehicleType,
                ChargeFromBase = dto.ChargeFromBase,
                IsSchoolRun = dto.IsSchoolRun,
                DateCreated = DateTime.UtcNow,
                ActionByUserId = _currentUser.UserId ?? 0,
                BookedByName = _currentUser.UserName,
            };

            var (rDriverPrice, rAccountPrice, rMileage, rMileageText, rDurationText) =
                await _pricing.CalculatePriceAsync(returnBooking, ct);

            returnBooking.Price = rDriverPrice;
            returnBooking.PriceAccount = rAccountPrice;
            returnBooking.Mileage = rMileage;
            returnBooking.MileageText = rMileageText;
            returnBooking.DurationText = rDurationText;

            _db.Bookings.Add(returnBooking);
            await _db.SaveChangesAsync(ct);

            await _publisher.Publish(new BookingCreatedEvent(returnBooking.Id), ct);
        }

        return await MapToDto(booking.Id, ct);
    }

    private async Task<BookingDto> MapToDto(int bookingId, CancellationToken ct)
    {
        var b = await _db.Bookings
            .AsNoTracking()
            .Include(x => x.Vias)
            .Include(x => x.UserProfile)
            .FirstAsync(x => x.Id == bookingId, ct);

        string? accountName = null;
        if (b.AccountNumber.HasValue)
        {
            accountName = await _db.Accounts
                .Where(a => a.AccountNumber == b.AccountNumber)
                .Select(a => a.CompanyName)
                .FirstOrDefaultAsync(ct);
        }

        return BookingMapper.ToDto(b, accountName);
    }
}

// ── Shared mapper ────────────────────────────────────────────────────────────
public static class BookingMapper
{
    public static BookingDto ToDto(Booking b, string? accountName = null)
    {
        return new BookingDto(
            b.Id, b.PickupAddress, b.PickupPostCode, b.DestinationAddress, b.DestinationPostCode,
            b.Details, b.PassengerName, b.Passengers, b.PhoneNumber, b.Email,
            b.PickupDateTime, b.ArriveBy, b.IsASAP,
            b.Scope.HasValue ? (int)b.Scope.Value : null,
            b.Status.HasValue ? (int)b.Status.Value : null,
            b.UserId, b.UserProfile?.FullName, b.UserProfile?.ColorCodeRGB,
            b.Price, b.PriceAccount, b.Tip, b.ManuallyPriced,
            b.Mileage, b.MileageText, b.DurationText,
            b.AccountNumber, accountName,
            (int)b.VehicleType, b.WaitingTimeMinutes, b.WaitingTimePriceDriver, b.WaitingTimePriceAccount,
            b.ParkingCharge, b.VatAmountAdded,
            b.Cancelled, b.CancelledOnArrival, b.IsSchoolRun,
            b.PostedForInvoicing, b.PostedForStatement,
            b.ConfirmationStatus.HasValue ? (int)b.ConfirmationStatus.Value : null,
            b.PaymentStatus.HasValue ? (int)b.PaymentStatus.Value : null,
            b.PaymentLink, b.PaymentReceiptSent,
            b.DateCreated, b.DateUpdated, b.BookedByName,
            b.Vias.OrderBy(v => v.ViaSequence)
                .Select(v => new BookingViaDto(v.Id, v.Address, v.PostCode, v.ViaSequence))
                .ToList());
    }
}
