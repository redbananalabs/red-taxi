# Google Places Integration

## Overview

Google Places API provides address autocomplete, place details, and geocoding for the Red Taxi platform. This is the primary address lookup provider.

## Purpose

- Address autocomplete as users type
- Full address resolution with lat/lng
- Place details (name, formatted address, coordinates)
- UK-biased results for taxi operations

## API Services Used

| Service | Purpose | Billing |
|---------|---------|---------|
| Places Autocomplete | Suggest addresses as user types | Per request |
| Place Details | Get full address + coordinates | Per request |
| Geocoding | Convert address to lat/lng | Per request |

## Integration Flow

### Address Autocomplete

```
User types "123 High St" 
    → Frontend debounces (300ms)
    → API: GET /api/address/search?q=123+High+St
    → Backend calls Places Autocomplete
    → Return suggestions with place_id
    → User selects suggestion
    → API: GET /api/address/resolve/{place_id}
    → Backend calls Place Details
    → Return full address + lat/lng
```

### Sequence Diagram

```
┌────────┐     ┌─────────┐     ┌───────────────┐
│ Client │     │ Red API │     │ Google Places │
└───┬────┘     └────┬────┘     └──────┬────────┘
    │               │                  │
    │ search?q=...  │                  │
    │──────────────>│                  │
    │               │ autocomplete     │
    │               │─────────────────>│
    │               │                  │
    │               │ suggestions      │
    │               │<─────────────────│
    │ suggestions   │                  │
    │<──────────────│                  │
    │               │                  │
    │ resolve/{id}  │                  │
    │──────────────>│                  │
    │               │ place details    │
    │               │─────────────────>│
    │               │                  │
    │               │ full details     │
    │               │<─────────────────│
    │ address+coord │                  │
    │<──────────────│                  │
```

## API Endpoints

### Address Search

```http
GET /api/address/search?q={query}&sessionToken={token}
```

**Response:**
```json
{
  "suggestions": [
    {
      "placeId": "ChIJ...",
      "description": "123 High Street, London SW1A 1AA",
      "mainText": "123 High Street",
      "secondaryText": "London SW1A 1AA"
    }
  ]
}
```

### Address Resolve

```http
GET /api/address/resolve?placeId={placeId}&sessionToken={token}
```

**Response:**
```json
{
  "address": "123 High Street, London SW1A 1AA",
  "postcode": "SW1A 1AA",
  "latitude": 51.5014,
  "longitude": -0.1419,
  "components": {
    "streetNumber": "123",
    "route": "High Street",
    "locality": "London",
    "postalCode": "SW1A 1AA"
  }
}
```

## Configuration

### Environment Variables

```
GOOGLE_PLACES_API_KEY=AIza...
GOOGLE_PLACES_REGION=uk
```

### Service Registration

```csharp
services.AddHttpClient<IGooglePlacesClient, GooglePlacesClient>(client =>
{
    client.BaseAddress = new Uri("https://maps.googleapis.com/maps/api/");
});

services.Configure<GooglePlacesOptions>(options =>
{
    options.ApiKey = configuration["GOOGLE_PLACES_API_KEY"];
    options.Region = "uk";
    options.Language = "en-GB";
});
```

## Implementation

### Client Interface

```csharp
public interface IAddressSearchService
{
    Task<IEnumerable<AddressSuggestion>> SearchAsync(
        string query, 
        string sessionToken,
        CancellationToken ct = default);
        
    Task<AddressDetails> ResolveAsync(
        string placeId, 
        string sessionToken,
        CancellationToken ct = default);
}
```

### Google Places Client

```csharp
public class GooglePlacesClient : IAddressSearchService
{
    public async Task<IEnumerable<AddressSuggestion>> SearchAsync(
        string query, string sessionToken, CancellationToken ct)
    {
        var url = $"place/autocomplete/json" +
            $"?input={Uri.EscapeDataString(query)}" +
            $"&key={_options.ApiKey}" +
            $"&components=country:gb" +
            $"&sessiontoken={sessionToken}";
            
        var response = await _client.GetFromJsonAsync<AutocompleteResponse>(url, ct);
        
        return response.Predictions.Select(p => new AddressSuggestion
        {
            PlaceId = p.PlaceId,
            Description = p.Description,
            MainText = p.StructuredFormatting.MainText,
            SecondaryText = p.StructuredFormatting.SecondaryText
        });
    }
    
    public async Task<AddressDetails> ResolveAsync(
        string placeId, string sessionToken, CancellationToken ct)
    {
        var url = $"place/details/json" +
            $"?place_id={placeId}" +
            $"&key={_options.ApiKey}" +
            $"&fields=formatted_address,geometry,address_components" +
            $"&sessiontoken={sessionToken}";
            
        var response = await _client.GetFromJsonAsync<PlaceDetailsResponse>(url, ct);
        var result = response.Result;
        
        return new AddressDetails
        {
            Address = result.FormattedAddress,
            Postcode = ExtractPostcode(result.AddressComponents),
            Latitude = result.Geometry.Location.Lat,
            Longitude = result.Geometry.Location.Lng
        };
    }
}
```

## Session Tokens

Google Places uses session tokens to group autocomplete requests with the final place details request for billing purposes.

```csharp
// Generate on client, pass through all related requests
var sessionToken = Guid.NewGuid().ToString();

// Use same token for search and resolve
await _addressService.SearchAsync(query, sessionToken);
await _addressService.ResolveAsync(placeId, sessionToken);
```

## UK Biasing

Results are biased to UK addresses:
- `components=country:gb` restricts to UK
- `region=uk` biases ranking
- `language=en-GB` for British formatting

## Cost Optimisation

| Technique | Savings |
|-----------|---------|
| Session tokens | Groups requests into single billing session |
| Debouncing | Reduces autocomplete calls |
| Caching POIs | Local POI lookup before Google |
| Fields parameter | Only request needed fields |

### Request Fields

Only request necessary fields to reduce cost:
```
fields=formatted_address,geometry,address_components
```

## Fallback Strategy

If Google Places fails:
1. Log error with correlation ID
2. Try Ideal Postcodes (if postcode provided)
3. Return error to user if both fail

```csharp
public async Task<AddressDetails> ResolveWithFallbackAsync(string placeId)
{
    try
    {
        return await _googlePlaces.ResolveAsync(placeId);
    }
    catch (Exception ex)
    {
        _logger.LogWarning(ex, "Google Places failed, trying fallback");
        
        // If we have a postcode, try Ideal Postcodes
        if (TryExtractPostcode(placeId, out var postcode))
        {
            return await _idealPostcodes.LookupAsync(postcode);
        }
        
        throw;
    }
}
```

## Error Handling

| Error | Action |
|-------|--------|
| ZERO_RESULTS | Return empty, user refines search |
| OVER_QUERY_LIMIT | Retry with backoff, alert if persistent |
| REQUEST_DENIED | Check API key, alert |
| INVALID_REQUEST | Log and return error |

## Monitoring

- Track request counts by tenant
- Alert on error rate > 1%
- Monitor latency (target < 500ms)
- Track monthly spend vs budget

## Related Documents

- [Ideal Postcodes](ideal-postcodes.md) - Fallback provider
- [Booking System](../features/booking-system.md)
- [API - Address](../api/address-api.md)
