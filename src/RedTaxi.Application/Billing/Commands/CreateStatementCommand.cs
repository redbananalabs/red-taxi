using MediatR;
using Microsoft.EntityFrameworkCore;
using RedTaxi.Application.Billing.Services;
using RedTaxi.Domain.Entities;
using RedTaxi.Domain.Enums;
using RedTaxi.Infrastructure.Persistence;
using RedTaxi.Shared.DTOs;

namespace RedTaxi.Application.Billing.Commands;

/// <summary>
/// Creates a DriverInvoiceStatement using the settlement formula.
/// Processes posted-for-statement jobs that don't yet have a StatementId.
/// </summary>
public record CreateStatementCommand(
    int DriverUserId,
    DateTime PeriodStart,
    DateTime PeriodEnd) : IRequest<StatementDto>;

public class CreateStatementCommandHandler : IRequestHandler<CreateStatementCommand, StatementDto>
{
    private readonly TenantDbContext _db;

    public CreateStatementCommandHandler(TenantDbContext db)
    {
        _db = db;
    }

    public async Task<StatementDto> Handle(CreateStatementCommand request, CancellationToken cancellationToken)
    {
        var driver = await _db.UserProfiles
            .FirstOrDefaultAsync(u => u.UserId == request.DriverUserId, cancellationToken)
            ?? throw new KeyNotFoundException($"Driver {request.DriverUserId} not found.");

        var config = await _db.CompanyConfigs
            .FirstOrDefaultAsync(cancellationToken)
            ?? throw new InvalidOperationException("Company config not found.");

        // Get posted jobs not yet linked to a statement
        var jobs = await _db.Bookings
            .Where(b => b.UserId == request.DriverUserId
                && b.PostedForStatement
                && b.StatementId == null
                && b.PickupDateTime >= request.PeriodStart
                && b.PickupDateTime <= request.PeriodEnd)
            .ToListAsync(cancellationToken);

        if (jobs.Count == 0)
            throw new InvalidOperationException("No posted jobs found for the given period.");

        // Calculate settlement
        var result = SettlementCalculator.Calculate(jobs, driver.CommissionRate, config);

        // Get expenses for the period
        var totalExpenses = await _db.DriverExpenses
            .Where(e => e.UserId == request.DriverUserId
                && e.Date >= request.PeriodStart
                && e.Date <= request.PeriodEnd)
            .SumAsync(e => e.Amount, cancellationToken);

        var netPayable = result.SubTotal - totalExpenses;

        var statement = new DriverInvoiceStatement
        {
            UserId = request.DriverUserId,
            StatementDate = DateTime.UtcNow,
            PeriodStart = request.PeriodStart,
            PeriodEnd = request.PeriodEnd,
            EarningsCash = result.EarningsCash,
            EarningsCard = result.EarningsCard,
            EarningsAccount = result.EarningsAccount,
            EarningsRank = result.EarningsRank,
            TotalCommission = result.TotalCommission,
            CardFees = result.CardFees,
            TotalExpenses = Math.Round(totalExpenses, 2),
            SubTotal = result.SubTotal,
            NetPayable = Math.Round(netPayable, 2),
            JobCount = jobs.Count,
            DateCreated = DateTime.UtcNow,
        };

        _db.DriverInvoiceStatements.Add(statement);
        await _db.SaveChangesAsync(cancellationToken);

        // Link jobs to this statement
        foreach (var job in jobs)
            job.StatementId = statement.Id;

        await _db.SaveChangesAsync(cancellationToken);

        return new StatementDto(
            statement.Id, statement.UserId, driver.FullName,
            statement.StatementDate, statement.PeriodStart, statement.PeriodEnd,
            statement.EarningsCash, statement.EarningsCard,
            statement.EarningsAccount, statement.EarningsRank,
            statement.TotalCommission, statement.CardFees,
            statement.TotalExpenses, statement.SubTotal, statement.NetPayable,
            statement.JobCount);
    }
}
