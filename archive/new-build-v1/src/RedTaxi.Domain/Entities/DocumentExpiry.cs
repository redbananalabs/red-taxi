using System;
using RedTaxi.Domain.Enums;

namespace RedTaxi.Domain.Entities;

public class DocumentExpiry
{
    public int Id { get; set; }
    public int UserId { get; set; }
    public DocumentType DocumentType { get; set; }
    public DateTime? ExpiryDate { get; set; }
    public string? DocumentUrl { get; set; }
    public DateTime? UploadedAt { get; set; }
    public string? Notes { get; set; }
}
