using System;

namespace RedTaxi.Domain.Entities;

public class DriverMessage
{
    public int Id { get; set; }
    public int? UserId { get; set; }
    public string Message { get; set; } = string.Empty;
    public bool Read { get; set; }
    public DateTime DateCreated { get; set; }
}
