namespace RedTaxi.Shared.DTOs;

public record StatementDto(int Id, int UserId, string? DriverName, DateTime StatementDate,
    DateTime PeriodStart, DateTime PeriodEnd,
    decimal EarningsCash, decimal EarningsCard, decimal EarningsAccount, decimal EarningsRank,
    decimal TotalCommission, decimal CardFees, decimal TotalExpenses, decimal SubTotal, decimal NetPayable,
    int JobCount);
