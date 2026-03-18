using MediatR;
using Microsoft.EntityFrameworkCore;
using RedTaxi.Domain.Entities;
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

        // BK12: COA Toggle — if IsCOA and already CancelledOnArrival, toggle it off
        if (request.IsCOA && booking.Cancelled && booking.CancelledOnArrival)
        {
            booking.CancelledOnArrival = false;
            booking.DateUpdated = DateTime.UtcNow;
            await _db.SaveChangesAsync(ct);
            return true;
        }

        if (booking.Cancelled)
            return false; // already cancelled (non-COA toggle)

        booking.Cancelled = true;
        booking.CancelledOnArrival = request.IsCOA;
        booking.CancelledByName = _currentUser.UserName;
        booking.DateUpdated = DateTime.UtcNow;

        // BK12: Create COARecord when toggling COA on
        if (request.IsCOA)
        {
            _db.COARecords.Add(new COARecord
            {
                BookingId = booking.Id,
                AccountCharge = booking.PriceAccount,
                DriverPayout = booking.Price,
                Reason = "Cancelled on arrival",
                CreatedAt = DateTime.UtcNow,
                CreatedByName = _currentUser.UserName,
            });
        }

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
