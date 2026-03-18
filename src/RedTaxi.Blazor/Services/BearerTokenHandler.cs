using System.Net.Http.Headers;
using System.Net.Http.Json;
using RedTaxi.Shared.DTOs;

namespace RedTaxi.Blazor.Services;

/// <summary>
/// DelegatingHandler that auto-authenticates with the API using service credentials
/// and attaches the Bearer token to every outgoing request.
/// For Blazor Server — token stored in memory, auto-refreshes on 401.
/// </summary>
public class BearerTokenHandler : DelegatingHandler
{
    private readonly IConfiguration _config;
    private readonly ILogger<BearerTokenHandler> _logger;
    private string? _accessToken;
    private DateTime _tokenExpiry = DateTime.MinValue;
    private readonly SemaphoreSlim _authLock = new(1, 1);

    public BearerTokenHandler(IConfiguration config, ILogger<BearerTokenHandler> logger)
    {
        _config = config;
        _logger = logger;
    }

    protected override async Task<HttpResponseMessage> SendAsync(
        HttpRequestMessage request, CancellationToken cancellationToken)
    {
        await EnsureTokenAsync(cancellationToken);

        if (!string.IsNullOrEmpty(_accessToken))
        {
            request.Headers.Authorization = new AuthenticationHeaderValue("Bearer", _accessToken);
        }

        request.Headers.TryAddWithoutValidation("X-Tenant-Slug",
            _config["Dispatch:TenantSlug"] ?? "ace");

        var response = await base.SendAsync(request, cancellationToken);

        // On 401, clear token and retry once
        if (response.StatusCode == System.Net.HttpStatusCode.Unauthorized && _accessToken != null)
        {
            _accessToken = null;
            _tokenExpiry = DateTime.MinValue;

            await EnsureTokenAsync(cancellationToken);
            if (!string.IsNullOrEmpty(_accessToken))
            {
                // Clone the request with new token
                var retry = await CloneRequestAsync(request);
                retry.Headers.Authorization = new AuthenticationHeaderValue("Bearer", _accessToken);
                response = await base.SendAsync(retry, cancellationToken);
            }
        }

        return response;
    }

    private async Task EnsureTokenAsync(CancellationToken ct)
    {
        if (!string.IsNullOrEmpty(_accessToken) && DateTime.UtcNow < _tokenExpiry.AddMinutes(-1))
            return;

        await _authLock.WaitAsync(ct);
        try
        {
            // Double-check after acquiring lock
            if (!string.IsNullOrEmpty(_accessToken) && DateTime.UtcNow < _tokenExpiry.AddMinutes(-1))
                return;

            var email = _config["Dispatch:ServiceEmail"] ?? "admin@ace.test";
            var password = _config["Dispatch:ServicePassword"] ?? "Test123!";
            var tenantSlug = _config["Dispatch:TenantSlug"] ?? "ace";

            var loginRequest = new
            {
                email,
                password,
                tenantSlug
            };

            var baseUrl = _config["ApiBaseUrl"] ?? "https://localhost:5001";

            using var loginClient = new HttpClient(new HttpClientHandler
            {
                ServerCertificateCustomValidationCallback = (_, _, _, _) => true
            })
            {
                BaseAddress = new Uri(baseUrl)
            };

            loginClient.DefaultRequestHeaders.Add("X-Tenant-Slug", tenantSlug);

            var response = await loginClient.PostAsJsonAsync("/api/auth/login", loginRequest, ct);

            if (response.IsSuccessStatusCode)
            {
                var loginResponse = await response.Content.ReadFromJsonAsync<LoginResponse>(cancellationToken: ct);
                if (loginResponse != null)
                {
                    _accessToken = loginResponse.AccessToken;
                    _tokenExpiry = loginResponse.ExpiresAt;
                    _logger.LogInformation("Dispatch console authenticated as {Email}", email);
                }
            }
            else
            {
                _logger.LogWarning("Dispatch console login failed: {Status}", response.StatusCode);
            }
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Failed to authenticate dispatch console");
        }
        finally
        {
            _authLock.Release();
        }
    }

    private static async Task<HttpRequestMessage> CloneRequestAsync(HttpRequestMessage original)
    {
        var clone = new HttpRequestMessage(original.Method, original.RequestUri);
        if (original.Content != null)
        {
            var content = await original.Content.ReadAsByteArrayAsync();
            clone.Content = new ByteArrayContent(content);
            if (original.Content.Headers.ContentType != null)
                clone.Content.Headers.ContentType = original.Content.Headers.ContentType;
        }

        foreach (var header in original.Headers)
        {
            clone.Headers.TryAddWithoutValidation(header.Key, header.Value);
        }

        return clone;
    }
}
