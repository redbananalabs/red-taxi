using Microsoft.EntityFrameworkCore;
using RedTaxi.Domain.Entities;
using RedTaxi.Domain.Interfaces;

namespace RedTaxi.Infrastructure.Persistence;

public class TenantDbContext : DbContext
{
    public TenantDbContext(DbContextOptions<TenantDbContext> options) : base(options) { }

    // Core Booking
    public DbSet<Booking> Bookings => Set<Booking>();
    public DbSet<BookingVia> BookingVias => Set<BookingVia>();
    public DbSet<BookingChangeAudit> BookingChangeAudits => Set<BookingChangeAudit>();

    // Pricing
    public DbSet<Tariff> Tariffs => Set<Tariff>();
    public DbSet<AccountTariff> AccountTariffs => Set<AccountTariff>();
    public DbSet<ZoneToZonePrice> ZoneToZonePrices => Set<ZoneToZonePrice>();
    public DbSet<FixedPriceJourney> FixedPriceJourneys => Set<FixedPriceJourney>();

    // Dispatch
    public DbSet<DriverAllocation> DriverAllocations => Set<DriverAllocation>();
    public DbSet<DriverOnShift> DriversOnShift => Set<DriverOnShift>();
    public DbSet<JobOffer> JobOffers => Set<JobOffer>();

    // Users & Drivers
    public DbSet<UserProfile> UserProfiles => Set<UserProfile>();
    public DbSet<AppRefreshToken> AppRefreshTokens => Set<AppRefreshToken>();
    public DbSet<UserDeviceRegistration> UserDeviceRegistrations => Set<UserDeviceRegistration>();
    public DbSet<AccountUserLink> AccountUserLinks => Set<AccountUserLink>();
    public DbSet<UserActionLog> UserActionLogs => Set<UserActionLog>();

    // Accounts
    public DbSet<Account> Accounts => Set<Account>();
    public DbSet<AccountInvoice> AccountInvoices => Set<AccountInvoice>();
    public DbSet<AccountPassenger> AccountPassengers => Set<AccountPassenger>();
    public DbSet<CreditNote> CreditNotes => Set<CreditNote>();

    // Drivers
    public DbSet<DriverInvoiceStatement> DriverInvoiceStatements => Set<DriverInvoiceStatement>();
    public DbSet<DriverAvailability> DriverAvailabilities => Set<DriverAvailability>();
    public DbSet<DriverAvailabilityAudit> DriverAvailabilityAudits => Set<DriverAvailabilityAudit>();
    public DbSet<DriverLocationHistory> DriverLocationHistories => Set<DriverLocationHistory>();
    public DbSet<DriverMessage> DriverMessages => Set<DriverMessage>();
    public DbSet<DriverExpense> DriverExpenses => Set<DriverExpense>();
    public DbSet<DriverShiftLog> DriverShiftLogs => Set<DriverShiftLog>();
    public DbSet<DocumentExpiry> DocumentExpiries => Set<DocumentExpiry>();

    // Customers
    public DbSet<Customer> Customers => Set<Customer>();
    public DbSet<SavedAddress> SavedAddresses => Set<SavedAddress>();

    // Messaging & Notifications
    public DbSet<MessagingNotifyConfig> MessagingNotifyConfigs => Set<MessagingNotifyConfig>();
    public DbSet<UINotification> UINotifications => Set<UINotification>();

    // Config
    public DbSet<CompanyConfig> CompanyConfigs => Set<CompanyConfig>();
    public DbSet<LocalPOI> LocalPOIs => Set<LocalPOI>();
    public DbSet<GeoFence> GeoFences => Set<GeoFence>();

    // Web/External
    public DbSet<WebBooking> WebBookings => Set<WebBooking>();
    public DbSet<WebAmendmentRequest> WebAmendmentRequests => Set<WebAmendmentRequest>();
    public DbSet<UrlMapping> UrlMappings => Set<UrlMapping>();
    public DbSet<QRCodeClick> QRCodeClicks => Set<QRCodeClick>();
    public DbSet<ReviewRequest> ReviewRequests => Set<ReviewRequest>();
    public DbSet<COARecord> COARecords => Set<COARecord>();
    public DbSet<TurnDown> TurnDowns => Set<TurnDown>();

