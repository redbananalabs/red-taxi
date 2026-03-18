using MediatR;
using Microsoft.EntityFrameworkCore;
using RedTaxi.Application.Bookings.Commands;
using RedTaxi.Infrastructure.Persistence;
using RedTaxi.Shared.DTOs;

namespace RedTaxi.Application.Bookings.Queries;

/// <summary>
/// Search bookings by phone, passenger name, or reference. Supports pagination.
/// </summary>
public record FindBookingsQuery(
    string? SearchTerm,
    DateTime? FromDate,
    DateTime? ToDate,
    int? AccountNumber,
    int? DriverUserId,
    bool IncludeCancelled,
    int Page,
    int PageSize) : IRequest<FindBookingsResult>;

public record FindBookingsResult(List<BookingDto> Items, int TotalCount);

public class FindBookingsQueryHandler : IRequestHandler<FindBookingsQuery, FindBookingsResult>
{
    private readonly TenantDbContext _db;

    public FindBookingsQueryHandler(TenantDbContext db) => _db = db;

    public async Task<FindBookingsResult> Handle(FindBookingsQuery request, CancellationToken ct)
    {
        var query = _db.Bookings.AsNoTracking().AsQueryable();

        if (!request.IncludeCancelled)
            query = query.Where(b => !b.Cancelled);

        if (request.FromDate.HasValue)
            query = query.Where(b => b.PickupDateTime >= request.FromDate.Value);

        if (request.ToDate.HasValue)
            query = query.Where(b => b.PickupDateTime <= request.ToDate.Value);

        if (request.AccountNumber.HasValue)
            query = query.Where(b => b.AccountNumber == request.AccountNumber.Value);

        if (request.DriverUserId.HasValue)
            query = query.Where(b => b.UserId == request.DriverUserId.Value);

        if (!string.IsNullOrWhiteSpace(request.SearchTerm))
        {
            var term = request.SearchTerm.Trim();
            query = query.Where(b =>
                (b.PhoneNumber != null && b.PhoneNumber.Contains(term)) ||
                (b.PassengerName != null && b.PassengerName.Contains(term)) ||
                (b.PickupAddress.Contains(term)) ||
                (b.DestinationAddress != null && b.DestinationAddress.Contains(term)) ||
                (b.Details != null && b.Details.Contains(term)));
        }

        int totalCount = await query.CountAsync(ct);

        var page = Math.Max(1, request.Page);
        var pageSize = Math.Clamp(request.PageSize, 1, 200);

        var bookings = await query
            .Include(x => x.Vias)
            .Include(x => x.UserProfile)
            .OrderByDescending(b => b.PickupDateTime)
            .Skip((page - 1) * pageSize)
            .Take(pageSize)
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

        var items = bookings.Select(b =>
        {
            string? name = b.AccountNumber.HasValue && accountNames.TryGetValue(b.AccountNumber.Value, out var n) ? n : null;
            return BookingMapper.ToDto(b, name);
        }).ToList();

        return new FindBookingsResult(items, totalCount);
    }
}
