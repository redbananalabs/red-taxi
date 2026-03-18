using MediatR;
using Microsoft.EntityFrameworkCore;
using RedTaxi.Infrastructure.Persistence;
using RedTaxi.Shared.DTOs;

namespace RedTaxi.Application.Identity.Queries;

public record GetUserQuery(int UserId) : IRequest<UserInfoDto?>;

public class GetUserQueryHandler : IRequestHandler<GetUserQuery, UserInfoDto?>
{
    private readonly TenantDbContext _db;

    public GetUserQueryHandler(TenantDbContext db)
    {
        _db = db;
    }

    public async Task<UserInfoDto?> Handle(GetUserQuery request, CancellationToken cancellationToken)
    {
        var user = await _db.UserProfiles
            .FirstOrDefaultAsync(u => u.UserId == request.UserId, cancellationToken);

        if (user == null) return null;

        return new UserInfoDto(user.UserId, user.FullName, user.Email, user.Role.ToString(), null, null);
    }
}
