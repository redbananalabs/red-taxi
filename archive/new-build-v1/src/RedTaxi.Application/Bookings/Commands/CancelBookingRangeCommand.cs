using MediatR;
using Microsoft.EntityFrameworkCore;
using RedTaxi.Domain.Events;
using RedTaxi.Domain.Interfaces;
using RedTaxi.Infrastructure.Persistence;

namespace RedTaxi.Application.Bookings.Commands;

/// <summary>
/// Cancels a range of block bookings sharing the same RecurrenceID.
/// If CancelAll is true, cancels all bookings with that RecurrenceID.
/// If CancelFromDate is provided, cancels only bookings on or after that date.
/// </summary>
public record CancelBookingRangeCommand(int BookingId, bool CancelAll, DateTime? CancelFromDate) : IRequest<int>;

public class CancelBookingRangeCommandHandler : IRequestHandler<CancelBookingRangeCommand, int>
{
    private readonly TenantDbContext _db;
    private readonly ICurrentUserService _currentUser;
    private readonly IPublisher _publisher;

    public CancelBookingRangeCommandHandler(TenantDbContext db, ICurrentUserService currentUser, IPublisher publisher)
    {
        _db = db;
        _currentUser = currentUser;
        _publisher = publisher;
    }

    public async Task<int> Handle(CancelBookingRangeCommand request, CancellationToken ct)
    {
        // Load the reference booking to get its RecurrenceID
        var reference = await _db.Bookings
            .AsNoTracking()
            .FirstOrDefaultAsync(b => b.Id == request.BookingId, ct)
            ?? throw new KeyNotFoundException($"Booking {request.BookingId} not found.");

        // Determine the recurrence group ID — could be the booking's own RecurrenceID or the booking itself as parent
        var recurrenceId = reference.RecurrenceID ?? reference.Id;

        // Query all bookings in the recurrence group (parent + generated children)
        var query = _db.Bookings
            .Where(b => !b.Cancelled &&
                        (b.Id == recurrenceId || b.RecurrenceID == recurrenceId));

        if (!request.CancelAll && request.CancelFromDate.HasValue)
        {
            var fromDate = request.CancelFromDate.Value;
            query = query.Where(b => b.PickupDateTime >= fromDate);
        }

        var bookingsToCancel = await query.ToListAsync(ct);

        foreach (var booking in bookingsToCancel)
        {
            booking.Cancelled = true;
            booking.CancelledByName = _currentUser.UserName;
            booking.DateUpdated = DateTime.UtcNow;

            // Clear driver assignment on cancellation
            if (booking.UserId.HasValue)
            {
                booking.UserId = null;
                booking.SuggestedUserId = null;
                booking.AllocatedAt = null;
                booking.AllocatedById = null;
            }
        }

        await _db.SaveChangesAsync(ct);

        foreach (var booking in bookingsToCancel)
        {
            await _publisher.Publish(new BookingCancelledEvent(booking.Id, false), ct);
        }

        return bookingsToCancel.Count;
    }
}
