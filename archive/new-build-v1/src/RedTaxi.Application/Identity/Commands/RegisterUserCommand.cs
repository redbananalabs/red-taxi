using FluentValidation;
using MediatR;
using Microsoft.EntityFrameworkCore;
using RedTaxi.Domain.Entities;
using RedTaxi.Domain.Enums;
using RedTaxi.Infrastructure.Persistence;
using RedTaxi.Shared.DTOs;

namespace RedTaxi.Application.Identity.Commands;

public record RegisterUserCommand(
    string Email,
    string Password,
    string FullName,
    string? PhoneNumber,
    UserRole Role) : IRequest<UserInfoDto>;

public class RegisterUserCommandValidator : AbstractValidator<RegisterUserCommand>
{
    public RegisterUserCommandValidator()
    {
        RuleFor(x => x.Email).NotEmpty().EmailAddress();
        RuleFor(x => x.Password).NotEmpty().MinimumLength(6);
        RuleFor(x => x.FullName).NotEmpty().MaximumLength(250);
        RuleFor(x => x.Role).IsInEnum();
    }
}

public class RegisterUserCommandHandler : IRequestHandler<RegisterUserCommand, UserInfoDto>
{
    private readonly TenantDbContext _db;

    public RegisterUserCommandHandler(TenantDbContext db)
    {
        _db = db;
    }

    public async Task<UserInfoDto> Handle(RegisterUserCommand request, CancellationToken cancellationToken)
    {
        var exists = await _db.UserProfiles
            .AnyAsync(u => u.Email == request.Email, cancellationToken);

        if (exists)
            throw new InvalidOperationException("A user with this email already exists.");

        // Get the next UserId (auto-increment simulation for the FK column)
        var maxUserId = await _db.UserProfiles
            .MaxAsync(u => (int?)u.UserId, cancellationToken) ?? 0;

        var user = new UserProfile
        {
            UserId = maxUserId + 1,
            Email = request.Email,
            PasswordHash = BCrypt.Net.BCrypt.HashPassword(request.Password),
            FullName = request.FullName,
            PhoneNumber = request.PhoneNumber,
            Role = request.Role,
            IsActive = true,
        };

        _db.UserProfiles.Add(user);
        await _db.SaveChangesAsync(cancellationToken);

        return new UserInfoDto(user.UserId, user.FullName, user.Email, user.Role.ToString(), null, null);
    }
}
