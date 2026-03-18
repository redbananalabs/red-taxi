using MediatR;
using Microsoft.EntityFrameworkCore;
using RedTaxi.Domain.Entities;
using RedTaxi.Domain.Events;
using RedTaxi.Domain.Interfaces;
using RedTaxi.Infrastructure.Persistence;
using RedTaxi.Shared.DTOs;

namespace RedTaxi.Application.Bookings.Commands;

public record DuplicateBookingCommand(int SourceBookingId, DateTime NewPickupDateTime) : IRequest<BookingDto>;

public class DuplicateBookingCommandHandler : IRequestHandler<DuplicateBookingCommand, BookingDto>
{
    private readonly TenantDbContext _db;
    private readonly ICurrentUserService _currentUser;
    private readonly IPricingService _pricing;
    private readonly IPublisher _publisher;

    public DuplicateBookingCommandHandler(
        TenantDbContext db, ICurrentUserService currentUser, IPricingService pricing, IPublisher publisher)
    {
        _db = db;
        _currentUser = currentUser;
        _pricing = pricing;
        _publisher = publisher;
    }

    public async Task<BookingDto> Handle(DuplicateBookingCommand request, CancellationToken ct)
    {
        var source = await _db.Bookings
            .AsNoTracking()
            .Include(b => b.Vias)
            .FirstOrDefaultAsync(b => b.Id == request.SourceBookingId, ct)
            ?? throw new KeyNotFoundException($"Booking {request.SourceBookingId} not found.");

        var duplicate = new Booking
        {
            PickupAddress = source.PickupAddress,
            PickupPostCode = source.PickupPostCode,
            DestinationAddress = source.DestinationAddress,
            DestinationPostCode = source.DestinationPostCode,
            Details = source.Details,
            PassengerName = source.PassengerName,
            Passengers = source.Passengers,
            PhoneNumber = source.PhoneNumber,
            Email = source.Email,
            PickupDateTime = request.NewPickupDateTime,
            IsASAP = false,
            Scope = source.Scope,
            AccountNumber = source.AccountNumber,
            VehicleType = source.VehicleType,
            ChargeFromBase = source.ChargeFromBase,
            IsSchoolRun = source.IsSchoolRun,
            DateCreated = DateTime.UtcNow,
            ActionByUserId = _currentUser.UserId ?? 0,
            BookedByName = _currentUser.UserName,
        };

        foreach (var via in source.Vias.OrderBy(v => v.ViaSequence))
        {
            duplicate.Vias.Add(new BookingVia
            {
                Address = via.Address,
                PostCode = via.PostCode,
                ViaSequence = via.ViaSequence,
            });
        }

        var (driverPrice, accountPrice, mileage, mileageText, durationText) =
            await _pricing.CalculatePriceAsync(duplicate, ct);

        duplicate.Price = driverPrice;
        duplicate.PriceAccount = accountPrice;
        duplicate.Mileage = mileage;
        duplicate.MileageText = mileageText;
        duplicate.DurationText = durationText;

        _db.Bookings.Add(duplicate);
        await _db.SaveChangesAsync(ct);
        await _publisher.Publish(new BookingCreatedEvent(duplicate.Id), ct);

        var result = await _db.Bookings
            .AsNoTracking()
            .Include(x => x.Vias)
            .Include(x => x.UserProfile)
            .FirstAsync(x => x.Id == duplicate.Id, ct);

        return BookingMapper.ToDto(result);
    }
}
