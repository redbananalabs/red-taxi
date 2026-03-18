using MediatR;
using Microsoft.EntityFrameworkCore;
using RedTaxi.Domain.Enums;
using RedTaxi.Infrastructure.Persistence;
using RedTaxi.Shared.DTOs;

namespace RedTaxi.Application.Fleet.Commands;

public record UpdateDriverProfileCommand(
    int UserId,
    string? FullName,
    string? PhoneNumber,
    string? ColorCodeRGB,
    string? RegNo,
    VehicleType VehicleType,
    string? VehicleMake,
    string? VehicleModel,
    string? VehicleColour,
    bool IsActive,
    bool IsSubstitute,
    decimal? CommissionRate,
    CommsPlatform CommsPlatform) : IRequest<DriverDto>;

public class UpdateDriverProfileCommandHandler : IRequestHandler<UpdateDriverProfileCommand, DriverDto>
{
    private readonly TenantDbContext _db;

    public UpdateDriverProfileCommandHandler(TenantDbContext db)
    {
        _db = db;
    }

    public async Task<DriverDto> Handle(UpdateDriverProfileCommand request, CancellationToken cancellationToken)
    {
        var user = await _db.UserProfiles
            .FirstOrDefaultAsync(u => u.UserId == request.UserId, cancellationToken)
            ?? throw new KeyNotFoundException($"Driver {request.UserId} not found.");

        user.FullName = request.FullName;
        user.PhoneNumber = request.PhoneNumber;
        user.ColorCodeRGB = request.ColorCodeRGB;
        user.RegNo = request.RegNo;
        user.VehicleType = request.VehicleType;
        user.VehicleMake = request.VehicleMake;
        user.VehicleModel = request.VehicleModel;
        user.VehicleColour = request.VehicleColour;
        user.IsActive = request.IsActive;
        user.IsSubstitute = request.IsSubstitute;
        user.CommissionRate = request.CommissionRate;
        user.CommsPlatform = request.CommsPlatform;

        await _db.SaveChangesAsync(cancellationToken);

        return new DriverDto(
            user.Id, user.UserId, user.FullName, user.PhoneNumber,
            user.ColorCodeRGB, user.RegNo,
            (int)user.VehicleType, user.VehicleMake, user.VehicleModel, user.VehicleColour,
            user.IsActive, user.IsSubstitute, user.CommissionRate,
            (int)user.CommsPlatform);
    }
}
