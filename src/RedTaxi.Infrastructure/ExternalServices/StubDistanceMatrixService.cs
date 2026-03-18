using RedTaxi.Domain.Interfaces;

namespace RedTaxi.Infrastructure.ExternalServices;

/// <summary>
/// Stub implementation of IDistanceMatrixService.
/// Replace with Google Maps or similar provider integration in production.
/// </summary>
public class StubDistanceMatrixService : IDistanceMatrixService
{
    public Task<(decimal distanceMiles, int durationMinutes)> GetDistanceAsync(
        string origin, string destination, CancellationToken ct = default)
    {
        // Stub: return zero — a real implementation would call Google Distance Matrix API
        return Task.FromResult((0m, 0));
    }
}
