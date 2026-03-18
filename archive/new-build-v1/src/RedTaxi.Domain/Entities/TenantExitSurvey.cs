namespace RedTaxi.Domain.Entities;

public class TenantExitSurvey
{
    public int Id { get; set; }
    public Guid TenantId { get; set; }
    public string? Reason { get; set; }
    public string? Feedback { get; set; }
    public DateTime CreatedAt { get; set; }

    public Tenant? Tenant { get; set; }
}
