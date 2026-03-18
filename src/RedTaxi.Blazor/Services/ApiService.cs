namespace RedTaxi.Blazor.Services;

using System.Net.Http.Json;
using RedTaxi.Shared.DTOs;

public class ApiService
{
    private readonly HttpClient _http;

    public ApiService(HttpClient http)
    {
        _http = http;
    }

    // ── Bookings ──────────────────────────────────────────────────
    public Task<List<BookingDto>?> GetBookingsAsync(DateTime? date = null, int? status = null)
    {
        var url = "/api/bookings";
        var query = new List<string>();
        if (date.HasValue) query.Add($"date={date.Value:yyyy-MM-dd}");
        if (status.HasValue) query.Add($"status={status.Value}");
        if (query.Count > 0) url += "?" + string.Join("&", query);
        return _http.GetFromJsonAsync<List<BookingDto>>(url);
    }

    public Task<BookingDto?> GetBookingAsync(int id)
        => _http.GetFromJsonAsync<BookingDto>($"/api/bookings/{id}");

    public async Task<BookingDto?> CreateBookingAsync(BookingCreateDto dto)
    {
        var response = await _http.PostAsJsonAsync("/api/bookings", dto);
        response.EnsureSuccessStatusCode();
        return await response.Content.ReadFromJsonAsync<BookingDto>();
    }

    public async Task<BookingDto?> UpdateBookingAsync(int id, BookingUpdateDto dto)
    {
        var response = await _http.PutAsJsonAsync($"/api/bookings/{id}", dto);
        response.EnsureSuccessStatusCode();
        return await response.Content.ReadFromJsonAsync<BookingDto>();
    }

    public Task CancelBookingAsync(int id)
        => _http.PostAsync($"/api/bookings/{id}/cancel", null);

    public Task CompleteBookingAsync(int id)
        => _http.PostAsync($"/api/bookings/{id}/complete", null);

    public async Task<BookingDto?> MergeSchoolRunsAsync(int sourceBookingId, int targetBookingId)
    {
        var response = await _http.PostAsJsonAsync("/api/bookings/merge",
            new { SourceBookingId = sourceBookingId, TargetBookingId = targetBookingId });
        response.EnsureSuccessStatusCode();
        return await response.Content.ReadFromJsonAsync<BookingDto>();
    }

    public async Task<List<BookingDto>?> GenerateBlockBookingsAsync(int parentBookingId)
    {
        var response = await _http.PostAsync($"/api/bookings/{parentBookingId}/generate-block", null);
        response.EnsureSuccessStatusCode();
        return await response.Content.ReadFromJsonAsync<List<BookingDto>>();
    }

    public async Task<BookingDto?> CreateReturnBookingAsync(int originalBookingId, DateTime returnPickupDateTime)
    {
        var response = await _http.PostAsync(
            $"/api/bookings/{originalBookingId}/return?returnPickupDateTime={returnPickupDateTime:o}", null);
        response.EnsureSuccessStatusCode();
        return await response.Content.ReadFromJsonAsync<BookingDto>();
    }

    public async Task<int> AutoCompleteBookingsAsync()
    {
        var response = await _http.PostAsync("/api/bookings/auto-complete", null);
        response.EnsureSuccessStatusCode();
        return await response.Content.ReadFromJsonAsync<int>();
    }

    public async Task<int> CancelBookingRangeAsync(int bookingId, bool cancelAll, DateTime? cancelFromDate)
    {
        var response = await _http.PostAsJsonAsync("/api/bookings/cancel-range",
            new { BookingId = bookingId, CancelAll = cancelAll, CancelFromDate = cancelFromDate });
        response.EnsureSuccessStatusCode();
        return await response.Content.ReadFromJsonAsync<int>();
    }

    // ── Dispatch ──────────────────────────────────────────────────
    public Task AllocateDriverAsync(int bookingId, int driverUserId)
        => _http.PostAsJsonAsync($"/api/dispatch/allocate", new { BookingId = bookingId, DriverUserId = driverUserId });

