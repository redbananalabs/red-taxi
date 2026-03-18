using FluentValidation;
using MediatR;
using Microsoft.EntityFrameworkCore;
using RedTaxi.Domain.Entities;
using RedTaxi.Infrastructure.Persistence;
using RedTaxi.Shared.DTOs;

namespace RedTaxi.Application.Accounts.Commands;

public record CreateAccountCommand(
    string CompanyName,
    string? ContactName,
    string? ContactPhone,
    string? ContactEmail,
    int? AccountTariffId,
    int? BillingCycle) : IRequest<AccountDto>;

public class CreateAccountCommandValidator : AbstractValidator<CreateAccountCommand>
{
    public CreateAccountCommandValidator()
    {
        RuleFor(x => x.CompanyName).NotEmpty().MaximumLength(250);
        RuleFor(x => x.ContactEmail).EmailAddress().When(x => !string.IsNullOrEmpty(x.ContactEmail));
    }
}

public class CreateAccountCommandHandler : IRequestHandler<CreateAccountCommand, AccountDto>
{
    private readonly TenantDbContext _db;

    public CreateAccountCommandHandler(TenantDbContext db)
    {
        _db = db;
    }

    public async Task<AccountDto> Handle(CreateAccountCommand request, CancellationToken cancellationToken)
    {
        var maxAccountNumber = await _db.Accounts
            .MaxAsync(a => (int?)a.AccountNumber, cancellationToken) ?? 0;

        var account = new Account
        {
            AccountNumber = maxAccountNumber + 1,
            CompanyName = request.CompanyName,
            ContactName = request.ContactName,
            ContactPhone = request.ContactPhone,
            ContactEmail = request.ContactEmail,
            AccountTariffId = request.AccountTariffId,
            BillingCycle = request.BillingCycle.HasValue
                ? (Domain.Enums.BillingCycle)request.BillingCycle.Value
                : null,
            IsActive = true,
        };

        _db.Accounts.Add(account);
        await _db.SaveChangesAsync(cancellationToken);

        return new AccountDto(
            account.Id, account.AccountNumber, account.CompanyName,
            account.ContactName, account.ContactPhone, account.ContactEmail,
            account.AccountTariffId, null, account.IsActive);
    }
}
