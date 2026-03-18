using RedTaxi.Domain.Enums;

namespace RedTaxi.Domain.Entities;

public class Account
{
    public int Id { get; set; }
    public int AccountNumber { get; set; }
    public string CompanyName { get; set; } = string.Empty;
    public string? ContactName { get; set; }
    public string? ContactPhone { get; set; }
    public string? ContactEmail { get; set; }
    public string? PurchaseOrderNo { get; set; }
    public string? Reference { get; set; }
    public string? BookerEmail { get; set; }
    public string? BookerName { get; set; }
    public int? AccountTariffId { get; set; }
    public int? DefaultTariffId { get; set; }
    public BillingCycle? BillingCycle { get; set; }
    public bool IsActive { get; set; }

    // Navigation properties
    public AccountTariff? AccountTariff { get; set; }
    public ICollection<AccountPassenger> Passengers { get; set; } = [];
}
