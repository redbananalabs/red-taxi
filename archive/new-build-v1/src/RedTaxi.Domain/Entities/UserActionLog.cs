using System;

namespace RedTaxi.Domain.Entities;

public class UserActionLog
{
    public int Id { get; set; }
    public int UserId { get; set; }
    public string? Action { get; set; }
    public string? Details { get; set; }
    public string? EntityType { get; set; }
    public string? EntityId { get; set; }
    public DateTime TimeStamp { get; set; }
}
