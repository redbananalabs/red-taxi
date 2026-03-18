using System;

namespace RedTaxi.Domain.Entities;

public class UINotification
{
    public int Id { get; set; }
    public int? UserId { get; set; }
    public string? Title { get; set; }
    public string? Message { get; set; }
    public bool IsRead { get; set; }
    public string? NavigationType { get; set; }
    public string? NavigationId { get; set; }
    public DateTime DateCreated { get; set; }
}
