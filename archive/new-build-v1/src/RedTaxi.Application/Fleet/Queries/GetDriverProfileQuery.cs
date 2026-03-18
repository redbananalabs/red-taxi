using MediatR;
using Microsoft.EntityFrameworkCore;
using RedTaxi.Infrastructure.Persistence;
using RedTaxi.Shared.DTOs;

namespace RedTaxi.Application.Fleet.Queries;

public record GetDriverProfileQuery(int UserId) : IRequest<DriverDto?>;

public class GetDriverProfileQueryHandler : IRequestHandler<GetDriverProfileQuery, DriverDto?>
{
    private readonly TenantDbContext _db;

    public GetDriverProfileQueryHandler(TenantDbContext db)
    {
        _db = db;
    }

    public async Task<DriverDto?> Handle(GetDriverProfileQuery request, CancellationToken cancellationToken)
    {
        var u = await _db.UserProfiles
            .FirstOrDefaultAsync(x => x.UserId == request.UserId, cancellationToken);

        if (u == null) return null;

        return new DriverDto(
            u.Id, u.UserId, u.FullName, u.PhoneNumber,
            u.ColorCodeRGB, u.RegNo,
            (int)u.VehicleType, u.VehicleMake, u.VehicleModel, u.VehicleColour,
            u.IsActive, u.IsSubstitute, u.CommissionRate,
            (int)u.CommsPlatform);
    }
}
