using MediatR;
using Microsoft.EntityFrameworkCore;
using RedTaxi.Infrastructure.Persistence;

namespace RedTaxi.Application.Billing.Commands;

public record MarkInvoicePaidCommand(int InvoiceId) : IRequest<bool>;

public class MarkInvoicePaidCommandHandler : IRequestHandler<MarkInvoicePaidCommand, bool>
{
    private readonly TenantDbContext _db;

    public MarkInvoicePaidCommandHandler(TenantDbContext db)
    {
        _db = db;
    }

    public async Task<bool> Handle(MarkInvoicePaidCommand request, CancellationToken cancellationToken)
    {
        var invoice = await _db.AccountInvoices
            .FirstOrDefaultAsync(i => i.Id == request.InvoiceId, cancellationToken);

        if (invoice == null) return false;

        invoice.IsPaid = true;
        invoice.PaidDate = DateTime.UtcNow;
        await _db.SaveChangesAsync(cancellationToken);
        return true;
    }
}
