using MediatR;
using Microsoft.EntityFrameworkCore;
using RedTaxi.Infrastructure.Persistence;
using RedTaxi.Shared.DTOs;

namespace RedTaxi.Application.Accounts.Queries;

public record GetAccountPassengersQuery(int AccountId) : IRequest<List<AccountPassengerDto>>;

public class GetAccountPassengersQueryHandler : IRequestHandler<GetAccountPassengersQuery, List<AccountPassengerDto>>
{
    private readonly TenantDbContext _db;

    public GetAccountPassengersQueryHandler(TenantDbContext db)
    {
        _db = db;
    }

    public async Task<List<AccountPassengerDto>> Handle(GetAccountPassengersQuery request, CancellationToken cancellationToken)
    {
        return await _db.AccountPassengers
            .Where(p => p.AccountId == request.AccountId)
            .OrderBy(p => p.Name)
            .Select(p => new AccountPassengerDto(
                p.Id, p.AccountId, p.Name,
                p.Description, p.Address, p.PostCode,
                p.Phone, p.Email, p.IsActive))
            .ToListAsync(cancellationToken);
    }
}
