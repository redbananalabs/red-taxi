using MediatR;
using Microsoft.EntityFrameworkCore;
using RedTaxi.Infrastructure.Persistence;
using RedTaxi.Shared.DTOs;

namespace RedTaxi.Application.Accounts.Queries;

public record GetAccountsQuery(bool? ActiveOnly = null, string? Search = null) : IRequest<List<AccountDto>>;

public class GetAccountsQueryHandler : IRequestHandler<GetAccountsQuery, List<AccountDto>>
{
    private readonly TenantDbContext _db;

    public GetAccountsQueryHandler(TenantDbContext db)
    {
        _db = db;
    }

    public async Task<List<AccountDto>> Handle(GetAccountsQuery request, CancellationToken cancellationToken)
    {
        var query = _db.Accounts.Include(a => a.AccountTariff).AsQueryable();

        if (request.ActiveOnly == true)
            query = query.Where(a => a.IsActive);

        if (!string.IsNullOrWhiteSpace(request.Search))
            query = query.Where(a =>
                a.CompanyName.Contains(request.Search) ||
                (a.ContactName != null && a.ContactName.Contains(request.Search)));

        return await query
            .OrderBy(a => a.CompanyName)
            .Select(a => new AccountDto(
                a.Id, a.AccountNumber, a.CompanyName,
                a.ContactName, a.ContactPhone, a.ContactEmail,
                a.AccountTariffId, a.AccountTariff != null ? a.AccountTariff.Name : null,
                a.IsActive))
            .ToListAsync(cancellationToken);
    }
}
