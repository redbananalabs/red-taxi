using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;
using RedTaxi.Domain.Entities;
using RedTaxi.Domain.Enums;
using RedTaxi.Domain.Interfaces;
using RedTaxi.Infrastructure.Persistence;

namespace RedTaxi.Application.Messaging.Services;

/// <summary>
/// Central message dispatcher: given an event type, looks up MessagingNotifyConfig
/// and routes to the correct service (SMS, Push, Email).
/// Handles template variable substitution for: {PassengerName}, {DriverName},
/// {PickupAddress}, {DestinationAddress}, {PickupTime}, {BookingId}, {VehicleReg},
/// {Price}, {CompanyName}, {TrackingUrl}, {PaymentUrl}.
/// </summary>
public class MessageDispatcher
{
    private readonly TenantDbContext _db;
    private readonly IMessageService _smsService;
    private readonly IPushNotificationService _pushService;
    private readonly TemplateRenderer _templateRenderer;
    private readonly ILogger<MessageDispatcher> _logger;

    public MessageDispatcher(
        TenantDbContext db,
        IMessageService smsService,
        IPushNotificationService pushService,
        TemplateRenderer templateRenderer,
        ILogger<MessageDispatcher> logger)
    {
        _db = db;
        _smsService = smsService;
        _pushService = pushService;
        _templateRenderer = templateRenderer;
        _logger = logger;
    }

    /// <summary>
    /// Dispatches a notification for a booking event to the appropriate recipient
    /// via the configured channel(s).
    /// </summary>
    public async Task DispatchAsync(
        SentMessageType eventType,
        Booking booking,
        UserProfile? driver = null,
        string? recipientPhone = null,
        string? recipientEmail = null,
        int? recipientUserId = null,
        CancellationToken ct = default)
    {
        var configs = await _db.MessagingNotifyConfigs
            .AsNoTracking()
            .Where(c => c.EventType == eventType && c.IsEnabled)
            .ToListAsync(ct);

        if (configs.Count == 0)
        {
            _logger.LogDebug("No messaging config for event {EventType} — skipping.", eventType);
            return;
        }

        var companyConfig = await _db.CompanyConfigs.AsNoTracking().FirstOrDefaultAsync(ct);
        var context = TemplateRenderer.FromBooking(booking, driver, companyConfig);

        foreach (var config in configs)
        {
            var renderedMessage = _templateRenderer.Render(
                config.TemplateText ?? string.Empty,
                context);

            if (string.IsNullOrWhiteSpace(renderedMessage)) continue;

            try
            {
                switch (config.Channel)
                {
                    case SendMessageOfType.Sms:
                        if (!string.IsNullOrEmpty(recipientPhone))
                        {
                            await _smsService.SendAsync(SendMessageOfType.Sms, recipientPhone, renderedMessage, ct);
                        }
                        break;

                    case SendMessageOfType.WhatsApp:
                        if (!string.IsNullOrEmpty(recipientPhone))
                        {
                            await _smsService.SendAsync(SendMessageOfType.WhatsApp, recipientPhone, renderedMessage, ct);
                        }
                        break;

                    case SendMessageOfType.Push:
                        if (recipientUserId.HasValue)
                        {
                            var title = GetNotificationTitle(eventType, companyConfig?.CompanyName);
                            await _pushService.SendToUserAsync(
                                recipientUserId.Value,
                                title,
                                renderedMessage,
                                new Dictionary<string, string>
                                {
                                    { "bookingId", booking.Id.ToString() },
                                    { "eventType", eventType.ToString() },
                                },
                                ct);
                        }
                        break;

                    case SendMessageOfType.None:
                    default:
                        break;
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Failed to dispatch {Channel} message for {EventType}.", config.Channel, eventType);
            }
        }
    }

    private static string GetNotificationTitle(SentMessageType eventType, string? companyName)
    {
        var prefix = companyName ?? "Red Taxi";
        return eventType switch
        {
            SentMessageType.DriverOnAllocate => $"{prefix} — New Job",
            SentMessageType.DriverOnUnAllocate => $"{prefix} — Job Removed",
            SentMessageType.DriverOnAmend => $"{prefix} — Job Updated",
            SentMessageType.DriverOnCancel => $"{prefix} — Job Cancelled",
            SentMessageType.CustomerOnAllocate => $"{prefix} — Driver Assigned",
            SentMessageType.CustomerOnUnAllocate => $"{prefix} — Booking Update",
            SentMessageType.CustomerOnAmend => $"{prefix} — Booking Changed",
            SentMessageType.CustomerOnCancel => $"{prefix} — Booking Cancelled",
            SentMessageType.CustomerOnComplete => $"{prefix} — Journey Complete",
            _ => prefix,
        };
    }
}
