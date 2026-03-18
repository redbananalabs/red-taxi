using System;
using RedTaxi.Domain.Enums;

namespace RedTaxi.Domain.Entities;

public class DriverExpense
{
    public int Id { get; set; }
    public int UserId { get; set; }
    public ExpenseCategory Category { get; set; }
    public string? Description { get; set; }
    public decimal Amount { get; set; }
    public DateTime Date { get; set; }
    public string? ReceiptUrl { get; set; }
    public DateTime DateCreated { get; set; }
}
