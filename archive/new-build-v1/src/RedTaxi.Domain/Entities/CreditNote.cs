namespace RedTaxi.Domain.Entities;

public class CreditNote
{
    public int Id { get; set; }
    public int AccountInvoiceId { get; set; }
    public decimal Amount { get; set; }
    public string? Reason { get; set; }
    public DateTime CreatedAt { get; set; }
    public string? CreatedByName { get; set; }
}
