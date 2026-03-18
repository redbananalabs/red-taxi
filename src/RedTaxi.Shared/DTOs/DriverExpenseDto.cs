namespace RedTaxi.Shared.DTOs;

public record DriverExpenseDto(int Id, int DriverId, DateTime Date, string Category,
    string Description, decimal Amount, DateTime DateCreated);
