using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;
using RedTaxi.Domain.Entities;
using RedTaxi.Domain.Enums;

namespace RedTaxi.Infrastructure.Persistence;

/// <summary>
/// Seeds the RedTaxi_ace tenant database with representative test data for Ace Taxis (Dorset) Ltd.
/// All operations are idempotent — each section checks for existing rows before inserting.
/// </summary>
public class AceTaxisSeedService
{
    private readonly IConfiguration _configuration;
    private readonly ILogger<AceTaxisSeedService> _logger;

    public AceTaxisSeedService(
        IConfiguration configuration,
        ILogger<AceTaxisSeedService> logger)
    {
        _configuration = configuration;
        _logger = logger;
    }

    // -------------------------------------------------------------------------
    // Entry point
    // -------------------------------------------------------------------------

    public async Task SeedAsync(CancellationToken ct = default)
    {
        _logger.LogInformation("Starting Ace Taxis seed...");

        await using var db = CreateContext();

        await SeedCompanyConfigAsync(db, ct);
        await SeedTariffsAsync(db, ct);
        var schoolTariffId = await SeedAccountTariffAsync(db, ct);
        await SeedUserProfilesAsync(db, ct);
        await SeedAccountsAsync(db, schoolTariffId, ct);
        await SeedBookingsAsync(db, ct);
        await SeedLocalPOIsAsync(db, ct);
        await SeedMessagingNotifyConfigsAsync(db, ct);
        await SeedDocumentExpiriesAsync(db, ct);

        _logger.LogInformation("Ace Taxis seed complete.");
    }

    // -------------------------------------------------------------------------
    // Context factory — connects directly to RedTaxi_ace
    // -------------------------------------------------------------------------

    private TenantDbContext CreateContext()
    {
        var template = _configuration.GetConnectionString("TenantTemplate")
            ?? "Server=localhost;Database=RedTaxi_{slug};Trusted_Connection=True;TrustServerCertificate=True";

        var connectionString = template.Replace("{slug}", "ace");

        var options = new DbContextOptionsBuilder<TenantDbContext>()
            .UseSqlServer(connectionString)
            .Options;

        return new TenantDbContext(options);
    }

    // -------------------------------------------------------------------------
    // 1. CompanyConfig
    // -------------------------------------------------------------------------

    private async Task SeedCompanyConfigAsync(TenantDbContext db, CancellationToken ct)
    {
        if (await db.CompanyConfigs.AnyAsync(ct))
        {
            _logger.LogDebug("CompanyConfig already exists — skipping.");
            return;
        }

        db.CompanyConfigs.Add(new CompanyConfig
        {
            CompanyName                  = "Ace Taxis (Dorset) Ltd",
            BasePostcode                 = "SP8 4SS",
            AddressLookupLat             = 51.0478m,
            AddressLookupLng             = -2.2769m,
            UnallocatedColour            = "#795548",
            CashCommissionRate           = 15m,
            RankCommissionRate           = 7.5m,
            CardTopupRate                = 2.5m,
            AddVatOnCardPayments         = false,
            DriverWaitingRatePerMinute   = 0.33m,
            AccountWaitingRatePerMinute  = 0.42m,
            MinimumJourneyMinutes        = 15,
            DefaultBlockBookingMonths    = 6,
            JobOfferTimeoutSeconds       = 120,
            JobOfferRetryCount           = 3,
            JobOfferRetryDelaySeconds    = 30,
            TimeZoneId                   = "Europe/London",
            CurrencyCode                 = "GBP",
            PaymentProcessor             = "Revolut",
            MapCenterLatitude            = 51.0478m,
            MapCenterLongitude           = -2.2769m,
            MapDefaultZoom               = 13,
            BankHolidays                 = System.Text.Json.JsonSerializer.Serialize(new[] {
                "2025-04-18","2025-04-21","2025-05-05","2025-05-26","2025-08-25",
                "2026-04-03","2026-04-06","2026-05-04","2026-05-25","2026-08-31",
                "2027-03-26","2027-03-29","2027-05-03","2027-05-31","2027-08-30"
            }),
        });

        await db.SaveChangesAsync(ct);
        _logger.LogInformation("Seeded CompanyConfig.");
    }

