using MediatR;
using Microsoft.EntityFrameworkCore;
using RedTaxi.Domain.Enums;
using RedTaxi.Infrastructure.Persistence;
using RedTaxi.Shared.DTOs;

namespace RedTaxi.Application.Billing.Queries;

/// <summary>
/// Returns account jobs that are ready for invoicing (not yet posted).
/// </summary>
public record ChargeableJobDto(
    int Id,
    string PickupAddress,
    string? DestinationAddress,
    string? PassengerName,
    DateTime PickupDateTime,
    decimal Price,
    decimal PriceAccount,
    decimal ParkingCharge,
    decimal WaitingTimePriceAccount,
    int? AccountNumber);

public record GetChargeableJobsQuery(
    int AccountNumber,
    DateTime From,
    DateTime To) : IRequest<List<ChargeableJobDto>>;

public class GetChargeableJobsQueryHandler : IRequestHandler<GetChargeableJobsQuery, List<ChargeableJobDto>>
{
    private readonly TenantDbContext _db;

    public GetChargeableJobsQueryHandler(TenantDbContext db)
    {
        _db = db;
    }

    public async Task<List<ChargeableJobDto>> Handle(GetChargeableJobsQuery request, CancellationToken cancellationToken)
    {
        return await _db.Bookings
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
    }
}
