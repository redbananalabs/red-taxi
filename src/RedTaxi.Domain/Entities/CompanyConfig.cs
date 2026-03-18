namespace RedTaxi.Domain.Entities;

/// <summary>
/// Per-tenant company configuration stored in the tenant's own database.
/// Only one row expected per tenant database.
/// </summary>
public class CompanyConfig
{
    public int Id { get; set; }

    // Branding / identity
    public string? CompanyName { get; set; }
    public string? LogoUrl { get; set; }
    public string? PrimaryColour { get; set; }

    // Base location (used for "charge from base" calculations and map centering)
    public string? BasePostcode { get; set; }
    public decimal? AddressLookupLat { get; set; }
    public decimal? AddressLookupLng { get; set; }

    // Scheduler display
    public string? UnallocatedColour { get; set; }

    // Commission / pricing
    public decimal CashCommissionRate { get; set; }
    public decimal RankCommissionRate { get; set; }
    public decimal CardTopupRate { get; set; }
    public bool AddVatOnCardPayments { get; set; }

    // Waiting time rates
    public decimal DriverWaitingRatePerMinute { get; set; }
    public decimal AccountWaitingRatePerMinute { get; set; }

    // Booking defaults
    public int DefaultBlockBookingMonths { get; set; } = 6;
    public int MinimumJourneyMinutes { get; set; } = 15;

    // Auto-dispatch settings
    public bool AutoDispatchEnabled { get; set; }
    public int JobOfferTimeoutSeconds { get; set; } = 120;
    public int JobOfferRetryCount { get; set; } = 3;
    public int JobOfferRetryDelaySeconds { get; set; } = 30;

    // Locale
    public string? TimeZoneId { get; set; } = "Europe/London";
    public string? CurrencyCode { get; set; } = "GBP";

    // Payment processors
    public string? RevolutApiKey { get; set; }
    public string? StripePublishableKey { get; set; }
    public string? StripeSecretKey { get; set; }

    /// <summary>"Stripe" or "Revolut"</summary>
    public string? PaymentProcessor { get; set; }

    // Messaging
    public string? SmsProvider { get; set; }

    /// <summary>Comma-separated WhatsApp SIDs / configuration identifiers.</summary>
    public string? WhatsAppSids { get; set; }
}
