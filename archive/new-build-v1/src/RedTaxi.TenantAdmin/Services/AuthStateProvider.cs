using System.Security.Claims;
using System.Text.Json;
using Microsoft.AspNetCore.Components.Authorization;
using Microsoft.JSInterop;

namespace RedTaxi.TenantAdmin.Services;

public class AuthStateProvider : AuthenticationStateProvider
{
    private readonly IJSRuntime _js;
    private readonly ClaimsPrincipal _anonymous = new(new ClaimsIdentity());

    public AuthStateProvider(IJSRuntime js) => _js = js;

    public override async Task<AuthenticationState> GetAuthenticationStateAsync()
    {
        try
        {
            var token = await _js.InvokeAsync<string>("localStorage.getItem", "auth_token");
            if (string.IsNullOrWhiteSpace(token))
                return new AuthenticationState(_anonymous);

            var claims = ParseClaimsFromJwt(token);
            var identity = new ClaimsIdentity(claims, "jwt");
            return new AuthenticationState(new ClaimsPrincipal(identity));
        }
        catch
        {
            return new AuthenticationState(_anonymous);
        }
    }

    public async Task MarkUserAsAuthenticated(string token)
    {
        await _js.InvokeVoidAsync("localStorage.setItem", "auth_token", token);
        var claims = ParseClaimsFromJwt(token);
        var identity = new ClaimsIdentity(claims, "jwt");
        var user = new ClaimsPrincipal(identity);
        NotifyAuthenticationStateChanged(Task.FromResult(new AuthenticationState(user)));
    }

    public async Task MarkUserAsLoggedOut()
    {
        await _js.InvokeVoidAsync("localStorage.removeItem", "auth_token");
        NotifyAuthenticationStateChanged(Task.FromResult(new AuthenticationState(_anonymous)));
    }

    private static IEnumerable<Claim> ParseClaimsFromJwt(string jwt)
    {
        var claims = new List<Claim>();
        var payload = jwt.Split('.')[1];
        var jsonBytes = ParseBase64WithoutPadding(payload);
        var keyValuePairs = JsonSerializer.Deserialize<Dictionary<string, object>>(jsonBytes);
        if (keyValuePairs is null) return claims;

        foreach (var kvp in keyValuePairs)
        {
            claims.Add(new Claim(kvp.Key, kvp.Value?.ToString() ?? string.Empty));
        }
        return claims;
    }

    private static byte[] ParseBase64WithoutPadding(string base64)
    {
        switch (base64.Length % 4)
        {
            case 2: base64 += "=="; break;
            case 3: base64 += "="; break;
        }
        return Convert.FromBase64String(base64);
    }
}
