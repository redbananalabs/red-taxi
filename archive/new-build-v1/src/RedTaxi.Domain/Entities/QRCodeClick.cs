using System;

namespace RedTaxi.Domain.Entities;

public class QRCodeClick
{
    public int Id { get; set; }
    public string? QRCodeId { get; set; }
    public DateTime ClickedAt { get; set; }
    public string? Location { get; set; }
}
