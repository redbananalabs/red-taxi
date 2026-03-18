using MediatR;
using Microsoft.EntityFrameworkCore;
using RedTaxi.Domain.Entities;
using RedTaxi.Domain.Enums;
using RedTaxi.Domain.Events;
using RedTaxi.Domain.Interfaces;
using RedTaxi.Infrastructure.Persistence;

namespace RedTaxi.Application.Dispatch.Commands;

/// <summary>
/// Batch-converts all soft allocates for a date into firm allocates.
/// </summary>
public record ConfirmSoftAllocatesCommand(DateTime Date) : IRequest<int>;

public class ConfirmSoftAllocatesCommandHandler : IRequestHandler<ConfirmSoftAllocatesCommand, int>
{
    private readonly TenantDbContext _db;
    private readonly ICurrentUserService _currentUser;
    private readonly IPublisher _publisher;

    public ConfirmSoftAllocatesCommandHandler(TenantDbContext db, ICurrentUserService currentUser, IPublisher publisher)
    {
        _db = db;
        _currentUser = currentUser;
        _publisher = publisher;
    }

    public async Task<int> Handle(ConfirmSoftAllocatesCommand request, CancellationToken ct)
    {
        var date = request.Date.Date;
        var nextDay = date.AddDays(1);

        var bookings = await _db.Bookings
            .Where(b => b.SuggestedUserId.HasValue
                && !b.UserId.HasValue
                && !b.Cancelled
                && b.PickupDateTime >= date
                && b.PickupDateTime < nextDay)
            .ToListAsync(ct);

        int count = 0;
        foreach (var booking in bookings)
        {
            var driverUserId = booking.SuggestedUserId!.Value;
            int? previousDriver = booking.UserId;

            booking.UserId = driverUserId;
            booking.SuggestedUserId = null;
            booking.AllocatedAt = DateTime.UtcNow;
            booking.AllocatedById = _currentUser.UserId;
            booking.Status = BookingStatus.None;
            booking.DateUpdated = DateTime.UtcNow;

            _db.DriverAllocations.Add(new DriverAllocation
            {
                BookingId = booking.Id,
                UserId = driverUserId,
                AllocatedAt = DateTime.UtcNow,
                AllocatedByName = _currentUser.UserName,
            });

            _db.JobOffers.Add(new JobOffer
            {
                BookingId = booking.Id,
                UserId = driverUserId,
                OfferGuid = Guid.NewGuid(),
                OfferedAt = DateTime.UtcNow,
                Channel = SendMessageOfType.Push,
                AttemptNumber = 1,
            });

            count++;
        }

        await _db.SaveChangesAsync(ct);

        // Publish events after save
        foreach (var booking in bookings)
        {
            await _publisher.Publish(
                new BookingAllocatedEvent(booking.Id, booking.UserId!.Value, null), ct);
        }

        return count;
    }
}
