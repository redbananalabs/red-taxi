using RedTaxi.Domain.Enums;

namespace RedTaxi.Domain.Entities;

public class LocalPOI
{
    public int Id { get; set; }
    public string Name { get; set; } = string.Empty;
    public string? Address { get; set; }
    public string? PostCode { get; set; }
    public decimal? Latitude { get; set; }
    public decimal? Longitude { get; set; }
    public LocalPOIType Type { get; set; }
    public bool IsActive { get; set; }
}
