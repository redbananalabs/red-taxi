using System.Net.Http.Headers;
using System.Text;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;
using RedTaxi.Domain.Enums;
using RedTaxi.Domain.Interfaces;
using RedTaxi.Infrastructure.Persistence;

namespace RedTaxi.Infrastructure.ExternalServices;

public class TextLocalSmsService : IMessageService
{
    private readonly TenantDbContext _db;
    private readonly IHttpClientFactory _httpClientFactory;
    private readonly ILogger<TextLocalSmsService> _logger;

    public TextLocalSmsService(
        TenantDbContext db,
        IHttpClientFactory httpClientFactory,
        ILogger<TextLocalSmsService> logger)
    {
        _db = db;
        _httpClientFactory = httpClientFactory;
        _logger = logger;
    }

    public async Task SendAsync(SendMessageOfType channel, string recipient, string message, CancellationToken ct = default)
    {
        if (channel != SendMessageOfType.Sms)
        {
            _logger.LogDebug("TextLocalSmsService only handles SMS — ignoring {Channel}.", channel);
            return;
        }

        var config = await _db.CompanyConfigs.AsNoTracking().FirstOrDefaultAsync(ct);
        var apiKey = config?.SmsProvider; // SmsProvider stores the TextLocal API key
        if (string.IsNullOrEmpty(apiKey))
        {
            _logger.LogWarning("SMS provider (TextLocal) API key not configured — skipping SMS.");
            return;
        }

        var companyName = config?.CompanyName ?? "RedTaxi";
        // TextLocal sender name max 11 chars
        var sender = companyName.Length > 11 ? companyName[..11] : companyName;

        var client = _httpClientFactory.CreateClient();

        var formData = new Dictionary<string, string>
        {
            { "apikey", apiKey },
            { "numbers", recipient },
            { "message", message },
            { "sender", sender },
        };

        try
        {
            var response = await client.PostAsync(
                "https://api.txtlocal.com/send/",
                new FormUrlEncodedContent(formData),
                ct);

            var responseBody = await response.Content.ReadAsStringAsync(ct);

            if (response.IsSuccessStatusCode)
            {
                _logger.LogInformation("SMS sent to {Recipient} via TextLocal.", recipient);
            }
            else
            {
                _logger.LogWarning("TextLocal SMS failed ({StatusCode}): {Response}", response.StatusCode, responseBody);
            }
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Failed to send SMS to {Recipient} via TextLocal.", recipient);
            throw;
        }
    }
}
