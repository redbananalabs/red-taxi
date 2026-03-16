# Ideal Postcodes Integration

## Overview

Ideal Postcodes provides UK postcode lookup and address validation. Used as a secondary address provider alongside Google Places, particularly for postcode-based searches.

## Purpose

- UK postcode lookup (faster than Google for postcode searches)
- Address validation and formatting
- Fallback when Google Places unavailable
- Cost-effective for high-volume postcode lookups

## Why Ideal Postcodes?

| Feature | Ideal Postcodes | Google Places |
|---------|-----------------|---------------|
| UK postcode lookup | Optimised | General |
| PAF data | Yes (Royal Mail) | No |
| Per-lookup cost | Lower for postcodes | Higher |
| Session tokens | No | Yes |
| Coordinates | Yes | Yes |

## Integration Flow

### Postcode Lookup

```
User enters "SW1A 1AA"
    → Detected as postcode format
    → API: GET /api/address/postcode-lookup?postcode=SW1A1AA
    → Backend calls Ideal Postcodes
    → Return addresses at postcode
    → User selects address
    → Return full address + lat/lng
```

### Address Autocomplete

```
User types "123 High"
    → API: GET /api/address/autocomplete?q=123+High
    → Backend calls Ideal Postcodes Autocomplete
    → Return suggestions with UDPRN
    → User selects suggestion
    → API: GET /api/address/resolve/udprn/{udprn}
    → Return full address
```

## API Endpoints

### Postcode Lookup

```http
GET /api/address/postcode-lookup?postcode={postcode}
```

**Response:**
```json
{
  "postcode": "SW1A 1AA",
  "addresses": [
    {
      "udprn": "12345678",
      "address": "Buckingham Palace, London SW1A 1AA",
      "line1": "Buckingham Palace",
      "line2": "",
      "line3": "",
      "postTown": "London",
      "postcode": "SW1A 1AA",
      "latitude": 51.5014,
      "longitude": -0.1419
    }
  ]
}
```

### Address Autocomplete

```http
GET /api/address/autocomplete?q={query}
```

**Response:**
```json
{
  "suggestions": [
    {
      "udprn": "12345678",
      "suggestion": "123 High Street, London SW1A 1AA",
      "urls": {
        "udprn": "/v1/udprn/12345678"
      }
    }
  ]
}
```

### Resolve by UDPRN

```http
GET /api/address/resolve/udprn/{udprn}
```

**Response:**
```json
{
  "address": "123 High Street, London SW1A 1AA",
  "line1": "123 High Street",
  "postTown": "London",
  "postcode": "SW1A 1AA",
  "latitude": 51.5014,
  "longitude": -0.1419,
  "county": "Greater London",
  "country": "England"
}
```

## Configuration

### Environment Variables

```
IDEAL_POSTCODES_API_KEY=ak_...
```

### Service Registration

```csharp
services.AddHttpClient<IIdealPostcodesClient, IdealPostcodesClient>(client =>
{
    client.BaseAddress = new Uri("https://api.ideal-postcodes.co.uk/v1/");
});

services.Configure<IdealPostcodesOptions>(options =>
{
    options.ApiKey = configuration["IDEAL_POSTCODES_API_KEY"];
});
```

## Implementation

### Client Interface

```csharp
public interface IIdealPostcodesClient
{
    Task<PostcodeLookupResult> LookupPostcodeAsync(
        string postcode, 
        CancellationToken ct = default);
        
    Task<IEnumerable<AddressSuggestion>> AutocompleteAsync(
        string query, 
        CancellationToken ct = default);
        
    Task<AddressDetails> ResolveUdprnAsync(
        string udprn, 
        CancellationToken ct = default);
}
```

### Implementation

```csharp
public class IdealPostcodesClient : IIdealPostcodesClient
{
    public async Task<PostcodeLookupResult> LookupPostcodeAsync(
        string postcode, CancellationToken ct)
    {
        var cleanPostcode = postcode.Replace(" ", "").ToUpper();
        var url = $"postcodes/{cleanPostcode}?api_key={_options.ApiKey}";
        
        var response = await _client.GetFromJsonAsync<IdealResponse>(url, ct);
        
        return new PostcodeLookupResult
        {
            Postcode = postcode,
            Addresses = response.Result.Select(MapToAddress).ToList()
        };
    }
    
    public async Task<AddressDetails> ResolveUdprnAsync(
        string udprn, CancellationToken ct)
    {
        var url = $"udprn/{udprn}?api_key={_options.ApiKey}";
        
        var response = await _client.GetFromJsonAsync<IdealResponse>(url, ct);
        var result = response.Result;
        
        return new AddressDetails
        {
            Address = FormatAddress(result),
            Postcode = result.Postcode,
            Latitude = result.Latitude,
            Longitude = result.Longitude
        };
    }
}
```

## Postcode Detection

```csharp
public static class PostcodeDetector
{
    // UK postcode regex
    private static readonly Regex PostcodeRegex = new(
        @"^([A-Z]{1,2}\d[A-Z\d]?\s*\d[A-Z]{2})$",
        RegexOptions.IgnoreCase | RegexOptions.Compiled);
    
    public static bool IsPostcode(string input)
    {
        if (string.IsNullOrWhiteSpace(input)) return false;
        return PostcodeRegex.IsMatch(input.Trim());
    }
}
```

## Routing Logic

```csharp
public class AddressSearchService : IAddressSearchService
{
    public async Task<IEnumerable<AddressSuggestion>> SearchAsync(string query)
    {
        // If looks like a postcode, use Ideal Postcodes
        if (PostcodeDetector.IsPostcode(query))
        {
            return await _idealPostcodes.LookupPostcodeAsync(query);
        }
        
        // Otherwise use Google Places
        return await _googlePlaces.AutocompleteAsync(query);
    }
}
```

## UDPRN vs Place ID

| Identifier | Provider | Stability |
|------------|----------|-----------|
| UDPRN | Ideal Postcodes | Permanent (Royal Mail) |
| Place ID | Google | Can change |

UDPRN (Unique Delivery Point Reference Number) is the Royal Mail's permanent identifier for UK addresses.

## Error Handling

| Error | Action |
|-------|--------|
| 4040 (Postcode not found) | Return empty, user refines |
| 4010 (Invalid key) | Alert, check key |
| 4020 (Key exhausted) | Fallback to Google |
| 5xx | Retry with backoff |

## Caching

Postcode lookups cached for 24 hours (addresses rarely change):

```csharp
public async Task<PostcodeLookupResult> LookupWithCacheAsync(string postcode)
{
    var cacheKey = $"postcode:{postcode.Replace(" ", "").ToUpper()}";
    
    var cached = await _cache.GetAsync<PostcodeLookupResult>(cacheKey);
    if (cached != null) return cached;
    
    var result = await _client.LookupPostcodeAsync(postcode);
    await _cache.SetAsync(cacheKey, result, TimeSpan.FromHours(24));
    
    return result;
}
```

## Cost Management

- Postcode lookups: ~£0.02 per lookup
- Bundle pricing available for high volume
- Cache aggressively (postcodes don't change often)
- Use Local POIs before external lookups

## Monitoring

- Track lookups per tenant
- Monitor error rates
- Alert on key exhaustion
- Track cache hit rates

## Related Documents

- [Google Places](google-places.md) - Primary provider
- [Booking System](../features/booking-system.md)
- [Local POIs](../features/local-pois.md)
