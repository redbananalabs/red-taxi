using MediatR;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;
using RedTaxi.Application.Messaging.Services;
using RedTaxi.Domain.Enums;
using RedTaxi.Domain.Events;
using RedTaxi.Domain.Interfaces;
using RedTaxi.Infrastructure.Persistence;

namespace RedTaxi.Application.Messaging.EventHandlers;

/// <summary>
/// Listens to booking domain events and sends notifications (Push, SMS, etc.)
/// based on the tenant's MessagingNotifyConfig settings.
/// </summary>
public class NotificationOnAllocatedHandler : INotificationHandler<BookingAllocatedEvent>
{
    private readonly NotificationDispatcher _dispatcher;

    public NotificationOnAllocatedHandler(NotificationDispatcher dispatcher) => _dispatcher = dispatcher;

    public async Task Handle(BookingAllocatedEvent notification, CancellationToken ct)
    {
        await _dispatcher.HandleBookingEventAsync(
            notification.BookingId,
            notification.DriverUserId,
            SentMessageType.DriverOnAllocate,
            SentMessageType.CustomerOnAllocate,
            ct);
    }
}

public class NotificationOnUnallocatedHandler : INotificationHandler<BookingUnallocatedEvent>
{
    private readonly NotificationDispatcher _dispatcher;

    public NotificationOnUnallocatedHandler(NotificationDispatcher dispatcher) => _dispatcher = dispatcher;

    public async Task Handle(BookingUnallocatedEvent notification, CancellationToken ct)
    {
        await _dispatcher.HandleBookingEventAsync(
            notification.BookingId,
            notification.DriverUserId,
            SentMessageType.DriverOnUnAllocate,
            SentMessageType.CustomerOnUnAllocate,
            ct);
    }
}

public class NotificationOnAmendedHandler : INotificationHandler<BookingAmendedEvent>
{
    private readonly NotificationDispatcher _dispatcher;

    public NotificationOnAmendedHandler(NotificationDispatcher dispatcher) => _dispatcher = dispatcher;

    public async Task Handle(BookingAmendedEvent notification, CancellationToken ct)
    {
        await _dispatcher.HandleBookingEventAsync(
            notification.BookingId,
            driverUserId: null,
            SentMessageType.DriverOnAmend,
            SentMessageType.CustomerOnAmend,
            ct);
    }
}

public class NotificationOnCancelledHandler : INotificationHandler<BookingCancelledEvent>
{
    private readonly NotificationDispatcher _dispatcher;

    public NotificationOnCancelledHandler(NotificationDispatcher dispatcher) => _dispatcher = dispatcher;

    public async Task Handle(BookingCancelledEvent notification, CancellationToken ct)
    {
        await _dispatcher.HandleBookingEventAsync(
            notification.BookingId,
            driverUserId: null,
            SentMessageType.DriverOnCancel,
            SentMessageType.CustomerOnCancel,
            ct);
    }
}

public class NotificationOnCompletedHandler : INotificationHandler<BookingCompletedEvent>
{
    private readonly NotificationDispatcher _dispatcher;

    public NotificationOnCompletedHandler(NotificationDispatcher dispatcher) => _dispatcher = dispatcher;

    public async Task Handle(BookingCompletedEvent notification, CancellationToken ct)
    {
        await _dispatcher.HandleBookingEventAsync(
            notification.BookingId,
            driverUserId: null,
            driverEventType: null,
            SentMessageType.CustomerOnComplete,
            ct);
    }
}

/// <summary>
/// Shared logic for dispatching notifications based on MessagingNotifyConfig.
/// </summary>
public class NotificationDispatcher
{
    private readonly TenantDbContext _db;
    private readonly IPushNotificationService _pushService;
    private readonly IMessageService _messageService;
    private readonly TemplateRenderer _templateRenderer;
    private readonly ILogger<NotificationDispatcher> _logger;

    public NotificationDispatcher(
        TenantDbContext db,
        IPushNotificationService pushService,
        IMessageService messageService,
        TemplateRenderer templateRenderer,
        ILogger<NotificationDispatcher> logger)
    {
        _db = db;
        _pushService = pushService;
        _messageService = messageService;
        _templateRenderer = templateRenderer;
        _logger = logger;
    }

