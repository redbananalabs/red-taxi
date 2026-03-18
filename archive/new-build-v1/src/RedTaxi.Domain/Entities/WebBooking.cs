using System;
using RedTaxi.Domain.Enums;

namespace RedTaxi.Domain.Entities;

public class WebBooking
{
    public int Id { get; set; }
    public string? PassengerName { get; set; }
    public string? PhoneNumber { get; set; }
    public string? Email { get; set; }
    public string PickupAddress { get; set; } = string.Empty;
    public string? PickupPostCode { get; set; }
    public string? DestinationAddress { get; set; }
    public string? DestinationPostCode { get; set; }
    public DateTime PickupDateTime { get; set; }
    public string? Details { get; set; }
    public int Passengers { get; set; } = 1;
    public VehicleType VehicleType { get; set; }
    public int? AccountNumber { get; set; }
    public WebBookingStatus Status { get; set; }
    public decimal? Price { get; set; }
    public int? ConvertedBookingId { get; set; }
    public string? RejectionReason { get; set; }
    public string? ProcessedByName { get; set; }
    public DateTime? ProcessedAt { get; set; }
    public DateTime DateCreated { get; set; }
}
