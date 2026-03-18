namespace RedTaxi.Domain.Entities;

public class BookingVia
{
    public int Id { get; set; }
    public int BookingId { get; set; }
    public string Address { get; set; } = string.Empty;
    public string? PostCode { get; set; }
    public int ViaSequence { get; set; }

    // Navigation properties
    public Booking Booking { get; set; } = null!;
}
