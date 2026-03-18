using Microsoft.EntityFrameworkCore;
using RedTaxi.Domain.Entities;

namespace RedTaxi.Infrastructure.Persistence;

public class PlatformDbContext : DbContext
{
    public PlatformDbContext(DbContextOptions<PlatformDbContext> options) : base(options) { }

    public DbSet<Tenant> Tenants => Set<Tenant>();
    public DbSet<TenantExitSurvey> TenantExitSurveys => Set<TenantExitSurvey>();
    public DbSet<PlatformConfig> PlatformConfigs => Set<PlatformConfig>();

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        base.OnModelCreating(modelBuilder);

        modelBuilder.Entity<Tenant>(e =>
        {
            e.HasKey(t => t.Id);
            e.Property(t => t.Name).HasMaxLength(250).IsRequired();
            e.Property(t => t.Slug).HasMaxLength(100).IsRequired();
            e.Property(t => t.ContactEmail).HasMaxLength(250);
            e.Property(t => t.ContactPhone).HasMaxLength(20);
            e.HasIndex(t => t.Slug).IsUnique();
        });

        modelBuilder.Entity<TenantExitSurvey>(e =>
        {
            e.HasKey(s => s.Id);
            e.HasOne(s => s.Tenant).WithMany().HasForeignKey(s => s.TenantId);
        });

        modelBuilder.Entity<PlatformConfig>(e =>
        {
            e.HasKey(c => c.Id);
            e.Property(c => c.Key).HasMaxLength(100).IsRequired();
            e.HasIndex(c => c.Key).IsUnique();
        });
    }
}
