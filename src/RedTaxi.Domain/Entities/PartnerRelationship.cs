namespace RedTaxi.Domain.Entities;

using RedTaxi.Domain.Enums;

public class PartnerRelationship
{
    public int Id { get; set; }
    public Guid TenantId { get; set; }
    public Guid PartnerTenantId { get; set; }
    public PartnerStatus Status { get; set; }
    public string? CoverageRules { get; set; }
    public string? CommercialTerms { get; set; }
    public int Priority { get; set; }
    public DateTime CreatedAt { get; set; }
}
