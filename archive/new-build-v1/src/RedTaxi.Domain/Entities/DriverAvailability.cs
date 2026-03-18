using System;
using RedTaxi.Domain.Enums;

namespace RedTaxi.Domain.Entities;

public class DriverAvailability
{
    public int Id { get; set; }
    public int UserId { get; set; }
    public DateTime Date { get; set; }
    public TimeSpan StartTime { get; set; }
    public TimeSpan EndTime { get; set; }
    public DriverAvailabilityType AvailabilityType { get; set; }
    public string? Details { get; set; }
    public bool GiveOrTake { get; set; }
    public DateTime DateCreated { get; set; }
    public string? CreatedByName { get; set; }
}