    // Partners
    public DbSet<PartnerRelationship> PartnerRelationships => Set<PartnerRelationship>();
    public DbSet<CoverRequest> CoverRequests => Set<CoverRequest>();
    public DbSet<SettlementRecord> SettlementRecords => Set<SettlementRecord>();

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        base.OnModelCreating(modelBuilder);

        // Booking
        modelBuilder.Entity<Booking>(e =>
        {
            e.HasKey(b => b.Id);
            e.Property(b => b.PickupAddress).HasMaxLength(250);
            e.Property(b => b.PickupPostCode).HasMaxLength(9);
            e.Property(b => b.DestinationAddress).HasMaxLength(250);
            e.Property(b => b.DestinationPostCode).HasMaxLength(9);
            e.Property(b => b.Details).HasMaxLength(2000);
            e.Property(b => b.PassengerName).HasMaxLength(250);
            e.Property(b => b.PhoneNumber).HasMaxLength(20);
            e.Property(b => b.Email).HasMaxLength(250);
            e.Property(b => b.BookedByName).HasMaxLength(250);
            e.Property(b => b.UpdatedByName).HasMaxLength(250);
            e.Property(b => b.CancelledByName).HasMaxLength(250);
            e.Property(b => b.Price).HasColumnType("decimal(18,2)");
            e.Property(b => b.PriceAccount).HasColumnType("decimal(18,2)");
            e.Property(b => b.Tip).HasColumnType("decimal(18,2)");
            e.Property(b => b.Mileage).HasColumnType("decimal(18,2)");
            e.Property(b => b.WaitingTimePriceDriver).HasColumnType("decimal(18,2)");
            e.Property(b => b.WaitingTimePriceAccount).HasColumnType("decimal(18,2)");
            e.Property(b => b.ParkingCharge).HasColumnType("decimal(18,2)");
            e.Property(b => b.VatAmountAdded).HasColumnType("decimal(18,2)");
            e.HasMany(b => b.Vias).WithOne(v => v.Booking).HasForeignKey(v => v.BookingId);
            e.HasOne(b => b.Customer).WithMany(c => c.Bookings).HasForeignKey(b => b.CustomerId);
            e.HasOne(b => b.UserProfile).WithMany().HasForeignKey(b => b.UserId);
            e.HasOne(b => b.Statement).WithMany().HasForeignKey(b => b.StatementId);
            e.HasIndex(b => b.PickupDateTime);
            e.HasIndex(b => b.PhoneNumber);
            e.HasIndex(b => b.UserId);
            e.HasIndex(b => b.AccountNumber);
        });

        // BookingVia
        modelBuilder.Entity<BookingVia>(e =>
        {
            e.HasKey(v => v.Id);
            e.Property(v => v.Address).HasMaxLength(250);
            e.Property(v => v.PostCode).HasMaxLength(9);
        });

        // BookingChangeAudit
        modelBuilder.Entity<BookingChangeAudit>(e =>
        {
            e.HasKey(a => a.Id);
            e.HasIndex(a => a.EntityIdentifier);
        });

        // UserProfile
        modelBuilder.Entity<UserProfile>(e =>
        {
            e.HasKey(u => u.Id);
            e.Property(u => u.ColorCodeRGB).HasMaxLength(10);
            e.Property(u => u.RegNo).HasMaxLength(20);
            e.Property(u => u.VehicleMake).HasMaxLength(20);
            e.Property(u => u.VehicleModel).HasMaxLength(30);
            e.Property(u => u.VehicleColour).HasMaxLength(20);
            e.Property(u => u.CommissionRate).HasColumnType("decimal(5,2)");
            e.Property(u => u.Heading).HasColumnType("decimal(6,3)");
            e.Property(u => u.Speed).HasColumnType("decimal(6,2)");
            e.HasIndex(u => u.UserId);
        });

        // Account
        modelBuilder.Entity<Account>(e =>
        {
            e.HasKey(a => a.Id);
            e.Property(a => a.CompanyName).HasMaxLength(250);
            e.Property(a => a.ContactName).HasMaxLength(250);
            e.Property(a => a.ContactPhone).HasMaxLength(20);
            e.Property(a => a.ContactEmail).HasMaxLength(250);
            e.HasOne(a => a.AccountTariff).WithMany().HasForeignKey(a => a.AccountTariffId);
            e.HasMany(a => a.Passengers).WithOne().HasForeignKey(p => p.AccountId);
            e.HasIndex(a => a.AccountNumber).IsUnique();
        });

