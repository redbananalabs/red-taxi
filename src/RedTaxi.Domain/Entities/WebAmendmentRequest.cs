using System;

namespace RedTaxi.Domain.Entities;

public class WebAmendmentRequest
{
    public int Id { get; set; }
    public int BookingId { get; set; }
    public string? Amendments { get; set; }
    public bool CancelBooking { get; set; }
    public bool ApplyToBlock { get; set; }
    public bool Processed { get; set; }
    public DateTime RequestedOn { get; set; }
}
