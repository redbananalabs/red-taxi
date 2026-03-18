using AceTaxis.Data.Models;
using AceTaxis.Domain;

namespace AceTaxis.Interfaces
{
    public interface IBookingModel
    {
        string BookedByName { get; set; }
        ConfirmationStatus? ConfirmationStatus { get; set; }
        string Details { get; set; }
        string Email { get; set; }
        bool IsAllDay { get; set; }
        string? PassengerName { get; set; }
        int Passengers { get; set; }
        PaymentStatus? PaymentStatus { get; set; }
        
        string PhoneNumber { get; set; }
        string PickupAddress { get; set; }
        DateTime PickupDateTime { get; set; }
        string PickupPostCode { get; set; }
        string DestinationAddress { get; set; }
        string DestinationPostCode { get; set; }
        string? RecurrenceException { get; set; }
        int? RecurrenceID { get; set; }
        string? RecurrenceRule { get; set; }
        BookingScope? Scope { get; set; }

        int DurationMinutes { get; set; }
        decimal Price { get; set; }
        decimal PriceAccount { get; set; }
        decimal? Mileage { get; set; }
        string? MileageText { get; set; }
        string? DurationText { get; set; }

        int ActionByUserId { get; set; }

        List<BookingVia> Vias { get; set; }

        int? AccountNumber { get; set; }
        int WaitingTimeMinutes { get; set; }
        decimal ParkingCharge { get; set; }
        
    }

    public interface IPersistedBookingModel
    {
        string? BackgroundColorRGB { get; set; }
        int BookingId { get; set; }
        string? Fullname { get; set; }
        string? RegNo { get; set; }
        int? UserId { get; set; }
        int? SuggestedUserId { get; set; }

        DateTime? PaymentLinkSentOn { get; set; }
        string? PaymentLinkSentBy { get; set; }
        bool IsASAP { get; set; }
    }
}