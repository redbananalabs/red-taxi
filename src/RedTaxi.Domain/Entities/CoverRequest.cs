namespace RedTaxi.Domain.Entities;

using RedTaxi.Domain.Enums;

public class CoverRequest
{
    public int Id { get; set; }
    public Guid SourceTenantId { get; set; }
    public Guid TargetTenantId { get; set; }
    public int BookingId { get; set; }
    public CoverRequestStatus Status { get; set; }
    public decimal OfferedPrice { get; set; }
    public string? Notes { get; set; }
    public DateTime RequestedAt { get; set; }
    public DateTime? RespondedAt { get; set; }
    public int? RespondedByUserId { get; set; }
}
