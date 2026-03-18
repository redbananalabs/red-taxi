using MediatR;
using Microsoft.EntityFrameworkCore;
using RedTaxi.Infrastructure.Persistence;
using RedTaxi.Shared.DTOs;

namespace RedTaxi.Application.Fleet.Queries;

public record GetDriverAvailabilityQuery(int UserId, DateTime? From = null, DateTime? To = null)
    : IRequest<List<DriverAvailabilityDto>>;

public class GetDriverAvailabilityQueryHandler
    : IRequestHandler<GetDriverAvailabilityQuery, List<DriverAvailabilityDto>>
{
    private readonly TenantDbContext _db;

    public GetDriverAvailabilityQueryHandler(TenantDbContext db)
    {
        _db = db;
    }

    public async Task<List<DriverAvailabilityDto>> Handle(
        GetDriverAvailabilityQuery request, CancellationToken cancellationToken)
    {
        var query = _db.DriverAvailabilities
            .Where(a => a.UserId == request.UserId);

        if (request.From.HasValue)
            query = query.Where(a => a.Date >= request.From.Value);

        if (request.To.HasValue)
            query = query.Where(a => a.Date <= request.To.Value);

        return await query
            .OrderBy(a => a.Date)
            .ThenBy(a => a.StartTime)
            .Select(a => new DriverAvailabilityDto(
                a.Id, a.UserId, a.Date, a.StartTime, a.EndTime,
                (int)a.AvailabilityType, a.Details, a.GiveOrTake))
            .ToListAsync(cancellationToken);
    }
}
