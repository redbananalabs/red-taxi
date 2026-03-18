namespace RedTaxi.Shared.DTOs;

public record TenantDto(Guid Id, string Name, string Slug, string? ContactEmail, string? ContactPhone,
    int SubscriptionTier, int Status, bool IsActive, DateTime CreatedAt);
