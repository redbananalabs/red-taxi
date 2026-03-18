using MediatR;
using Microsoft.AspNetCore.SignalR;
using Microsoft.Extensions.Logging;
using RedTaxi.Application.Hubs;
using RedTaxi.Domain.Events;

namespace RedTaxi.Application.Fleet.EventHandlers;

public class DriverGpsEventHandler : INotificationHandler<DriverGpsUpdatedEvent>
{
    private readonly IHubContext<DispatchHub> _hub;
    private readonly ILogger<DriverGpsEventHandler> _logger;

    public DriverGpsEventHandler(
        IHubContext<DispatchHub> hub,
        ILogger<DriverGpsEventHandler> logger)
    {
        _hub = hub;
        _logger = logger;
    }

    public async Task Handle(DriverGpsUpdatedEvent notification, CancellationToken ct)
    {
        var payload = new
        {
            userId = notification.UserId,
            lat = notification.Lat,
            lng = notification.Lng
        };

        await _hub.Clients.Group("dispatch").SendAsync("DriverLocationUpdate", payload, ct);
    }
}
