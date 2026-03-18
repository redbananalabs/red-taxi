using System;

namespace RedTaxi.Domain.Entities;

public class TurnDown
{
    public int Id { get; set; }
    public int BookingId { get; set; }
    public int? UserId { get; set; }
    public decimal? Amount { get; set; }
    public DateTime TimeStamp { get; set; }
    public string? Reason { get; set; }
}
