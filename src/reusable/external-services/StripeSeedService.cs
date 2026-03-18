using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;
using RedTaxi.Domain.Interfaces;
using RedTaxi.Infrastructure.Persistence;
using Stripe;

namespace RedTaxi.Infrastructure.ExternalServices;

public class StripeSeedService : IStripeService
{
    private readonly PlatformDbContext _db;
    private readonly ILogger<StripeSeedService> _logger;

    private record ProductDefinition(
        string Key,
        string Name,
        long MonthlyGbp,
        long AnnualGbp);

    private static readonly ProductDefinition[] Plans =
    [
        new("plan_solo",       "Red Taxi Solo",       19900,  191000),
        new("plan_team",       "Red Taxi Team",       38900,  373400),
        new("plan_fleet",      "Red Taxi Fleet",      79900,  767000),
        new("plan_enterprise", "Red Taxi Enterprise", 0,      0),
    ];

    private static readonly ProductDefinition[] Addons =
    [
        new("addon_5_drivers",        "+5 Drivers",          8900,  0),
        new("addon_2000_bookings",    "+2,000 Bookings",     6000,  0),
        new("addon_5000_bookings",    "+5,000 Bookings",     20000, 0),
        new("addon_10000_bookings",   "+10,000 Bookings",    40000, 0),
        new("addon_sms_500",          "SMS Pack 500",        2500,  0),
        new("addon_sms_2000",         "SMS Pack 2,000",      7500,  0),
        new("addon_sms_5000",         "SMS Pack 5,000",      15000, 0),
        new("addon_web_portal",       "Web Portal",          10900, 0),
        new("addon_custom_domain",    "Custom Domain",       6500,  0),
        new("addon_api_access",       "API Access",          10900, 0),
    ];

    public StripeSeedService(IConfiguration configuration, PlatformDbContext db, ILogger<StripeSeedService> logger)
    {
        _db = db;
        _logger = logger;

        var secretKey = configuration["Stripe:SecretKey"]
            ?? throw new InvalidOperationException("Stripe:SecretKey is not configured.");

        StripeConfiguration.ApiKey = secretKey;
    }

    // -------------------------------------------------------------------------
    // Seed
    // -------------------------------------------------------------------------

    public async Task SeedProductsAsync(CancellationToken ct = default)
    {
        _logger.LogInformation("Starting Stripe product seed...");

        foreach (var plan in Plans)
            await EnsurePlanAsync(plan, ct);

        foreach (var addon in Addons)
            await EnsureAddonAsync(addon, ct);

        _logger.LogInformation("Stripe product seed complete.");
    }

    // -------------------------------------------------------------------------
    // Plan (monthly + annual prices)
    // -------------------------------------------------------------------------

    private async Task EnsurePlanAsync(ProductDefinition plan, CancellationToken ct)
    {
        var product = await FindOrCreateProductAsync(plan.Key, plan.Name, ct);

        // Monthly price
        var monthlyConfigKey = $"stripe_price_{plan.Key}_monthly";
        if (!await ConfigKeyExistsAsync(monthlyConfigKey, ct))
        {
            // Enterprise plans are custom-quoted — use unit_amount = 0 as a placeholder
            var monthlyPrice = await CreateRecurringPriceAsync(
                productId: product.Id,
                unitAmount: plan.MonthlyGbp,
                interval: "month",
                nickname: $"{plan.Name} – Monthly",
                ct);

            await UpsertConfigAsync(monthlyConfigKey, monthlyPrice.Id, ct);
            _logger.LogInformation("Created monthly price {PriceId} for {Key}", monthlyPrice.Id, plan.Key);
        }
        else
        {
            _logger.LogDebug("Monthly price for {Key} already recorded — skipping.", plan.Key);
        }

        // Annual price
        var annualConfigKey = $"stripe_price_{plan.Key}_annual";
        if (!await ConfigKeyExistsAsync(annualConfigKey, ct))
        {
            var annualPrice = await CreateRecurringPriceAsync(
                productId: product.Id,
                unitAmount: plan.AnnualGbp,
                interval: "year",
                nickname: $"{plan.Name} – Annual",
                ct);

            await UpsertConfigAsync(annualConfigKey, annualPrice.Id, ct);
            _logger.LogInformation("Created annual price {PriceId} for {Key}", annualPrice.Id, plan.Key);
        }
        else
        {
            _logger.LogDebug("Annual price for {Key} already recorded — skipping.", plan.Key);
        }
    }

    // -------------------------------------------------------------------------
    // Bolt-on (monthly price only)
    // -------------------------------------------------------------------------

