using MediatR;
using Microsoft.EntityFrameworkCore;
using RedTaxi.Domain.Events;
using RedTaxi.Domain.Interfaces;
using RedTaxi.Infrastructure.Persistence;

namespace RedTaxi.Application.Bookings.Commands;

public record CancelBookingCommand(int BookingId, bool IsCOA = false) : IRequest<bool>;

public class CancelBookingCommandHandler : IRequestHandler<CancelBookingCommand, bool>
{
    private readonly TenantDbContext _db;
    private readonly ICurrentUserService _currentUser;
    private readonly IPublisher _publisher;

    public CancelBookingCommandHandler(TenantDbContext db, ICurrentUserService currentUser, IPublisher publisher)
    {
        _db = db;
        _currentUser = currentUser;
        _publisher = publisher;
    }

    public async Task<bool> Handle(CancelBookingCommand request, CancellationToken ct)
    {
        var booking = await _db.Bookings.FirstOrDefaultAsync(b => b.Id == request.BookingId, ct)
            ?? throw new KeyNotFoundException($"Booking {request.BookingId} not found.");

        if (booking.Cancelled)
            return false; // already cancelled

        booking.Cancelled = true;
        booking.CancelledOnArrival = request.IsCOA;
        booking.CancelledByName = _currentUser.UserName;
        booking.DateUpdated = DateTime.UtcNow;

        // Clear driver assignment on cancellation
        if (booking.UserId.HasValue)
        {
            var previousDriverId = booking.UserId.Value;
            booking.UserId = null;
            booking.SuggestedUserId = null;
            booking.AllocatedAt = null;
            booking.AllocatedById = null;
        }

        await _db.SaveChangesAsync(ct);
        await _publisher.Publish(new BookingCancelledEvent(booking.Id, request.IsCOA), ct);

        return true;
    }
}
