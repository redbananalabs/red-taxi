namespace RedTaxi.Domain.Entities;

using RedTaxi.Domain.Enums;

public class Tenant
{
    public Guid Id { get; set; }
    public string Name { get; set; } = string.Empty;
    public string Slug { get; set; } = string.Empty;
    public string? ContactEmail { get; set; }
    public string? ContactPhone { get; set; }
    public string? BrandingConfig { get; set; }
    public SubscriptionTier SubscriptionTier { get; set; }
    public TenantStatus Status { get; set; }
    public bool IsActive { get; set; }
    public string? StripeCustomerId { get; set; }
    public string? StripeSubscriptionId { get; set; }
    public string? ConnectionString { get; set; }
    public DateTime? TrialEndsAt { get; set; }
    public DateTime CreatedAt { get; set; }
    public DateTime? UpdatedAt { get; set; }
}
