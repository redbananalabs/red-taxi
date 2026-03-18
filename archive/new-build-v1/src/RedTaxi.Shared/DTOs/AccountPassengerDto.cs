namespace RedTaxi.Shared.DTOs;

public record AccountPassengerDto(int Id, int AccountId, string Name, string? Description, string? Address,
    string? PostCode, string? Phone, string? Email, bool IsActive);
