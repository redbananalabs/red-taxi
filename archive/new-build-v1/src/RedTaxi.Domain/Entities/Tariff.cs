using RedTaxi.Domain.Enums;

namespace RedTaxi.Domain.Entities;

public class Tariff
{
    public int Id { get; set; }
    public TariffType Type { get; set; }
    public string Name { get; set; } = string.Empty;
    public string? Description { get; set; }
    public decimal InitialCharge { get; set; }
    public decimal FirstMileCharge { get; set; }
    public decimal AdditionalMileCharge { get; set; }
    public bool IsActive { get; set; }
}
