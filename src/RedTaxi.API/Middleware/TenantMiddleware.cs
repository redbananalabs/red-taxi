using RedTaxi.Domain.Interfaces;

namespace RedTaxi.API.Middleware;

/// <summary>
/// Logs the current tenant slug for every inbound request.
/// No blocking — purely observational context setup.
/// </summary>
public class TenantMiddleware
{
    private readonly RequestDelegate _next;
    private readonly ILogger<TenantMiddleware> _logger;

    public TenantMiddleware(RequestDelegate next, ILogger<TenantMiddleware> logger)
    {
        _next   = next;
        _logger = logger;
    }

    public async Task InvokeAsync(HttpContext context, ITenantConnectionResolver tenantResolver)
    {
        var slug = tenantResolver.GetTenantSlug();
        _logger.LogDebug("Request {Method} {Path} — tenant: {TenantSlug}",
            context.Request.Method,
            context.Request.Path,
            slug);

        await _next(context);
    }
}
