using System.Net.Http.Headers;
using System.Text;
using System.Text.Json;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;
using RedTaxi.Domain.Interfaces;
using RedTaxi.Infrastructure.Persistence;

namespace RedTaxi.Infrastructure.ExternalServices;

public class FcmService : IPushNotificationService
{
    private readonly TenantDbContext _db;
    private readonly IHttpClientFactory _httpClientFactory;
    private readonly IConfiguration _configuration;
    private readonly ILogger<FcmService> _logger;

    public FcmService(
        TenantDbContext db,
        IHttpClientFactory httpClientFactory,
        IConfiguration configuration,
        ILogger<FcmService> logger)
    {
        _db = db;
        _httpClientFactory = httpClientFactory;
        _configuration = configuration;
        _logger = logger;
    }

    public async Task SendToDeviceAsync(
        string deviceToken, string title, string body,
        Dictionary<string, string>? data = null, CancellationToken ct = default)
    {
        var projectId = _configuration["Firebase:ProjectId"];
        if (string.IsNullOrEmpty(projectId))
        {
            _logger.LogWarning("Firebase:ProjectId not configured — skipping push notification.");
            return;
        }

        var serverKey = _configuration["Firebase:ServerKey"];
        if (string.IsNullOrEmpty(serverKey))
        {
            _logger.LogWarning("Firebase:ServerKey not configured — skipping push notification.");
            return;
        }

        var client = _httpClientFactory.CreateClient();
        client.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("Bearer", serverKey);

        // FCM v1 API
        var url = $"https://fcm.googleapis.com/v1/projects/{projectId}/messages:send";

        var message = new
        {
            message = new
            {
                token = deviceToken,
                notification = new
                {
                    title,
                    body,
                },
                data = data ?? new Dictionary<string, string>(),
                android = new
                {
                    priority = "high",
                },
                apns = new
                {
                    payload = new
                    {
                        aps = new
                        {
                            alert = new { title, body },
                            sound = "default",
                        },
                    },
                },
            },
        };

        var content = new StringContent(
            JsonSerializer.Serialize(message),
            Encoding.UTF8,
            "application/json");

        try
        {
            var response = await client.PostAsync(url, content, ct);

            if (response.IsSuccessStatusCode)
            {
                _logger.LogDebug("FCM notification sent to device token {Token}.", deviceToken[..Math.Min(20, deviceToken.Length)]);
            }
            else
            {
                var errorBody = await response.Content.ReadAsStringAsync(ct);
                _logger.LogWarning("FCM send failed ({StatusCode}): {Error}", response.StatusCode, errorBody);
            }
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Failed to send FCM notification to device token.");
        }
    }

    public async Task SendToUserAsync(
        int userId, string title, string body,
        Dictionary<string, string>? data = null, CancellationToken ct = default)
    {
        // Find all device registrations for this user
        var devices = await _db.UserDeviceRegistrations
            .AsNoTracking()
            .Where(d => d.UserId == userId)
            .OrderByDescending(d => d.LastUsedAt ?? d.RegisteredAt)
            .ToListAsync(ct);

        if (devices.Count == 0)
        {
            _logger.LogDebug("No device registrations found for user {UserId} — skipping push.", userId);
            return;
        }

        foreach (var device in devices)
        {
            await SendToDeviceAsync(device.DeviceToken, title, body, data, ct);
        }

        _logger.LogInformation("FCM notification sent to {Count} device(s) for user {UserId}.",
            devices.Count, userId);
    }
}
