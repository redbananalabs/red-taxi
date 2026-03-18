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

public record UpdateBookingCommand(BookingUpdateDto Dto) : IRequest<BookingDto>;

public class UpdateBookingCommandValidator : AbstractValidator<UpdateBookingCommand>
{
    public UpdateBookingCommandValidator()
    {
        RuleFor(x => x.Dto.Id).GreaterThan(0);
        RuleFor(x => x.Dto.PickupAddress).NotEmpty().MaximumLength(250);
        RuleFor(x => x.Dto.PickupDateTime).GreaterThan(DateTime.MinValue);
    }
}

public class UpdateBookingCommandHandler : IRequestHandler<UpdateBookingCommand, BookingDto>
{
    private readonly TenantDbContext _db;
    private readonly ICurrentUserService _currentUser;
    private readonly IPricingService _pricing;
    private readonly IPublisher _publisher;

    public UpdateBookingCommandHandler(
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

    public async Task<BookingDto> Handle(UpdateBookingCommand request, CancellationToken ct)
    {
        var dto = request.Dto;
        var booking = await _db.Bookings
            .Include(b => b.Vias)
            .FirstOrDefaultAsync(b => b.Id == dto.Id, ct)
            ?? throw new KeyNotFoundException($"Booking {dto.Id} not found.");

        // Track whether pricing-sensitive fields changed
        bool needsReprice = !booking.ManuallyPriced && (
            booking.PickupAddress != dto.PickupAddress ||
            booking.PickupPostCode != (dto.PickupPostCode ?? string.Empty) ||
            booking.DestinationAddress != dto.DestinationAddress ||
            booking.DestinationPostCode != dto.DestinationPostCode ||
            booking.Passengers != dto.Passengers ||
            (int)booking.VehicleType != dto.VehicleType ||
            booking.AccountNumber != dto.AccountNumber ||
            booking.ChargeFromBase != dto.ChargeFromBase);

        // Update fields
        booking.PickupAddress = dto.PickupAddress;
        booking.PickupPostCode = dto.PickupPostCode ?? string.Empty;
        booking.DestinationAddress = dto.DestinationAddress;
        booking.DestinationPostCode = dto.DestinationPostCode;
        booking.Details = dto.Details;
        booking.PassengerName = dto.PassengerName;
        booking.Passengers = dto.Passengers;
        booking.PhoneNumber = dto.PhoneNumber;
        booking.Email = dto.Email;
        booking.PickupDateTime = dto.PickupDateTime;
        booking.ArriveBy = dto.ArriveBy;
        booking.IsASAP = dto.IsASAP;
        booking.Scope = (BookingScope)dto.Scope;
        booking.AccountNumber = dto.AccountNumber;
        booking.VehicleType = (VehicleType)dto.VehicleType;
        booking.ChargeFromBase = dto.ChargeFromBase;
        booking.IsSchoolRun = dto.IsSchoolRun;
        booking.DateUpdated = DateTime.UtcNow;
        booking.UpdatedByName = _currentUser.UserName;

        // Sync vias
        booking.Vias.Clear();
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
            needsReprice = true; // vias changed
        }

        // Auto-recalculate price if pricing-sensitive fields changed
        if (needsReprice)
        {
            var (driverPrice, accountPrice, mileage, mileageText, durationText) =
                await _pricing.CalculatePriceAsync(booking, ct);

            booking.Price = driverPrice;
            booking.PriceAccount = accountPrice;
            booking.Mileage = mileage;
            booking.MileageText = mileageText;
            booking.DurationText = durationText;
        }

        await _db.SaveChangesAsync(ct);
        await _publisher.Publish(new BookingAmendedEvent(booking.Id), ct);

        // Reload with navigation properties
        var result = await _db.Bookings
            .AsNoTracking()
            .Include(x => x.Vias)
            .Include(x => x.UserProfile)
            .FirstAsync(x => x.Id == booking.Id, ct);

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
