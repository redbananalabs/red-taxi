namespace RedTaxi.Domain.Entities;

public class FixedPriceJourney
{
    public int Id { get; set; }
    public string PickupPostcodePrefix { get; set; } = string.Empty;
    public string DestinationPostcodePrefix { get; set; } = string.Empty;
    public decimal Price { get; set; }
    public decimal? PriceAccount { get; set; }
    public string? Description { get; set; }
    public bool IsActive { get; set; }
}
