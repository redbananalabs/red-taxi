using MediatR;
using Microsoft.AspNetCore.SignalR;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;
using RedTaxi.Application.Bookings.Commands;
using RedTaxi.Application.Hubs;
using RedTaxi.Domain.Events;
using RedTaxi.Infrastructure.Persistence;

namespace RedTaxi.Application.Bookings.EventHandlers;

public class BookingUpdatedEventHandler : INotificationHandler<BookingAmendedEvent>
{
    private readonly TenantDbContext _db;
    private readonly IHubContext<DispatchHub> _hub;
    private readonly ILogger<BookingUpdatedEventHandler> _logger;

    public BookingUpdatedEventHandler(
        TenantDbContext db,
        IHubContext<DispatchHub> hub,
        ILogger<BookingUpdatedEventHandler> logger)
    {
        _db = db;
        _hub = hub;
        _logger = logger;
    }

    public async Task Handle(BookingAmendedEvent notification, CancellationToken ct)
    {
        _logger.LogInformation("Booking {BookingId} amended — broadcasting BookingUpdated.", notification.BookingId);

        var booking = await _db.Bookings
            .AsNoTracking()
            .Include(x => x.Vias)
            .Include(x => x.UserProfile)
            .FirstOrDefaultAsync(x => x.Id == notification.BookingId, ct);

        if (booking == null) return;

        var dto = BookingMapper.ToDto(booking);
        await _hub.Clients.Group("dispatch").SendAsync("BookingUpdated", dto, ct);
    }
}
