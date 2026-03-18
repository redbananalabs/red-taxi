using Microsoft.EntityFrameworkCore;
using RedTaxi.Domain.Interfaces;
using RedTaxi.Infrastructure.Persistence;

namespace RedTaxi.Infrastructure.Tenancy;

public class TenantDbContextFactory : IDbContextFactory<TenantDbContext>
{
    private readonly ITenantConnectionResolver _resolver;

    public TenantDbContextFactory(ITenantConnectionResolver resolver)
    {
        _resolver = resolver;
    }

    public TenantDbContext CreateDbContext()
    {
        var connectionString = _resolver.GetConnectionString();
        var options = new DbContextOptionsBuilder<TenantDbContext>()
            .UseSqlServer(connectionString)
            .Options;
        return new TenantDbContext(options);
    }
}
