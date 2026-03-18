using MediatR;
using Microsoft.EntityFrameworkCore;
using RedTaxi.Infrastructure.Persistence;
using RedTaxi.Shared.DTOs;

namespace RedTaxi.Application.Billing.Queries;

public record GetStatementsQuery(int? DriverUserId = null) : IRequest<List<StatementDto>>;

public class GetStatementsQueryHandler : IRequestHandler<GetStatementsQuery, List<StatementDto>>
{
    private readonly TenantDbContext _db;

    public GetStatementsQueryHandler(TenantDbContext db)
    {
        _db = db;
    }

    public async Task<List<StatementDto>> Handle(GetStatementsQuery request, CancellationToken cancellationToken)
    {
        var query = _db.DriverInvoiceStatements.AsQueryable();

        if (request.DriverUserId.HasValue)
            query = query.Where(s => s.UserId == request.DriverUserId.Value);

        var results = await (from s in query
                             join u in _db.UserProfiles on s.UserId equals u.UserId into uj
                             from u in uj.DefaultIfEmpty()
                             orderby s.StatementDate descending
                             select new StatementDto(
                                 s.Id, s.UserId, u != null ? u.FullName : null,
                                 s.StatementDate, s.PeriodStart, s.PeriodEnd,
                                 s.EarningsCash, s.EarningsCard,
                                 s.EarningsAccount, s.EarningsRank,
                                 s.TotalCommission, s.CardFees,
                                 s.TotalExpenses, s.SubTotal, s.NetPayable,
                                 s.JobCount))
            .ToListAsync(cancellationToken);

        return results;
    }
}
