namespace RedTaxi.Shared.DTOs;

public record BookingDto(
    int Id, string PickupAddress, string? PickupPostCode, string? DestinationAddress, string? DestinationPostCode,
    string? Details, string? PassengerName, int Passengers, string? PhoneNumber, string? Email,
    DateTime PickupDateTime, DateTime? ArriveBy, bool IsASAP, int? Scope, int? Status,
    int? UserId, string? DriverName, string? DriverColour,
    decimal Price, decimal PriceAccount, decimal Tip, bool ManuallyPriced,
    decimal? Mileage, string? MileageText, string? DurationText,
    int? AccountNumber, string? AccountName,
    int VehicleType, int WaitingTimeMinutes, decimal WaitingTimePriceDriver, decimal WaitingTimePriceAccount,
    decimal ParkingCharge, decimal VatAmountAdded,
    bool Cancelled, bool CancelledOnArrival, bool IsSchoolRun,
    bool PostedForInvoicing, bool PostedForStatement,
    int? ConfirmationStatus, int? PaymentStatus,
    string? PaymentLink, bool PaymentReceiptSent,
    DateTime DateCreated, DateTime? DateUpdated, string? BookedByName,
    List<BookingViaDto>? Vias);