        // AccountInvoice
        modelBuilder.Entity<AccountInvoice>(e =>
        {
            e.HasKey(i => i.Id);
            e.Property(i => i.TotalAmount).HasColumnType("decimal(18,2)");
            e.Property(i => i.VatAmount).HasColumnType("decimal(18,2)");
            e.Property(i => i.NetAmount).HasColumnType("decimal(18,2)");
        });

        // AccountTariff
        modelBuilder.Entity<AccountTariff>(e =>
        {
            e.HasKey(t => t.Id);
            e.Property(t => t.AccountInitialCharge).HasColumnType("decimal(18,2)");
            e.Property(t => t.DriverInitialCharge).HasColumnType("decimal(18,2)");
            e.Property(t => t.AccountFirstMileCharge).HasColumnType("decimal(18,2)");
            e.Property(t => t.DriverFirstMileCharge).HasColumnType("decimal(18,2)");
            e.Property(t => t.AccountAdditionalMileCharge).HasColumnType("decimal(18,2)");
            e.Property(t => t.DriverAdditionalMileCharge).HasColumnType("decimal(18,2)");
        });

        // Tariff
        modelBuilder.Entity<Tariff>(e =>
        {
            e.HasKey(t => t.Id);
            e.Property(t => t.Name).HasMaxLength(100);
            e.Property(t => t.InitialCharge).HasColumnType("decimal(18,2)");
            e.Property(t => t.FirstMileCharge).HasColumnType("decimal(18,2)");
            e.Property(t => t.AdditionalMileCharge).HasColumnType("decimal(18,2)");
        });

        // CreditNote
        modelBuilder.Entity<CreditNote>(e =>
        {
            e.HasKey(c => c.Id);
            e.Property(c => c.Amount).HasColumnType("decimal(18,2)");
        });

        // COARecord
        modelBuilder.Entity<COARecord>(e =>
        {
            e.HasKey(c => c.Id);
            e.Property(c => c.AccountCharge).HasColumnType("decimal(18,2)");
            e.Property(c => c.DriverPayout).HasColumnType("decimal(18,2)");
        });

        // CompanyConfig - single row per tenant DB
        modelBuilder.Entity<CompanyConfig>(e =>
        {
            e.HasKey(c => c.Id);
            e.Property(c => c.CashCommissionRate).HasColumnType("decimal(5,2)");
            e.Property(c => c.RankCommissionRate).HasColumnType("decimal(5,2)");
            e.Property(c => c.CardTopupRate).HasColumnType("decimal(5,2)");
            e.Property(c => c.DriverWaitingRatePerMinute).HasColumnType("decimal(18,2)");
            e.Property(c => c.AccountWaitingRatePerMinute).HasColumnType("decimal(18,2)");
            e.Property(c => c.AddressLookupLat).HasColumnType("decimal(10,6)");
            e.Property(c => c.AddressLookupLng).HasColumnType("decimal(10,6)");
            e.Property(c => c.MapCenterLatitude).HasColumnType("decimal(10,6)");
            e.Property(c => c.MapCenterLongitude).HasColumnType("decimal(10,6)");
        });

        // LocalPOI
        modelBuilder.Entity<LocalPOI>(e =>
        {
            e.HasKey(p => p.Id);
            e.Property(p => p.Latitude).HasColumnType("decimal(10,6)");
            e.Property(p => p.Longitude).HasColumnType("decimal(10,6)");
        });

        // DriverInvoiceStatement
        modelBuilder.Entity<DriverInvoiceStatement>(e =>
        {
            e.HasKey(s => s.Id);
            e.Property(s => s.EarningsCash).HasColumnType("decimal(18,2)");
            e.Property(s => s.EarningsCard).HasColumnType("decimal(18,2)");
            e.Property(s => s.EarningsAccount).HasColumnType("decimal(18,2)");
            e.Property(s => s.EarningsRank).HasColumnType("decimal(18,2)");
            e.Property(s => s.TotalCommission).HasColumnType("decimal(18,2)");
            e.Property(s => s.CardFees).HasColumnType("decimal(18,2)");
            e.Property(s => s.TotalExpenses).HasColumnType("decimal(18,2)");
            e.Property(s => s.SubTotal).HasColumnType("decimal(18,2)");
            e.Property(s => s.NetPayable).HasColumnType("decimal(18,2)");
        });

