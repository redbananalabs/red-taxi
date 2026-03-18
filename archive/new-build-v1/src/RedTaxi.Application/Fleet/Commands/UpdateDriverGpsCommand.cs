using MediatR;
using Microsoft.EntityFrameworkCore;
using RedTaxi.Domain.Entities;
using RedTaxi.Infrastructure.Persistence;
using RedTaxi.Shared.DTOs;

namespace RedTaxi.Application.Fleet.Commands;

public record UpdateDriverGpsCommand(
    int UserId,
    decimal Latitude,
    decimal Longitude,
    decimal? Heading,
    decimal? Speed) : IRequest<DriverLocationDto>;

public class UpdateDriverGpsCommandHandler : IRequestHandler<UpdateDriverGpsCommand, DriverLocationDto>
{
    private readonly TenantDbContext _db;

    public UpdateDriverGpsCommandHandler(TenantDbContext db)
    {
        _db = db;
    }

    public async Task<DriverLocationDto> Handle(UpdateDriverGpsCommand request, CancellationToken cancellationToken)
    {
        var now = DateTime.UtcNow;

        // Update user profile heading/speed
        var user = await _db.UserProfiles
            .FirstOrDefaultAsync(u => u.UserId == request.UserId, cancellationToken);

        if (user != null)
        {
            user.Heading = request.Heading;
            user.Speed = request.Speed;
        }

        // Update shift record
        var shift = await _db.DriversOnShift
            .FirstOrDefaultAsync(s => s.UserId == request.UserId, cancellationToken);

        if (shift != null)
            shift.LastGpsUpdate = now;

        // Record location history
        var history = new DriverLocationHistory
        {
            UserId = request.UserId,
            Latitude = request.Latitude,
            Longitude = request.Longitude,
            Heading = request.Heading,
            Speed = request.Speed,
            TimeStamp = now,
        };

        _db.DriverLocationHistories.Add(history);
        await _db.SaveChangesAsync(cancellationToken);

        return new DriverLocationDto(
            request.UserId, request.Latitude, request.Longitude,
            request.Heading, request.Speed, now);
    }
}
