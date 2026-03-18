using MediatR;
using Microsoft.EntityFrameworkCore;
using RedTaxi.Domain.Events;
using RedTaxi.Domain.Interfaces;
using RedTaxi.Infrastructure.Persistence;

namespace RedTaxi.Application.Dispatch.Commands;

public record UnallocateBookingCommand(int BookingId) : IRequest<bool>;

public class UnallocateBookingCommandHandler : IRequestHandler<UnallocateBookingCommand, bool>
{
    private readonly TenantDbContext _db;
    private readonly ICurrentUserService _currentUser;
    private readonly IPublisher _publisher;

    public UnallocateBookingCommandHandler(TenantDbContext db, ICurrentUserService currentUser, IPublisher publisher)
    {
        _db = db;
        _currentUser = currentUser;
        _publisher = publisher;
    }

    public async Task<bool> Handle(UnallocateBookingCommand request, CancellationToken ct)
    {
        var booking = await _db.Bookings.FirstOrDefaultAsync(b => b.Id == request.BookingId, ct)
            ?? throw new KeyNotFoundException($"Booking {request.BookingId} not found.");

        if (!booking.UserId.HasValue)
            return false; // not allocated

        int previousDriverId = booking.UserId.Value;

        // Record unallocation on the allocation record
        var allocation = await _db.DriverAllocations
            .Where(a => a.BookingId == booking.Id && a.UserId == previousDriverId && a.UnallocatedAt == null)
            .OrderByDescending(a => a.AllocatedAt)
            .FirstOrDefaultAsync(ct);

        if (allocation != null)
        {
            allocation.UnallocatedAt = DateTime.UtcNow;
            allocation.UnallocatedByName = _currentUser.UserName;
        }

        booking.UserId = null;
        booking.SuggestedUserId = null;
        booking.AllocatedAt = null;
        booking.AllocatedById = null;
        booking.Status = null;
        booking.DateUpdated = DateTime.UtcNow;

        await _db.SaveChangesAsync(ct);
        await _publisher.Publish(new BookingUnallocatedEvent(booking.Id, previousDriverId), ct);

        return true;
    }
}
