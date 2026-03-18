using MediatR;
using Microsoft.EntityFrameworkCore;
using RedTaxi.Infrastructure.Persistence;

namespace RedTaxi.Application.Config.Commands;

public record DeleteLocalPOICommand(int Id) : IRequest<bool>;

public class DeleteLocalPOICommandHandler : IRequestHandler<DeleteLocalPOICommand, bool>
{
    private readonly TenantDbContext _db;

    public DeleteLocalPOICommandHandler(TenantDbContext db) => _db = db;

    public async Task<bool> Handle(DeleteLocalPOICommand request, CancellationToken cancellationToken)
    {
        var poi = await _db.LocalPOIs.FirstOrDefaultAsync(p => p.Id == request.Id, cancellationToken);
        if (poi == null) return false;

        _db.LocalPOIs.Remove(poi);
        await _db.SaveChangesAsync(cancellationToken);
        return true;
    }
}
