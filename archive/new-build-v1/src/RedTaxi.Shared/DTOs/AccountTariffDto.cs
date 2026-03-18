namespace RedTaxi.Shared.DTOs;

public record AccountTariffDto(int Id, string Name, decimal AccountInitialCharge, decimal DriverInitialCharge,
    decimal AccountFirstMileCharge, decimal DriverFirstMileCharge,
    decimal AccountAdditionalMileCharge, decimal DriverAdditionalMileCharge);
