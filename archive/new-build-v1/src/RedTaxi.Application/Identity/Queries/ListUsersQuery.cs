using MediatR;
using Microsoft.EntityFrameworkCore;
using RedTaxi.Domain.Enums;
using RedTaxi.Infrastructure.Persistence;
using RedTaxi.Shared.DTOs;

namespace RedTaxi.Application.Identity.Queries;

public record ListUsersQuery(UserRole? RoleFilter = null, bool? ActiveOnly = null) : IRequest<List<UserInfoDto>>;

public class ListUsersQueryHandler : IRequestHandler<ListUsersQuery, List<UserInfoDto>>
{
    private readonly TenantDbContext _db;

    public ListUsersQueryHandler(TenantDbContext db)
    {
        _db = db;
    }

    public async Task<List<UserInfoDto>> Handle(ListUsersQuery request, CancellationToken cancellationToken)
    {
        var query = _db.UserProfiles.AsQueryable();

        if (request.RoleFilter.HasValue)
            query = query.Where(u => u.Role == request.RoleFilter.Value);

        if (request.ActiveOnly == true)
            query = query.Where(u => u.IsActive);

        return await query
            .OrderBy(u => u.FullName)
            .Select(u => new UserInfoDto(u.UserId, u.FullName, u.Email, u.Role.ToString(), null, null))
            .ToListAsync(cancellationToken);
    }
}
