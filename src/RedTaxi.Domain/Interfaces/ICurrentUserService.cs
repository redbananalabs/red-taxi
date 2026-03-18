namespace RedTaxi.Domain.Interfaces;

public interface ICurrentUserService
{
    int? UserId { get; }
    string? UserName { get; }
    string? Role { get; }
    Guid? TenantId { get; }
    bool IsAuthenticated { get; }
}