    // -------------------------------------------------------------------------
    // 2. Tariffs (PRD §22)
    // -------------------------------------------------------------------------

    private async Task SeedTariffsAsync(TenantDbContext db, CancellationToken ct)
    {
        if (await db.Tariffs.AnyAsync(ct))
        {
            _logger.LogDebug("Tariffs already exist — skipping.");
            return;
        }

        db.Tariffs.AddRange(
            new Tariff
            {
                Type                 = TariffType.Tariff1,
                Name                 = "Day Rate",
                InitialCharge        = 0m,
                FirstMileCharge      = 4.80m,
                AdditionalMileCharge = 3.00m,
                IsActive             = true,
            },
            new Tariff
            {
                Type                 = TariffType.Tariff2,
                Name                 = "Night Rate",
                InitialCharge        = 0m,
                FirstMileCharge      = 7.20m,
                AdditionalMileCharge = 4.50m,
                IsActive             = true,
            },
            new Tariff
            {
                Type                 = TariffType.Tariff3,
                Name                 = "Holiday Rate",
                InitialCharge        = 0m,
                FirstMileCharge      = 9.60m,
                AdditionalMileCharge = 6.00m,
                IsActive             = true,
            });

        await db.SaveChangesAsync(ct);
        _logger.LogInformation("Seeded 3 Tariffs.");
    }

    // -------------------------------------------------------------------------
    // 3. AccountTariff — School Tariff
    // -------------------------------------------------------------------------

    private async Task<int> SeedAccountTariffAsync(TenantDbContext db, CancellationToken ct)
    {
        var existing = await db.AccountTariffs
            .FirstOrDefaultAsync(t => t.Name == "School Tariff", ct);

        if (existing is not null)
        {
            _logger.LogDebug("AccountTariff 'School Tariff' already exists — skipping.");
            return existing.Id;
        }

        var tariff = new AccountTariff
        {
            Name                        = "School Tariff",
            AccountInitialCharge        = 0m,
            DriverInitialCharge         = 0m,
            AccountFirstMileCharge      = 4.80m,
            DriverFirstMileCharge       = 4.80m,
            AccountAdditionalMileCharge = 3.00m,
            DriverAdditionalMileCharge  = 2.20m,
        };

        db.AccountTariffs.Add(tariff);
        await db.SaveChangesAsync(ct);
        _logger.LogInformation("Seeded AccountTariff 'School Tariff' (Id={Id}).", tariff.Id);
        return tariff.Id;
    }

    // -------------------------------------------------------------------------
    // 4. UserProfiles — 5 Drivers + 1 Admin
    // -------------------------------------------------------------------------

