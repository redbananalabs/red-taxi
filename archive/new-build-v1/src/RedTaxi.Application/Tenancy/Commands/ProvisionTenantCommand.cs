using MediatR;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;
using RedTaxi.Domain.Entities;
using RedTaxi.Domain.Enums;
using RedTaxi.Infrastructure.Persistence;

namespace RedTaxi.Application.Tenancy.Commands;

public record ProvisionTenantCommand(
    string StripeCustomerId,
    string? StripeSubscriptionId,
    string? CustomerEmail) : IRequest<Guid>;

public class ProvisionTenantCommandHandler : IRequestHandler<ProvisionTenantCommand, Guid>
{
    private readonly PlatformDbContext _platformDb;
    private readonly IConfiguration _configuration;
    private readonly ILogger<ProvisionTenantCommandHandler> _logger;

    public ProvisionTenantCommandHandler(
        PlatformDbContext platformDb,
        IConfiguration configuration,
        ILogger<ProvisionTenantCommandHandler> logger)
    {
        _platformDb = platformDb;
        _configuration = configuration;
        _logger = logger;
    }

    public async Task<Guid> Handle(ProvisionTenantCommand request, CancellationToken ct)
    {
        // Check if tenant already exists for this Stripe customer
        var existing = await _platformDb.Tenants
            .FirstOrDefaultAsync(t => t.StripeCustomerId == request.StripeCustomerId, ct);

        if (existing != null)
        {
            _logger.LogInformation("Tenant already exists for Stripe customer {CustomerId} — skipping provision.",
                request.StripeCustomerId);
            return existing.Id;
        }

        // Generate a slug from the email or customer ID
        var slug = GenerateSlug(request.CustomerEmail, request.StripeCustomerId);

        var tenant = new Tenant
        {
            Id = Guid.NewGuid(),
            Name = request.CustomerEmail ?? slug,
            Slug = slug,
            ContactEmail = request.CustomerEmail,
            StripeCustomerId = request.StripeCustomerId,
            StripeSubscriptionId = request.StripeSubscriptionId,
            SubscriptionTier = SubscriptionTier.Solo,
            Status = TenantStatus.Active,
            IsActive = true,
            CreatedAt = DateTime.UtcNow,
        };

        // Build the tenant connection string
        var template = _configuration.GetConnectionString("TenantTemplate")
            ?? "Server=localhost\\SQLEXPRESS;Database=RedTaxi_{slug};Trusted_Connection=True;TrustServerCertificate=True";
        tenant.ConnectionString = template.Replace("{slug}", slug);

        _platformDb.Tenants.Add(tenant);
        await _platformDb.SaveChangesAsync(ct);

        _logger.LogInformation("Tenant {TenantId} ({Slug}) created for Stripe customer {CustomerId}.",
            tenant.Id, slug, request.StripeCustomerId);

        // Run EF migrations on the new tenant database
        await ProvisionTenantDatabaseAsync(tenant.ConnectionString, ct);

        // Seed default CompanyConfig and tariffs
        await SeedTenantDefaults(tenant.ConnectionString, tenant.Name, ct);

        return tenant.Id;
    }

    private async Task ProvisionTenantDatabaseAsync(string connectionString, CancellationToken ct)
    {
        try
        {
            var options = new DbContextOptionsBuilder<TenantDbContext>()
                .UseSqlServer(connectionString)
                .Options;

            using var tenantDb = new TenantDbContext(options);
            await tenantDb.Database.MigrateAsync(ct);

            _logger.LogInformation("Tenant database migrated successfully.");
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Failed to migrate tenant database.");
            throw;
        }
    }

    private async Task SeedTenantDefaults(string connectionString, string companyName, CancellationToken ct)
    {
        try
        {
            var options = new DbContextOptionsBuilder<TenantDbContext>()
                .UseSqlServer(connectionString)
                .Options;

            using var tenantDb = new TenantDbContext(options);

            // Seed default CompanyConfig
            if (!await tenantDb.CompanyConfigs.AnyAsync(ct))
            {
                tenantDb.CompanyConfigs.Add(new CompanyConfig
                {
                    CompanyName = companyName,
                    TimeZoneId = "Europe/London",
                    CurrencyCode = "GBP",
                    CashCommissionRate = 10m,
                    RankCommissionRate = 10m,
                    CardTopupRate = 3.5m,
                    DriverWaitingRatePerMinute = 0.40m,
                    AccountWaitingRatePerMinute = 0.50m,
                    MinimumJourneyMinutes = 15,
                    DefaultBlockBookingMonths = 6,
                    AutoDispatchEnabled = false,
                    JobOfferTimeoutSeconds = 120,
                    JobOfferRetryCount = 3,
                    JobOfferRetryDelaySeconds = 30,
                });
            }

            // Seed default tariffs
            if (!await tenantDb.Tariffs.AnyAsync(ct))
            {
                tenantDb.Tariffs.AddRange(
                    new Tariff
                    {
                        Name = "Tariff 1",
                        Type = TariffType.Tariff1,
                        InitialCharge = 3.50m,
                        FirstMileCharge = 2.00m,
                        AdditionalMileCharge = 1.80m,
                        IsActive = true,
                    },
                    new Tariff
                    {
                        Name = "Tariff 2",
                        Type = TariffType.Tariff2,
                        InitialCharge = 4.50m,
                        FirstMileCharge = 2.50m,
                        AdditionalMileCharge = 2.20m,
                        IsActive = true,
                    });
            }

            await tenantDb.SaveChangesAsync(ct);
            _logger.LogInformation("Tenant default data seeded.");
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Failed to seed tenant defaults.");
            throw;
        }
    }

    private static string GenerateSlug(string? email, string fallback)
    {
        if (!string.IsNullOrWhiteSpace(email))
        {
            // Use part before @ sign, sanitize
            var local = email.Split('@')[0]
                .ToLowerInvariant()
                .Replace(".", "-")
                .Replace("+", "-");

            // Append short hash for uniqueness
            var hash = Math.Abs(email.GetHashCode()).ToString("x8")[..6];
            return $"{local}-{hash}";
        }

        return $"tenant-{fallback[..Math.Min(8, fallback.Length)].ToLowerInvariant()}";
    }
}
