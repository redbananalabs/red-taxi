using MediatR;
using RedTaxi.Domain.Entities;
using RedTaxi.Domain.Enums;
using RedTaxi.Domain.Interfaces;
using RedTaxi.Infrastructure.Persistence;
using RedTaxi.Shared.DTOs;

namespace RedTaxi.Application.Fleet.Commands;

public record SetDriverAvailabilityCommand(
    int UserId,
    DateTime Date,
    TimeSpan StartTime,
    TimeSpan EndTime,
    DriverAvailabilityType AvailabilityType,
    string? Details,
    bool GiveOrTake) : IRequest<DriverAvailabilityDto>;

public class SetDriverAvailabilityCommandHandler : IRequestHandler<SetDriverAvailabilityCommand, DriverAvailabilityDto>
{
    private readonly TenantDbContext _db;
    private readonly ICurrentUserService _currentUser;

    public SetDriverAvailabilityCommandHandler(TenantDbContext db, ICurrentUserService currentUser)
    {
        _db = db;
        _currentUser = currentUser;
    }

    public async Task<DriverAvailabilityDto> Handle(SetDriverAvailabilityCommand request, CancellationToken cancellationToken)
    {
        var availability = new DriverAvailability
        {
            UserId = request.UserId,
            Date = request.Date.Date,
            StartTime = request.StartTime,
            EndTime = request.EndTime,
            AvailabilityType = request.AvailabilityType,
            Details = request.Details,
            GiveOrTake = request.GiveOrTake,
            DateCreated = DateTime.UtcNow,
            CreatedByName = _currentUser.UserName,
        };

        _db.DriverAvailabilities.Add(availability);
        await _db.SaveChangesAsync(cancellationToken);

        return new DriverAvailabilityDto(
            availability.Id, availability.UserId, availability.Date,
            availability.StartTime, availability.EndTime,
            (int)availability.AvailabilityType, availability.Details, availability.GiveOrTake);
    }
}
