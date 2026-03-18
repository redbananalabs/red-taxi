using MediatR;
using Microsoft.EntityFrameworkCore;
using RedTaxi.Domain.Enums;
using RedTaxi.Infrastructure.Persistence;

namespace RedTaxi.Application.WebBooking.Queries;

public record PendingWebBookingDto(
    int Id,
    string? PassengerName,
    string? PhoneNumber,
    string? Email,
    string PickupAddress,
    string? PickupPostCode,
    string? DestinationAddress,
    string? DestinationPostCode,
    DateTime PickupDateTime,
    string? Details,
    int Passengers,
    int VehicleType,
    int? AccountNumber,
    decimal? Price,
    DateTime DateCreated);

public record GetPendingWebBookingsQuery : IRequest<List<PendingWebBookingDto>>;

public class GetPendingWebBookingsQueryHandler : IRequestHandler<GetPendingWebBookingsQuery, List<PendingWebBookingDto>>
{
    private readonly TenantDbContext _db;

    public GetPendingWebBookingsQueryHandler(TenantDbContext db) => _db = db;

    public async Task<List<PendingWebBookingDto>> Handle(GetPendingWebBookingsQuery request, CancellationToken cancellationToken)
    {
        return await _db.WebBookings
            .Where(w => w.Status == WebBookingStatus.Default)
            .OrderBy(w => w.PickupDateTime)
            .Select(w => new PendingWebBookingDto(
                w.Id, w.PassengerName, w.PhoneNumber, w.Email,
                w.PickupAddress, w.PickupPostCode,
                w.DestinationAddress, w.DestinationPostCode,
                w.PickupDateTime, w.Details, w.Passengers,
                (int)w.VehicleType, w.AccountNumber, w.Price,
                w.DateCreated))
            .ToListAsync(cancellationToken);
    }
}
