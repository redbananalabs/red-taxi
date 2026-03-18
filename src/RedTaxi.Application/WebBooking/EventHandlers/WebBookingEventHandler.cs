using MediatR;
using Microsoft.AspNetCore.SignalR;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;
using RedTaxi.Application.Hubs;
using RedTaxi.Domain.Events;
using RedTaxi.Infrastructure.Persistence;
using RedTaxi.Shared.DTOs;

namespace RedTaxi.Application.WebBooking.EventHandlers;

public class WebBookingEventHandler : INotificationHandler<WebBookingSubmittedEvent>
{
    private readonly TenantDbContext _db;
    private readonly IHubContext<DispatchHub> _hub;
    private readonly ILogger<WebBookingEventHandler> _logger;

    public WebBookingEventHandler(
        TenantDbContext db,
        IHubContext<DispatchHub> hub,
        ILogger<WebBookingEventHandler> logger)
    {
        _db = db;
        _hub = hub;
        _logger = logger;
    }

    public async Task Handle(WebBookingSubmittedEvent notification, CancellationToken ct)
    {
        _logger.LogInformation("WebBooking {WebBookingId} submitted — broadcasting.", notification.WebBookingId);

        var wb = await _db.WebBookings
            .AsNoTracking()
            .FirstOrDefaultAsync(x => x.Id == notification.WebBookingId, ct);

        if (wb == null) return;

        var dto = new WebBookingDto(
            wb.Id, wb.PassengerName, wb.PhoneNumber, wb.Email,
            wb.PickupAddress, wb.DestinationAddress, wb.PickupDateTime,
            wb.Details, wb.Passengers, (int)wb.VehicleType, wb.AccountNumber,
            (int)wb.Status, wb.Price, wb.DateCreated);

        await _hub.Clients.Group("dispatch").SendAsync("WebBookingSubmitted", dto, ct);
    }
}
