using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using RedTaxi.Infrastructure.ExternalServices;

namespace RedTaxi.API.Controllers;

[ApiController]
[Route("api/address")]
[Authorize]
public class AddressController : ControllerBase
{
    private readonly GooglePlacesService _places;

    public AddressController(GooglePlacesService places)
    {
        _places = places;
    }

    /// <summary>
    /// Returns predictions from Google Places Autocomplete.
    /// </summary>
    [HttpGet("autocomplete")]
    public async Task<ActionResult<List<PlacePrediction>>> Autocomplete(
        [FromQuery] string q,
        CancellationToken ct)
    {
        if (string.IsNullOrWhiteSpace(q))
            return BadRequest("Query parameter 'q' is required.");

        var predictions = await _places.AutocompleteAsync(q, ct);
        return Ok(predictions);
    }

    /// <summary>
    /// Returns formatted address, postcode, lat, lng from Google Places Details.
    /// </summary>
    [HttpGet("details")]
    public async Task<ActionResult<PlaceDetails>> Details(
        [FromQuery] string placeId,
        CancellationToken ct)
    {
        if (string.IsNullOrWhiteSpace(placeId))
            return BadRequest("Query parameter 'placeId' is required.");

        var details = await _places.GetDetailsAsync(placeId, ct);
        return details is null ? NotFound() : Ok(details);
    }
}
