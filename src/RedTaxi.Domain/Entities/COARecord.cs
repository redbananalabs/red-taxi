namespace RedTaxi.Domain.Entities;

/// <summary>
/// Charge-Off Adjustment record — tracks manual adjustments between account charge and driver payout.
/// </summary>
public class COARecord
{
    public int Id { get; set; }
    public int BookingId { get; set; }
    public decimal AccountCharge { get; set; }
    public decimal DriverPayout { get; set; }
    public string? Reason { get; set; }
    public DateTime CreatedAt { get; set; }
    public string? CreatedByName { get; set; }
}
