using MediatR;
using Microsoft.AspNetCore.SignalR;
using Microsoft.Extensions.Logging;
using RedTaxi.Application.Hubs;
using RedTaxi.Domain.Events;

namespace RedTaxi.Application.Bookings.EventHandlers;

public class BookingCompletedEventHandler : INotificationHandler<BookingCompletedEvent>
{
    private readonly IHubContext<DispatchHub> _hub;
    private readonly ILogger<BookingCompletedEventHandler> _logger;

    public BookingCompletedEventHandler(
        IHubContext<DispatchHub> hub,
        ILogger<BookingCompletedEventHandler> logger)
    {
        _hub = hub;
        _logger = logger;
    }

    public async Task Handle(BookingCompletedEvent notification, CancellationToken ct)
    {
        _logger.LogInformation("Booking {BookingId} completed — broadcasting.", notification.BookingId);

        var payload = new { bookingId = notification.BookingId };
        await _hub.Clients.Group("dispatch").SendAsync("BookingCompleted", payload, ct);
    }
}
