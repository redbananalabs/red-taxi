using MediatR;
using Microsoft.AspNetCore.SignalR;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;
using RedTaxi.Application.Hubs;
using RedTaxi.Domain.Events;
using RedTaxi.Infrastructure.Persistence;

namespace RedTaxi.Application.Bookings.EventHandlers;

public class BookingCancelledEventHandler : INotificationHandler<BookingCancelledEvent>
{
    private readonly TenantDbContext _db;
    private readonly IHubContext<DispatchHub> _hub;
    private readonly ILogger<BookingCancelledEventHandler> _logger;

    public BookingCancelledEventHandler(
        TenantDbContext db,
        IHubContext<DispatchHub> hub,
        ILogger<BookingCancelledEventHandler> logger)
    {
        _db = db;
        _hub = hub;
        _logger = logger;
    }

    public async Task Handle(BookingCancelledEvent notification, CancellationToken ct)
    {
        _logger.LogInformation("Booking {BookingId} cancelled (COA={IsCOA}) — broadcasting.", notification.BookingId, notification.IsCOA);

        var payload = new { bookingId = notification.BookingId, isCOA = notification.IsCOA };

        // Broadcast to dispatch group
        await _hub.Clients.Group("dispatch").SendAsync("BookingCancelled", payload, ct);

        // Also notify the assigned driver if any
        var driverUserId = await _db.Bookings
            .AsNoTracking()
            .Where(b => b.Id == notification.BookingId)
            .Select(b => b.UserId)
            .FirstOrDefaultAsync(ct);

        if (driverUserId.HasValue)
        {
            await _hub.Clients.Group($"driver-{driverUserId.Value}")
                .SendAsync("BookingCancelled", payload, ct);
        }
    }
}
