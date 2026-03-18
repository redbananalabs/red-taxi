using MediatR;
using Microsoft.AspNetCore.SignalR;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;
using RedTaxi.Application.Hubs;
using RedTaxi.Application.Bookings.Commands;
using RedTaxi.Domain.Events;
using RedTaxi.Infrastructure.Persistence;

namespace RedTaxi.Application.Bookings.EventHandlers;

public class BookingCreatedEventHandler : INotificationHandler<BookingCreatedEvent>
{
    private readonly TenantDbContext _db;
    private readonly IHubContext<DispatchHub> _hub;
    private readonly ILogger<BookingCreatedEventHandler> _logger;

    public BookingCreatedEventHandler(
        TenantDbContext db,
        IHubContext<DispatchHub> hub,
        ILogger<BookingCreatedEventHandler> logger)
    {
        _db = db;
        _hub = hub;
        _logger = logger;
    }

    public async Task Handle(BookingCreatedEvent notification, CancellationToken ct)
    {
        _logger.LogInformation("Booking {BookingId} created — broadcasting to dispatch board.", notification.BookingId);

        var booking = await _db.Bookings
            .AsNoTracking()
            .Include(x => x.Vias)
            .Include(x => x.UserProfile)
            .FirstOrDefaultAsync(x => x.Id == notification.BookingId, ct);

        if (booking == null) return;

        var dto = BookingMapper.ToDto(booking);
        await _hub.Clients.All.SendAsync("BookingCreated", dto, ct);
    }
}
