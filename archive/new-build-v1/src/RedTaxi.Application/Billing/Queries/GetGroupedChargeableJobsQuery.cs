using MediatR;
using Microsoft.EntityFrameworkCore;
using RedTaxi.Domain.Enums;
using RedTaxi.Infrastructure.Persistence;
using RedTaxi.Shared.DTOs;

namespace RedTaxi.Application.Billing.Queries;

public record GetGroupedChargeableJobsQuery(int AccountNumber, DateTime From, DateTime To) : IRequest<GroupedJobsResult>;

public record GroupedJobsResult(
    List<PassengerGroup> SinglesGroups,
    List<RouteGroup> SharedGroups);

public record PassengerGroup(string PassengerName, List<ChargeableJobDto> Jobs);
public record RouteGroup(string Pickup, string Destination, List<ChargeableJobDto> Jobs);

public class GetGroupedChargeableJobsQueryHandler : IRequestHandler<GetGroupedChargeableJobsQuery, GroupedJobsResult>
{
    private readonly TenantDbContext _db;

    public GetGroupedChargeableJobsQueryHandler(TenantDbContext db)
    {
        _db = db;
    }

    public async Task<GroupedJobsResult> Handle(GetGroupedChargeableJobsQuery request, CancellationToken cancellationToken)
    {
        var jobs = await _db.Bookings
            .Where(b => b.AccountNumber == request.AccountNumber
                && b.Scope == BookingScope.Account
                && !b.Cancelled
                && !b.PostedForInvoicing
                && b.PickupDateTime >= request.From
                && b.PickupDateTime <= request.To)
            .OrderBy(b => b.PickupDateTime)
            .Select(b => new ChargeableJobDto(
                b.Id, b.PickupAddress, b.DestinationAddress,
                b.PassengerName, b.PickupDateTime,
                b.Price, b.PriceAccount,
                b.ParkingCharge, b.WaitingTimePriceAccount,
                b.AccountNumber))
            .ToListAsync(cancellationToken);

        // Singles: Group by passenger name
        var singlesGroups = jobs
            .GroupBy(j => j.PassengerName ?? "Unknown")
            .Select(g => new PassengerGroup(g.Key, g.ToList()))
            .ToList();

        // Shared: Group by normalized (PickupAddress + DestinationAddress)
        var sharedGroups = jobs
            .GroupBy(j => new
            {
                Pickup = (j.PickupAddress ?? "").Trim().ToUpperInvariant(),
                Destination = (j.DestinationAddress ?? "").Trim().ToUpperInvariant()
            })
            .Where(g => g.Count() > 1)
            .Select(g => new RouteGroup(g.Key.Pickup, g.Key.Destination, g.ToList()))
            .ToList();

        return new GroupedJobsResult(singlesGroups, sharedGroups);
    }
}
