using System.Text;
using FluentValidation;
using Hangfire;
using Hangfire.SqlServer;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;
using RedTaxi.Application.Hubs;
using RedTaxi.API.Middleware;
using RedTaxi.API.Services;
using RedTaxi.Application;
using RedTaxi.Domain.Interfaces;
using RedTaxi.Infrastructure.ExternalServices;
using RedTaxi.Infrastructure.Persistence;
using RedTaxi.Infrastructure.Tenancy;
using Serilog;
using StackExchange.Redis;

// ---------------------------------------------------------------------------
// Bootstrap Serilog before the host builds so startup errors are captured.
// ---------------------------------------------------------------------------
Log.Logger = new LoggerConfiguration()
    .WriteTo.Console()
    .CreateBootstrapLogger();

try
{
    var builder = WebApplication.CreateBuilder(args);

    // -----------------------------------------------------------------------
    // Serilog — read full config from appsettings after host is configured
    // -----------------------------------------------------------------------
    builder.Host.UseSerilog((ctx, services, cfg) =>
        cfg.ReadFrom.Configuration(ctx.Configuration)
           .ReadFrom.Services(services)
           .Enrich.FromLogContext()
           .WriteTo.Console());

    // -----------------------------------------------------------------------
    // DbContexts
    // -----------------------------------------------------------------------

    // PlatformDbContext — singleton SQL Server connection
    builder.Services.AddDbContext<PlatformDbContext>(opts =>
        opts.UseSqlServer(
            builder.Configuration.GetConnectionString("PlatformConnection"),
            sql => sql.MigrationsAssembly("RedTaxi.Infrastructure")));

    // TenantDbContext — per-request factory (scoped)
    builder.Services.AddScoped<IDbContextFactory<TenantDbContext>, TenantDbContextFactory>();
    builder.Services.AddScoped<TenantDbContext>(sp =>
        sp.GetRequiredService<IDbContextFactory<TenantDbContext>>().CreateDbContext());

    // -----------------------------------------------------------------------
    // Tenancy / per-request services
    // -----------------------------------------------------------------------
    builder.Services.AddHttpContextAccessor();
    builder.Services.AddScoped<ITenantConnectionResolver, TenantConnectionResolver>();

    // -----------------------------------------------------------------------
    // MediatR
    // -----------------------------------------------------------------------
    builder.Services.AddMediatR(cfg =>
        cfg.RegisterServicesFromAssembly(typeof(IApplicationMarker).Assembly));

    // -----------------------------------------------------------------------
    // FluentValidation
    // -----------------------------------------------------------------------
    builder.Services.AddValidatorsFromAssembly(typeof(IApplicationMarker).Assembly);

    // -----------------------------------------------------------------------
    // JWT Authentication
    // -----------------------------------------------------------------------
    var jwtSecret = builder.Configuration["Jwt:Secret"]
        ?? throw new InvalidOperationException("Jwt:Secret is required.");
    var jwtIssuer   = builder.Configuration["Jwt:Issuer"]   ?? "RedTaxi";
    var jwtAudience = builder.Configuration["Jwt:Audience"] ?? "RedTaxi";

    builder.Services
        .AddAuthentication(JwtBearerDefaults.AuthenticationScheme)
        .AddJwtBearer(opts =>
        {
            opts.TokenValidationParameters = new TokenValidationParameters
            {
                ValidateIssuer           = true,
                ValidateAudience         = true,
                ValidateLifetime         = true,
                ValidateIssuerSigningKey = true,
                ValidIssuer              = jwtIssuer,
                ValidAudience            = jwtAudience,
                IssuerSigningKey         = new SymmetricSecurityKey(
                    Encoding.UTF8.GetBytes(jwtSecret)),
                ClockSkew                = TimeSpan.Zero,
            };

            // Allow JWT via query string for SignalR
            opts.Events = new JwtBearerEvents
            {
                OnMessageReceived = ctx =>
                {
                    var token = ctx.Request.Query["access_token"];
                    var path  = ctx.HttpContext.Request.Path;
                    if (!string.IsNullOrEmpty(token) && path.StartsWithSegments("/hubs"))
                        ctx.Token = token;
                    return Task.CompletedTask;
                },
            };
        });

    builder.Services.AddAuthorization();

    // -----------------------------------------------------------------------
    // CORS — allow localhost dev origins
    // -----------------------------------------------------------------------
    builder.Services.AddCors(opts =>
        opts.AddPolicy("LocalDev", policy =>
            policy
                .WithOrigins(
                    "http://localhost:3000",
                    "http://localhost:4200",
                    "http://localhost:5173",
                    "https://localhost:5001",
                    "http://localhost:5000")
                .AllowAnyMethod()
                .AllowAnyHeader()
                .AllowCredentials()));

    // -----------------------------------------------------------------------
    // SignalR
    // -----------------------------------------------------------------------
    builder.Services.AddSignalR();

    // -----------------------------------------------------------------------
    // Swagger / OpenAPI
    // -----------------------------------------------------------------------
    builder.Services.AddEndpointsApiExplorer();
    builder.Services.AddSwaggerGen(opts =>
    {
        opts.SwaggerDoc("v1", new() { Title = "RedTaxi API", Version = "v1" });

        // Bearer token support in Swagger UI
        opts.AddSecurityDefinition("Bearer", new Microsoft.OpenApi.Models.OpenApiSecurityScheme
        {
            Name         = "Authorization",
            Type         = Microsoft.OpenApi.Models.SecuritySchemeType.Http,
            Scheme       = "bearer",
            BearerFormat = "JWT",
            In           = Microsoft.OpenApi.Models.ParameterLocation.Header,
            Description  = "Enter your JWT token. Example: eyJhbGci...",
        });
        opts.AddSecurityRequirement(new Microsoft.OpenApi.Models.OpenApiSecurityRequirement
        {
            {
                new Microsoft.OpenApi.Models.OpenApiSecurityScheme
                {
                    Reference = new Microsoft.OpenApi.Models.OpenApiReference
                    {
                        Type = Microsoft.OpenApi.Models.ReferenceType.SecurityScheme,
                        Id   = "Bearer",
                    },
                },
                Array.Empty<string>()
            },
        });
    });

    // -----------------------------------------------------------------------
    // Redis
    // -----------------------------------------------------------------------
    var redisConnectionString = builder.Configuration["Redis:ConnectionString"] ?? "localhost:6379";
    builder.Services.AddSingleton<IConnectionMultiplexer>(sp =>
    {
        var config = ConfigurationOptions.Parse(redisConnectionString);
        config.AbortOnConnectFail = false;
        return ConnectionMultiplexer.Connect(config);
    });

    // -----------------------------------------------------------------------
    // Hangfire
    // -----------------------------------------------------------------------
    builder.Services.AddHangfire(cfg =>
        cfg.SetDataCompatibilityLevel(CompatibilityLevel.Version_180)
           .UseSimpleAssemblyNameTypeSerializer()
           .UseRecommendedSerializerSettings()
           .UseSqlServerStorage(
               builder.Configuration.GetConnectionString("PlatformConnection"),
               new SqlServerStorageOptions
               {
                   CommandBatchMaxTimeout       = TimeSpan.FromMinutes(5),
                   SlidingInvisibilityTimeout   = TimeSpan.FromMinutes(5),
                   QueuePollInterval            = TimeSpan.Zero,
                   UseRecommendedIsolationLevel = true,
                   DisableGlobalLocks           = true,
               }));

    builder.Services.AddHangfireServer();

    // -----------------------------------------------------------------------
    // HttpClientFactory (used by payment, FCM, SMS, email services)
    // -----------------------------------------------------------------------
    builder.Services.AddHttpClient();

    // -----------------------------------------------------------------------
    // Tenant seed services
    // -----------------------------------------------------------------------
    builder.Services.AddScoped<RedTaxi.Infrastructure.Persistence.AceTaxisSeedService>();

    // -----------------------------------------------------------------------
    // Application services
    // -----------------------------------------------------------------------
    builder.Services.AddScoped<ICurrentUserService, CurrentUserService>();
    builder.Services.AddScoped<IStripeService, StripeSeedService>();
    builder.Services.AddScoped<IPricingService, RedTaxi.Application.Pricing.Services.PricingService>();
    builder.Services.AddScoped<IDistanceMatrixService, RedTaxi.Infrastructure.ExternalServices.GoogleDistanceMatrixService>();
    builder.Services.AddScoped<RedTaxi.Application.Identity.Services.JwtTokenService>();

    // Payment service (Stripe / Revolut)
    builder.Services.AddScoped<IPaymentService, PaymentService>();

    // Push notifications (FCM)
    builder.Services.AddScoped<IPushNotificationService, FcmService>();

    // SMS (TextLocal)
    builder.Services.AddScoped<IMessageService, TextLocalSmsService>();

    // Email (SendGrid)
    builder.Services.AddScoped<IEmailService, SendGridEmailService>();

    // Google Places
    builder.Services.AddScoped<GooglePlacesService>();

    // Template rendering and message dispatching
    builder.Services.AddScoped<RedTaxi.Application.Messaging.Services.TemplateRenderer>();
    builder.Services.AddScoped<RedTaxi.Application.Messaging.Services.MessageDispatcher>();
    builder.Services.AddScoped<RedTaxi.Application.Messaging.EventHandlers.NotificationDispatcher>();

    // -----------------------------------------------------------------------
    // Health checks
    // -----------------------------------------------------------------------
    builder.Services.AddHealthChecks()
        .AddSqlServer(
            builder.Configuration.GetConnectionString("PlatformConnection")!,
            name: "platform-db",
            tags: ["db", "sql"])
        .AddRedis(
            redisConnectionString,
            name: "redis",
            tags: ["cache", "redis"]);

    // -----------------------------------------------------------------------
    // MVC controllers
    // -----------------------------------------------------------------------
    builder.Services.AddControllers();

    // ===================================================================
    // Build app
    // ===================================================================
    var app = builder.Build();

    // -----------------------------------------------------------------------
    // Stripe seed on startup
    // -----------------------------------------------------------------------
    try
    {
        using var scope = app.Services.CreateScope();
        var stripe = scope.ServiceProvider.GetRequiredService<IStripeService>();
        await stripe.SeedProductsAsync();
    }
    catch (Exception ex)
    {
        Log.Warning(ex, "Stripe seed failed on startup — skipping. Check Stripe:SecretKey.");
    }

    // -----------------------------------------------------------------------
    // Ace Taxis tenant seed on startup (idempotent)
    // -----------------------------------------------------------------------
    try
    {
        using var scope = app.Services.CreateScope();
        var aceSeed = scope.ServiceProvider.GetRequiredService<RedTaxi.Infrastructure.Persistence.AceTaxisSeedService>();
        await aceSeed.SeedAsync();
    }
    catch (Exception ex)
    {
        Log.Warning(ex, "Ace Taxis seed failed on startup — skipping. Ensure RedTaxi_ace database exists and migrations have run.");
    }

    // -----------------------------------------------------------------------
    // Middleware pipeline
    // -----------------------------------------------------------------------
    app.UseSerilogRequestLogging();

    if (app.Environment.IsDevelopment())
    {
        app.UseSwagger();
        app.UseSwaggerUI(c => c.SwaggerEndpoint("/swagger/v1/swagger.json", "RedTaxi API v1"));
    }

    app.UseHttpsRedirection();
    app.UseCors("LocalDev");

    app.UseAuthentication();
    app.UseAuthorization();

    app.UseMiddleware<TenantMiddleware>();

    // -----------------------------------------------------------------------
    // Endpoints
    // -----------------------------------------------------------------------
    app.MapControllers();
    app.MapHub<DispatchHub>("/hubs/dispatch");
    app.MapHangfireDashboard(
        builder.Configuration["Hangfire:DashboardPath"] ?? "/hangfire");
    app.MapHealthChecks("/health");

    app.Run();
}
catch (Exception ex) when (ex is not HostAbortedException)
{
    Log.Fatal(ex, "RedTaxi API terminated unexpectedly.");
}
finally
{
    Log.CloseAndFlush();
}
