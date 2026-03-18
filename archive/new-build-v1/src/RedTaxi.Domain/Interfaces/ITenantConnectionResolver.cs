namespace RedTaxi.Domain.Interfaces;

public interface ITenantConnectionResolver
{
    string GetConnectionString();
    string GetTenantSlug();
    Guid GetTenantId();
}
