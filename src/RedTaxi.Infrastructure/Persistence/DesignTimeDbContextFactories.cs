using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Design;

namespace RedTaxi.Infrastructure.Persistence;

public class PlatformDbContextDesignTimeFactory : IDesignTimeDbContextFactory<PlatformDbContext>
{
    public PlatformDbContext CreateDbContext(string[] args)
    {
        var optionsBuilder = new DbContextOptionsBuilder<PlatformDbContext>();
        optionsBuilder.UseSqlServer(
            "Server=localhost;Database=RedTaxi_Platform;Trusted_Connection=True;TrustServerCertificate=True");
        return new PlatformDbContext(optionsBuilder.Options);
    }
}

public class TenantDbContextDesignTimeFactory : IDesignTimeDbContextFactory<TenantDbContext>
{
    public TenantDbContext CreateDbContext(string[] args)
    {
        var optionsBuilder = new DbContextOptionsBuilder<TenantDbContext>();
        optionsBuilder.UseSqlServer(
            "Server=localhost;Database=RedTaxi_ace;Trusted_Connection=True;TrustServerCertificate=True");
        return new TenantDbContext(optionsBuilder.Options);
    }
}
