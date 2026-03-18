using MediatR;
using Microsoft.AspNetCore.SignalR;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;
using RedTaxi.Application.Hubs;
using RedTaxi.Application.Bookings.Commands;
using RedTaxi.Domain.Events;
using RedTaxi.Infrastructure.Persistence;

namespace RedTaxi.Application.Dispatch.EventHandlers;

public class BookingAllocatedEventHandler : INotificationHandler<BookingAllocatedEvent>
{
    private readonly TenantDbContext _db;
    private readonly IHubContext<DispatchHub> _hub;
    private readonly ILogger<BookingAllocatedEventHandler> _logger;

    public BookingAllocatedEventHandler(
        TenantDbContext db,
        IHubContext<DispatchHub> hub,
        ILogger<BookingAllocatedEventHandler> logger)
    {
        _db = db;
        _hub = hub;
        _logger = logger;
    }

    public async Task Handle(BookingAllocatedEvent notification, CancellationToken ct)
    {
        _logger.LogInformation(
            "Booking {BookingId} allocated to driver {DriverUserId}. Previous driver: {PreviousDriver}.",
            notification.BookingId, notification.DriverUserId, notification.PreviousDriverUserId);

        var booking = await _db.Bookings
            .AsNoTracking()
            .Include(x => x.Vias)
            .Include(x => x.UserProfile)
            .FirstOrDefaultAsync(x => x.Id == notification.BookingId, ct);

        if (booking == null) return;

        var dto = BookingMapper.ToDto(booking);

        // Broadcast to all connected dispatch clients
        await _hub.Clients.All.SendAsync("BookingAllocated", dto, ct);

        // Notify the specific driver
        await _hub.Clients.Group($"driver-{notification.DriverUserId}")
            .SendAsync("JobOffered", dto, ct);

        // If there was a previous driver, notify them of removal
        if (notification.PreviousDriverUserId.HasValue)
        {
            await _hub.Clients.Group($"driver-{notification.PreviousDriverUserId.Value}")
                .SendAsync("JobRemoved", notification.BookingId, ct);
        }
    }
}
