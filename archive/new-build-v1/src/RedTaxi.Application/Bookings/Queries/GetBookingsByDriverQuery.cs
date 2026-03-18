using MediatR;
using Microsoft.EntityFrameworkCore;
using RedTaxi.Application.Bookings.Commands;
using RedTaxi.Infrastructure.Persistence;
using RedTaxi.Shared.DTOs;

namespace RedTaxi.Application.Bookings.Queries;

public record GetBookingsByDriverQuery(int DriverUserId, DateTime? Date = null) : IRequest<List<BookingDto>>;

public class GetBookingsByDriverQueryHandler : IRequestHandler<GetBookingsByDriverQuery, List<BookingDto>>
{
    private readonly TenantDbContext _db;

    public GetBookingsByDriverQueryHandler(TenantDbContext db) => _db = db;

    public async Task<List<BookingDto>> Handle(GetBookingsByDriverQuery request, CancellationToken ct)
    {
        var date = request.Date?.Date ?? DateTime.UtcNow.Date;
        var nextDay = date.AddDays(1);

        var bookings = await _db.Bookings
            .AsNoTracking()
            .Include(x => x.Vias)
            .Include(x => x.UserProfile)
            .Where(b => b.UserId == request.DriverUserId
                && b.PickupDateTime >= date
                && b.PickupDateTime < nextDay
                && !b.Cancelled)
            .OrderBy(b => b.PickupDateTime)
            .ToListAsync(ct);

        var accountNumbers = bookings
            .Where(b => b.AccountNumber.HasValue)
            .Select(b => b.AccountNumber!.Value)
            .Distinct()
            .ToList();

        var accountNames = accountNumbers.Count > 0
            ? await _db.Accounts
                .Where(a => accountNumbers.Contains(a.AccountNumber))
                .ToDictionaryAsync(a => a.AccountNumber, a => a.CompanyName, ct)
            : new Dictionary<int, string>();

        return bookings.Select(b =>
        {
            string? name = b.AccountNumber.HasValue && accountNames.TryGetValue(b.AccountNumber.Value, out var n) ? n : null;
            return BookingMapper.ToDto(b, name);
        }).ToList();
    }
}
