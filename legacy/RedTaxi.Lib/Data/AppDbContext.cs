using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Identity.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Design;
using Microsoft.Extensions.Configuration;

//public partial class AppDbContext : IdentityDbContext<AppUser, AppRole, int>
public partial class AppDbContext : IdentityDbContext<AppUser, AppRole, int>
{
    public AppDbContext(DbContextOptions<AppDbContext> options)
        : base(options)
    {

    }

    public virtual DbSet<AppRefreshToken> AppRefreshTokens { get; set; }

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        base.OnModelCreating(modelBuilder);

        modelBuilder.Entity<AppUser>(b =>
        {
            b.ToTable("AppUsers");
        });
        modelBuilder.Entity<IdentityUserClaim<int>>(b =>
        {
            b.ToTable("AppUserClaims");
        });
        modelBuilder.Entity<IdentityUserLogin<int>>(b =>
        {
            b.ToTable("AppUserLogins");
        });
        modelBuilder.Entity<IdentityUserToken<int>>(b =>
        {
            b.ToTable("AppUserTokens");
        });
        modelBuilder.Entity<AppRole>(b =>
        {
            b.ToTable("AppRoles");
        });
        modelBuilder.Entity<IdentityRoleClaim<int>>(b =>
        {
            b.ToTable("AppRoleClaims");
        });
        modelBuilder.Entity<IdentityUserRole<int>>(b =>
        {
            b.ToTable("AspNetUserRoles");
        });

        foreach (var relationship in modelBuilder.Model.GetEntityTypes().SelectMany(e => e.GetForeignKeys()))
        {
            relationship.DeleteBehavior = DeleteBehavior.Restrict;
        }
    }
}

public class AppDbContextFactory : IDesignTimeDbContextFactory<AppDbContext>
{
    public AppDbContext CreateDbContext(string[] args)
    {
        var optionsBuilder = new DbContextOptionsBuilder<AppDbContext>();

        var configuration = new ConfigurationBuilder()
                    .SetBasePath(Directory.GetCurrentDirectory())
                    .AddJsonFile("appsettings.json")
                    .Build();

        var connectionString = configuration
                    .GetConnectionString("DefaultConnection");

        optionsBuilder.UseSqlServer(connectionString);

        return new AppDbContext(optionsBuilder.Options);
    }
}
