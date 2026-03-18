using System.Net.Http.Headers;
using System.Text;
using System.Text.Json;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;
using RedTaxi.Domain.Interfaces;
using RedTaxi.Infrastructure.Persistence;
using Stripe;

namespace RedTaxi.Infrastructure.ExternalServices;

public class PaymentService : IPaymentService
{
    private readonly TenantDbContext _db;
    private readonly IHttpClientFactory _httpClientFactory;
    private readonly ILogger<PaymentService> _logger;

    public PaymentService(
        TenantDbContext db,
        IHttpClientFactory httpClientFactory,
        ILogger<PaymentService> logger)
    {
        _db = db;
        _httpClientFactory = httpClientFactory;
        _logger = logger;
    }

    public async Task<(string paymentLink, string orderId)> CreatePaymentLinkAsync(
        int bookingId, decimal amount, string customerPhone, CancellationToken ct = default)
    {
        var config = await _db.CompanyConfigs.AsNoTracking().FirstOrDefaultAsync(ct)
            ?? throw new InvalidOperationException("CompanyConfig not found.");

        return config.PaymentProcessor?.ToLowerInvariant() switch
        {
            "revolut" => await CreateRevolutPaymentAsync(config, bookingId, amount, customerPhone, ct),
            "stripe" => await CreateStripePaymentAsync(config, bookingId, amount, customerPhone, ct),
            _ => throw new InvalidOperationException($"Unsupported payment processor: {config.PaymentProcessor}")
        };
    }

    public async Task<bool> RefundAsync(string orderId, decimal amount, CancellationToken ct = default)
    {
        var config = await _db.CompanyConfigs.AsNoTracking().FirstOrDefaultAsync(ct)
            ?? throw new InvalidOperationException("CompanyConfig not found.");

        return config.PaymentProcessor?.ToLowerInvariant() switch
        {
            "revolut" => await RefundRevolutAsync(config, orderId, amount, ct),
            "stripe" => await RefundStripeAsync(config, orderId, amount, ct),
            _ => throw new InvalidOperationException($"Unsupported payment processor: {config.PaymentProcessor}")
        };
    }

    // ── Stripe ───────────────────────────────────────────────────────────────

    private async Task<(string paymentLink, string orderId)> CreateStripePaymentAsync(
        Domain.Entities.CompanyConfig config, int bookingId, decimal amount, string customerPhone, CancellationToken ct)
    {
        if (string.IsNullOrEmpty(config.StripeSecretKey))
            throw new InvalidOperationException("Tenant Stripe secret key is not configured.");

        // Use the tenant's own Stripe keys (not platform keys)
        var requestOptions = new RequestOptions { ApiKey = config.StripeSecretKey };

        var sessionService = new Stripe.Checkout.SessionService();
        var options = new Stripe.Checkout.SessionCreateOptions
        {
            Mode = "payment",
            PaymentMethodTypes = ["card"],
            LineItems =
            [
                new Stripe.Checkout.SessionLineItemOptions
                {
                    PriceData = new Stripe.Checkout.SessionLineItemPriceDataOptions
                    {
                        Currency = config.CurrencyCode?.ToLowerInvariant() ?? "gbp",
                        UnitAmount = (long)(amount * 100), // Stripe uses smallest currency unit
                        ProductData = new Stripe.Checkout.SessionLineItemPriceDataProductDataOptions
                        {
                            Name = $"Booking #{bookingId}",
                        },
                    },
                    Quantity = 1,
                },
            ],
            Metadata = new Dictionary<string, string>
            {
                { "booking_id", bookingId.ToString() },
                { "customer_phone", customerPhone },
            },
            SuccessUrl = $"https://pay.redtaxi.io/success?booking={bookingId}",
            CancelUrl = $"https://pay.redtaxi.io/cancel?booking={bookingId}",
        };

        var session = await sessionService.CreateAsync(options, requestOptions, ct);

        _logger.LogInformation("Stripe checkout session {SessionId} created for booking {BookingId}.",
            session.Id, bookingId);

        return (session.Url, session.Id);
    }

