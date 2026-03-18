using System;

namespace RedTaxi.Domain.Entities;

public class DriverInvoiceStatement
{
    public int Id { get; set; }
    public int UserId { get; set; }
    public DateTime StatementDate { get; set; }
    public DateTime PeriodStart { get; set; }
    public DateTime PeriodEnd { get; set; }
    public decimal EarningsCash { get; set; }
    public decimal EarningsCard { get; set; }
    public decimal EarningsAccount { get; set; }
    public decimal EarningsRank { get; set; }
    public decimal TotalCommission { get; set; }
    public decimal CardFees { get; set; }
    public decimal TotalExpenses { get; set; }
    public decimal SubTotal { get; set; }
    public decimal NetPayable { get; set; }
    public int JobCount { get; set; }
    public string? PdfUrl { get; set; }
    public DateTime? EmailSentDate { get; set; }
    public DateTime DateCreated { get; set; }
}
