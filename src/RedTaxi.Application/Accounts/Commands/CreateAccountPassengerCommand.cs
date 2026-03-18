using FluentValidation;
using MediatR;
using RedTaxi.Domain.Entities;
using RedTaxi.Infrastructure.Persistence;
using RedTaxi.Shared.DTOs;

namespace RedTaxi.Application.Accounts.Commands;

public record CreateAccountPassengerCommand(
    int AccountId,
    string Name,
    string? Description,
    string? Address,
    string? PostCode,
    string? Phone,
    string? Email) : IRequest<AccountPassengerDto>;

public class CreateAccountPassengerCommandValidator : AbstractValidator<CreateAccountPassengerCommand>
{
    public CreateAccountPassengerCommandValidator()
    {
        RuleFor(x => x.AccountId).GreaterThan(0);
        RuleFor(x => x.Name).NotEmpty().MaximumLength(250);
    }
}

public class CreateAccountPassengerCommandHandler : IRequestHandler<CreateAccountPassengerCommand, AccountPassengerDto>
{
    private readonly TenantDbContext _db;

    public CreateAccountPassengerCommandHandler(TenantDbContext db)
    {
        _db = db;
    }

    public async Task<AccountPassengerDto> Handle(CreateAccountPassengerCommand request, CancellationToken cancellationToken)
    {
        var passenger = new AccountPassenger
        {
            AccountId = request.AccountId,
            Name = request.Name,
            Description = request.Description,
            Address = request.Address,
            PostCode = request.PostCode,
            Phone = request.Phone,
            Email = request.Email,
            IsActive = true,
        };

        _db.AccountPassengers.Add(passenger);
        await _db.SaveChangesAsync(cancellationToken);

        return new AccountPassengerDto(
            passenger.Id, passenger.AccountId, passenger.Name,
            passenger.Description, passenger.Address, passenger.PostCode,
            passenger.Phone, passenger.Email, passenger.IsActive);
    }
}
