namespace RedTaxi.Domain.Entities;

public class AccountInvoice
{
    public int Id { get; set; }
    public int AccountId { get; set; }
    public int AccountNumber { get; set; }
    public int InvoiceNumber { get; set; }
    public DateTime InvoiceDate { get; set; }
    public DateTime PeriodStart { get; set; }
    public DateTime PeriodEnd { get; set; }
    public decimal TotalAmount { get; set; }
    public decimal VatAmount { get; set; }
    public decimal NetAmount { get; set; }
    public bool IsPaid { get; set; }
    public DateTime? PaidDate { get; set; }
    public string? PdfUrl { get; set; }
    public DateTime? EmailSentDate { get; set; }
    public DateTime DateCreated { get; set; }
}
