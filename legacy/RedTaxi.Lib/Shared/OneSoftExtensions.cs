using Microsoft.AspNetCore.Builder;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.IdentityModel.Tokens;
using Microsoft.OpenApi.Models;
using RedTaxi.Modules.Messaging.Services;
using RedTaxi.Modules.Messaging;
using System.Data.SqlClient;
using System.Text;
using WatchDog;
using WatchDog.src.Enums;
using System.Text.Json.Serialization;
using Microsoft.AspNetCore.Identity.UI.Services;
using SendGrid.Extensions.DependencyInjection;
using Microsoft.AspNetCore.Identity;
using Amazon.S3;
using RedTaxi.Integrations.Aws;
using FirebaseAdmin;
using Google.Apis.Auth.OAuth2;

public static partial class MiddlewareInitializer
{
    public static WebApplication UseOneSoft(this WebApplication app,
        bool useWatchdog, bool serilogRequestLogging = false)
    {
        app.MapControllers();
        app.UseStaticFiles();

        app.UseRouting();
        app.UseAuthentication();
        app.UseAuthorization();
        app.UseMiddleware<JwtMiddleware>();

        app.UseDeveloperExceptionPage();

        app.UseSwagger();
        app.UseSwaggerUI(c =>
        {
            c.SwaggerEndpoint("/swagger/core/swagger.json", "Online API");
            c.SwaggerEndpoint("/swagger/v1/swagger.json", "V1 API");
        });

        if (useWatchdog)
        {
            app.UseWatchDogExceptionLogger();
            app.UseWatchDog(opt =>
            {
                opt.WatchPageUsername = "admin";
                opt.WatchPagePassword = "admin";
            });
        }

        return app;
    }
}

public static partial class ServiceInitializer
{
    public static IServiceCollection AddOneSoft(this IServiceCollection services, OneSoftConfig config)
    {
        var env = Environment.GetEnvironmentVariable("ASPNETCORE_ENVIRONMENT") ?? "Production";
        var configuration = new ConfigurationBuilder()
            .AddJsonFile(@"appsettings.json", optional: false)
            .AddJsonFile($"appsettings.{env}.json", optional: true)
            .Build();

        #region DATABASE CONTEXT
        services.AddDbContext<AppDbContext>(options =>
               options.UseSqlServer(configuration.GetConnectionString(name: @"DefaultConnection")));
        services.AddTransient(typeof(AppDbContext));
        #endregion

        #region JWT AUTH
        if (config.AddApiAuth)
        {
            services.AddDefaultIdentity<AppUser>(options =>
            {
                options.User.RequireUniqueEmail = true;

                options.Password.RequireDigit = false;
                options.Password.RequireLowercase = false;
                options.Password.RequireUppercase = false;
                options.Password.RequiredLength = 4;
                options.Password.RequireNonAlphanumeric = false;
            })
              .AddRoles<AppRole>()
              .AddEntityFrameworkStores<AppDbContext>()
              .AddDefaultTokenProviders();

            services.Configure<JwtConfig>(configuration.GetSection("JwtConfig"));

            var key = new SymmetricSecurityKey(Encoding.ASCII.GetBytes(configuration[@"JwtConfig:Key"]));
            var issuer = configuration[@"JwtConfig:Issuer"];
            var tokenvps = new TokenValidationParameters
            {
                ValidateIssuerSigningKey = true,
                IssuerSigningKey = key,
                ValidateIssuer = true,
                ValidateAudience = true,
                ValidateLifetime = true,
                RequireExpirationTime = true,
                ClockSkew = TimeSpan.Zero,
                ValidIssuer = issuer,
                ValidAudience = issuer
            };

            services.AddSingleton(tokenvps);
            services.AddAuthentication(options =>
            {

            });

            services.AddScoped<IUsersService, UsersService>();
            services.AddScoped<IAuthenticationService, AuthenticationService>();
        }


        #endregion

        #region SWAGGER
        services.AddEndpointsApiExplorer();
        services.AddSwaggerGen(c =>
        {
            c.SwaggerDoc("core", new OpenApiInfo { Title = "Abacus Online - Core", Version = "core" });
            c.SwaggerDoc("v1", new OpenApiInfo { Title = "Abacus Online - v1", Version = "v1" });

            c.AddSecurityDefinition(
                    "Bearer",
                    new OpenApiSecurityScheme
                    {
                        Name = "Authorization",
                        Type = SecuritySchemeType.Http,
                        Scheme = "Bearer",
                        BearerFormat = "JWT",
                        In = ParameterLocation.Header,
                        Description = "JWT Authorization header using the Bearer scheme."
                    });

            c.AddSecurityRequirement(new OpenApiSecurityRequirement
                    {
                        {
                            new OpenApiSecurityScheme
                            {
                                Reference = new OpenApiReference
                                {
                                    Type = ReferenceType.SecurityScheme,
                                    Id = "Bearer"
                                }
                            },
                            new List<string>()
                        }
                    });
        });
        #endregion

        #region DI

        if (config.AddMessaging)
        {

            if (FirebaseApp.DefaultInstance == null)
            {
                FirebaseApp.Create(new AppOptions()
                {
                    Credential = GoogleCredential.FromFile("pushNotificationConfig.json")
                });
            }

            services.Configure<MessagingConfig>(configuration.GetSection("MessagingConfig"));
            services.AddSendGrid(options =>
                options.ApiKey = configuration.GetValue<string>("MessagingConfig:Email:SendGridApiKey")
                         ?? throw new Exception("The 'SendGridApiKey' is not configured"));
            services.AddTransient<IEmailSender, MessageService>();
            services.AddScoped<IPushNotificationService, PushNotificationService>();
        }

        if(config.AddMemoryCache)
        {
            services.AddMemoryCache();
        }

        #endregion

        services.AddControllers()
                .AddJsonOptions(options =>
                {
                    options.JsonSerializerOptions.ReferenceHandler = ReferenceHandler.IgnoreCycles;
                    options.JsonSerializerOptions.WriteIndented = true;
                });

        #region WATCHDOG
        if (config.AddWatchdog)
        {
            try
            {
                services.AddWatchDogServices(opt =>
                {
                    opt.IsAutoClear = true;
                    opt.ClearTimeSchedule = WatchDogAutoClearScheduleEnum.Every6Hours;
                    opt.SetExternalDbConnString = configuration.GetConnectionString(name: @"DefaultConnection");
                    opt.DbDriverOption = WatchDogDbDriverEnum.MSSQL;
                });
            }
            catch(SqlException ex)
            {
                if(ex.ErrorCode == -2146232060)
                {
                    // db not created yet
                }
            }

        }
        #endregion

        #region AWS
        if (config.AddAWS)
        {
            services.Configure<AWSConfig>(configuration.GetSection("AWSConfig"));
            services.AddAWSService<IAmazonS3>();
            services.AddScoped<AmazonAWSService>();
        }
        #endregion

        return services;
    }
}

public class OneSoftConfig
{
    public bool AddJwt { get; set; }
    public bool AddApiAuth { get; set; }
    public bool AddMessaging { get; set; }
    public bool AddWatchdog { get; set; }
    public bool AddMemoryCache { get; set; }
    public bool AddAWS { get; set; }

}
