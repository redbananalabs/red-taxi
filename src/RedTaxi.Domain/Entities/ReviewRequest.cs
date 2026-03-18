using System;

namespace RedTaxi.Domain.Entities;

public class ReviewRequest
{
    public int Id { get; set; }
    public int BookingId { get; set; }
    public int? CustomerId { get; set; }
    public DateTime RequestedAt { get; set; }
    public DateTime? CompletedAt { get; set; }
    public int? Rating { get; set; }
    public string? Comment { get; set; }
}
