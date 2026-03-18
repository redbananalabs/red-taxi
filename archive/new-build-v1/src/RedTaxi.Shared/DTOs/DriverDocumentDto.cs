namespace RedTaxi.Shared.DTOs;

public record DriverDocumentDto(int Id, int DriverId, string TypeCode, string? TypeName,
    string? FileName, DateTime? ExpiryDate, DateTime? UploadedOn);
