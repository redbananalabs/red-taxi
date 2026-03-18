using MediatR;
using Microsoft.EntityFrameworkCore;
using RedTaxi.Domain.Events;
using RedTaxi.Domain.Interfaces;
using RedTaxi.Infrastructure.Persistence;
using RedTaxi.Shared.DTOs;

namespace RedTaxi.Application.Pricing.Commands;

/// <summary>
/// Forces a price recalculation on an existing booking (unless manually priced).
/// </summary>
public record RecalculatePriceCommand(int BookingId) : IRequest<PriceResultDto>;

public class RecalculatePriceCommandHandler : IRequestHandler<RecalculatePriceCommand, PriceResultDto>
{
    private readonly TenantDbContext _db;
    private readonly IPricingService _pricing;
    private readonly IPublisher _publisher;

    public RecalculatePriceCommandHandler(TenantDbContext db, IPricingService pricing, IPublisher publisher)
    {
        _db = db;
        _pricing = pricing;
        _publisher = publisher;
    }

    public async Task<PriceResultDto> Handle(RecalculatePriceCommand request, CancellationToken ct)
    {
        var booking = await _db.Bookings.FirstOrDefaultAsync(b => b.Id == request.BookingId, ct)
            ?? throw new KeyNotFoundException($"Booking {request.BookingId} not found.");

        if (booking.ManuallyPriced)
        {
            return new PriceResultDto(
                booking.Price, booking.PriceAccount, booking.Mileage ?? 0m,
                booking.MileageText, booking.DurationText, "Manual");
        }

        var (driverPrice, accountPrice, mileage, mileageText, durationText) =
            await _pricing.CalculatePriceAsync(booking, ct);

        booking.Price = driverPrice;
        booking.PriceAccount = accountPrice;
        booking.Mileage = mileage;
        booking.MileageText = mileageText;
        booking.DurationText = durationText;
        booking.DateUpdated = DateTime.UtcNow;

        await _db.SaveChangesAsync(ct);
        await _publisher.Publish(new BookingAmendedEvent(booking.Id), ct);

        return new PriceResultDto(driverPrice, accountPrice, mileage, mileageText, durationText, "Recalculated");
    }
}
