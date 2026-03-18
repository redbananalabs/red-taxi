using MediatR;
using Microsoft.EntityFrameworkCore;
using RedTaxi.Application.Bookings.Commands;
using RedTaxi.Infrastructure.Persistence;
using RedTaxi.Shared.DTOs;

namespace RedTaxi.Application.Bookings.Queries;

public record GetBookingByIdQuery(int BookingId) : IRequest<BookingDto?>;

public class GetBookingByIdQueryHandler : IRequestHandler<GetBookingByIdQuery, BookingDto?>
{
    private readonly TenantDbContext _db;

    public GetBookingByIdQueryHandler(TenantDbContext db) => _db = db;

    public async Task<BookingDto?> Handle(GetBookingByIdQuery request, CancellationToken ct)
    {
        var b = await _db.Bookings
            .AsNoTracking()
            .Include(x => x.Vias)
            .Include(x => x.UserProfile)
            .FirstOrDefaultAsync(x => x.Id == request.BookingId, ct);

        if (b == null) return null;

        string? accountName = null;
        if (b.AccountNumber.HasValue)
        {
            accountName = await _db.Accounts
                .Where(a => a.AccountNumber == b.AccountNumber)
                .Select(a => a.CompanyName)
                .FirstOrDefaultAsync(ct);
        }

        return BookingMapper.ToDto(b, accountName);
    }
}
