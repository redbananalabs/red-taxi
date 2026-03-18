using MediatR;
using Microsoft.EntityFrameworkCore;
using RedTaxi.Domain.Entities;
using RedTaxi.Domain.Interfaces;
using RedTaxi.Infrastructure.Persistence;

namespace RedTaxi.Application.Billing.Commands;

public record CreateCreditNoteCommand(
    int AccountInvoiceId,
    decimal Amount,
    string? Reason) : IRequest<int>;

public class CreateCreditNoteCommandHandler : IRequestHandler<CreateCreditNoteCommand, int>
{
    private readonly TenantDbContext _db;
    private readonly ICurrentUserService _currentUser;

    public CreateCreditNoteCommandHandler(TenantDbContext db, ICurrentUserService currentUser)
    {
        _db = db;
        _currentUser = currentUser;
    }

    public async Task<int> Handle(CreateCreditNoteCommand request, CancellationToken cancellationToken)
    {
        var invoice = await _db.AccountInvoices
            .FirstOrDefaultAsync(i => i.Id == request.AccountInvoiceId, cancellationToken)
            ?? throw new KeyNotFoundException($"Invoice {request.AccountInvoiceId} not found.");

        var creditNote = new CreditNote
        {
            AccountInvoiceId = request.AccountInvoiceId,
            Amount = request.Amount,
            Reason = request.Reason,
            CreatedAt = DateTime.UtcNow,
            CreatedByName = _currentUser.UserName,
        };

        _db.CreditNotes.Add(creditNote);
        await _db.SaveChangesAsync(cancellationToken);

        return creditNote.Id;
    }
}
