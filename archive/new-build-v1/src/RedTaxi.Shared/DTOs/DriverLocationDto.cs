namespace RedTaxi.Shared.DTOs;

public record DriverLocationDto(int UserId, decimal Latitude, decimal Longitude, decimal? Heading, decimal? Speed, DateTime TimeStamp);
