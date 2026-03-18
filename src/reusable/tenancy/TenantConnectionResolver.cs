using Microsoft.AspNetCore.Http;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using RedTaxi.Domain.Interfaces;
using RedTaxi.Infrastructure.Persistence;

namespace RedTaxi.Infrastructure.Tenancy;

public class TenantConnectionResolver : ITenantConnectionResolver
{
    private readonly IHttpContextAccessor _httpContextAccessor;
    private readonly IConfiguration _configuration;
    private readonly PlatformDbContext _platformDb;

    public TenantConnectionResolver(
        IHttpContextAccessor httpContextAccessor,
        IConfiguration configuration,
        PlatformDbContext platformDb)
    {
        _httpContextAccessor = httpContextAccessor;
        _configuration = configuration;
        _platformDb = platformDb;
    }

    public string GetConnectionString()
    {
        var slug = GetTenantSlug();
        var template = _configuration.GetConnectionString("TenantTemplate")
            ?? "Server=localhost\\SQLEXPRESS;Database=RedTaxi_{slug};Trusted_Connection=True;TrustServerCertificate=True";
        return template.Replace("{slug}", slug);
    }

    public string GetTenantSlug()
    {
        var httpContext = _httpContextAccessor.HttpContext;

        // Try from JWT claim first
        var slugClaim = httpContext?.User?.FindFirst("tenant_slug")?.Value;
        if (!string.IsNullOrEmpty(slugClaim))
            return slugClaim;

        // Try from header
        var headerSlug = httpContext?.Request.Headers["X-Tenant-Slug"].FirstOrDefault();
        if (!string.IsNullOrEmpty(headerSlug))
            return headerSlug;

        // Default to ace for development
        return "ace";
    }

    public Guid GetTenantId()
    {
        var httpContext = _httpContextAccessor.HttpContext;
        var idClaim = httpContext?.User?.FindFirst("tenant_id")?.Value;
        return idClaim != null ? Guid.Parse(idClaim) : Guid.Empty;
    }
}
