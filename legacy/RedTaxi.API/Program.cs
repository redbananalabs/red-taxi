using RedTaxi.Configuration;
using RedTaxi.Data;
using RedTaxi.Domain.IdealPostcodes;
using RedTaxi.Interfaces;
using RedTaxi.Services;
using RedTaxi.Services.Cache;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.AspNetCore.HttpLogging;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Caching.StackExchangeRedis;
using StackExchange.Redis;
using System.Globalization;


namespace RedTaxi.API
{
    public class Program
    {
        private static IConfiguration Config { get; set; }

        public static void Main(string[] args)
        {
            var cultureInfo = new CultureInfo("en-GB");
            cultureInfo.NumberFormat.CurrencySymbol = "�";

            CultureInfo.DefaultThreadCurrentCulture = cultureInfo;
            CultureInfo.DefaultThreadCurrentUICulture = cultureInfo;

            var env = Environment.GetEnvironmentVariable("ASPNETCORE_ENVIRONMENT") ?? "Production";
            var config = new ConfigurationBuilder()
               .AddJsonFile(@"appsettings.json", optional: false, reloadOnChange: true)
               .AddJsonFile($"appsettings.{env}.json", optional: true, reloadOnChange: true)
               .Build();

            Config = config;

            var builder = WebApplication.CreateBuilder(args);

            builder.Services.AddSingleton(s => new GetAddress.ApiKeys("jfLGB-3SeE-asi_xmTyAAA44072", "admin-key"));
           // builder.Services.AddHttpClient<GetAddress.Api>();

            builder.Services.AddAutoMapper(typeof(AutoMapperProfile));
            // builder.Services.AddHttpLogging(o => { });

            // ---------------- LOGGING ----------------
            builder.Logging.ClearProviders();

            // Console (optional, useful in dev)
            builder.Logging.AddConsole();

            // File logging (Microsoft logger, no Serilog)
            builder.Logging.ClearProviders();
            builder.Logging.AddConsole();


            var logdirectory = Path.Combine(AppContext.BaseDirectory, "Logs");
            var logFile = Path.Combine($"ace-api-{DateTime.Today:dd-MM-yyyy}.log");

            builder.Logging.AddProvider(new SimpleFileLoggerProvider(Path.Combine(logdirectory, logFile)));
           // builder.Logging.AddProvider(new SimpleFileLoggerProvider(@$"C:\Temp\ace-api-test.log"));
            
            
            builder.Services.Configure<DropBoxConfig>(Config.GetSection("Dropbox"));
            //builder.WebHost.UseSentry(o => o.ExperimentalMetrics = new ExperimentalMetricsOptions { EnableCodeLocations = true });

            builder.Services.AddHttpLogging(o =>
            {
                o.LoggingFields = HttpLoggingFields.None;
            });

            builder.Services.AddOneSoft(new OneSoftConfig
            {
                AddApiAuth = true,
                AddJwt = true,
                AddMessaging = true,
                AddWatchdog = false,
            });

            builder.Services.AddCors(o => o.AddPolicy("MyPolicy", builder =>
            {
                builder.AllowAnyOrigin()
                       .AllowAnyMethod()
                       .AllowAnyHeader();
            }));

            builder.Services.AddDbContextFactory<RedTaxiDbContext>(options =>
                options.UseSqlServer(Config.GetConnectionString(name: @"DefaultConnection"),
                sqlServerOptionsAction: sqlOptions =>
                {
                    sqlOptions.EnableRetryOnFailure(
                        maxRetryCount: 5,
                        maxRetryDelay: TimeSpan.FromSeconds(2),
                        errorNumbersToAdd: null);
                }), ServiceLifetime.Scoped);


            // redis cache
            builder.Services.AddStackExchangeRedisCache(options =>
            {
                var redisConnectionString =
                    builder.Configuration["Redis:ConnectionString"]; // e.g. "localhost:6379"

                var instanceName =
                    builder.Configuration["Redis:InstanceName"];     // e.g. "AceTaxis:"

                options.InstanceName = instanceName;

                options.ConfigurationOptions = new ConfigurationOptions
                {
                    EndPoints = { redisConnectionString },

                    AbortOnConnectFail = false,   // REQUIRED for recovery
                    ConnectRetry = 5,
                    ConnectTimeout = 5000,
                    SyncTimeout = 5000,

                    KeepAlive = 30,
                    ReconnectRetryPolicy = new ExponentialRetry(5000),

                    SocketManager = new SocketManager(
                        name: "RedTaxi.Redis",
                        workerCount: 2,
                        useHighPrioritySocketThreads: true
                    )
                };

                options.ConfigurationOptions.ClientName = "RedTaxi.API";
            });

            builder.Services.AddSingleton<IConnectionMultiplexer>(sp =>
            {
                var config = ConfigurationOptions.Parse(
                    builder.Configuration["Redis:ConnectionString"],
                    true
                );

                config.AbortOnConnectFail = false;
                config.ConnectRetry = 3;
                config.ReconnectRetryPolicy = new ExponentialRetry(5000);

                return ConnectionMultiplexer.Connect(config);
            });
            // end redis cache

            //builder.Services.AddDbContext<RedTaxiDbContext>(options =>
            //    options.UseSqlServer(Config.GetConnectionString(name: @"DefaultConnection")));

            builder.Services.AddAuthentication(options =>
            {
                options.DefaultAuthenticateScheme = JwtBearerDefaults.AuthenticationScheme;
            });

            // Add services to the container.
            builder.Services.AddControllers();
            // Learn more about configuring Swagger/OpenAPI at https://aka.ms/aspnetcore/swashbuckle
            builder.Services.AddHttpContextAccessor();

            builder.Services.AddScoped<BookingService>();
            builder.Services.AddScoped<TariffService>();
            builder.Services.AddScoped<LocalPOIService>();
            builder.Services.AddScoped<UserProfileService>();
            builder.Services.AddScoped<AccountsService>();
            builder.Services.AddScoped<AceMessagingService>();
            builder.Services.AddScoped<AvailabilityService>();
            builder.Services.AddScoped<RevoluttService>();
            builder.Services.AddScoped<DispatchService>();
            builder.Services.AddScoped<AdminUIService>();
            builder.Services.AddScoped<ReportingService>();
            builder.Services.AddScoped<DocumentService>();
            builder.Services.AddScoped<UINotificationService>();
            builder.Services.AddScoped<UserActionsService>();
            builder.Services.AddScoped<GeoZoneService>();
            builder.Services.AddScoped<UrlTrackingService>();
            // cache service

            builder.Services.AddScoped<UserLocationCacheService>();
            builder.Services.AddScoped<UserProfileCacheService>();
            builder.Services.AddHostedService<StartupCacheService>();

            builder.Services.AddHttpClient<AddressLookupService>();
            builder.Services.AddScoped<IAddressLookupService, AddressLookupService>();

            // end cache service

            builder.Services.AddHttpClient<IdealPostcodesClient>((sp, http) => { })
                .ConfigureHttpClient(c => { /* optional timeouts etc */ });

            // Then register with your API key
            builder.Services.AddSingleton(sp =>
                new IdealPostcodesClient(
                    builder.Configuration["IdealPostcodes:ApiKey"]
                        ?? throw new InvalidOperationException("IdealPostcodes:ApiKey missing"),
                    sp.GetRequiredService<IHttpClientFactory>().CreateClient(nameof(IdealPostcodesClient))
                ));

            var app = builder.Build();
            // app.UseSentryDotNet();

           // app.UseHttpLogging();

            //app.UseSerilogRequestLogging();
            // Enable Cors
            app.UseCors("MyPolicy");

            app.UseHttpsRedirection();


            app.UseOneSoft(false);

            app.MapControllers();

            try
            {
                //Log.Information("Starting AceTaxisAPI web host");
                app.Run();
            }
            catch (Exception ex)
            {
                //Log.Fatal(ex, "Host terminated unexpectedly");
                throw;
            }
            finally
            {
                //Log.CloseAndFlush();
            }
        }
    }
}
