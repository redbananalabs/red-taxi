namespace RedTaxi.Domain.Interfaces;

public interface IAuditable
{
    DateTime DateCreated { get; set; }
    DateTime? DateUpdated { get; set; }
}
