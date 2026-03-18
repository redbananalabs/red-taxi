using System.Net.Http.Headers;
using System.Net.Http.Json;
using Microsoft.JSInterop;
using RedTaxi.Shared.DTOs;

namespace RedTaxi.TenantAdmin.Services;

public class AdminApiClient
{
    private readonly HttpClient _http;
    private readonly IJSRuntime _js;

    public AdminApiClient(HttpClient http, IJSRuntime js)
    {
        _http = http;
        _js = js;
    }

    private async Task SetAuthHeader()
    {
        var token = await _js.InvokeAsync<string>("localStorage.getItem", "auth_token");
        if (!string.IsNullOrWhiteSpace(token))
            _http.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("Bearer", token);
    }

    // Auth
    public async Task<LoginResponse?> LoginAsync(LoginRequest request) =>
        await PostAsync<LoginResponse>("api/auth/login", request);

    // Dashboard
    public async Task<DashboardKpiDto?> GetDashboardKpiAsync() =>
        await GetAsync<DashboardKpiDto>("api/dashboard/kpi");

    // Bookings
    public async Task<List<BookingDto>> FindBookingsAsync(string? search = null, int page = 1, int pageSize = 20)
    {
        var url = $"api/bookings/find?page={page}&pageSize={pageSize}";
        if (!string.IsNullOrWhiteSpace(search)) url += $"&search={Uri.EscapeDataString(search)}";
        return await GetAsync<List<BookingDto>>(url) ?? new();
    }

    public async Task<BookingDto?> GetBookingAsync(int id) =>
        await GetAsync<BookingDto>($"api/bookings/{id}");

    public async Task UpdateBookingAsync(BookingUpdateDto dto) =>
        await PutAsync($"api/bookings/{dto.Id}", dto);

    // Accounts
    public async Task<List<AccountDto>> GetAccountsAsync(string? search = null)
    {
        var url = "api/accounts";
        if (!string.IsNullOrWhiteSpace(search)) url += $"?search={Uri.EscapeDataString(search)}";
        return await GetAsync<List<AccountDto>>(url) ?? new();
    }

    public async Task<AccountDto?> GetAccountAsync(int id) =>
        await GetAsync<AccountDto>($"api/accounts/{id}");

    public async Task<List<AccountPassengerDto>> GetAccountPassengersAsync(int accountId) =>
        await GetAsync<List<AccountPassengerDto>>($"api/accounts/{accountId}/passengers") ?? new();

    public async Task UpdateAccountAsync(int id, AccountDto dto) =>
        await PutAsync($"api/accounts/{id}", dto);

    // Drivers
    public async Task<List<DriverDto>> GetDriversAsync() =>
        await GetAsync<List<DriverDto>>("api/drivers") ?? new();

    public async Task<DriverDto?> GetDriverAsync(int id) =>
        await GetAsync<DriverDto>($"api/drivers/{id}");

    public async Task UpdateDriverAsync(int id, DriverDto dto) =>
        await PutAsync($"api/drivers/{id}", dto);

    // Tariffs
    public async Task<List<TariffDto>> GetTariffsAsync() =>
        await GetAsync<List<TariffDto>>("api/tariffs") ?? new();

    public async Task UpdateTariffAsync(int id, TariffDto dto) =>
        await PutAsync($"api/tariffs/{id}", dto);

    // Account Tariffs
    public async Task<List<AccountTariffDto>> GetAccountTariffsAsync() =>
        await GetAsync<List<AccountTariffDto>>("api/account-tariffs") ?? new();

    public async Task UpdateAccountTariffAsync(int id, AccountTariffDto dto) =>
        await PutAsync($"api/account-tariffs/{id}", dto);

    // Statements
    public async Task<List<StatementDto>> GetStatementsAsync() =>
        await GetAsync<List<StatementDto>>("api/statements") ?? new();

    public async Task<List<BookingDto>> GetUninvoicedDriverJobsAsync() =>
        await GetAsync<List<BookingDto>>("api/statements/uninvoiced") ?? new();

    public async Task PostStatementAsync(object request) =>
        await PostAsync("api/statements", request);

    // Invoices
    public async Task<List<InvoiceDto>> GetInvoicesAsync() =>
        await GetAsync<List<InvoiceDto>>("api/invoices") ?? new();

    public async Task<List<BookingDto>> GetUninvoicedAccountJobsAsync(int accountId) =>
        await GetAsync<List<BookingDto>>($"api/invoices/uninvoiced?accountId={accountId}") ?? new();

    public async Task PostInvoiceAsync(object request) =>
        await PostAsync("api/invoices", request);

    // Driver Availability
    public async Task<List<DriverAvailabilityDto>> GetAvailabilityAsync(DateTime? date = null)
    {
        var url = "api/availability";
        if (date.HasValue) url += $"?date={date.Value:yyyy-MM-dd}";
        return await GetAsync<List<DriverAvailabilityDto>>(url) ?? new();
    }

    // Company Config
    public async Task<CompanyConfigDto?> GetConfigAsync() =>
        await GetAsync<CompanyConfigDto>("api/config");

    public async Task UpdateConfigAsync(CompanyConfigDto dto) =>
        await PutAsync("api/config", dto);

    // Messaging Config
    public async Task<List<MessagingConfigDto>> GetMessagingConfigAsync() =>
        await GetAsync<List<MessagingConfigDto>>("api/config/messaging") ?? new();

    public async Task UpdateMessagingConfigAsync(List<MessagingConfigDto> configs) =>
        await PutAsync("api/config/messaging", configs);

    // Generic helpers
    private async Task<T?> GetAsync<T>(string url)
    {
        await SetAuthHeader();
        var resp = await _http.GetAsync(url);
        if (!resp.IsSuccessStatusCode) return default;
        return await resp.Content.ReadFromJsonAsync<T>();
    }

    private async Task<T?> PostAsync<T>(string url, object data)
    {
        await SetAuthHeader();
        var resp = await _http.PostAsJsonAsync(url, data);
        if (!resp.IsSuccessStatusCode) return default;
        return await resp.Content.ReadFromJsonAsync<T>();
    }

    private async Task PostAsync(string url, object data)
    {
        await SetAuthHeader();
        await _http.PostAsJsonAsync(url, data);
    }

    private async Task PutAsync(string url, object data)
    {
        await SetAuthHeader();
        await _http.PutAsJsonAsync(url, data);
    }
}
