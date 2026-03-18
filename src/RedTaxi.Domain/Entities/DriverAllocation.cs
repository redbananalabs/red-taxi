using System;

namespace RedTaxi.Domain.Entities;

public class DriverAllocation
{
    public int Id { get; set; }
    public int BookingId { get; set; }
    public int UserId { get; set; }
    public DateTime AllocatedAt { get; set; }
    public string? AllocatedByName { get; set; }
    public DateTime? UnallocatedAt { get; set; }
    public string? UnallocatedByName { get; set; }
}
