using System.Net.Http.Json;
using System.Text.Json;
using System.Text.Json.Serialization;
using Microsoft.Extensions.Configuration;

namespace RedTaxi.Infrastructure.ExternalServices;

public class GooglePlacesService
{
    private readonly HttpClient _httpClient;
    private readonly string _apiKey;

    private static readonly JsonSerializerOptions JsonOptions = new()
    {
        PropertyNameCaseInsensitive = true,
    };

    public GooglePlacesService(IHttpClientFactory httpClientFactory, IConfiguration configuration)
    {
        _httpClient = httpClientFactory.CreateClient();
        _apiKey = configuration["Google:ApiKey"] ?? "";
    }

    public async Task<List<PlacePrediction>> AutocompleteAsync(string query, CancellationToken ct = default)
    {
        if (string.IsNullOrWhiteSpace(query))
            return [];

        var url = $"https://maps.googleapis.com/maps/api/place/autocomplete/json"
                + $"?input={Uri.EscapeDataString(query)}"
                + $"&components=country:gb"
                + $"&key={_apiKey}";

        var response = await _httpClient.GetFromJsonAsync<AutocompleteResponse>(url, JsonOptions, ct);

        if (response?.Predictions is null)
            return [];

        return response.Predictions.Select(p => new PlacePrediction(
            p.PlaceId,
            p.Description,
            p.StructuredFormatting?.MainText ?? p.Description,
            p.StructuredFormatting?.SecondaryText ?? ""
        )).ToList();
    }

    public async Task<PlaceDetails?> GetDetailsAsync(string placeId, CancellationToken ct = default)
    {
        if (string.IsNullOrWhiteSpace(placeId))
            return null;

        var url = $"https://maps.googleapis.com/maps/api/place/details/json"
                + $"?place_id={Uri.EscapeDataString(placeId)}"
                + $"&fields=formatted_address,geometry,address_components"
                + $"&key={_apiKey}";

        var response = await _httpClient.GetFromJsonAsync<DetailsResponse>(url, JsonOptions, ct);

        if (response?.Result is null)
            return null;

        var result = response.Result;
        var postCode = result.AddressComponents?
            .FirstOrDefault(c => c.Types?.Contains("postal_code") == true)?
            .LongName;

        var lat = result.Geometry?.Location?.Lat ?? 0m;
        var lng = result.Geometry?.Location?.Lng ?? 0m;

        return new PlaceDetails(result.FormattedAddress ?? "", postCode, lat, lng);
    }

    // --- Internal DTOs for Google API deserialization ---

    private sealed class AutocompleteResponse
    {
        public List<PredictionItem>? Predictions { get; set; }
    }

    private sealed class PredictionItem
    {
        [JsonPropertyName("place_id")]
        public string PlaceId { get; set; } = "";
        public string Description { get; set; } = "";
        [JsonPropertyName("structured_formatting")]
        public StructuredFormattingItem? StructuredFormatting { get; set; }
    }

    private sealed class StructuredFormattingItem
    {
        [JsonPropertyName("main_text")]
        public string? MainText { get; set; }
        [JsonPropertyName("secondary_text")]
        public string? SecondaryText { get; set; }
    }

    private sealed class DetailsResponse
    {
        public DetailsResult? Result { get; set; }
    }

    private sealed class DetailsResult
    {
        [JsonPropertyName("formatted_address")]
        public string? FormattedAddress { get; set; }
        public GeometryItem? Geometry { get; set; }
        [JsonPropertyName("address_components")]
        public List<AddressComponentItem>? AddressComponents { get; set; }
    }

    private sealed class GeometryItem
    {
        public LocationItem? Location { get; set; }
    }

    private sealed class LocationItem
    {
        public decimal Lat { get; set; }
        public decimal Lng { get; set; }
    }

    private sealed class AddressComponentItem
    {
        [JsonPropertyName("long_name")]
        public string? LongName { get; set; }
        public List<string>? Types { get; set; }
    }
}

public record PlacePrediction(string PlaceId, string Description, string MainText, string SecondaryText);
public record PlaceDetails(string FormattedAddress, string? PostCode, decimal Lat, decimal Lng);
