using MediatR;
using Microsoft.EntityFrameworkCore;
using RedTaxi.Domain.Enums;
using RedTaxi.Domain.Events;
using RedTaxi.Infrastructure.Persistence;

namespace RedTaxi.Application.Bookings.Commands;

public record CompleteBookingCommand(int BookingId) : IRequest<bool>;

public class CompleteBookingCommandHandler : IRequestHandler<CompleteBookingCommand, bool>
{
    private readonly TenantDbContext _db;
    private readonly IPublisher _publisher;

    public CompleteBookingCommandHandler(TenantDbContext db, IPublisher publisher)
    {
        _db = db;
        _publisher = publisher;
    }

    public async Task<bool> Handle(CompleteBookingCommand request, CancellationToken ct)
    {
        var booking = await _db.Bookings.FirstOrDefaultAsync(b => b.Id == request.BookingId, ct)
            ?? throw new KeyNotFoundException($"Booking {request.BookingId} not found.");

        if (booking.Status == BookingStatus.Complete)
            return false;

        booking.Status = BookingStatus.Complete;
        booking.DateUpdated = DateTime.UtcNow;

        await _db.SaveChangesAsync(ct);
        await _publisher.Publish(new BookingCompletedEvent(booking.Id), ct);

        return true;
    }
}
