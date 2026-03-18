namespace RedTaxi.Domain.Entities;

public class AccountTariff
{
    public int Id { get; set; }
    public string Name { get; set; } = string.Empty;

    // Account-facing charges
    public decimal AccountInitialCharge { get; set; }
    public decimal AccountFirstMileCharge { get; set; }
    public decimal AccountAdditionalMileCharge { get; set; }

    // Driver payout rates
    public decimal DriverInitialCharge { get; set; }
    public decimal DriverFirstMileCharge { get; set; }
    public decimal DriverAdditionalMileCharge { get; set; }
}
