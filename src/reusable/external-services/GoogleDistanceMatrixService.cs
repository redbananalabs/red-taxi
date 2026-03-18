using System.Text.Json;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;
using RedTaxi.Domain.Interfaces;

namespace RedTaxi.Infrastructure.ExternalServices;

public class GoogleDistanceMatrixService : IDistanceMatrixService
{
    private readonly HttpClient _httpClient;
    private readonly string _apiKey;
    private readonly ILogger<GoogleDistanceMatrixService> _logger;

    public GoogleDistanceMatrixService(IHttpClientFactory httpClientFactory, IConfiguration configuration, ILogger<GoogleDistanceMatrixService> logger)
    {
        _httpClient = httpClientFactory.CreateClient();
        _apiKey = configuration["Google:ApiKey"] ?? "";
        _logger = logger;
    }

    public async Task<(decimal distanceMiles, int durationMinutes)> GetDistanceAsync(string origin, string destination, CancellationToken ct = default)
    {
        if (string.IsNullOrWhiteSpace(_apiKey))
        {
            _logger.LogWarning("Google API key not configured, returning estimate");
            return EstimateFallback(origin, destination);
        }

        try
        {
            var url = $"https://maps.googleapis.com/maps/api/distancematrix/json?origins={Uri.EscapeDataString(origin)}&destinations={Uri.EscapeDataString(destination)}&units=imperial&key={_apiKey}";
            var response = await _httpClient.GetAsync(url, ct);
            response.EnsureSuccessStatusCode();

            var json = await response.Content.ReadAsStringAsync(ct);
            using var doc = JsonDocument.Parse(json);
            var root = doc.RootElement;

            var status = root.GetProperty("status").GetString();
            if (status != "OK")
            {
                _logger.LogWarning("Distance Matrix API returned status: {Status}", status);
                return EstimateFallback(origin, destination);
            }

            var element = root.GetProperty("rows")[0].GetProperty("elements")[0];
            var elementStatus = element.GetProperty("status").GetString();
            if (elementStatus != "OK")
            {
                _logger.LogWarning("Distance Matrix element status: {Status} for {Origin} → {Destination}", elementStatus, origin, destination);
                return EstimateFallback(origin, destination);
            }

            var distanceMeters = element.GetProperty("distance").GetProperty("value").GetDecimal();
            var durationSeconds = element.GetProperty("duration").GetProperty("value").GetInt32();

            var distanceMiles = distanceMeters / 1609.34m;
            var durationMinutes = durationSeconds / 60;

            return (Math.Round(distanceMiles, 1), Math.Max(durationMinutes, 1));
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Distance Matrix API call failed for {Origin} → {Destination}", origin, destination);
            return EstimateFallback(origin, destination);
        }
    }

    private static (decimal distanceMiles, int durationMinutes) EstimateFallback(string origin, string destination)
    {
        // Rough estimate when API unavailable: ~5 miles, ~15 minutes
        return (5.0m, 15);
    }
}
