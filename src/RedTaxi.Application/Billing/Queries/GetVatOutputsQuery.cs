using MediatR;
using Microsoft.EntityFrameworkCore;
using RedTaxi.Infrastructure.Persistence;

namespace RedTaxi.Application.Billing.Queries;

public record VatOutputDto(
    DateTime PeriodStart,
    DateTime PeriodEnd,
    decimal TotalNet,
    decimal TotalVat,
    decimal TotalGross,
    int InvoiceCount);

public record GetVatOutputsQuery(DateTime From, DateTime To) : IRequest<VatOutputDto>;

public class GetVatOutputsQueryHandler : IRequestHandler<GetVatOutputsQuery, VatOutputDto>
{
    private readonly TenantDbContext _db;

    public GetVatOutputsQueryHandler(TenantDbContext db)
    {
        _db = db;
    }

    public async Task<VatOutputDto> Handle(GetVatOutputsQuery request, CancellationToken cancellationToken)
    {
        var invoices = await _db.AccountInvoices
            .Where(i => i.InvoiceDate >= request.From && i.InvoiceDate <= request.To)
            .ToListAsync(cancellationToken);

        return new VatOutputDto(
            request.From,
            request.To,
            invoices.Sum(i => i.NetAmount),
            invoices.Sum(i => i.VatAmount),
            invoices.Sum(i => i.TotalAmount),
            invoices.Count);
    }
}
