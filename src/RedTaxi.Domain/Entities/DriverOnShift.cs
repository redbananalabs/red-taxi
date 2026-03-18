using System;

namespace RedTaxi.Domain.Entities;

public class DriverOnShift
{
    public int Id { get; set; }
    public int UserId { get; set; }
    public bool IsOnline { get; set; }
    public int? ActiveBookingId { get; set; }
    public DateTime? ShiftStartedAt { get; set; }
    public DateTime? LastGpsUpdate { get; set; }
}
