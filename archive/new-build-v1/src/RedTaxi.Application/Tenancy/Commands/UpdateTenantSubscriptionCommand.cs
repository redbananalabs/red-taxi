using MediatR;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;
using RedTaxi.Domain.Enums;
using RedTaxi.Infrastructure.Persistence;

namespace RedTaxi.Application.Tenancy.Commands;

public record UpdateTenantSubscriptionCommand(
    string StripeCustomerId,
    string StripeSubscriptionId,
    string Status,
    string EventType,
    string? PriceId,
    DateTime? CurrentPeriodEnd,
    bool CancelAtPeriodEnd) : IRequest<bool>;

public class UpdateTenantSubscriptionCommandHandler : IRequestHandler<UpdateTenantSubscriptionCommand, bool>
{
    private readonly PlatformDbContext _platformDb;
    private readonly ILogger<UpdateTenantSubscriptionCommandHandler> _logger;

    // Map Stripe price ID prefixes to subscription tiers (lookup by metadata in production)
    private static readonly Dictionary<string, SubscriptionTier> PriceTierMap = new()
    {
        { "plan_solo", SubscriptionTier.Solo },
        { "plan_team", SubscriptionTier.Team },
        { "plan_fleet", SubscriptionTier.Fleet },
        { "plan_enterprise", SubscriptionTier.Enterprise },
    };

    public UpdateTenantSubscriptionCommandHandler(
        PlatformDbContext platformDb,
        ILogger<UpdateTenantSubscriptionCommandHandler> logger)
    {
        _platformDb = platformDb;
        _logger = logger;
    }

    public async Task<bool> Handle(UpdateTenantSubscriptionCommand request, CancellationToken ct)
    {
        var tenant = await _platformDb.Tenants
            .FirstOrDefaultAsync(t => t.StripeCustomerId == request.StripeCustomerId, ct);

        if (tenant == null)
        {
            _logger.LogWarning("No tenant found for Stripe customer {CustomerId}.", request.StripeCustomerId);
            return false;
        }

        tenant.StripeSubscriptionId = request.StripeSubscriptionId;
        tenant.UpdatedAt = DateTime.UtcNow;

        // Map Stripe subscription status to tenant status
        switch (request.Status)
        {
            case "active":
                tenant.Status = TenantStatus.Active;
                tenant.IsActive = true;
                break;

            case "trialing":
                tenant.Status = TenantStatus.Trial;
                tenant.IsActive = true;
                if (request.CurrentPeriodEnd.HasValue)
                    tenant.TrialEndsAt = request.CurrentPeriodEnd.Value;
                break;

            case "past_due":
                tenant.Status = TenantStatus.PastDue;
                tenant.IsActive = true; // Still active but degraded
                break;

            case "canceled":
                // Start grace period flow: GracePeriod → SoftLocked → HardLocked
                if (request.EventType == "customer.subscription.deleted")
                {
                    tenant.Status = TenantStatus.GracePeriod;
                    tenant.IsActive = true; // Grace period — still accessible
                    _logger.LogWarning("Tenant {TenantId} subscription cancelled — entering grace period.", tenant.Id);
                }
                break;

            case "unpaid":
                tenant.Status = TenantStatus.SoftLocked;
                tenant.IsActive = false;
                _logger.LogWarning("Tenant {TenantId} subscription unpaid — soft locked.", tenant.Id);
                break;

            default:
                _logger.LogDebug("Unhandled Stripe subscription status: {Status}", request.Status);
                break;
        }

        // Determine subscription tier from price ID if available
        if (!string.IsNullOrEmpty(request.PriceId))
        {
            var tier = await ResolveTierFromPriceIdAsync(request.PriceId, ct);
            if (tier.HasValue)
            {
                tenant.SubscriptionTier = tier.Value;
            }
        }

        await _platformDb.SaveChangesAsync(ct);

        _logger.LogInformation("Tenant {TenantId} subscription updated: Status={Status}, Tier={Tier}.",
            tenant.Id, tenant.Status, tenant.SubscriptionTier);

        return true;
    }

    private async Task<SubscriptionTier?> ResolveTierFromPriceIdAsync(string priceId, CancellationToken ct)
    {
        // Look up the price ID in PlatformConfig to find which plan it belongs to
        var configEntry = await _platformDb.PlatformConfigs
            .AsNoTracking()
            .Where(c => c.Value == priceId && c.Key.StartsWith("stripe_price_plan_"))
            .FirstOrDefaultAsync(ct);

        if (configEntry == null) return null;

        // Key format: stripe_price_plan_solo_monthly or stripe_price_plan_solo_annual
        var key = configEntry.Key;
        foreach (var (planKey, tier) in PriceTierMap)
        {
            if (key.Contains(planKey))
                return tier;
        }

        return null;
    }
}
