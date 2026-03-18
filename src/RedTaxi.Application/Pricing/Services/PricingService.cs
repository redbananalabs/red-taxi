using Microsoft.EntityFrameworkCore;
using RedTaxi.Domain.Entities;
using RedTaxi.Domain.Enums;
using RedTaxi.Domain.Interfaces;
using RedTaxi.Infrastructure.Persistence;

namespace RedTaxi.Application.Pricing.Services;

public class PricingService : IPricingService
{
    private readonly TenantDbContext _db;
    private readonly IDistanceMatrixService _distance;

    public PricingService(TenantDbContext db, IDistanceMatrixService distance)
    {
        _db = db;
        _distance = distance;
    }

    public async Task<(decimal driverPrice, decimal accountPrice, decimal mileage, string mileageText, string durationText)>
        CalculatePriceAsync(Booking booking, CancellationToken ct = default)
    {
        // Priority 1: Manual override — skip all calculation
        if (booking.ManuallyPriced)
            return (booking.Price, booking.PriceAccount, booking.Mileage ?? 0m, booking.MileageText ?? "", booking.DurationText ?? "");

        // Get distance/duration from external service
        var origin = !string.IsNullOrWhiteSpace(booking.PickupPostCode) ? booking.PickupPostCode : booking.PickupAddress;
        var dest = !string.IsNullOrWhiteSpace(booking.DestinationPostCode) ? booking.DestinationPostCode : booking.DestinationAddress;

        decimal journeyMiles = 0m;
        int durationMinutes = 0;

        if (!string.IsNullOrWhiteSpace(dest))
        {
            (journeyMiles, durationMinutes) = await _distance.GetDistanceAsync(origin, dest, ct);
        }

        string mileageText = $"{journeyMiles:F1} miles";
        string durationText = durationMinutes > 0 ? $"{durationMinutes} min" : "";

        // Priority 2: Zone-to-Zone pricing
        var zoneResult = await TryZoneToZonePriceAsync(booking, ct);
        if (zoneResult.HasValue)
            return (zoneResult.Value.driverPrice, zoneResult.Value.accountPrice, journeyMiles, mileageText, durationText);

        // Priority 3: Fixed route pricing
        var fixedResult = await TryFixedPriceAsync(booking, ct);
        if (fixedResult.HasValue)
            return (fixedResult.Value.driverPrice, fixedResult.Value.accountPrice, journeyMiles, mileageText, durationText);

        // Priority 4: Account tariff (dual pricing)
        if (booking.AccountNumber.HasValue)
        {
            var accountResult = await TryAccountTariffPriceAsync(booking, journeyMiles, ct);
            if (accountResult.HasValue)
                return (accountResult.Value.driverPrice, accountResult.Value.accountPrice, journeyMiles, mileageText, durationText);
        }

        // Priority 5: Standard tariff
        var standardResult = await CalculateStandardTariffAsync(booking, journeyMiles, ct);
        return (standardResult.driverPrice, standardResult.accountPrice, journeyMiles, mileageText, durationText);
    }

    private async Task<(decimal driverPrice, decimal accountPrice)?> TryZoneToZonePriceAsync(Booking booking, CancellationToken ct)
    {
        // Load all active geofences and zone-to-zone prices
        var geoFences = await _db.GeoFences.AsNoTracking().ToListAsync(ct);
        var zoneToZonePrices = await _db.ZoneToZonePrices.AsNoTracking().Where(z => z.IsActive).ToListAsync(ct);

        if (geoFences.Count == 0 || zoneToZonePrices.Count == 0)
            return null;

        // Find which zone the pickup falls in and which zone the destination falls in
        // Since we don't have lat/lng on the booking, zone matching is by name/area lookup
        // In a full implementation this would do point-in-polygon tests
        // For now, we match zone names against the booking addresses as a placeholder
        string? pickupZone = null;
        string? destZone = null;

        foreach (var fence in geoFences)
        {
            if (!string.IsNullOrWhiteSpace(fence.Area))
            {
                if (booking.PickupPostCode?.StartsWith(fence.Area, StringComparison.OrdinalIgnoreCase) == true
                    || booking.PickupAddress.Contains(fence.Name, StringComparison.OrdinalIgnoreCase))
                    pickupZone = fence.Name;

                if (booking.DestinationPostCode?.StartsWith(fence.Area, StringComparison.OrdinalIgnoreCase) == true
                    || (booking.DestinationAddress?.Contains(fence.Name, StringComparison.OrdinalIgnoreCase) == true))
                    destZone = fence.Name;
            }
        }

        if (pickupZone == null || destZone == null)
            return null;

        var match = zoneToZonePrices.FirstOrDefault(z =>
            z.StartZoneName.Equals(pickupZone, StringComparison.OrdinalIgnoreCase) &&
            z.EndZoneName.Equals(destZone, StringComparison.OrdinalIgnoreCase));

        if (match == null)
            return null;

        // Cost = driver price, Charge = account price
        return (match.Cost, match.Charge);
    }