    public async Task HandleBookingEventAsync(
        int bookingId,
        int? driverUserId,
        SentMessageType? driverEventType,
        SentMessageType? customerEventType,
        CancellationToken ct)
    {
        var booking = await _db.Bookings
            .AsNoTracking()
            .Include(b => b.UserProfile)
            .FirstOrDefaultAsync(b => b.Id == bookingId, ct);

        if (booking == null)
        {
            _logger.LogWarning("Booking {BookingId} not found for notification dispatch.", bookingId);
            return;
        }

        var config = await _db.CompanyConfigs.AsNoTracking().FirstOrDefaultAsync(ct);

        // Resolve driver
        var resolvedDriverUserId = driverUserId ?? booking.UserId;
        Domain.Entities.UserProfile? driver = null;
        if (resolvedDriverUserId.HasValue)
        {
            driver = await _db.UserProfiles
                .AsNoTracking()
                .FirstOrDefaultAsync(u => u.UserId == resolvedDriverUserId.Value, ct);
        }

        var templateContext = TemplateRenderer.FromBooking(booking, driver, config);

        // Handle driver notifications
        if (driverEventType.HasValue && resolvedDriverUserId.HasValue)
        {
            await SendNotificationsForEventAsync(
                driverEventType.Value,
                templateContext,
                recipientUserId: resolvedDriverUserId.Value,
                recipientPhone: driver?.PhoneNumber,
                recipientEmail: driver?.Email,
                ct);
        }

        // Handle customer notifications
        if (customerEventType.HasValue)
        {
            await SendNotificationsForEventAsync(
                customerEventType.Value,
                templateContext,
                recipientUserId: null, // Customers don't have user IDs in the driver system
                recipientPhone: booking.PhoneNumber,
                recipientEmail: booking.Email,
                ct);
        }
    }

    private async Task SendNotificationsForEventAsync(
        SentMessageType eventType,
        TemplateContext context,
        int? recipientUserId,
        string? recipientPhone,
        string? recipientEmail,
        CancellationToken ct)
    {
        var configs = await _db.MessagingNotifyConfigs
            .AsNoTracking()
            .Where(c => c.EventType == eventType && c.IsEnabled)
            .ToListAsync(ct);

        foreach (var notifyConfig in configs)
        {
            var renderedMessage = _templateRenderer.Render(
                notifyConfig.TemplateText ?? GetDefaultTemplate(eventType),
                context);

            try
            {
                switch (notifyConfig.Channel)
                {
                    case SendMessageOfType.Push:
                        if (recipientUserId.HasValue)
                        {
                            await _pushService.SendToUserAsync(
                                recipientUserId.Value,
                                GetNotificationTitle(eventType),
                                renderedMessage,
                                new Dictionary<string, string>
                                {
                                    { "bookingId", context.BookingId?.ToString() ?? "" },
                                    { "eventType", eventType.ToString() },
                                },
                                ct);
                        }
                        break;

                    case SendMessageOfType.Sms:
                        if (!string.IsNullOrEmpty(recipientPhone))
                        {
                            await _messageService.SendAsync(SendMessageOfType.Sms, recipientPhone, renderedMessage, ct);
                        }
                        break;

                    case SendMessageOfType.WhatsApp:
                        if (!string.IsNullOrEmpty(recipientPhone))
                        {
                            await _messageService.SendAsync(SendMessageOfType.WhatsApp, recipientPhone, renderedMessage, ct);
                        }
                        break;
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Failed to send {Channel} notification for {EventType} to user {UserId}.",
                    notifyConfig.Channel, eventType, recipientUserId);
            }
        }
    }

    private static string GetNotificationTitle(SentMessageType eventType) => eventType switch
    {
        SentMessageType.DriverOnAllocate => "New Job Allocated",
        SentMessageType.DriverOnUnAllocate => "Job Unallocated",
        SentMessageType.DriverOnAmend => "Job Updated",
        SentMessageType.DriverOnCancel => "Job Cancelled",
        SentMessageType.CustomerOnAllocate => "Driver On The Way",
        SentMessageType.CustomerOnUnAllocate => "Booking Update",
        SentMessageType.CustomerOnAmend => "Booking Updated",
        SentMessageType.CustomerOnCancel => "Booking Cancelled",
        SentMessageType.CustomerOnComplete => "Journey Complete",
        _ => "Notification",
    };

    private static string GetDefaultTemplate(SentMessageType eventType) => eventType switch
    {
        SentMessageType.DriverOnAllocate => "You have been allocated to booking #{BookingId}. Pickup: {PickupAddress} at {PickupTime}.",
        SentMessageType.DriverOnUnAllocate => "You have been unallocated from booking #{BookingId}.",
        SentMessageType.DriverOnAmend => "Booking #{BookingId} has been amended. Pickup: {PickupAddress} at {PickupTime}.",
        SentMessageType.DriverOnCancel => "Booking #{BookingId} has been cancelled.",
        SentMessageType.CustomerOnAllocate => "Your driver {DriverName} ({VehicleReg}) is on the way. Pickup: {PickupAddress}.",
        SentMessageType.CustomerOnUnAllocate => "Your booking #{BookingId} driver assignment has changed. We are finding you a new driver.",
        SentMessageType.CustomerOnAmend => "Your booking #{BookingId} has been updated. Pickup: {PickupAddress} at {PickupTime}.",
        SentMessageType.CustomerOnCancel => "Your booking #{BookingId} has been cancelled.",
        SentMessageType.CustomerOnComplete => "Your journey is complete. Thank you for travelling with {CompanyName}!",
        _ => "Notification from {CompanyName}.",
    };
}