    public Task SoftAllocateDriverAsync(int bookingId, int driverUserId)
        => _http.PostAsJsonAsync($"/api/dispatch/soft-allocate", new { BookingId = bookingId, DriverUserId = driverUserId });

    public Task UnallocateBookingAsync(int bookingId)
        => _http.PostAsJsonAsync($"/api/dispatch/unallocate", new { BookingId = bookingId });

    // ── Drivers ───────────────────────────────────────────────────
    public Task<List<DriverDto>?> GetDriversAsync()
        => _http.GetFromJsonAsync<List<DriverDto>>("/api/drivers");

    public Task<DriverDto?> GetDriverAsync(int id)
        => _http.GetFromJsonAsync<DriverDto>($"/api/drivers/{id}");

    public Task<List<DriverLocationDto>?> GetDriverLocationsAsync()
        => _http.GetFromJsonAsync<List<DriverLocationDto>>("/api/drivers/locations");

    public Task<List<DriverAvailabilityDto>?> GetDriverAvailabilityAsync(int driverUserId, DateTime date)
        => _http.GetFromJsonAsync<List<DriverAvailabilityDto>>($"/api/drivers/{driverUserId}/availability?date={date:yyyy-MM-dd}");

    // ── Accounts ──────────────────────────────────────────────────
    public Task<List<AccountDto>?> GetAccountsAsync()
        => _http.GetFromJsonAsync<List<AccountDto>>("/api/accounts");

    public Task<AccountDto?> GetAccountAsync(int id)
        => _http.GetFromJsonAsync<AccountDto>($"/api/accounts/{id}");

    // ── Pricing ───────────────────────────────────────────────────
    public async Task<PriceResultDto?> GetPriceAsync(string pickup, string destination, int vehicleType, int? accountNumber = null)
    {
        var url = $"/api/pricing/calculate?pickup={Uri.EscapeDataString(pickup)}&destination={Uri.EscapeDataString(destination)}&vehicleType={vehicleType}";
        if (accountNumber.HasValue) url += $"&accountNumber={accountNumber.Value}";
        return await _http.GetFromJsonAsync<PriceResultDto>(url);
    }

    // ── Dashboard KPIs ────────────────────────────────────────────
    public Task<DashboardKpiDto?> GetDashboardKpisAsync()
        => _http.GetFromJsonAsync<DashboardKpiDto>("/api/dashboard/kpis");

    // ── Phone Lookup (DC18) ────────────────────────────────────────
    public Task<List<BookingDto>?> GetBookingsByPhoneAsync(string phone)
        => _http.GetFromJsonAsync<List<BookingDto>>($"/api/bookings/phone-lookup?phone={Uri.EscapeDataString(phone)}");

    // ── Messaging (DC27/DC28) ──────────────────────────────────────
    public async Task SendMessageAsync(List<int> driverUserIds, string message)
    {
        var response = await _http.PostAsJsonAsync("/api/messaging/send",
            new { DriverUserIds = driverUserIds, Message = message, IsBroadcast = false });
        response.EnsureSuccessStatusCode();
    }

    public async Task SendGlobalMessageAsync(string message)
    {
        var response = await _http.PostAsJsonAsync("/api/messaging/send",
            new { DriverUserIds = (List<int>?)null, Message = message, IsBroadcast = true });
        response.EnsureSuccessStatusCode();
    }

    // ── SMS Heartbeat (DC26) ───────────────────────────────────────
    public async Task<bool> GetSmsHeartbeatAsync()
    {
        try
        {
            var response = await _http.GetFromJsonAsync<SmsHeartbeatResponse>("/api/messaging/heartbeat");
            if (response == null) return false;
            return response.IsHealthy;
        }
        catch
        {
            return false;
        }
    }

    // ── Payment Link (DC34) ────────────────────────────────────────
    public Task SendPaymentLinkAsync(int bookingId)
        => _http.PostAsync($"/api/bookings/{bookingId}/payment-link", null);
}

public record SmsHeartbeatResponse(bool IsHealthy, DateTime? LastHeartbeat);
