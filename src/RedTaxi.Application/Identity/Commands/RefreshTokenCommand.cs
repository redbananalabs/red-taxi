using MediatR;
using Microsoft.EntityFrameworkCore;
using RedTaxi.Application.Identity.Services;
using RedTaxi.Domain.Interfaces;
using RedTaxi.Infrastructure.Persistence;
using RedTaxi.Shared.DTOs;

namespace RedTaxi.Application.Identity.Commands;

public record RefreshTokenCommand(string RefreshToken) : IRequest<LoginResponse>;

public class RefreshTokenCommandHandler : IRequestHandler<RefreshTokenCommand, LoginResponse>
{
    private readonly TenantDbContext _db;
    private readonly JwtTokenService _jwt;
    private readonly ITenantConnectionResolver _tenantResolver;

    public RefreshTokenCommandHandler(
        TenantDbContext db,
        JwtTokenService jwt,
        ITenantConnectionResolver tenantResolver)
    {
        _db = db;
        _jwt = jwt;
        _tenantResolver = tenantResolver;
    }

    public async Task<LoginResponse> Handle(RefreshTokenCommand request, CancellationToken cancellationToken)
    {
        var storedToken = await _db.AppRefreshTokens
            .FirstOrDefaultAsync(t => t.Token == request.RefreshToken, cancellationToken)
            ?? throw new UnauthorizedAccessException("Invalid refresh token.");

        if (storedToken.RevokedAt != null)
            throw new UnauthorizedAccessException("Refresh token has been revoked.");

        if (storedToken.ExpiresAt < DateTime.UtcNow)
            throw new UnauthorizedAccessException("Refresh token has expired.");

        // Revoke old token
        storedToken.RevokedAt = DateTime.UtcNow;

        var user = await _db.UserProfiles
            .FirstOrDefaultAsync(u => u.UserId == storedToken.UserId, cancellationToken)
            ?? throw new UnauthorizedAccessException("User not found.");

        var tenantId = _tenantResolver.GetTenantId();
        var tenantSlug = _tenantResolver.GetTenantSlug();

        var (accessToken, expiresAt) = _jwt.GenerateAccessToken(user, tenantId, tenantSlug);
        var newRefreshTokenValue = _jwt.GenerateRefreshToken();

        storedToken.ReplacedByToken = newRefreshTokenValue;

        var newRefreshToken = new Domain.Entities.AppRefreshToken
        {
            UserId = user.UserId,
            Token = newRefreshTokenValue,
            ExpiresAt = DateTime.UtcNow.AddDays(30),
            CreatedAt = DateTime.UtcNow,
        };

        _db.AppRefreshTokens.Add(newRefreshToken);
        await _db.SaveChangesAsync(cancellationToken);

        return new LoginResponse(
            accessToken,
            newRefreshTokenValue,
            expiresAt,
            new UserInfoDto(user.UserId, user.FullName, user.Email, user.Role.ToString(), tenantId, tenantSlug));
    }
}
