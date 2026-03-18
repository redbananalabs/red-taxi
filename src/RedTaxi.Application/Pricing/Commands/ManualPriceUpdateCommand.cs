using FluentValidation;
using MediatR;
using Microsoft.EntityFrameworkCore;
using RedTaxi.Domain.Events;
using RedTaxi.Infrastructure.Persistence;
using RedTaxi.Shared.DTOs;

namespace RedTaxi.Application.Pricing.Commands;

public record ManualPriceUpdateCommand(int BookingId, decimal DriverPrice, decimal AccountPrice) : IRequest<PriceResultDto>;

public class ManualPriceUpdateCommandValidator : AbstractValidator<ManualPriceUpdateCommand>
{
    public ManualPriceUpdateCommandValidator()
    {
        RuleFor(x => x.BookingId).GreaterThan(0);
        RuleFor(x => x.DriverPrice).GreaterThanOrEqualTo(0);
        RuleFor(x => x.AccountPrice).GreaterThanOrEqualTo(0);
    }
}

public class ManualPriceUpdateCommandHandler : IRequestHandler<ManualPriceUpdateCommand, PriceResultDto>
{
    private readonly TenantDbContext _db;
    private readonly IPublisher _publisher;

    public ManualPriceUpdateCommandHandler(TenantDbContext db, IPublisher publisher)
    {
        _db = db;
        _publisher = publisher;
    }

    public async Task<PriceResultDto> Handle(ManualPriceUpdateCommand request, CancellationToken ct)
    {
        var booking = await _db.Bookings.FirstOrDefaultAsync(b => b.Id == request.BookingId, ct)
            ?? throw new KeyNotFoundException($"Booking {request.BookingId} not found.");

        booking.Price = request.DriverPrice;
        booking.PriceAccount = request.AccountPrice;
        booking.ManuallyPriced = true;
        booking.DateUpdated = DateTime.UtcNow;

        await _db.SaveChangesAsync(ct);
        await _publisher.Publish(new BookingAmendedEvent(booking.Id), ct);

        return new PriceResultDto(
            booking.Price, booking.PriceAccount, booking.Mileage ?? 0m,
            booking.MileageText, booking.DurationText, "Manual");
    }
}