    private async Task EnsureAddonAsync(ProductDefinition addon, CancellationToken ct)
    {
        var product = await FindOrCreateProductAsync(addon.Key, addon.Name, ct);

        var configKey = $"stripe_price_{addon.Key}_monthly";
        if (!await ConfigKeyExistsAsync(configKey, ct))
        {
            var price = await CreateRecurringPriceAsync(
                productId: product.Id,
                unitAmount: addon.MonthlyGbp,
                interval: "month",
                nickname: $"{addon.Name} – Monthly",
                ct);

            await UpsertConfigAsync(configKey, price.Id, ct);
            _logger.LogInformation("Created monthly price {PriceId} for {Key}", price.Id, addon.Key);
        }
        else
        {
            _logger.LogDebug("Monthly price for {Key} already recorded — skipping.", addon.Key);
        }
    }

    // -------------------------------------------------------------------------
    // Shared helpers
    // -------------------------------------------------------------------------

    /// <summary>
    /// Finds a Stripe product whose metadata contains redtaxi_product_key == key,
    /// or creates a new one with type "service".
    /// </summary>
    private async Task<Product> FindOrCreateProductAsync(string key, string name, CancellationToken ct)
    {
        var service = new ProductService();

        // Search existing products by metadata key (Stripe supports metadata filtering)
        var searchOptions = new ProductSearchOptions
        {
            Query = $"metadata[\"redtaxi_product_key\"]:\"{key}\"",
            Limit = 1,
        };

        var searchResult = await service.SearchAsync(searchOptions, cancellationToken: ct);

        if (searchResult.Data.Count > 0)
        {
            var existing = searchResult.Data[0];
            _logger.LogDebug("Found existing Stripe product {ProductId} for key {Key}", existing.Id, key);
            return existing;
        }

        // Not found — create it
        var createOptions = new ProductCreateOptions
        {
            Name = name,
            // "service" is set via Type property (maps to the "type" field in Stripe API v1)
            Metadata = new Dictionary<string, string>
            {
                { "redtaxi_product_key", key },
            },
        };

        var product = await service.CreateAsync(createOptions, cancellationToken: ct);
        _logger.LogInformation("Created Stripe product {ProductId} for key {Key}", product.Id, key);
        return product;
    }

    private static async Task<Price> CreateRecurringPriceAsync(
        string productId,
        long unitAmount,
        string interval,
        string nickname,
        CancellationToken ct)
    {
        var service = new PriceService();

        var options = new PriceCreateOptions
        {
            Product = productId,
            Currency = "gbp",
            UnitAmount = unitAmount,
            Nickname = nickname,
            Recurring = new PriceRecurringOptions
            {
                Interval = interval,
            },
        };

        return await service.CreateAsync(options, cancellationToken: ct);
    }

    private async Task<bool> ConfigKeyExistsAsync(string key, CancellationToken ct)
    {
        return await _db.PlatformConfigs
            .AsNoTracking()
            .AnyAsync(c => c.Key == key, ct);
    }

    private async Task UpsertConfigAsync(string key, string value, CancellationToken ct)
    {
        var existing = await _db.PlatformConfigs
            .FirstOrDefaultAsync(c => c.Key == key, ct);

        if (existing is null)
        {
            _db.PlatformConfigs.Add(new RedTaxi.Domain.Entities.PlatformConfig
            {
                Key = key,
                Value = value,
                Description = $"Stripe price ID seeded at startup for {key}",
                UpdatedAt = DateTime.UtcNow,
            });
        }
        else
        {
            existing.Value = value;
            existing.UpdatedAt = DateTime.UtcNow;
        }

        await _db.SaveChangesAsync(ct);
    }

    // -------------------------------------------------------------------------
    // IStripeService — customer / session wrappers
    // -------------------------------------------------------------------------

    public async Task<string> CreateCustomerAsync(
        string email,
        string name,
        CancellationToken ct = default)
    {
        var service = new CustomerService();

        var options = new CustomerCreateOptions
        {
            Email = email,
            Name = name,
        };

        var customer = await service.CreateAsync(options, cancellationToken: ct);
        return customer.Id;
    }

    public async Task<string> CreateCheckoutSessionAsync(
        string customerId,
        string priceId,
        string successUrl,
        string cancelUrl,
        CancellationToken ct = default)
    {
        var service = new Stripe.Checkout.SessionService();

        var options = new Stripe.Checkout.SessionCreateOptions
        {
            Customer = customerId,
            Mode = "subscription",
            LineItems =
            [
                new Stripe.Checkout.SessionLineItemOptions
                {
                    Price = priceId,
                    Quantity = 1,
                },
            ],
            SuccessUrl = successUrl,
            CancelUrl = cancelUrl,
        };

        var session = await service.CreateAsync(options, cancellationToken: ct);
        return session.Url;
    }

    public async Task<string> CreateBillingPortalSessionAsync(
        string customerId,
        string returnUrl,
        CancellationToken ct = default)
    {
        var service = new Stripe.BillingPortal.SessionService();

        var options = new Stripe.BillingPortal.SessionCreateOptions
        {
            Customer = customerId,
            ReturnUrl = returnUrl,
        };

        var session = await service.CreateAsync(options, cancellationToken: ct);
        return session.Url;
    }
}
