namespace RedTaxi.Shared.DTOs;

public record LoginRequest(string Email, string Password, string? TenantSlug);
public record LoginResponse(string AccessToken, string RefreshToken, DateTime ExpiresAt, UserInfoDto User);
public record RefreshTokenRequest(string RefreshToken);
public record UserInfoDto(int Id, string? FullName, string? Email, string Role, Guid? TenantId, string? TenantSlug);
