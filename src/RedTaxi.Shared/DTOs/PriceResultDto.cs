namespace RedTaxi.Shared.DTOs;

public record PriceResultDto(decimal DriverPrice, decimal AccountPrice, decimal Mileage,
    string? MileageText, string? DurationText, string? TariffApplied);
