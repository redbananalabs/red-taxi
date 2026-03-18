using RedTaxi.Domain.Entities;

namespace RedTaxi.Domain.Interfaces;

public interface IPricingService
{
    Task<(decimal driverPrice, decimal accountPrice, decimal mileage, string mileageText, string durationText)> CalculatePriceAsync(Booking booking, CancellationToken ct = default);
}
