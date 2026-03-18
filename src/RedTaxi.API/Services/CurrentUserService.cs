using System.Security.Claims;
using RedTaxi.Domain.Interfaces;

namespace RedTaxi.API.Services;

/// <summary>
/// Reads the current user's identity from the JWT claims in HttpContext.User.
/// </summary>
public class CurrentUserService : ICurrentUserService
{
    private readonly IHttpContextAccessor _httpContextAccessor;

    public CurrentUserService(IHttpContextAccessor httpContextAccessor)
    {
        _httpContextAccessor = httpContextAccessor;
    }

    private ClaimsPrincipal? User => _httpContextAccessor.HttpContext?.User;

    public int? UserId
    {
        get
        {
            var raw = User?.FindFirstValue(ClaimTypes.NameIdentifier)
                   ?? User?.FindFirstValue("sub");
            return int.TryParse(raw, out var id) ? id : null;
        }
    }

    public string? UserName => User?.FindFirstValue(ClaimTypes.Name)
                            ?? User?.FindFirstValue("name");

    public string? Role => User?.FindFirstValue(ClaimTypes.Role)
                        ?? User?.FindFirstValue("role");

    public Guid? TenantId
    {
        get
        {
            var raw = User?.FindFirstValue("tenant_id");
            return Guid.TryParse(raw, out var id) ? id : null;
        }
    }

    public bool IsAuthenticated => User?.Identity?.IsAuthenticated ?? false;
}
