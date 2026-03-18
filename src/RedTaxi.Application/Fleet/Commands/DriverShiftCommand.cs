using MediatR;
using Microsoft.EntityFrameworkCore;
using RedTaxi.Domain.Entities;
using RedTaxi.Domain.Enums;
using RedTaxi.Infrastructure.Persistence;

namespace RedTaxi.Application.Fleet.Commands;

public record DriverShiftCommand(int UserId, AppDriverShift Action) : IRequest<bool>;

public class DriverShiftCommandHandler : IRequestHandler<DriverShiftCommand, bool>
{
    private readonly TenantDbContext _db;

    public DriverShiftCommandHandler(TenantDbContext db)
    {
        _db = db;
    }

    public async Task<bool> Handle(DriverShiftCommand request, CancellationToken cancellationToken)
    {
        var now = DateTime.UtcNow;

        // Log the shift event
        _db.DriverShiftLogs.Add(new DriverShiftLog
        {
            UserId = request.UserId,
            TimeStamp = now,
            EntryType = request.Action,
        });

        // Update or create DriverOnShift record
        var shift = await _db.DriversOnShift
            .FirstOrDefaultAsync(s => s.UserId == request.UserId, cancellationToken);

        if (request.Action == AppDriverShift.StartShift)
        {
            if (shift == null)
            {
                _db.DriversOnShift.Add(new DriverOnShift
                {
                    UserId = request.UserId,
                    IsOnline = true,
                    ShiftStartedAt = now,
                });
            }
            else
            {
                shift.IsOnline = true;
                shift.ShiftStartedAt = now;
            }
        }
        else if (request.Action == AppDriverShift.FinishShift)
        {
            if (shift != null)
            {
                shift.IsOnline = false;
                shift.ShiftStartedAt = null;
            }
        }

        await _db.SaveChangesAsync(cancellationToken);
        return true;
    }
}