    private async Task SeedUserProfilesAsync(TenantDbContext db, CancellationToken ct)
    {
        var existingUserIds = await db.UserProfiles
            .Select(u => u.UserId)
            .ToListAsync(ct);

        var passwordHash = BCrypt.Net.BCrypt.HashPassword("Test123!");

        var profiles = new[]
        {
            new UserProfile
            {
                UserId        = 1,
                FullName      = "Andrew Owen",
                Email         = "andrew@ace.test",
                PasswordHash  = passwordHash,
                ColorCodeRGB  = "#4CAF50",
                RegNo         = "AB12 CDE",
                VehicleType   = VehicleType.Saloon,
                VehicleMake   = "Toyota",
                VehicleModel  = "Prius",
                VehicleColour = "Silver",
                CommissionRate = 15m,
                IsActive      = true,
                Role          = UserRole.Driver,
            },
            new UserProfile
            {
                UserId        = 2,
                FullName      = "Jean Williams",
                Email         = "jean@ace.test",
                PasswordHash  = passwordHash,
                ColorCodeRGB  = "#2196F3",
                RegNo         = "CD34 EFG",
                VehicleType   = VehicleType.MPV,
                VehicleMake   = "Ford",
                VehicleModel  = "Galaxy",
                VehicleColour = "Blue",
                CommissionRate = 12m,
                IsActive      = true,
                Role          = UserRole.Driver,
            },
            new UserProfile
            {
                UserId        = 3,
                FullName      = "Mark Thompson",
                Email         = "mark@ace.test",
                PasswordHash  = passwordHash,
                ColorCodeRGB  = "#FF9800",
                RegNo         = "EF56 GHI",
                VehicleType   = VehicleType.Estate,
                VehicleMake   = "Skoda",
                VehicleModel  = "Superb",
                VehicleColour = "Black",
                CommissionRate = 15m,
                IsActive      = true,
                Role          = UserRole.Driver,
            },
            new UserProfile
            {
                UserId        = 4,
                FullName      = "Sarah Davis",
                Email         = "sarah@ace.test",
                PasswordHash  = passwordHash,
                ColorCodeRGB  = "#9C27B0",
                RegNo         = "GH78 IJK",
                VehicleType   = VehicleType.Saloon,
                VehicleMake   = "Hyundai",
                VehicleModel  = "Ioniq",
                VehicleColour = "White",
                CommissionRate = 15m,
                IsActive      = true,
                Role          = UserRole.Driver,
            },
            new UserProfile
            {
                UserId        = 5,
                FullName      = "Tom Richards",
                Email         = "tom@ace.test",
                PasswordHash  = passwordHash,
                ColorCodeRGB  = "#F44336",
                RegNo         = "IJ90 KLM",
                VehicleType   = VehicleType.SUV,
                VehicleMake   = "Kia",
                VehicleModel  = "Sportage",
                VehicleColour = "Grey",
                CommissionRate = 10m,
                IsActive      = true,
                Role          = UserRole.Driver,
            },
            new UserProfile
            {
                UserId       = 100,
                FullName     = "Admin User",
                Email        = "admin@ace.test",
                PasswordHash = passwordHash,
                IsActive     = true,
                Role         = UserRole.Admin,
            },
        };

        var toInsert = profiles
            .Where(p => !existingUserIds.Contains(p.UserId))
            .ToList();

        if (toInsert.Count == 0)
        {
            _logger.LogDebug("All UserProfiles already exist — skipping.");
            return;
        }

        db.UserProfiles.AddRange(toInsert);
        await db.SaveChangesAsync(ct);
        _logger.LogInformation("Seeded {Count} UserProfile(s).", toInsert.Count);
    }

    // -------------------------------------------------------------------------
    // 5. Accounts
    // -------------------------------------------------------------------------

    private async Task SeedAccountsAsync(TenantDbContext db, int schoolTariffId, CancellationToken ct)
    {
        var existingNumbers = await db.Accounts
            .Select(a => a.AccountNumber)
            .ToListAsync(ct);

        var accounts = new[]
        {
            new Account
            {
                AccountNumber  = 1001,
                CompanyName    = "Harbour Vale School",
                ContactName    = "Reception",
                ContactEmail   = "school@hvs.test",
                IsActive       = true,
                AccountTariffId = schoolTariffId,
            },
            new Account
            {
                AccountNumber = 1002,
                CompanyName   = "Dorset County Council",
                ContactName   = "Transport Dept",
                ContactEmail  = "transport@dcc.test",
                IsActive      = true,
            },
            new Account
            {
                AccountNumber = 1003,
                CompanyName   = "Shaftesbury Hospital",
                ContactName   = "Patient Transport",
                ContactEmail  = "transport@hospital.test",
                IsActive      = true,
            },
        };

        var toInsert = accounts
            .Where(a => !existingNumbers.Contains(a.AccountNumber))
            .ToList();

        if (toInsert.Count == 0)
        {
            _logger.LogDebug("All Accounts already exist — skipping.");
            return;
        }

        db.Accounts.AddRange(toInsert);
        await db.SaveChangesAsync(ct);
        _logger.LogInformation("Seeded {Count} Account(s).", toInsert.Count);
    }

