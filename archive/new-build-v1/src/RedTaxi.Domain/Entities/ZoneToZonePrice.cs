namespace RedTaxi.Domain.Entities;

public class ZoneToZonePrice
{
    public int Id { get; set; }
    public string StartZoneName { get; set; } = string.Empty;
    public string EndZoneName { get; set; } = string.Empty;
    public decimal Cost { get; set; }
    public decimal Charge { get; set; }
    public bool IsActive { get; set; }
}
