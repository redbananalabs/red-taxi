namespace RedTaxi.Shared.DTOs;

public record DriverDto(int Id, int UserId, string? FullName, string? PhoneNumber, string? ColorCodeRGB,
    string? RegNo, int VehicleType, string? VehicleMake, string? VehicleModel, string? VehicleColour,
    bool IsActive, bool IsSubstitute, decimal? CommissionRate, int CommsPlatform);
