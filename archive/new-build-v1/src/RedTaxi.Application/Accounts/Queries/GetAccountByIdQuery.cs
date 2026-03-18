using MediatR;
using Microsoft.EntityFrameworkCore;
using RedTaxi.Infrastructure.Persistence;
using RedTaxi.Shared.DTOs;

namespace RedTaxi.Application.Accounts.Queries;

public record GetAccountByIdQuery(int Id) : IRequest<AccountDto?>;

public class GetAccountByIdQueryHandler : IRequestHandler<GetAccountByIdQuery, AccountDto?>
{
    private readonly TenantDbContext _db;

    public GetAccountByIdQueryHandler(TenantDbContext db)
    {
        _db = db;
    }

    public async Task<AccountDto?> Handle(GetAccountByIdQuery request, CancellationToken cancellationToken)
    {
        var a = await _db.Accounts
            .Include(x => x.AccountTariff)
            .FirstOrDefaultAsync(x => x.Id == request.Id, cancellationToken);

        if (a == null) return null;

        return new AccountDto(
            a.Id, a.AccountNumber, a.CompanyName,
            a.ContactName, a.ContactPhone, a.ContactEmail,
            a.AccountTariffId, a.AccountTariff?.Name,
            a.IsActive);
    }
}