    private async Task<(decimal driverPrice, decimal accountPrice)?> TryFixedPriceAsync(Booking booking, CancellationToken ct)
    {
        if (string.IsNullOrWhiteSpace(booking.PickupPostCode) || string.IsNullOrWhiteSpace(booking.DestinationPostCode))
            return null;

        var pickupPrefix = booking.PickupPostCode.Trim().ToUpperInvariant();
        var destPrefix = booking.DestinationPostCode.Trim().ToUpperInvariant();

        var fixedPrices = await _db.FixedPriceJourneys
            .AsNoTracking()
            .Where(f => f.IsActive)
            .ToListAsync(ct);

        var match = fixedPrices.FirstOrDefault(f =>
            pickupPrefix.StartsWith(f.PickupPostcodePrefix.Trim().ToUpperInvariant()) &&
            destPrefix.StartsWith(f.DestinationPostcodePrefix.Trim().ToUpperInvariant()));

        if (match == null)
            return null;

        return (match.Price, match.PriceAccount ?? match.Price);
    }

    private async Task<(decimal driverPrice, decimal accountPrice)?> TryAccountTariffPriceAsync(
        Booking booking, decimal journeyMiles, CancellationToken ct)
    {
        var account = await _db.Accounts
            .AsNoTracking()
            .Include(a => a.AccountTariff)
            .FirstOrDefaultAsync(a => a.AccountNumber == booking.AccountNumber && a.IsActive, ct);

        if (account?.AccountTariff == null)
            return null;

        var at = account.AccountTariff;
        decimal totalMiles = CalculateTotalMiles(booking.ChargeFromBase, journeyMiles, deadMiles: 0m);

        decimal driverPrice = at.DriverInitialCharge + at.DriverFirstMileCharge
            + Math.Max(0m, totalMiles - 1m) * at.DriverAdditionalMileCharge;

        decimal accountPrice = at.AccountInitialCharge + at.AccountFirstMileCharge
            + Math.Max(0m, totalMiles - 1m) * at.AccountAdditionalMileCharge;

        return (Math.Round(driverPrice, 2), Math.Round(accountPrice, 2));
    }

    private async Task<(decimal driverPrice, decimal accountPrice)> CalculateStandardTariffAsync(
        Booking booking, decimal journeyMiles, CancellationToken ct)
    {
        var tariffType = await DetermineTariffTypeAsync(booking.PickupDateTime, ct);

        var tariff = await _db.Tariffs
            .AsNoTracking()
            .FirstOrDefaultAsync(t => t.Type == tariffType && t.IsActive, ct);

        if (tariff == null)
        {
            // Fallback: try Tariff1
            tariff = await _db.Tariffs.AsNoTracking().FirstOrDefaultAsync(t => t.IsActive, ct);
        }

        if (tariff == null)
            return (0m, 0m);

        decimal totalMiles = CalculateTotalMiles(booking.ChargeFromBase, journeyMiles, deadMiles: 0m);

        decimal price = tariff.InitialCharge + tariff.FirstMileCharge;
        if (totalMiles > 1m)
            price += (totalMiles - 1m) * tariff.AdditionalMileCharge;

        price = Math.Round(price, 2);
        return (price, price);
    }

    private async Task<TariffType> DetermineTariffTypeAsync(DateTime pickupDateTime, CancellationToken ct)
    {
        var date = pickupDateTime.Date;
        var time = pickupDateTime.TimeOfDay;

        // Tariff 3 (Holiday): Dec 24 after 18:00, Dec 25-26, Dec 31 after 18:00, Jan 1
        if (IsHolidayTariff(date, time))
            return TariffType.Tariff3;

        // Check configurable bank holidays
        var config = await _db.CompanyConfigs.AsNoTracking().FirstOrDefaultAsync(ct);
        if (config != null && IsBankHoliday(date, config))
            return TariffType.Tariff2;

        // Tariff 2 (Night): any day 22:00-06:59, all Sunday
        if (pickupDateTime.DayOfWeek == DayOfWeek.Sunday)
            return TariffType.Tariff2;

        if (time.Hours >= 22 || time.Hours < 7)
            return TariffType.Tariff2;

        // Tariff 1 (Day): Mon-Sat 07:00-21:59
        return TariffType.Tariff1;
    }

    private static bool IsHolidayTariff(DateTime date, TimeSpan time)
    {
        // Dec 25 or Dec 26 (all day)
        if (date.Month == 12 && (date.Day == 25 || date.Day == 26))
            return true;

        // Jan 1 (all day)
        if (date.Month == 1 && date.Day == 1)
            return true;

        // Dec 24 after 18:00
        if (date.Month == 12 && date.Day == 24 && time.Hours >= 18)
            return true;

        // Dec 31 after 18:00
        if (date.Month == 12 && date.Day == 31 && time.Hours >= 18)
            return true;

        return false;
    }

    private static bool IsBankHoliday(DateTime date, CompanyConfig config)
    {
        // Bank holidays could be stored in a JSON field or related table.
        // For now, CompanyConfig doesn't have a bank holiday list, so this is a placeholder.
        // In production, you'd parse config.BankHolidays or query a BankHoliday table.
        return false;
    }

    private static decimal CalculateTotalMiles(bool chargeFromBase, decimal journeyMiles, decimal deadMiles)
    {
        if (chargeFromBase)
            return (journeyMiles + deadMiles) / 2.0m;

        return journeyMiles;
    }
}
