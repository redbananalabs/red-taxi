using MediatR;
using Microsoft.EntityFrameworkCore;
using RedTaxi.Domain.Enums;
using RedTaxi.Domain.Events;
using RedTaxi.Infrastructure.Persistence;

namespace RedTaxi.Application.Bookings.Commands;

/// <summary>
/// Hangfire job that auto-completes bookings that were forgotten by drivers.
/// Returns the count of auto-completed bookings.
/// </summary>
public record AutoCompleteBookingsCommand : IRequest<int>;

public class AutoCompleteBookingsCommandHandler : IRequestHandler<AutoCompleteBookingsCommand, int>
{
    private readonly TenantDbContext _db;
    private readonly IPublisher _publisher;

    public AutoCompleteBookingsCommandHandler(TenantDbContext db, IPublisher publisher)
    {
        _db = db;
        _publisher = publisher;
    }

    public async Task<int> Handle(AutoCompleteBookingsCommand request, CancellationToken ct)
    {
        // Get configurable auto-complete hours (default 24h)
        var config = await _db.CompanyConfigs.AsNoTracking().FirstOrDefaultAsync(ct);
        var autoCompleteHours = config?.AutoCompleteHours ?? 24;

        var cutoff = DateTime.UtcNow.AddHours(-autoCompleteHours);

        // Find bookings that are allocated or accepted, past the cutoff, and not cancelled
        var overdueBookings = await _db.Bookings
            .Where(b =>
                !b.Cancelled &&
                b.Status != BookingStatus.Complete &&
                (b.Status == BookingStatus.None || b.Status == BookingStatus.AcceptedJob) &&
                b.UserId.HasValue &&
                b.PickupDateTime < cutoff)
            .ToListAsync(ct);

        foreach (var booking in overdueBookings)
        {
            booking.Status = BookingStatus.Complete;
            booking.Details = string.IsNullOrWhiteSpace(booking.Details)
                ? "Auto-completed by system"
                : $"{booking.Details} | Auto-completed by system";
            booking.DateUpdated = DateTime.UtcNow;
        }

        await _db.SaveChangesAsync(ct);

        foreach (var booking in overdueBookings)
        {
            await _publisher.Publish(new BookingCompletedEvent(booking.Id), ct);
        }

        return overdueBookings.Count;
    }
}
