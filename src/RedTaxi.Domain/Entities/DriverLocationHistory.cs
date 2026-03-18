using System;

namespace RedTaxi.Domain.Entities;

public class DriverLocationHistory
{
    public int Id { get; set; }
    public int UserId { get; set; }
    public decimal Longitude { get; set; }
    public decimal Latitude { get; set; }
    public decimal? Heading { get; set; }
    public decimal? Speed { get; set; }
    public DateTime TimeStamp { get; set; }
}
