using MediatR;
using Microsoft.EntityFrameworkCore;
using RedTaxi.Infrastructure.Persistence;

namespace RedTaxi.Application.Accounts.Commands;

public record DeleteAccountPassengerCommand(int Id) : IRequest<bool>;

public class DeleteAccountPassengerCommandHandler : IRequestHandler<DeleteAccountPassengerCommand, bool>
{
    private readonly TenantDbContext _db;

    public DeleteAccountPassengerCommandHandler(TenantDbContext db)
    {
        _db = db;
    }

    public async Task<bool> Handle(DeleteAccountPassengerCommand request, CancellationToken cancellationToken)
    {
        var passenger = await _db.AccountPassengers
            .FirstOrDefaultAsync(p => p.Id == request.Id, cancellationToken);

        if (passenger == null) return false;

        // Soft-delete: mark inactive
        passenger.IsActive = false;
        await _db.SaveChangesAsync(cancellationToken);
        return true;
    }
}
