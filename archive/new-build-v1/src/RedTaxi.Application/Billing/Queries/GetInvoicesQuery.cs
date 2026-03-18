using MediatR;
using Microsoft.EntityFrameworkCore;
using RedTaxi.Infrastructure.Persistence;
using RedTaxi.Shared.DTOs;

namespace RedTaxi.Application.Billing.Queries;

public record GetInvoicesQuery(int? AccountNumber = null, bool? UnpaidOnly = null) : IRequest<List<InvoiceDto>>;

public class GetInvoicesQueryHandler : IRequestHandler<GetInvoicesQuery, List<InvoiceDto>>
{
    private readonly TenantDbContext _db;

    public GetInvoicesQueryHandler(TenantDbContext db)
    {
        _db = db;
    }

    public async Task<List<InvoiceDto>> Handle(GetInvoicesQuery request, CancellationToken cancellationToken)
    {
        var query = _db.AccountInvoices.AsQueryable();

        if (request.AccountNumber.HasValue)
            query = query.Where(i => i.AccountNumber == request.AccountNumber.Value);

        if (request.UnpaidOnly == true)
            query = query.Where(i => !i.IsPaid);

        // Join with account for the name
        var results = await (from i in query
                             join a in _db.Accounts on i.AccountId equals a.Id into aj
                             from a in aj.DefaultIfEmpty()
                             orderby i.InvoiceDate descending
                             select new InvoiceDto(
                                 i.Id, i.AccountId, i.AccountNumber,
                                 a != null ? a.CompanyName : null,
                                 i.InvoiceNumber, i.InvoiceDate,
                                 i.PeriodStart, i.PeriodEnd,
                                 i.TotalAmount, i.VatAmount, i.NetAmount,
                                 i.IsPaid, i.PaidDate))
            .ToListAsync(cancellationToken);

        return results;
    }
}
