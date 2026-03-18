namespace RedTaxi.Shared.DTOs;

public record AccountDto(int Id, int AccountNumber, string CompanyName, string? ContactName, string? ContactPhone,
    string? ContactEmail, int? AccountTariffId, string? AccountTariffName, bool IsActive);
