namespace RedTaxi.Shared.DTOs;

public class BookingUpdateDto
{
    public int Id { get; set; }
    public string PickupAddress { get; set; } = string.Empty;
    public string? PickupPostCode { get; set; }
    public string? DestinationAddress { get; set; }
    public string? DestinationPostCode { get; set; }
    public string? Details { get; set; }
    public string? PassengerName { get; set; }
    public int Passengers { get; set; } = 1;
    public string? PhoneNumber { get; set; }
    public string? Email { get; set; }
    public DateTime PickupDateTime { get; set; }
    public DateTime? ArriveBy { get; set; }
    public bool IsASAP { get; set; }
    public int Scope { get; set; }
    public int? AccountNumber { get; set; }
    public int VehicleType { get; set; }
    public bool ChargeFromBase { get; set; }
    public bool IsSchoolRun { get; set; }
    public bool IsReturn { get; set; }
    public DateTime? ReturnPickupDateTime { get; set; }
    public List<BookingViaDto>? Vias { get; set; }
    // Repeat booking fields
    public int? RecurrenceFrequency { get; set; }
    public string? RecurrenceDays { get; set; }
    public DateTime? RecurrenceEndDate { get; set; }
}
