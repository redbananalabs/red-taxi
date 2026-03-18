using AceTaxis.DTOs.Address;
using AceTaxis.DTOs.LocalPOI;

namespace AceTaxis.Interfaces
{
    public interface IAddressLookupService
    {
        Task<IReadOnlyList<AddressSuggestion>> SearchAsync(string q, string sessionToken, CancellationToken ct);
        Task<ResolvedAddress> ResolveGooglePlaceAsync(string placeId, string sessionToken, CancellationToken ct);
        Task<ResolvedAddress> ResolvePOIAsync(string id);
        Task<List<AddressSuggestion>> GetPoisForDispatch(string search);
        Task<List<AddressSuggestion>> GetPoisForWebBooker(string search);
        Task<FindAddressResponse> PostcodeLookup(string postcode, string? houseNumber);
        Task<List<AddressSuggestion>> IdealSearchAddress(string query);
        Task<List<DTOs.Address.AddressSuggestion>> IdealPostcodeSearch(string postcode);
        Task<ResolvedAddress> ResolveIdealAddressAsync(string placeId, CancellationToken ct);
    }
}
