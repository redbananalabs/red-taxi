using MediatR;
using Microsoft.EntityFrameworkCore;
using RedTaxi.Domain.Enums;
using RedTaxi.Infrastructure.Persistence;

namespace RedTaxi.Application.Billing.Commands;

/// <summary>
/// Marks completed, non-cancelled jobs for a driver as PostedForStatement.
/// </summary>
public record PostJobsForStatementCommand(
    int DriverUserId,
    DateTime From,
    DateTime To) : IRequest<int>;

public class PostJobsForStatementCommandHandler : IRequestHandler<PostJobsForStatementCommand, int>
{
    private readonly TenantDbContext _db;

    public PostJobsForStatementCommandHandler(TenantDbContext db)
    {
        _db = db;
    }

    public async Task<int> Handle(PostJobsForStatementCommand request, CancellationToken cancellationToken)
    {
        var jobs = await _db.Bookings
            .Where(b => b.UserId == request.DriverUserId
                && !b.Cancelled
                && !b.PostedForStatement
                && b.Status == BookingStatus.Complete
                && b.PickupDateTime >= request.From
                && b.PickupDateTime <= request.To)
            .ToListAsync(cancellationToken);

        foreach (var job in jobs)
            job.PostedForStatement = true;

        await _db.SaveChangesAsync(cancellationToken);
        return jobs.Count;
    }
}
