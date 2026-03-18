using MediatR;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;
using RedTaxi.Domain.Enums;
using RedTaxi.Domain.Events;
using RedTaxi.Infrastructure.Persistence;

namespace RedTaxi.Application.Jobs;

public class JobOfferTimeoutJob
{
    private readonly TenantDbContext _db;
    private readonly IPublisher _publisher;
    private readonly ILogger<JobOfferTimeoutJob> _logger;

    public JobOfferTimeoutJob(TenantDbContext db, IPublisher publisher, ILogger<JobOfferTimeoutJob> logger)
    {
        _db = db;
        _publisher = publisher;
        _logger = logger;
    }

    public async Task CheckTimeout(Guid offerGuid)
    {
        var jobOffer = await _db.JobOffers
            .FirstOrDefaultAsync(j => j.OfferGuid == offerGuid);

        if (jobOffer == null)
        {
            _logger.LogWarning("JobOffer with Guid {OfferGuid} not found.", offerGuid);
            return;
        }

        // If the driver already responded, do nothing
        if (jobOffer.Response != null)
        {
            _logger.LogInformation("JobOffer {OfferGuid} already has response {Response}. Skipping timeout.",
                offerGuid, jobOffer.Response);
            return;
        }

        // Mark as timed out
        jobOffer.Response = AppJobOffer.TimedOut;
        jobOffer.RespondedAt = DateTime.UtcNow;

        // Update booking status and clear driver
        var booking = await _db.Bookings
            .FirstOrDefaultAsync(b => b.Id == jobOffer.BookingId);

        if (booking != null)
        {
            var driverUserId = booking.UserId;
            booking.Status = BookingStatus.RejectedJobTimeout;
            booking.UserId = null;
            booking.DateUpdated = DateTime.UtcNow;

            await _db.SaveChangesAsync();

            if (driverUserId.HasValue)
            {
                await _publisher.Publish(new BookingUnallocatedEvent(booking.Id, driverUserId.Value));
            }

            _logger.LogInformation("JobOffer {OfferGuid} timed out for booking {BookingId}.", offerGuid, booking.Id);
        }
        else
        {
            await _db.SaveChangesAsync();
        }
    }
}
