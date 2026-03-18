using System;

namespace RedTaxi.Domain.Entities;

public class DriverAvailabilityAudit
{
    public int Id { get; set; }
    public int UserId { get; set; }
    public DateTime Date { get; set; }
    public string? ChangeDescription { get; set; }
    public DateTime ChangedOn { get; set; }
    public string? ChangedByName { get; set; }
}
