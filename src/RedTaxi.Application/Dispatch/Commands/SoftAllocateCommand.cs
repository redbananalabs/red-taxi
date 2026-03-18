using MediatR;
using Microsoft.EntityFrameworkCore;
using RedTaxi.Infrastructure.Persistence;

namespace RedTaxi.Application.Dispatch.Commands;

/// <summary>
/// Sets SuggestedUserId only — no notifications sent. Used for pre-planning.
/// </summary>
public record SoftAllocateCommand(int BookingId, int DriverUserId) : IRequest<bool>;

public class SoftAllocateCommandHandler : IRequestHandler<SoftAllocateCommand, bool>
{
    private readonly TenantDbContext _db;

    public SoftAllocateCommandHandler(TenantDbContext db) => _db = db;

    public async Task<bool> Handle(SoftAllocateCommand request, CancellationToken ct)
    {
        var booking = await _db.Bookings.FirstOrDefaultAsync(b => b.Id == request.BookingId, ct)
            ?? throw new KeyNotFoundException($"Booking {request.BookingId} not found.");

        if (booking.Cancelled)
            throw new InvalidOperationException("Cannot soft-allocate a cancelled booking.");

        // Verify driver exists
        var driverExists = await _db.UserProfiles
            .AnyAsync(u => u.UserId == request.DriverUserId && u.IsActive, ct);
        if (!driverExists)
            throw new KeyNotFoundException($"Driver with UserId {request.DriverUserId} not found or inactive.");

        booking.SuggestedUserId = request.DriverUserId;
        booking.DateUpdated = DateTime.UtcNow;

        await _db.SaveChangesAsync(ct);
        return true;
    }
}
