using MediatR;
using Microsoft.EntityFrameworkCore;
using RedTaxi.Infrastructure.Persistence;
using RedTaxi.Shared.DTOs;

namespace RedTaxi.Application.Dispatch.Queries;

public record GetDriverListQuery(bool ActiveOnly = true) : IRequest<List<DriverDto>>;

public class GetDriverListQueryHandler : IRequestHandler<GetDriverListQuery, List<DriverDto>>
{
    private readonly TenantDbContext _db;

    public GetDriverListQueryHandler(TenantDbContext db) => _db = db;

    public async Task<List<DriverDto>> Handle(GetDriverListQuery request, CancellationToken ct)
    {
        var query = _db.UserProfiles.AsNoTracking().AsQueryable();

        if (request.ActiveOnly)
            query = query.Where(u => u.IsActive);

        var drivers = await query
            .OrderBy(u => u.FullName)
            .ToListAsync(ct);

        return drivers.Select(d => new DriverDto(
            d.Id, d.UserId, d.FullName, d.PhoneNumber, d.ColorCodeRGB,
            d.RegNo, (int)d.VehicleType, d.VehicleMake, d.VehicleModel, d.VehicleColour,
            d.IsActive, d.IsSubstitute, d.CommissionRate, (int)d.CommsPlatform
        )).ToList();
    }
}
