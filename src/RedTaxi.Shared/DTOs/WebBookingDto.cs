namespace RedTaxi.Shared.DTOs;

public record WebBookingDto(int Id, string? PassengerName, string? PhoneNumber, string? Email,
    string PickupAddress, string? DestinationAddress, DateTime PickupDateTime,
    string? Details, int Passengers, int VehicleType, int? AccountNumber,
    int Status, decimal? Price, DateTime DateCreated);
