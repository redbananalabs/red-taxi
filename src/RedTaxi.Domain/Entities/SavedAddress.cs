using RedTaxi.Domain.Enums;

namespace RedTaxi.Domain.Entities;

public class SavedAddress
{
    public int Id { get; set; }
    public int? CustomerId { get; set; }
    public string? Label { get; set; }
    public string Address { get; set; } = string.Empty;
    public string? PostCode { get; set; }
    public decimal? Lat { get; set; }
    public decimal? Lng { get; set; }
    public SavedAddressType Type { get; set; }
}