    // -------------------------------------------------------------------------
    // 6. Bookings — 10 test bookings (variety of scopes)
    // -------------------------------------------------------------------------

    private async Task SeedBookingsAsync(TenantDbContext db, CancellationToken ct)
    {
        if (await db.Bookings.AnyAsync(ct))
        {
            _logger.LogDebug("Bookings already exist — skipping.");
            return;
        }

        var today = DateTime.UtcNow.Date;

        var bookings = new[]
        {
            // --- 3 Cash bookings ---
            new Booking
            {
                PickupAddress       = "3 High Street, Gillingham",
                PickupPostCode      = "SP8 4AA",
                DestinationAddress  = "Gillingham Train Station",
                DestinationPostCode = "SP8 4QP",
                PassengerName       = "James Carter",
                PhoneNumber         = "07700 900001",
                Passengers          = 1,
                PickupDateTime      = today.AddHours(8).AddMinutes(30),
                DurationMinutes     = 10,
                Scope               = BookingScope.Cash,
                Price               = 8.50m,
                UserId              = 1,
                ConfirmationStatus  = ConfirmationStatus.Confirmed,
                Cancelled           = false,
                DateCreated         = DateTime.UtcNow,
                ActionByUserId      = 100,
                VehicleType         = VehicleType.Saloon,
            },
            new Booking
            {
                PickupAddress       = "15 Peacemarsh, Gillingham",
                PickupPostCode      = "SP8 4EU",
                DestinationAddress  = "Shaftesbury Town Hall, High Street",
                DestinationPostCode = "SP7 8JE",
                PassengerName       = "Helen Price",
                PhoneNumber         = "07700 900002",
                Passengers          = 2,
                PickupDateTime      = today.AddHours(10).AddMinutes(0),
                DurationMinutes     = 20,
                Scope               = BookingScope.Cash,
                Price               = 14.00m,
                UserId              = 2,
                ConfirmationStatus  = ConfirmationStatus.Confirmed,
                Cancelled           = false,
                DateCreated         = DateTime.UtcNow,
                ActionByUserId      = 100,
                VehicleType         = VehicleType.MPV,
            },
            new Booking
            {
                PickupAddress       = "Waitrose, Gillingham",
                PickupPostCode      = "SP8 4RS",
                DestinationAddress  = "Mere, Wiltshire",
                DestinationPostCode = "BA12 6DR",
                PassengerName       = "Robert Fox",
                PhoneNumber         = "07700 900003",
                Passengers          = 1,
                PickupDateTime      = today.AddHours(14).AddMinutes(15),
                DurationMinutes     = 25,
                Scope               = BookingScope.Cash,
                Price               = 18.50m,
                UserId              = null, // unallocated
                ConfirmationStatus  = ConfirmationStatus.Pending,
                Cancelled           = false,
                DateCreated         = DateTime.UtcNow,
                ActionByUserId      = 100,
                VehicleType         = VehicleType.Saloon,
            },

            // --- 3 Account bookings (account 1001 — school run) ---
            new Booking
            {
                PickupAddress       = "12 Saxon Way, Gillingham",
                PickupPostCode      = "SP8 4SQ",
                DestinationAddress  = "Harbour Vale School, School Lane, Bourton",
                DestinationPostCode = "SP8 5BT",
                PassengerName       = "Lily Baker",
                PhoneNumber         = "07700 900010",
                Passengers          = 1,
                PickupDateTime      = today.AddHours(8).AddMinutes(0),
                DurationMinutes     = 15,
                Scope               = BookingScope.Account,
                AccountNumber       = 1001,
                Price               = 0m,
                PriceAccount        = 9.60m,
                UserId              = 3,
                ConfirmationStatus  = ConfirmationStatus.Confirmed,
                IsSchoolRun         = true,
                Cancelled           = false,
                DateCreated         = DateTime.UtcNow,
                ActionByUserId      = 100,
                VehicleType         = VehicleType.Saloon,
            },
            new Booking
            {
                PickupAddress       = "8 Chantry Fields, Shaftesbury",
                PickupPostCode      = "SP7 8LD",
                DestinationAddress  = "Harbour Vale School, School Lane, Bourton",
                DestinationPostCode = "SP8 5BT",
                PassengerName       = "Oliver Nash",
                PhoneNumber         = "07700 900011",
                Passengers          = 1,
                PickupDateTime      = today.AddHours(8).AddMinutes(10),
                DurationMinutes     = 20,
                Scope               = BookingScope.Account,
                AccountNumber       = 1001,
                Price               = 0m,
                PriceAccount        = 12.00m,
                UserId              = 3,
                ConfirmationStatus  = ConfirmationStatus.Confirmed,
                IsSchoolRun         = true,
                Cancelled           = false,
                DateCreated         = DateTime.UtcNow,
                ActionByUserId      = 100,
                VehicleType         = VehicleType.Saloon,
            },
            new Booking
            {
                PickupAddress       = "Harbour Vale School, School Lane, Bourton",
                PickupPostCode      = "SP8 5BT",
                DestinationAddress  = "8 Chantry Fields, Shaftesbury",
                DestinationPostCode = "SP7 8LD",
                PassengerName       = "Oliver Nash",
                PhoneNumber         = "07700 900011",
                Passengers          = 1,
                PickupDateTime      = today.AddHours(15).AddMinutes(30),
                DurationMinutes     = 20,
                Scope               = BookingScope.Account,
                AccountNumber       = 1001,
                Price               = 0m,
                PriceAccount        = 12.00m,
                UserId              = null, // unallocated return leg
                ConfirmationStatus  = ConfirmationStatus.Pending,
                IsSchoolRun         = true,
                Cancelled           = false,
                DateCreated         = DateTime.UtcNow,
                ActionByUserId      = 100,
                VehicleType         = VehicleType.Saloon,
            },

            // --- 2 Card bookings ---
            new Booking
            {
                PickupAddress       = "Blandford Forum Railway Bridge, Blandford Forum",
                PickupPostCode      = "DT11 7AH",
                DestinationAddress  = "Blandford Forum Hospital, Milldown Road",
                DestinationPostCode = "DT11 7DD",
                PassengerName       = "Patricia Young",
                PhoneNumber         = "07700 900020",
                Passengers          = 1,
                PickupDateTime      = today.AddHours(11).AddMinutes(30),
                DurationMinutes     = 10,
                Scope               = BookingScope.Card,
                Price               = 7.50m,
                UserId              = 4,
                ConfirmationStatus  = ConfirmationStatus.Confirmed,
                PaymentStatus       = PaymentStatus.AwaitingPayment,
                Cancelled           = false,
                DateCreated         = DateTime.UtcNow,
                ActionByUserId      = 100,
                VehicleType         = VehicleType.Saloon,
            },
            new Booking
            {
                PickupAddress       = "Sherborne Station, Station Road, Sherborne",
                PickupPostCode      = "DT9 3BU",
                DestinationAddress  = "Sherborne School, Abbey Road",
                DestinationPostCode = "DT9 3LF",
                PassengerName       = "George Allen",
                PhoneNumber         = "07700 900021",
                Passengers          = 2,
                PickupDateTime      = today.AddHours(17).AddMinutes(0),
                DurationMinutes     = 10,
                Scope               = BookingScope.Card,
                Price               = 8.00m,
                UserId              = 5,
                ConfirmationStatus  = ConfirmationStatus.Confirmed,
                PaymentStatus       = PaymentStatus.AwaitingPayment,
                Cancelled           = false,
                DateCreated         = DateTime.UtcNow,
                ActionByUserId      = 100,
                VehicleType         = VehicleType.Saloon,
            },

            // --- 1 Rank booking ---
            new Booking
            {
                PickupAddress       = "Gillingham Taxi Rank, Station Road",
                PickupPostCode      = "SP8 4QP",
                DestinationAddress  = "Wyke Road, Gillingham",
                DestinationPostCode = "SP8 4NE",
                PassengerName       = "Rank Customer",
                Passengers          = 1,
                PickupDateTime      = today.AddHours(9).AddMinutes(45),
                DurationMinutes     = 8,
                Scope               = BookingScope.Rank,
                Price               = 6.00m,
                UserId              = 1,
                ConfirmationStatus  = ConfirmationStatus.Confirmed,
                Cancelled           = false,
                DateCreated         = DateTime.UtcNow,
                ActionByUserId      = 100,
                VehicleType         = VehicleType.Saloon,
            },

            // --- 1 ASAP booking ---
            new Booking
            {
                PickupAddress       = "Co-op, Common Mead Lane, Gillingham",
                PickupPostCode      = "SP8 4SZ",
                DestinationAddress  = "Bournemouth Airport",
                DestinationPostCode = "BH23 6SE",
                PassengerName       = "Susan Ward",
                PhoneNumber         = "07700 900030",
                Passengers          = 1,
                PickupDateTime      = DateTime.UtcNow.AddMinutes(15),
                DurationMinutes     = 60,
                Scope               = BookingScope.Cash,
                IsASAP              = true,
                Price               = 55.00m,
                UserId              = null, // unallocated — needs dispatching
                ConfirmationStatus  = ConfirmationStatus.Pending,
                Cancelled           = false,
                DateCreated         = DateTime.UtcNow,
                ActionByUserId      = 100,
                VehicleType         = VehicleType.Saloon,
            },
        };

        db.Bookings.AddRange(bookings);
        await db.SaveChangesAsync(ct);
        _logger.LogInformation("Seeded {Count} Bookings.", bookings.Length);
    }

