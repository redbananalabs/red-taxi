using MediatR;
using Microsoft.EntityFrameworkCore;
using RedTaxi.Application.Identity.Services;
using RedTaxi.Domain.Interfaces;
using RedTaxi.Infrastructure.Persistence;
using RedTaxi.Shared.DTOs;

namespace RedTaxi.Application.Identity.Commands;

public record LoginCommand(string Email, string Password, string? TenantSlug) : IRequest<LoginResponse>;

public class LoginCommandHandler : IRequestHandler<LoginCommand, LoginResponse>
{
    private readonly TenantDbContext _db;
    private readonly PlatformDbContext _platformDb;
    private readonly JwtTokenService _jwt;
    private readonly ITenantConnectionResolver _tenantResolver;

    public LoginCommandHandler(
        TenantDbContext db,
        PlatformDbContext platformDb,
        JwtTokenService jwt,
        ITenantConnectionResolver tenantResolver)
    {
        _db = db;
        _platformDb = platformDb;
        _jwt = jwt;
        _tenantResolver = tenantResolver;
    }

    public async Task<LoginResponse> Handle(LoginCommand request, CancellationToken cancellationToken)
    {
        var user = await _db.UserProfiles
            .FirstOrDefaultAsync(u => u.Email == request.Email, cancellationToken)
            ?? throw new UnauthorizedAccessException("Invalid email or password.");

        if (string.IsNullOrEmpty(user.PasswordHash) ||
            !BCrypt.Net.BCrypt.Verify(request.Password, user.PasswordHash))
        {
            throw new UnauthorizedAccessException("Invalid email or password.");
        }

        if (!user.IsActive)
            throw new UnauthorizedAccessException("Account is disabled.");

        var tenantId = _tenantResolver.GetTenantId();
        var tenantSlug = _tenantResolver.GetTenantSlug();

        var (accessToken, expiresAt) = _jwt.GenerateAccessToken(user, tenantId, tenantSlug);
        var refreshTokenValue = _jwt.GenerateRefreshToken();

        var refreshToken = new Domain.Entities.AppRefreshToken
        {
            UserId = user.UserId,
            Token = refreshTokenValue,
            ExpiresAt = DateTime.UtcNow.AddDays(30),
            CreatedAt = DateTime.UtcNow,
        };

        _db.AppRefreshTokens.Add(refreshToken);

        user.LastLogin = DateTime.UtcNow;
        await _db.SaveChangesAsync(cancellationToken);

        return new LoginResponse(
            accessToken,
            refreshTokenValue,
            expiresAt,
            new UserInfoDto(user.UserId, user.FullName, user.Email, user.Role.ToString(), tenantId, tenantSlug));
    }
}
