using MediatR;
using Microsoft.EntityFrameworkCore;
using RedTaxi.Domain.Enums;
using RedTaxi.Domain.Interfaces;
using RedTaxi.Infrastructure.Persistence;

namespace RedTaxi.Application.WebBooking.Commands;

public record RejectWebBookingCommand(int WebBookingId, string? Reason) : IRequest<bool>;

public class RejectWebBookingCommandHandler : IRequestHandler<RejectWebBookingCommand, bool>
{
    private readonly TenantDbContext _db;
    private readonly ICurrentUserService _currentUser;

    public RejectWebBookingCommandHandler(TenantDbContext db, ICurrentUserService currentUser)
    {
        _db = db;
        _currentUser = currentUser;
    }

    public async Task<bool> Handle(RejectWebBookingCommand request, CancellationToken cancellationToken)
    {
        var webBooking = await _db.WebBookings
            .FirstOrDefaultAsync(w => w.Id == request.WebBookingId, cancellationToken)
            ?? throw new KeyNotFoundException($"WebBooking {request.WebBookingId} not found.");

        if (webBooking.Status != WebBookingStatus.Default)
            throw new InvalidOperationException($"WebBooking {request.WebBookingId} has already been processed.");

        webBooking.Status = WebBookingStatus.Rejected;
        webBooking.RejectionReason = request.Reason;
        webBooking.ProcessedByName = _currentUser.UserName;
        webBooking.ProcessedAt = DateTime.UtcNow;

        await _db.SaveChangesAsync(cancellationToken);
        return true;
    }
}