    // -------------------------------------------------------------------------
    // 7. Local POIs
    // -------------------------------------------------------------------------

    private async Task SeedLocalPOIsAsync(TenantDbContext db, CancellationToken ct)
    {
        if (await db.LocalPOIs.AnyAsync(ct))
        {
            _logger.LogDebug("LocalPOIs already exist — skipping.");
            return;
        }

        db.LocalPOIs.AddRange(
            new LocalPOI
            {
                Name      = "Gillingham Train Station",
                Latitude  = 51.0335m,
                Longitude = -2.2736m,
                Type      = LocalPOIType.TrainStation,
                IsActive  = true,
            },
            new LocalPOI
            {
                Name      = "Shaftesbury Town Hall",
                Latitude  = 51.0050m,
                Longitude = -2.1964m,
                Type      = LocalPOIType.Miscellaneous,
                IsActive  = true,
            },
            new LocalPOI
            {
                Name      = "Blandford Forum Hospital",
                Latitude  = 50.8578m,
                Longitude = -2.1614m,
                Type      = LocalPOIType.Hospital,
                IsActive  = true,
            },
            new LocalPOI
            {
                Name      = "Sherborne School",
                Latitude  = 50.9466m,
                Longitude = -2.5166m,
                Type      = LocalPOIType.School,
                IsActive  = true,
            },
            new LocalPOI
            {
                Name      = "Bournemouth Airport",
                Latitude  = 50.7800m,
                Longitude = -1.8425m,
                Type      = LocalPOIType.Airport,
                IsActive  = true,
            });

        await db.SaveChangesAsync(ct);
        _logger.LogInformation("Seeded 5 LocalPOIs.");
    }