    private async Task<bool> RefundStripeAsync(
        Domain.Entities.CompanyConfig config, string orderId, decimal amount, CancellationToken ct)
    {
        if (string.IsNullOrEmpty(config.StripeSecretKey))
            throw new InvalidOperationException("Tenant Stripe secret key is not configured.");

        var requestOptions = new RequestOptions { ApiKey = config.StripeSecretKey };

        // For checkout sessions, we need to retrieve the payment intent first
        var sessionService = new Stripe.Checkout.SessionService();
        var session = await sessionService.GetAsync(orderId, requestOptions: requestOptions, cancellationToken: ct);

        if (string.IsNullOrEmpty(session.PaymentIntentId))
        {
            _logger.LogWarning("No payment intent found for session {SessionId}.", orderId);
            return false;
        }

        var refundService = new RefundService();
        var refundOptions = new RefundCreateOptions
        {
            PaymentIntent = session.PaymentIntentId,
            Amount = (long)(amount * 100),
        };

        var refund = await refundService.CreateAsync(refundOptions, requestOptions, ct);

        _logger.LogInformation("Stripe refund {RefundId} created for {Amount}.", refund.Id, amount);
        return refund.Status == "succeeded";
    }

    // ── Revolut ──────────────────────────────────────────────────────────────

    private async Task<(string paymentLink, string orderId)> CreateRevolutPaymentAsync(
        Domain.Entities.CompanyConfig config, int bookingId, decimal amount, string customerPhone, CancellationToken ct)
    {
        if (string.IsNullOrEmpty(config.RevolutApiKey))
            throw new InvalidOperationException("Tenant Revolut API key is not configured.");

        var client = _httpClientFactory.CreateClient();
        client.BaseAddress = new Uri("https://merchant.revolut.com");
        client.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("Bearer", config.RevolutApiKey);

        var currencyCode = config.CurrencyCode?.ToUpperInvariant() ?? "GBP";

        var orderPayload = new
        {
            amount = (int)(amount * 100), // Minor units
            currency = currencyCode,
            description = $"Booking #{bookingId}",
            metadata = new { booking_id = bookingId.ToString(), customer_phone = customerPhone },
        };

        var content = new StringContent(
            JsonSerializer.Serialize(orderPayload),
            Encoding.UTF8,
            "application/json");

        var response = await client.PostAsync("/api/1.0/orders", content, ct);
        response.EnsureSuccessStatusCode();

        var json = await response.Content.ReadAsStringAsync(ct);
        using var doc = JsonDocument.Parse(json);
        var root = doc.RootElement;

        var orderId = root.GetProperty("id").GetString()!;
        // Revolut returns a checkout_url in the public property
        var checkoutUrl = root.TryGetProperty("checkout_url", out var urlProp)
            ? urlProp.GetString()!
            : $"https://checkout.revolut.com/pay/{orderId}";

        _logger.LogInformation("Revolut order {OrderId} created for booking {BookingId}.", orderId, bookingId);

        return (checkoutUrl, orderId);
    }

    private async Task<bool> RefundRevolutAsync(
        Domain.Entities.CompanyConfig config, string orderId, decimal amount, CancellationToken ct)
    {
        if (string.IsNullOrEmpty(config.RevolutApiKey))
            throw new InvalidOperationException("Tenant Revolut API key is not configured.");

        var client = _httpClientFactory.CreateClient();
        client.BaseAddress = new Uri("https://merchant.revolut.com");
        client.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("Bearer", config.RevolutApiKey);

        var currencyCode = config.CurrencyCode?.ToUpperInvariant() ?? "GBP";

        var refundPayload = new
        {
            amount = (int)(amount * 100),
            currency = currencyCode,
            description = $"Refund for order {orderId}",
        };

        var content = new StringContent(
            JsonSerializer.Serialize(refundPayload),
            Encoding.UTF8,
            "application/json");

        var response = await client.PostAsync($"/api/1.0/orders/{orderId}/refund", content, ct);

        if (response.IsSuccessStatusCode)
        {
            _logger.LogInformation("Revolut refund completed for order {OrderId}, amount {Amount}.", orderId, amount);
            return true;
        }

        _logger.LogWarning("Revolut refund failed for order {OrderId}: {StatusCode}.", orderId, response.StatusCode);
        return false;
    }
}
