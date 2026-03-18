using System.Net.Http.Headers;
using System.Text;
using System.Text.Json;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;
using RedTaxi.Infrastructure.Persistence;

namespace RedTaxi.Infrastructure.ExternalServices;

public interface IEmailService
{
    Task SendAsync(string toEmail, string subject, string htmlBody, CancellationToken ct = default);
}

public class SendGridEmailService : IEmailService
{
    private readonly TenantDbContext _db;
    private readonly IHttpClientFactory _httpClientFactory;
    private readonly ILogger<SendGridEmailService> _logger;

    public SendGridEmailService(
        TenantDbContext db,
        IHttpClientFactory httpClientFactory,
        ILogger<SendGridEmailService> logger)
    {
        _db = db;
        _httpClientFactory = httpClientFactory;
        _logger = logger;
    }

    public async Task SendAsync(string toEmail, string subject, string htmlBody, CancellationToken ct = default)
    {
        var config = await _db.CompanyConfigs.AsNoTracking().FirstOrDefaultAsync(ct);

        // SendGrid API key could be stored in CompanyConfig or app configuration
        // For now we check a convention: the WhatsAppSids field can store additional config
        // In production, add a dedicated SendGridApiKey column to CompanyConfig
        var apiKey = Environment.GetEnvironmentVariable("SENDGRID_API_KEY");
        if (string.IsNullOrEmpty(apiKey))
        {
            _logger.LogWarning("SendGrid API key not configured — skipping email.");
            return;
        }

        var fromEmail = "noreply@redtaxi.io";
        var fromName = config?.CompanyName ?? "Red Taxi";

        var client = _httpClientFactory.CreateClient();
        client.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("Bearer", apiKey);

        var payload = new
        {
            personalizations = new[]
            {
                new
                {
                    to = new[] { new { email = toEmail } },
                    subject
                }
            },
            from = new { email = fromEmail, name = fromName },
            content = new[]
            {
                new { type = "text/html", value = htmlBody }
            }
        };

        var content = new StringContent(
            JsonSerializer.Serialize(payload),
            Encoding.UTF8,
            "application/json");

        try
        {
            var response = await client.PostAsync("https://api.sendgrid.com/v3/mail/send", content, ct);

            if (response.IsSuccessStatusCode)
            {
                _logger.LogInformation("Email sent to {ToEmail} via SendGrid.", toEmail);
            }
            else
            {
                var errorBody = await response.Content.ReadAsStringAsync(ct);
                _logger.LogWarning("SendGrid email failed ({StatusCode}): {Error}", response.StatusCode, errorBody);
            }
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Failed to send email to {ToEmail} via SendGrid.", toEmail);
            throw;
        }
    }
}
