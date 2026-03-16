# Tenancy Mode: Per-Tenant Database

## Architecture

Every tenant gets their own SQL Server database. A master database holds the tenant registry.

```
RedTaxi_Platform          ← Master DB (tenant registry, Stripe data, platform config)
RedTaxi_ace-taxis         ← Tenant DB (Ace Taxis — bookings, drivers, accounts, etc.)
RedTaxi_city-cabs         ← Tenant DB (City Cabs)
RedTaxi_metro-cars        ← Tenant DB (Metro Cars)
```

## Configuration

`appsettings.json`:
```json
{
  "ConnectionStrings": {
    "PlatformConnection": "Server=localhost;Database=RedTaxi_Platform;Trusted_Connection=true;TrustServerCertificate=true",
    "TenantTemplate": "Server=localhost;Database=RedTaxi_{slug};Trusted_Connection=true;TrustServerCertificate=true"
  },
  "Tenancy": {
    "Mode": "PerTenantDatabase"
  }
}
```

The `TenantTemplate` connection string uses `{slug}` as a placeholder. At runtime, the middleware replaces `{slug}` with the resolved tenant's slug to build the actual connection string.

## Tenant Resolution

Request arrives → resolve tenant identity → lookup in master DB → build connection string → set DbContext.

Resolution sources (checked in order):
1. **Custom domain** — `Host` header matches a `Tenant.CustomDomain`
2. **Subdomain** — extract slug from `{slug}.{platform-domain}`
3. **JWT claim** — `tenant_id` claim in bearer token (API requests)

## Database Provisioning

On tenant signup, a Hangfire background job:
1. Creates the database: `CREATE DATABASE [RedTaxi_{slug}]`
2. Runs all EF Core migrations against the new database
3. Seeds default data (tariffs, message templates, company settings)
4. Updates tenant record in master DB with status = Active

## Migration Strategy

- All tenant databases share the same EF Core schema
- New migrations applied to ALL tenant databases via a Hangfire job: `ApplyMigrationsToAllTenants`
- Migration status tracked per-tenant in master DB (`Tenant.LastMigrationApplied`)
- Failed migrations alert platform admin via notification, do not block other tenants
- Migrations run from CI/CD in production, not on startup

## Database Deletion

When a tenant's data deletion date is reached (30 days after hard lock):
1. Hangfire job drops the database: `DROP DATABASE [RedTaxi_{slug}]`
2. Tenant record in master DB marked as `Deleted`
3. Stripe Customer archived
4. Irreversible — no recovery after this point
