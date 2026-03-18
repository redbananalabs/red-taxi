using MediatR;
using Microsoft.EntityFrameworkCore;
using RedTaxi.Domain.Entities;
using RedTaxi.Infrastructure.Persistence;
using RedTaxi.Shared.DTOs;

namespace RedTaxi.Application.Bookings.Commands;

public record MergeSchoolRunsCommand(int SourceBookingId, int TargetBookingId) : IRequest<BookingDto>;

public class MergeSchoolRunsCommandHandler : IRequestHandler<MergeSchoolRunsCommand, BookingDto>
{
    private readonly TenantDbContext _db;

    public MergeSchoolRunsCommandHandler(TenantDbContext db)
    {
        _db = db;
    }

    public async Task<BookingDto> Handle(MergeSchoolRunsCommand request, CancellationToken ct)
    {
        var source = await _db.Bookings
            .Include(b => b.Vias)
            .FirstOrDefaultAsync(b => b.Id == request.SourceBookingId, ct)
            ?? throw new KeyNotFoundException($"Source booking {request.SourceBookingId} not found.");

        var target = await _db.Bookings
            .Include(b => b.Vias)
            .Include(b => b.UserProfile)
            .FirstOrDefaultAsync(b => b.Id == request.TargetBookingId, ct)
            ?? throw new KeyNotFoundException($"Target booking {request.TargetBookingId} not found.");

        // Validate: both must be school runs
        if (!source.IsSchoolRun)
            throw new InvalidOperationException($"Source booking {source.Id} is not a school run.");

        if (!target.IsSchoolRun)
            throw new InvalidOperationException($"Target booking {target.Id} is not a school run.");

        // Validate: same account
        if (source.AccountNumber != target.AccountNumber)
            throw new InvalidOperationException("Both bookings must belong to the same account to merge.");

        // Determine the next via sequence number
        var nextViaSequence = target.Vias.Any()
            ? target.Vias.Max(v => v.ViaSequence) + 1
            : 1;

        // Determine merge type and add appropriate via
        bool pickupsMatch = string.Equals(source.PickupAddress, target.PickupAddress, StringComparison.OrdinalIgnoreCase);
        bool destinationsMatch = string.Equals(source.DestinationAddress, target.DestinationAddress, StringComparison.OrdinalIgnoreCase);

        if (pickupsMatch)
        {
            // Pickups match: source destination becomes a via on target
            if (!string.IsNullOrWhiteSpace(source.DestinationAddress))
            {
                target.Vias.Add(new BookingVia
                {
                    BookingId = target.Id,
                    Address = source.DestinationAddress,
                    PostCode = source.DestinationPostCode,
                    ViaSequence = nextViaSequence,
                });
            }
        }
        else if (destinationsMatch)
        {
            // Destinations match: source pickup becomes a via on target
            target.Vias.Add(new BookingVia
            {
                BookingId = target.Id,
                Address = source.PickupAddress,
                PostCode = source.PickupPostCode,
                ViaSequence = nextViaSequence,
            });
        }
        else
        {
            // Different pickups and destinations but same account: source pickup becomes a via
            target.Vias.Add(new BookingVia
            {
                BookingId = target.Id,
                Address = source.PickupAddress,
                PostCode = source.PickupPostCode,
                ViaSequence = nextViaSequence,
            });
        }

        // Concatenate passenger names
        if (!string.IsNullOrWhiteSpace(source.PassengerName))
        {
            target.PassengerName = string.IsNullOrWhiteSpace(target.PassengerName)
                ? source.PassengerName
                : $"{target.PassengerName}, {source.PassengerName}";
        }

        // Increment passenger count
        target.Passengers += source.Passengers;

        // Flag for manual pricing review
        target.ManuallyPriced = true;
        target.DateUpdated = DateTime.UtcNow;

        // Mark source as cancelled and merged
        source.Cancelled = true;
        source.MergedIntoBookingId = target.Id;
        source.DateUpdated = DateTime.UtcNow;

        await _db.SaveChangesAsync(ct);

        // Reload for DTO mapping
        var updated = await _db.Bookings
            .AsNoTracking()
            .Include(x => x.Vias)
            .Include(x => x.UserProfile)
            .FirstAsync(x => x.Id == target.Id, ct);

        string? accountName = null;
        if (updated.AccountNumber.HasValue)
        {
            accountName = await _db.Accounts
                .Where(a => a.AccountNumber == updated.AccountNumber)
                .Select(a => a.CompanyName)
                .FirstOrDefaultAsync(ct);
        }

        return BookingMapper.ToDto(updated, accountName);
    }
}
