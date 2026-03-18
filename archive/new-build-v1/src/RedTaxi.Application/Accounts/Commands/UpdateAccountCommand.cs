using MediatR;
using Microsoft.EntityFrameworkCore;
using RedTaxi.Infrastructure.Persistence;
using RedTaxi.Shared.DTOs;

namespace RedTaxi.Application.Accounts.Commands;

public record UpdateAccountCommand(
    int Id,
    string CompanyName,
    string? ContactName,
    string? ContactPhone,
    string? ContactEmail,
    int? AccountTariffId,
    int? BillingCycle,
    bool IsActive) : IRequest<AccountDto>;

public class UpdateAccountCommandHandler : IRequestHandler<UpdateAccountCommand, AccountDto>
{
    private readonly TenantDbContext _db;

    public UpdateAccountCommandHandler(TenantDbContext db)
    {
        _db = db;
    }

    public async Task<AccountDto> Handle(UpdateAccountCommand request, CancellationToken cancellationToken)
    {
        var account = await _db.Accounts
            .FirstOrDefaultAsync(a => a.Id == request.Id, cancellationToken)
            ?? throw new KeyNotFoundException($"Account {request.Id} not found.");

        account.CompanyName = request.CompanyName;
        account.ContactName = request.ContactName;
        account.ContactPhone = request.ContactPhone;
        account.ContactEmail = request.ContactEmail;
        account.AccountTariffId = request.AccountTariffId;
        account.BillingCycle = request.BillingCycle.HasValue
            ? (Domain.Enums.BillingCycle)request.BillingCycle.Value
            : null;
        account.IsActive = request.IsActive;

        await _db.SaveChangesAsync(cancellationToken);

        return new AccountDto(
            account.Id, account.AccountNumber, account.CompanyName,
            account.ContactName, account.ContactPhone, account.ContactEmail,
            account.AccountTariffId, null, account.IsActive);
    }
}
