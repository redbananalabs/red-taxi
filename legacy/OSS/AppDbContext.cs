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
            b.ToTable("AppUsers");//.SplitToTable();
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

        //modelBuilder.Entity<AppRole>().HasData(new AppRole { Id = 1, Name = "Admin", NormalizedName = "Admin" });
        //modelBuilder.Entity<AppRole>().HasData(new AppRole { Id = 2, Name = "User", NormalizedName = "User" });

        //// seed users
        //var hasher = new PasswordHasher<AppUser>();

        //modelBuilder.Entity<AppUser>().HasData(
        //    new AppUser
        //    {
        //        Id = 1, // primary key
        //        UserName = "admin",
        //        NormalizedUserName = "Admin",
        //        PasswordHash = hasher.HashPassword(null, "polo"),
        //        Email = @"peter@abacusonline.net",
        //        NormalizedEmail = "peter@abacusonline.net",
        //        EmailConfirmed = true,
        //        PhoneNumber = "07572382366",
        //        PhoneNumberConfirmed = true,
        //        SecurityStamp = Guid.NewGuid().ToString(),
        //    },
        //    new AppUser
        //    {
        //        Id = 2, // primary key
        //        UserName = "user",
        //        NormalizedUserName = "User",
        //        PasswordHash = hasher.HashPassword(null, "polo"),
        //        Email = "andy@1soft.co.uk",
        //        NormalizedEmail = "andy@1soft.co.uk",
        //        EmailConfirmed = true,
        //        PhoneNumber = "07894561231",
        //        PhoneNumberConfirmed = false,
        //        SecurityStamp = Guid.NewGuid().ToString(),
        //    }
        //);

        //// assign roles
        //var a1 = new IdentityUserRole<int>
        //{
        //    RoleId = 1,
        //    UserId = 1
        //};
        //var a2 = new IdentityUserRole<int>
        //{
        //    RoleId = 2,
        //    UserId = 2
        //};

        //// admins
        //modelBuilder.Entity<IdentityUserRole<int>>().HasData(a1);
        //modelBuilder.Entity<IdentityUserRole<int>>().HasData(a2);
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