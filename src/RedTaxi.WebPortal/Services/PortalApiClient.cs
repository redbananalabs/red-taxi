using System.Net.Http.Json;
using RedTaxi.Shared.DTOs;

namespace RedTaxi.WebPortal.Services;

public class PortalApiClient
{
    private readonly HttpClient _http;

    public PortalApiClient(HttpClient http)
    {
        _http = http;
    }

    // Auth
    public async Task<LoginResponse?> LoginAsync(LoginRequest request)
    {
        var response = await _http.PostAsJsonAsync("/api/auth/login", request);
        response.EnsureSuccessStatusCode();
        return await response.Content.ReadFromJsonAsync<LoginResponse>();
    }

    // Web Bookings
    public async Task<List<WebBookingDto>> GetWebBookingsAsync()
    {
        return await _http.GetFromJsonAsync<List<WebBookingDto>>("/api/webbookings") ?? new();
    }

    public async Task<WebBookingDto?> CreateWebBookingAsync(WebBookingCreateRequest request)
    {
        var response = await _http.PostAsJsonAsync("/api/webbookings", request);
        response.EnsureSuccessStatusCode();
        return await response.Content.ReadFromJsonAsync<WebBookingDto>();
    }

    // Active Bookings (account bookings with upcoming pickup)
    public async Task<List<BookingDto>> GetActiveBookingsAsync()
    {
        return await _http.GetFromJsonAsync<List<BookingDto>>("/api/bookings/active") ?? new();
    }

    public async Task<List<BookingDto>> GetBookingHistoryAsync()
    {
        return await _http.GetFromJsonAsync<List<BookingDto>>("/api/bookings/history") ?? new();
    }

    public async Task RequestAmendBookingAsync(int bookingId, BookingAmendRequest request)
    {
        var response = await _http.PutAsJsonAsync($"/api/bookings/{bookingId}/amend", request);
        response.EnsureSuccessStatusCode();
    }

    public async Task RequestCancelBookingAsync(int bookingId)
    {
        var response = await _http.PostAsync($"/api/bookings/{bookingId}/cancel-request", null);
        response.EnsureSuccessStatusCode();
    }

    // Passengers
    public async Task<List<AccountPassengerDto>> GetPassengersAsync()
    {
        return await _http.GetFromJsonAsync<List<AccountPassengerDto>>("/api/account-passengers") ?? new();
    }

    public async Task<AccountPassengerDto?> CreatePassengerAsync(AccountPassengerCreateRequest request)
    {
        var response = await _http.PostAsJsonAsync("/api/account-passengers", request);
        response.EnsureSuccessStatusCode();
        return await response.Content.ReadFromJsonAsync<AccountPassengerDto>();
    }
}

// Request DTOs used only by the portal
public class WebBookingCreateRequest
{
    public string? PassengerName { get; set; }
    public string? PhoneNumber { get; set; }
    public string? Email { get; set; }
    public string PickupAddress { get; set; } = string.Empty;
    public string? PickupPostCode { get; set; }
    public string? DestinationAddress { get; set; }
    public string? DestinationPostCode { get; set; }
    public DateTime PickupDateTime { get; set; }
    public DateTime? ArriveBy { get; set; }
    public string? Details { get; set; }
    public int Passengers { get; set; } = 1;
    public int VehicleType { get; set; }
    public bool IsReturn { get; set; }
    public DateTime? ReturnPickupDateTime { get; set; }
    public int? RecurrenceFrequency { get; set; }
    public string? RecurrenceDays { get; set; }
    public DateTime? RecurrenceEndDate { get; set; }
}

public class BookingAmendRequest
{
    public string? PickupAddress { get; set; }
    public string? DestinationAddress { get; set; }
    public DateTime? PickupDateTime { get; set; }
    public string? Details { get; set; }
}

public class AccountPassengerCreateRequest
{
    public string Name { get; set; } = string.Empty;
    public string? Description { get; set; }
    public string? Address { get; set; }
    public string? PostCode { get; set; }
    public string? Phone { get; set; }
    public string? Email { get; set; }
}
