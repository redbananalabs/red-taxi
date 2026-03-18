using MediatR;
using Microsoft.EntityFrameworkCore;
using RedTaxi.Domain.Enums;
using RedTaxi.Infrastructure.Persistence;

namespace RedTaxi.Application.Billing.Commands;

/// <summary>
/// Marks matching account jobs as PostedForInvoicing = true.
/// Returns the count of jobs posted.
/// </summary>
public record PostJobsForInvoicingCommand(
    int AccountNumber,
    DateTime From,
    DateTime To) : IRequest<int>;

public class PostJobsForInvoicingCommandHandler : IRequestHandler<PostJobsForInvoicingCommand, int>
{
    private readonly TenantDbContext _db;

    public PostJobsForInvoicingCommandHandler(TenantDbContext db)
    {
        _db = db;
    }

    public async Task<int> Handle(PostJobsForInvoicingCommand request, CancellationToken cancellationToken)
    {
        var jobs = await _db.Bookings
            .Where(b => b.AccountNumber == request.AccountNumber
                && b.Scope == BookingScope.Account
                && !b.Cancelled
                && !b.PostedForInvoicing
                && b.PickupDateTime >= request.From
                && b.PickupDateTime <= request.To)
            .ToListAsync(cancellationToken);

        foreach (var job in jobs)
            job.PostedForInvoicing = true;

        await _db.SaveChangesAsync(cancellationToken);
        return jobs.Count;
    }
}
