using MediatR;
using Microsoft.AspNetCore.SignalR;
using Microsoft.Extensions.Logging;
using RedTaxi.Application.Hubs;
using RedTaxi.Domain.Events;

namespace RedTaxi.Application.Fleet.EventHandlers;

public class DriverShiftStartedEventHandler : INotificationHandler<DriverShiftStartedEvent>
{
    private readonly IHubContext<DispatchHub> _hub;
    private readonly ILogger<DriverShiftStartedEventHandler> _logger;

    public DriverShiftStartedEventHandler(
        IHubContext<DispatchHub> hub,
        ILogger<DriverShiftStartedEventHandler> logger)
    {
        _hub = hub;
        _logger = logger;
    }

    public async Task Handle(DriverShiftStartedEvent notification, CancellationToken ct)
    {
        _logger.LogInformation("Driver {UserId} started shift — broadcasting.", notification.UserId);

        var payload = new { userId = notification.UserId, isOnline = true };
        await _hub.Clients.Group("dispatch").SendAsync("DriverShiftChanged", payload, ct);
    }
}

public class DriverShiftEndedEventHandler : INotificationHandler<DriverShiftEndedEvent>
{
    private readonly IHubContext<DispatchHub> _hub;
    private readonly ILogger<DriverShiftEndedEventHandler> _logger;

    public DriverShiftEndedEventHandler(
        IHubContext<DispatchHub> hub,
        ILogger<DriverShiftEndedEventHandler> logger)
    {
        _hub = hub;
        _logger = logger;
    }

    public async Task Handle(DriverShiftEndedEvent notification, CancellationToken ct)
    {
        _logger.LogInformation("Driver {UserId} ended shift — broadcasting.", notification.UserId);

        var payload = new { userId = notification.UserId, isOnline = false };
        await _hub.Clients.Group("dispatch").SendAsync("DriverShiftChanged", payload, ct);
    }
}
