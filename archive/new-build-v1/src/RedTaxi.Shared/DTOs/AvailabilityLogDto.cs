namespace RedTaxi.Shared.DTOs;

public record AvailabilityLogDto(int Id, DateTime Date, string Description,
    DateTime ChangedOn, string ChangedBy, int DriverUserId);
