using RedTaxi.Domain.Enums;

namespace RedTaxi.Domain.Entities;

public class Booking
{
    public int Id { get; set; }

    // Pickup
    public string PickupAddress { get; set; } = string.Empty;
    public string PickupPostCode { get; set; } = string.Empty;

    // Destination
    public string? DestinationAddress { get; set; }
    public string? DestinationPostCode { get; set; }

    // Booking details
    public string? Details { get; set; }
    public string? PassengerName { get; set; }
    public int Passengers { get; set; } = 1;
    public string? PhoneNumber { get; set; }
    public string? Email { get; set; }

    // Scheduling
    public DateTime PickupDateTime { get; set; }
    public DateTime? ArriveBy { get; set; }
    public bool IsAllDay { get; set; }
    public int DurationMinutes { get; set; } = 15;

    // Recurrence
    public string? RecurrenceRule { get; set; }
    public int? RecurrenceID { get; set; }
    public string? RecurrenceException { get; set; }

    // Booking identity
    public string? BookedByName { get; set; }
    public ConfirmationStatus? ConfirmationStatus { get; set; }
    public PaymentStatus? PaymentStatus { get; set; }
    public BookingScope? Scope { get; set; }
    public int? AccountNumber { get; set; }
    public int? InvoiceNumber { get; set; }

    // Pricing
    public decimal Price { get; set; }
    public decimal PriceAccount { get; set; }
    public decimal Tip { get; set; }
    public bool ManuallyPriced { get; set; }
    public decimal? Mileage { get; set; }
    public string? MileageText { get; set; }
    public string? DurationText { get; set; }
    public bool ChargeFromBase { get; set; }

    // Cancellation
    public bool Cancelled { get; set; }
    public bool CancelledOnArrival { get; set; }

    // Driver assignment
    public int? UserId { get; set; }
    public int? SuggestedUserId { get; set; }
    public BookingStatus? Status { get; set; }

    // Vehicle
    public VehicleType VehicleType { get; set; }

    // Waiting time
    public int WaitingTimeMinutes { get; set; }
    public decimal WaitingTimePriceDriver { get; set; }
    public decimal WaitingTimePriceAccount { get; set; }

    // Extras
    public decimal ParkingCharge { get; set; }
    public bool IsASAP { get; set; }
    public decimal VatAmountAdded { get; set; }

    // Payment links
    public string? PaymentOrderId { get; set; }
    public string? PaymentLink { get; set; }
    public string? PaymentLinkSentBy { get; set; }
    public DateTime? PaymentLinkSentOn { get; set; }
    public bool PaymentReceiptSent { get; set; }

    // Invoicing / statements
    public bool PostedForInvoicing { get; set; }
    public bool PostedForStatement { get; set; }
    public DateTime? AllocatedAt { get; set; }
    public int? AllocatedById { get; set; }
    public int? StatementId { get; set; }

    // Flags
    public bool IsSchoolRun { get; set; }
    public int? MergedIntoBookingId { get; set; }

    // Customer FK
    public int? CustomerId { get; set; }

    // Audit
    public DateTime DateCreated { get; set; }
    public DateTime? DateUpdated { get; set; }
    public string? UpdatedByName { get; set; }
    public string? CancelledByName { get; set; }
    public int ActionByUserId { get; set; }

    // Navigation properties
    public ICollection<BookingVia> Vias { get; set; } = [];
    public Customer? Customer { get; set; }
    public UserProfile? UserProfile { get; set; }
    public DriverInvoiceStatement? Statement { get; set; }
}
