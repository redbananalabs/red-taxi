namespace RedTaxi.Domain.Interfaces;

public interface IDistanceMatrixService
{
    Task<(decimal distanceMiles, int durationMinutes)> GetDistanceAsync(string origin, string destination, CancellationToken ct = default);
}
