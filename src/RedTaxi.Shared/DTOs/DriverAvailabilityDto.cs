namespace RedTaxi.Shared.DTOs;

public record DriverAvailabilityDto(int Id, int UserId, DateTime Date, TimeSpan StartTime, TimeSpan EndTime,
    int AvailabilityType, string? Details, bool GiveOrTake);