        // DriverLocationHistory
        modelBuilder.Entity<DriverLocationHistory>(e =>
        {
            e.HasKey(l => l.Id);
            e.Property(l => l.Longitude).HasColumnType("decimal(10,7)");
            e.Property(l => l.Latitude).HasColumnType("decimal(9,7)");
            e.Property(l => l.Heading).HasColumnType("decimal(6,3)");
            e.Property(l => l.Speed).HasColumnType("decimal(6,2)");
            e.HasIndex(l => new { l.UserId, l.TimeStamp });
        });

        // DriverExpense
        modelBuilder.Entity<DriverExpense>(e =>
        {
            e.HasKey(x => x.Id);
            e.Property(x => x.Amount).HasColumnType("decimal(18,2)");
        });

        // JobOffer
        modelBuilder.Entity<JobOffer>(e =>
        {
            e.HasKey(j => j.Id);
            e.HasIndex(j => j.OfferGuid).IsUnique();
        });

        // ZoneToZonePrice
        modelBuilder.Entity<ZoneToZonePrice>(e =>
        {
            e.HasKey(z => z.Id);
            e.Property(z => z.Cost).HasColumnType("decimal(18,2)");
            e.Property(z => z.Charge).HasColumnType("decimal(18,2)");
        });

        // FixedPriceJourney
        modelBuilder.Entity<FixedPriceJourney>(e =>
        {
            e.HasKey(f => f.Id);
            e.Property(f => f.Price).HasColumnType("decimal(18,2)");
            e.Property(f => f.PriceAccount).HasColumnType("decimal(18,2)");
        });

        // WebBooking
        modelBuilder.Entity<WebBooking>(e =>
        {
            e.HasKey(w => w.Id);
            e.Property(w => w.Price).HasColumnType("decimal(18,2)");
        });

        // Customer
        modelBuilder.Entity<Customer>(e =>
        {
            e.HasKey(c => c.Id);
            e.Property(c => c.Phone).HasMaxLength(20);
            e.HasIndex(c => c.Phone);
        });

        // SavedAddress
        modelBuilder.Entity<SavedAddress>(e =>
        {
            e.HasKey(s => s.Id);
            e.Property(s => s.Lat).HasColumnType("decimal(10,6)");
            e.Property(s => s.Lng).HasColumnType("decimal(10,6)");
        });

        // TurnDown
        modelBuilder.Entity<TurnDown>(e =>
        {
            e.HasKey(t => t.Id);
            e.Property(t => t.Amount).HasColumnType("decimal(18,2)");
        });

        // SettlementRecord
        modelBuilder.Entity<SettlementRecord>(e =>
        {
            e.HasKey(s => s.Id);
            e.Property(s => s.GrossAmount).HasColumnType("decimal(18,2)");
            e.Property(s => s.PartnerAmount).HasColumnType("decimal(18,2)");
            e.Property(s => s.CommissionAmount).HasColumnType("decimal(18,2)");
        });

        // CoverRequest
        modelBuilder.Entity<CoverRequest>(e =>
        {
            e.HasKey(c => c.Id);
            e.Property(c => c.OfferedPrice).HasColumnType("decimal(18,2)");
        });

        // UrlMapping
        modelBuilder.Entity<UrlMapping>(e =>
        {
            e.HasKey(u => u.Id);
            e.HasIndex(u => u.ShortCode).IsUnique();
        });

        // Soft delete global query filters
        modelBuilder.Entity<Booking>().HasQueryFilter(b => !b.IsDeleted);
        modelBuilder.Entity<Account>().HasQueryFilter(a => !a.IsDeleted);
        modelBuilder.Entity<UserProfile>().HasQueryFilter(u => !u.IsDeleted);
        modelBuilder.Entity<Customer>().HasQueryFilter(c => !c.IsDeleted);
    }
}
