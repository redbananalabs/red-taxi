using MediatR;
using RedTaxi.Domain.Entities;
using RedTaxi.Domain.Enums;
using RedTaxi.Infrastructure.Persistence;

namespace RedTaxi.Application.Config.Commands;

public record CreateLocalPOICommand(
    string Name,
    string? Address,
    string? PostCode,
    decimal? Latitude,
    decimal? Longitude,
    LocalPOIType Type,
    bool IsActive) : IRequest<int>;

public class CreateLocalPOICommandHandler : IRequestHandler<CreateLocalPOICommand, int>
{
    private readonly TenantDbContext _db;

    public CreateLocalPOICommandHandler(TenantDbContext db) => _db = db;

    public async Task<int> Handle(CreateLocalPOICommand request, CancellationToken cancellationToken)
    {
        var poi = new LocalPOI
        {
            Name = request.Name,
            Address = request.Address,
            PostCode = request.PostCode,
            Latitude = request.Latitude,
            Longitude = request.Longitude,
            Type = request.Type,
            IsActive = request.IsActive,
        };

        _db.LocalPOIs.Add(poi);
        await _db.SaveChangesAsync(cancellationToken);
        return poi.Id;
    }
}
