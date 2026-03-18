using MediatR;
using Microsoft.EntityFrameworkCore;
using RedTaxi.Domain.Enums;
using RedTaxi.Infrastructure.Persistence;

namespace RedTaxi.Application.Config.Commands;

public record UpdateLocalPOICommand(
    int Id,
    string Name,
    string? Address,
    string? PostCode,
    decimal? Latitude,
    decimal? Longitude,
    LocalPOIType Type,
    bool IsActive) : IRequest<bool>;

public class UpdateLocalPOICommandHandler : IRequestHandler<UpdateLocalPOICommand, bool>
{
    private readonly TenantDbContext _db;

    public UpdateLocalPOICommandHandler(TenantDbContext db) => _db = db;

    public async Task<bool> Handle(UpdateLocalPOICommand request, CancellationToken cancellationToken)
    {
        var poi = await _db.LocalPOIs.FirstOrDefaultAsync(p => p.Id == request.Id, cancellationToken)
            ?? throw new KeyNotFoundException($"LocalPOI {request.Id} not found.");

        poi.Name = request.Name;
        poi.Address = request.Address;
        poi.PostCode = request.PostCode;
        poi.Latitude = request.Latitude;
        poi.Longitude = request.Longitude;
        poi.Type = request.Type;
        poi.IsActive = request.IsActive;

        await _db.SaveChangesAsync(cancellationToken);
        return true;
    }
}
