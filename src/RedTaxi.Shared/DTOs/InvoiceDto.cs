namespace RedTaxi.Shared.DTOs;

public record InvoiceDto(int Id, int AccountId, int AccountNumber, string? AccountName, int InvoiceNumber,
    DateTime InvoiceDate, DateTime PeriodStart, DateTime PeriodEnd,
    decimal TotalAmount, decimal VatAmount, decimal NetAmount, bool IsPaid, DateTime? PaidDate);
