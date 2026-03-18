namespace RedTaxi.Domain.Entities;

public class BookingChangeAudit
{
    public int Id { get; set; }
    public string EntityIdentifier { get; set; } = string.Empty;
    public string? UserFullName { get; set; }
    public DateTime TimeStamp { get; set; }
    public string? PropertyName { get; set; }
    public string? OldValue { get; set; }
    public string? NewValue { get; set; }
    public string? Action { get; set; }
    public string? EntityName { get; set; }
}
