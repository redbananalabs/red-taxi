namespace RedTaxi.Shared.DTOs;

public record CompanyConfigDto(int Id, string? CompanyName, string? BasePostcode,
    decimal CashCommissionRate, decimal RankCommissionRate, decimal CardTopupRate,
    bool AddVatOnCardPayments, decimal DriverWaitingRatePerMinute, decimal AccountWaitingRatePerMinute,
    int JobOfferTimeoutSeconds, bool AutoDispatchEnabled,
    string? LogoUrl, string? PrimaryColour, string? PaymentProcessor,
    decimal MapCenterLatitude = 51.0478m, decimal MapCenterLongitude = -2.2769m, int MapDefaultZoom = 13);
