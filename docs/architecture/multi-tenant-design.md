> **⚠️ SUPERSEDED:** This document describes an earlier shared-database-with-TenantId design. The current architecture uses **per-tenant databases**. See `docs/PRD.md §36` and `docs/architecture/tenancy-modes.md` for the authoritative spec. This file is retained for historical reference only.

# Multi-tenant Design

## Overview

Red Taxi uses a shared database, shared schema multi-tenancy model with row-level isolation.

## Tenancy Strategy

### Shared Database with TenantId

All tenant-scoped tables include a `TenantId` column.

```sql
CREATE TABLE Bookings (
    Id UNIQUEIDENTIFIER PRIMARY KEY,
    TenantId UNIQUEIDENTIFIER NOT NULL,  -- Tenant isolation
    ...
    INDEX IX_Bookings_TenantId (TenantId)
);
```

### Why Shared Database?

| Approach | Pros | Cons |
|----------|------|------|
| **Shared DB (chosen)** | Simple ops, efficient resources, easy queries | Noisy neighbour risk |
| DB per tenant | Full isolation | Complex ops, expensive |
| Schema per tenant | Good isolation | Migration complexity |

For our scale (< 1000 tenants initially), shared database is optimal.

## Tenant Resolution

### Resolution Order

1. **Subdomain**: `acme.redtaxi.io` → Tenant "acme"
2. **API Header**: `X-Tenant-Id: {guid}` for API clients
3. **JWT Claim**: `tenant_id` claim in token

### Middleware

```csharp
public class TenantResolutionMiddleware
{
    public async Task InvokeAsync(HttpContext context)
    {
        var tenantId = ResolveTenant(context);
        context.Items["TenantId"] = tenantId;
        await _next(context);
    }
}
```

## Data Isolation

### EF Core Global Query Filters

```csharp
protected override void OnModelCreating(ModelBuilder modelBuilder)
{
    // All tenant-scoped entities filtered automatically
    modelBuilder.Entity<Booking>()
        .HasQueryFilter(b => b.TenantId == _tenantProvider.TenantId);
        
    modelBuilder.Entity<Driver>()
        .HasQueryFilter(d => d.TenantId == _tenantProvider.TenantId);
}
```

### Bypass for Admin

```csharp
// Super-admin queries ignore tenant filter
var allBookings = await _context.Bookings
    .IgnoreQueryFilters()
    .ToListAsync();
```

## Tenant Configuration

### Tenant Entity

```csharp
public class Tenant
{
    public Guid Id { get; set; }
    public string Slug { get; set; }           // URL subdomain
    public string Name { get; set; }
    public string Plan { get; set; }           // starter, pro, enterprise
    
    // Branding
    public string LogoUrl { get; set; }
    public string PrimaryColour { get; set; }
    
    // Limits
    public int MaxDrivers { get; set; }
    public int MaxOperators { get; set; }
    public int MaxBookingsPerMonth { get; set; }
    
    // Features
    public bool AutoDispatchEnabled { get; set; }
    public bool WhatsAppEnabled { get; set; }
    public bool ApiAccessEnabled { get; set; }
    
    // Status
    public bool IsActive { get; set; }
    public DateTimeOffset CreatedAt { get; set; }
}
```

### Configuration Caching

Tenant config cached in Redis with 5-minute TTL.

```csharp
public async Task<TenantConfig> GetConfigAsync(Guid tenantId)
{
    var cacheKey = $"tenant:{tenantId}:config";
    var cached = await _redis.GetAsync<TenantConfig>(cacheKey);
    
    if (cached != null) return cached;
    
    var config = await _db.Tenants.FindAsync(tenantId);
    await _redis.SetAsync(cacheKey, config, TimeSpan.FromMinutes(5));
    
    return config;
}
```

## Plans & Feature Flags

### Plan Definitions

| Feature | Starter | Pro | Enterprise |
|---------|---------|-----|------------|
| Max Drivers | 10 | 50 | Unlimited |
| Max Operators | 2 | 10 | Unlimited |
| Auto Dispatch | ❌ | ✅ | ✅ |
| WhatsApp | ❌ | ✅ | ✅ |
| API Access | ❌ | ❌ | ✅ |
| Custom Branding | ❌ | ✅ | ✅ |
| SLA | None | Business | Premium |

### Feature Checks

```csharp
public class FeatureService
{
    public async Task<bool> IsEnabledAsync(string feature)
    {
        var tenant = await _tenantProvider.GetCurrentTenantAsync();
        return tenant.HasFeature(feature);
    }
}

// Usage
if (!await _features.IsEnabledAsync("auto-dispatch"))
{
    throw new FeatureNotAvailableException();
}
```

## Tenant Onboarding

### Flow

1. User signs up with email
2. System creates tenant record
3. System creates admin user
4. Admin completes setup wizard
5. Tenant goes live

### Provisioning

```csharp
public async Task<Tenant> ProvisionTenantAsync(CreateTenantRequest request)
{
    var tenant = new Tenant
    {
        Id = Guid.NewGuid(),
        Slug = request.Slug,
        Name = request.CompanyName,
        Plan = "starter",
        IsActive = true
    };
    
    await _db.Tenants.AddAsync(tenant);
    
    // Create admin user
    var admin = new User
    {
        TenantId = tenant.Id,
        Email = request.Email,
        Role = UserRole.TenantAdmin
    };
    
    await _userManager.CreateAsync(admin, request.Password);
    
    // Create default settings
    await _settingsService.CreateDefaultsAsync(tenant.Id);
    
    return tenant;
}
```

## Security Considerations

### Prevention of Cross-Tenant Access

1. **Query filters** - All queries scoped automatically
2. **Validation** - Foreign keys validated against tenant
3. **Audit** - All data access logged
4. **Testing** - Automated cross-tenant leak tests

### Tenant Deletion

Soft delete only. Data retained for 90 days before permanent deletion.

```csharp
public async Task DeactivateTenantAsync(Guid tenantId)
{
    var tenant = await _db.Tenants.FindAsync(tenantId);
    tenant.IsActive = false;
    tenant.DeactivatedAt = DateTimeOffset.UtcNow;
    
    // Schedule permanent deletion
    _backgroundJobs.Schedule<TenantDeletionJob>(
        job => job.Execute(tenantId),
        TimeSpan.FromDays(90)
    );
}
```

## Related Documents

- [System Overview](system-overview.md)
- [Security - Permissions](../security/permissions.md)