    // -------------------------------------------------------------------------
    // 8. MessagingNotifyConfig — 11 entries
    // -------------------------------------------------------------------------

    private async Task SeedMessagingNotifyConfigsAsync(TenantDbContext db, CancellationToken ct)
    {
        if (await db.MessagingNotifyConfigs.AnyAsync(ct))
        {
            _logger.LogDebug("MessagingNotifyConfigs already exist — skipping.");
            return;
        }

        db.MessagingNotifyConfigs.AddRange(
            new MessagingNotifyConfig { EventType = SentMessageType.DriverOnAllocate,   Channel = SendMessageOfType.WhatsApp, IsEnabled = true  },
            new MessagingNotifyConfig { EventType = SentMessageType.DriverOnUnAllocate, Channel = SendMessageOfType.WhatsApp, IsEnabled = true  },
            new MessagingNotifyConfig { EventType = SentMessageType.DriverOnAmend,      Channel = SendMessageOfType.Sms,      IsEnabled = true  },
            new MessagingNotifyConfig { EventType = SentMessageType.DriverOnCancel,     Channel = SendMessageOfType.Sms,      IsEnabled = true  },
            new MessagingNotifyConfig { EventType = SentMessageType.CustomerOnAllocate, Channel = SendMessageOfType.Sms,      IsEnabled = true  },
            new MessagingNotifyConfig { EventType = SentMessageType.CustomerOnUnAllocate, Channel = SendMessageOfType.Sms,   IsEnabled = true  },
            new MessagingNotifyConfig { EventType = SentMessageType.CustomerOnAmend,    Channel = SendMessageOfType.None,     IsEnabled = false },
            new MessagingNotifyConfig { EventType = SentMessageType.CustomerOnCancel,   Channel = SendMessageOfType.None,     IsEnabled = false },
            new MessagingNotifyConfig { EventType = SentMessageType.CustomerOnComplete, Channel = SendMessageOfType.Sms,      IsEnabled = true  },
            new MessagingNotifyConfig { EventType = SentMessageType.DriverDirectMessage, Channel = SendMessageOfType.Push,   IsEnabled = true  },
            new MessagingNotifyConfig { EventType = SentMessageType.DriverGlobalMessage, Channel = SendMessageOfType.Push,   IsEnabled = true  });

        await db.SaveChangesAsync(ct);
        _logger.LogInformation("Seeded 11 MessagingNotifyConfigs.");
    }

