using MediatR;
using Microsoft.EntityFrameworkCore;
using RedTaxi.Domain.Entities;
using RedTaxi.Infrastructure.Persistence;

namespace RedTaxi.Application.Dispatch.Commands;

public record RecordTurnDownCommand(int BookingId, int? DriverUserId, string? Reason) : IRequest<bool>;

public class RecordTurnDownCommandHandler : IRequestHandler<RecordTurnDownCommand, bool>
{
    private readonly TenantDbContext _db;

    public RecordTurnDownCommandHandler(TenantDbContext db) => _db = db;

    public async Task<bool> Handle(RecordTurnDownCommand request, CancellationToken ct)
    {
        var booking = await _db.Bookings.AsNoTracking().FirstOrDefaultAsync(b => b.Id == request.BookingId, ct)
            ?? throw new KeyNotFoundException($"Booking {request.BookingId} not found.");

        _db.TurnDowns.Add(new TurnDown
        {
            BookingId = request.BookingId,
            UserId = request.DriverUserId,
            Amount = booking.Price,
            TimeStamp = DateTime.UtcNow,
            Reason = request.Reason,
        });

        await _db.SaveChangesAsync(ct);
        return true;
    }
}
