using System;

namespace RedTaxi.Domain.Entities;

public class GeoFence
{
    public int Id { get; set; }
    public string Name { get; set; } = string.Empty;

    /// <summary>JSON array of lat/lng coordinate pairs defining the polygon boundary.</summary>
    public string? PolygonData { get; set; }

    public int Points { get; set; }
    public string? Area { get; set; }
    public DateTime CreatedOn { get; set; }
}
