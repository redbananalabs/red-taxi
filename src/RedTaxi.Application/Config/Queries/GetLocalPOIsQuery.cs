using MediatR;
using Microsoft.EntityFrameworkCore;
using RedTaxi.Infrastructure.Persistence;

namespace RedTaxi.Application.Config.Queries;

public record LocalPOIDto(
    int Id,
    string Name,
    string? Address,
    string? PostCode,
    decimal? Latitude,
    decimal? Longitude,
    int Type,
    bool IsActive);

public record GetLocalPOIsQuery : IRequest<List<LocalPOIDto>>;

public class GetLocalPOIsQueryHandler : IRequestHandler<GetLocalPOIsQuery, List<LocalPOIDto>>
{
    private readonly TenantDbContext _db;

    public GetLocalPOIsQueryHandler(TenantDbContext db) => _db = db;

    public async Task<List<LocalPOIDto>> Handle(GetLocalPOIsQuery request, CancellationToken cancellationToken)
    {
        return await _db.LocalPOIs
            .OrderBy(p => p.Name)
            .Select(p => new LocalPOIDto(
                p.Id, p.Name, p.Address, p.PostCode,
                p.Latitude, p.Longitude, (int)p.Type, p.IsActive))
            .ToListAsync(cancellationToken);
    }
}
