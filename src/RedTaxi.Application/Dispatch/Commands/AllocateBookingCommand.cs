using Hangfire;
using MediatR;
using Microsoft.EntityFrameworkCore;
using RedTaxi.Application.Jobs;
using RedTaxi.Domain.Entities;
using RedTaxi.Domain.Enums;
using RedTaxi.Domain.Events;
using RedTaxi.Domain.Interfaces;
using RedTaxi.Infrastructure.Persistence;

namespace RedTaxi.Application.Dispatch.Commands;

public record AllocateBookingCommand(int BookingId, int DriverUserId) : IRequest<bool>;

public class AllocateBookingCommandHandler : IRequestHandler<AllocateBookingCommand, bool>
{
    private readonly TenantDbContext _db;
    private readonly ICurrentUserService _currentUser;
    private readonly IPublisher _publisher;

    public AllocateBookingCommandHandler(TenantDbContext db, ICurrentUserService currentUser, IPublisher publisher)
    {
        _db = db;
        _currentUser = currentUser;
        _publisher = publisher;
    }

    public async Task<bool> Handle(AllocateBookingCommand request, CancellationToken ct)
    {
        var booking = await _db.Bookings.FirstOrDefaultAsync(b => b.Id == request.BookingId, ct)
            ?? throw new KeyNotFoundException($"Booking {request.BookingId} not found.");

        if (booking.Cancelled)
            throw new InvalidOperationException("Cannot allocate a cancelled booking.");

        var driver = await _db.UserProfiles
            .AsNoTracking()
            .FirstOrDefaultAsync(u => u.UserId == request.DriverUserId && u.IsActive, ct)
            ?? throw new KeyNotFoundException($"Driver with UserId {request.DriverUserId} not found or inactive.");

        int? previousDriver = booking.UserId;

        // DS02: Un-allocate previous driver first
        if (previousDriver.HasValue)
        {
            var previousAllocation = await _db.DriverAllocations
                .Where(a => a.BookingId == booking.Id && a.UserId == previousDriver.Value && a.UnallocatedAt == null)
                .OrderByDescending(a => a.AllocatedAt)
                .FirstOrDefaultAsync(ct);

            if (previousAllocation != null)
            {
                previousAllocation.UnallocatedAt = DateTime.UtcNow;
                previousAllocation.UnallocatedByName = _currentUser.UserName;
            }

            await _publisher.Publish(new BookingUnallocatedEvent(booking.Id, previousDriver.Value), ct);
        }

        booking.UserId = request.DriverUserId;
        booking.SuggestedUserId = null; // clear soft allocate
        booking.AllocatedAt = DateTime.UtcNow;
        booking.AllocatedById = _currentUser.UserId;
        booking.Status = BookingStatus.None; // awaiting driver response
        booking.DateUpdated = DateTime.UtcNow;

        // Create allocation record
        _db.DriverAllocations.Add(new DriverAllocation
        {
            BookingId = booking.Id,
            UserId = request.DriverUserId,
            AllocatedAt = DateTime.UtcNow,
            AllocatedByName = _currentUser.UserName,
        });

        // Create job offer
        var config = await _db.CompanyConfigs.AsNoTracking().FirstOrDefaultAsync(ct);
        var jobOffer = new JobOffer
        {
            BookingId = booking.Id,
            UserId = request.DriverUserId,
            OfferGuid = Guid.NewGuid(),
            OfferedAt = DateTime.UtcNow,
            Channel = SendMessageOfType.Push,
            AttemptNumber = 1,
        };
        _db.JobOffers.Add(jobOffer);

        // DS04: Audit log entry
        _db.BookingChangeAudits.Add(new BookingChangeAudit
        {
            EntityIdentifier = booking.Id.ToString(),
            UserFullName = "System",
            TimeStamp = DateTime.UtcNow,
            PropertyName = "UserId",
            OldValue = previousDriver?.ToString(),
            NewValue = request.DriverUserId.ToString(),
            Action = "Allocated",
            EntityName = "Booking"
        });

        await _db.SaveChangesAsync(ct);

        // DS08/DS09: Schedule job offer timeout via Hangfire
        var timeoutSeconds = config?.JobOfferTimeoutSeconds ?? 120;
        BackgroundJob.Schedule<JobOfferTimeoutJob>(
            job => job.CheckTimeout(jobOffer.OfferGuid),
            TimeSpan.FromSeconds(timeoutSeconds));

        await _publisher.Publish(new BookingAllocatedEvent(booking.Id, request.DriverUserId, previousDriver), ct);

        return true;
    }
}
