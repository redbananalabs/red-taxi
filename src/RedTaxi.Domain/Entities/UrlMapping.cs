namespace RedTaxi.Domain.Entities;

public class UrlMapping
{
    public int Id { get; set; }
    public string LongUrl { get; set; } = string.Empty;
    public string ShortCode { get; set; } = string.Empty;
    public int Clicks { get; set; }
}