    // -------------------------------------------------------------------------
    // 9. DocumentExpiry — 8 entries for driver 1 (Andrew Owen, UserId=1)
    // -------------------------------------------------------------------------

    private async Task SeedDocumentExpiriesAsync(TenantDbContext db, CancellationToken ct)
    {
        if (await db.DocumentExpiries.AnyAsync(d => d.UserId == 1, ct))
        {
            _logger.LogDebug("DocumentExpiry records for UserId=1 already exist — skipping.");
            return;
        }

        var uploadedAt = DateTime.UtcNow;

        db.DocumentExpiries.AddRange(
            new DocumentExpiry { UserId = 1, DocumentType = DocumentType.Insurance,     ExpiryDate = new DateTime(2026, 12, 31), UploadedAt = uploadedAt },
            new DocumentExpiry { UserId = 1, DocumentType = DocumentType.MOT,           ExpiryDate = new DateTime(2026,  9, 15), UploadedAt = uploadedAt },
            new DocumentExpiry { UserId = 1, DocumentType = DocumentType.DBS,           ExpiryDate = new DateTime(2027,  3,  1), UploadedAt = uploadedAt },
            new DocumentExpiry { UserId = 1, DocumentType = DocumentType.VehicleBadge,  ExpiryDate = new DateTime(2026,  6, 30), UploadedAt = uploadedAt },
            new DocumentExpiry { UserId = 1, DocumentType = DocumentType.DriverLicence, ExpiryDate = new DateTime(2028,  1, 15), UploadedAt = uploadedAt },
            new DocumentExpiry { UserId = 1, DocumentType = DocumentType.SafeGuarding,  ExpiryDate = new DateTime(2027,  6,  1), UploadedAt = uploadedAt },
            new DocumentExpiry { UserId = 1, DocumentType = DocumentType.FirstAidCert,  ExpiryDate = new DateTime(2026,  8, 20), UploadedAt = uploadedAt },
            new DocumentExpiry { UserId = 1, DocumentType = DocumentType.DriverPhoto,   ExpiryDate = null,                       UploadedAt = uploadedAt });

        await db.SaveChangesAsync(ct);
        _logger.LogInformation("Seeded 8 DocumentExpiry records for Andrew Owen (UserId=1).");
    }
}
