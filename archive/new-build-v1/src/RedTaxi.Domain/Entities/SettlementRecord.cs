namespace RedTaxi.Domain.Entities;

using RedTaxi.Domain.Enums;

public class SettlementRecord
{
    public int Id { get; set; }
    public int BookingId { get; set; }
    public Guid SourceTenantId { get; set; }
    public Guid FulfillingTenantId { get; set; }
    public int DriverId { get; set; }
    public decimal GrossAmount { get; set; }
    public decimal PartnerAmount { get; set; }
    public decimal CommissionAmount { get; set; }
    public SettlementModel SettlementModel { get; set; }
    public SettlementStatus SettlementStatus { get; set; }
    public DateTime CreatedAt { get; set; }
}
