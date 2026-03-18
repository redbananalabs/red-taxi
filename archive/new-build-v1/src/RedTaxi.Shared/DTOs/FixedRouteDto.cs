namespace RedTaxi.Shared.DTOs;

public record FixedRouteDto(int Id, string PickupPostcodePrefix, string DestinationPostcodePrefix,
    decimal Price, decimal AccountPrice, string Description, bool IsActive);
