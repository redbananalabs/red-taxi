namespace RedTaxi.Shared.DTOs;

public record TariffDto(int Id, int Type, string Name, string? Description,
    decimal InitialCharge, decimal FirstMileCharge, decimal AdditionalMileCharge, bool IsActive);
