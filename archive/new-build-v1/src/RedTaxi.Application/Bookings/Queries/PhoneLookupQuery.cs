using MediatR;
using Microsoft.EntityFrameworkCore;
using RedTaxi.Application.Bookings.Commands;
using RedTaxi.Infrastructure.Persistence;
using RedTaxi.Shared.DTOs;

namespace RedTaxi.Application.Bookings.Queries;

// ── BK27: Phone Number History Lookup ────────────────────────────────────────

public record PhoneLookupQuery(string PhoneNumber) : IRequest<PhoneLookupResult>;

public record PhoneLookupResult(
    List<BookingDto> CurrentBookings,   // today + future, not cancelled
    List<BookingDto> PreviousBookings,  // past, deduplicated by PickupAddress, max 10
    List<BookingDto> CancelledBookings  // recent cancelled, max 3
);

public class PhoneLookupQueryHandler : IRequestHandler<PhoneLookupQuery, PhoneLookupResult>
{
    private readonly TenantDbContext _db;

    public PhoneLookupQueryHandler(TenantDbContext db) => _db = db;

    public async Task<PhoneLookupResult> Handle(PhoneLookupQuery request, CancellationToken ct)
    {
        var phone = StandardisePhone(request.PhoneNumber);
        if (string.IsNullOrWhiteSpace(phone))
            return new PhoneLookupResult(new(), new(), new());

        var today = DateTime.UtcNow.Date;

        var allBookings = await _db.Bookings
            .AsNoTracking()
            .Include(b => b.Vias)
            .Include(b => b.UserProfile)
            .Where(b => b.PhoneNumber != null && b.PhoneNumber == phone)
            .OrderByDescending(b => b.PickupDateTime)
            .ToListAsync(ct);

        var accountNumbers = allBookings
            .Where(b => b.AccountNumber.HasValue)
            .Select(b => b.AccountNumber!.Value)
            .Distinct()
            .ToList();

        var accountNames = accountNumbers.Count > 0
            ? await _db.Accounts
                .Where(a => accountNumbers.Contains(a.AccountNumber))
                .ToDictionaryAsync(a => a.AccountNumber, a => a.CompanyName, ct)
            : new Dictionary<int, string>();

        BookingDto ToDto(Domain.Entities.Booking b)
        {
            string? name = b.AccountNumber.HasValue && accountNames.TryGetValue(b.AccountNumber.Value, out var n) ? n : null;
            return BookingMapper.ToDto(b, name);
        }

        // Current: today + future, not cancelled
        var current = allBookings
            .Where(b => !b.Cancelled && b.PickupDateTime >= today)
            .Select(ToDto)
            .ToList();

        // Previous: past, not cancelled, deduplicated by PickupAddress, max 10
        var previous = allBookings
            .Where(b => !b.Cancelled && b.PickupDateTime < today)
            .GroupBy(b => b.PickupAddress)
            .Select(g => g.First())
            .Take(10)
            .Select(ToDto)
            .ToList();

        // Cancelled: recent cancelled, max 3
        var cancelled = allBookings
            .Where(b => b.Cancelled)
            .Take(3)
            .Select(ToDto)
            .ToList();

        return new PhoneLookupResult(current, previous, cancelled);
    }

    private static string? StandardisePhone(string? phone)
    {
        if (string.IsNullOrWhiteSpace(phone)) return phone;
        phone = phone.Trim().Replace(" ", "");
        if (phone.StartsWith("+44")) phone = "0" + phone[3..];
        if (phone.StartsWith("044")) phone = "0" + phone[3..];
        return phone;
    }
}
