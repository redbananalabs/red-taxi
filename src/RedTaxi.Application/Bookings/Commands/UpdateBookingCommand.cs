using System.Text.RegularExpressions;
using FluentValidation;
using MediatR;
using Microsoft.EntityFrameworkCore;
using RedTaxi.Domain.Entities;
using RedTaxi.Domain.Enums;
using RedTaxi.Domain.Events;
using RedTaxi.Domain.Interfaces;
using RedTaxi.Infrastructure.Persistence;
using RedTaxi.Shared.DTOs;

namespace RedTaxi.Application.Bookings.Commands;

public record UpdateBookingCommand(BookingUpdateDto Dto) : IRequest<BookingDto>;

public class UpdateBookingCommandValidator : AbstractValidator<UpdateBookingCommand>
{
    public UpdateBookingCommandValidator()
    {
        RuleFor(x => x.Dto.Id).GreaterThan(0);
        RuleFor(x => x.Dto.PickupAddress).NotEmpty().MaximumLength(250);
        RuleFor(x => x.Dto.PickupDateTime).GreaterThan(DateTime.MinValue);
    }
}

public class UpdateBookingCommandHandler : IRequestHandler<UpdateBookingCommand, BookingDto>
{
    private readonly TenantDbContext _db;
    private readonly ICurrentUserService _currentUser;
    private readonly IPricingService _pricing;
    private readonly IPublisher _publisher;

    public UpdateBookingCommandHandler(
        TenantDbContext db,
        ICurrentUserService currentUser,
        IPricingService pricing,
        IPublisher publisher)
    {
        _db = db;
        _currentUser = currentUser;
        _pricing = pricing;
        _publisher = publisher;
    }

    // ── BK02: Phone Standardisation ──────────────────────────────────────────
    private static string? StandardisePhone(string? phone)
    {
        if (string.IsNullOrWhiteSpace(phone)) return phone;
        phone = phone.Trim().Replace(" ", "");
        if (phone.StartsWith("+44")) phone = "0" + phone[3..];
        if (phone.StartsWith("044")) phone = "0" + phone[3..];
        return phone;
    }

    // ── BK03: Postcode Standardisation ───────────────────────────────────────
    private static string? StandardisePostcode(string? postcode)
    {
        if (string.IsNullOrWhiteSpace(postcode)) return postcode;
        postcode = postcode.Trim().ToUpperInvariant();
        if (postcode.Length >= 5 && !postcode.Contains(' '))
            postcode = postcode[..^3] + " " + postcode[^3..];
        return postcode;
    }

    // ── BK04: Address Normalisation ──────────────────────────────────────────
    private static string? NormaliseAddress(string? address)
    {
        if (string.IsNullOrWhiteSpace(address)) return address;
        return Regex.Replace(address.Trim(), @"\s+", " ");
    }

    // ── BK32: Audit — compare old vs new and write BookingChangeAudit rows ──
    private void AuditChanges(Booking booking, BookingUpdateDto dto, string? userName)
    {
        var now = DateTime.UtcNow;
        var entityId = booking.Id.ToString();

        void Check(string prop, string? oldVal, string? newVal)
        {
            if (oldVal == newVal) return;
            _db.BookingChangeAudits.Add(new BookingChangeAudit
            {
                EntityIdentifier = entityId,
                EntityName = "Booking",
                PropertyName = prop,
                OldValue = oldVal,
                NewValue = newVal,
                UserFullName = userName,
                TimeStamp = now,
                Action = "Update",
            });
        }

        Check("PickupAddress", booking.PickupAddress, NormaliseAddress(dto.PickupAddress) ?? dto.PickupAddress);
        Check("PickupPostCode", booking.PickupPostCode, StandardisePostcode(dto.PickupPostCode) ?? string.Empty);
        Check("DestinationAddress", booking.DestinationAddress, NormaliseAddress(dto.DestinationAddress));
        Check("DestinationPostCode", booking.DestinationPostCode, StandardisePostcode(dto.DestinationPostCode));
        Check("Details", booking.Details, dto.Details);
        Check("PassengerName", booking.PassengerName, dto.PassengerName);
        Check("Passengers", booking.Passengers.ToString(), dto.Passengers.ToString());
        Check("PhoneNumber", booking.PhoneNumber, StandardisePhone(dto.PhoneNumber));
        Check("Email", booking.Email, dto.Email);
        Check("PickupDateTime", booking.PickupDateTime.ToString("O"), dto.PickupDateTime.ToString("O"));
        Check("ArriveBy", booking.ArriveBy?.ToString("O"), dto.ArriveBy?.ToString("O"));
        Check("IsASAP", booking.IsASAP.ToString(), dto.IsASAP.ToString());
        Check("Scope", booking.Scope.HasValue ? ((int)booking.Scope.Value).ToString() : null, dto.Scope.ToString());
        Check("AccountNumber", booking.AccountNumber?.ToString(), dto.AccountNumber?.ToString());
        Check("VehicleType", ((int)booking.VehicleType).ToString(), dto.VehicleType.ToString());
        Check("ChargeFromBase", booking.ChargeFromBase.ToString(), dto.ChargeFromBase.ToString());
        Check("IsSchoolRun", booking.IsSchoolRun.ToString(), dto.IsSchoolRun.ToString());
    }

    public async Task<BookingDto> Handle(UpdateBookingCommand request, CancellationToken ct)
    {
        var dto = request.Dto;
        var booking = await _db.Bookings
            .Include(b => b.Vias)
            .FirstOrDefaultAsync(b => b.Id == dto.Id, ct)
            ?? throw new KeyNotFoundException($"Booking {dto.Id} not found.");

        // BK32: Record audit trail before mutating
        AuditChanges(booking, dto, _currentUser.UserName);

        // Standardise inputs
        var pickupAddress = NormaliseAddress(dto.PickupAddress) ?? dto.PickupAddress;
        var pickupPostCode = StandardisePostcode(dto.PickupPostCode) ?? string.Empty;
        var destinationAddress = NormaliseAddress(dto.DestinationAddress);
        var destinationPostCode = StandardisePostcode(dto.DestinationPostCode);
        var phoneNumber = StandardisePhone(dto.PhoneNumber);

        // Track whether pricing-sensitive fields changed
        bool needsReprice = !booking.ManuallyPriced && (
            booking.PickupAddress != pickupAddress ||
            booking.PickupPostCode != pickupPostCode ||
            booking.DestinationAddress != destinationAddress ||
            booking.DestinationPostCode != destinationPostCode ||
            booking.Passengers != dto.Passengers ||
            (int)booking.VehicleType != dto.VehicleType ||
            booking.AccountNumber != dto.AccountNumber ||
            booking.ChargeFromBase != dto.ChargeFromBase);

        // Update fields
        booking.PickupAddress = pickupAddress;
        booking.PickupPostCode = pickupPostCode;
        booking.DestinationAddress = destinationAddress;
        booking.DestinationPostCode = destinationPostCode;
        booking.Details = dto.Details;
        booking.PassengerName = dto.PassengerName;
        booking.Passengers = dto.Passengers;
        booking.PhoneNumber = phoneNumber;
        booking.Email = dto.Email;
        booking.PickupDateTime = dto.PickupDateTime;
        booking.ArriveBy = dto.ArriveBy;
        booking.IsASAP = dto.IsASAP;
        booking.Scope = (BookingScope)dto.Scope;
        booking.AccountNumber = dto.AccountNumber;
        booking.VehicleType = (VehicleType)dto.VehicleType;
        booking.ChargeFromBase = dto.ChargeFromBase;
        booking.IsSchoolRun = dto.IsSchoolRun;
        booking.DateUpdated = DateTime.UtcNow;
        booking.UpdatedByName = _currentUser.UserName;

        // Sync vias
        booking.Vias.Clear();
        if (dto.Vias is { Count: > 0 })
        {
            foreach (var via in dto.Vias)
            {
                booking.Vias.Add(new BookingVia
                {
                    Address = NormaliseAddress(via.Address) ?? via.Address,
                    PostCode = StandardisePostcode(via.PostCode),
                    ViaSequence = via.ViaSequence,
                });
            }
            needsReprice = true; // vias changed
        }

        // Auto-recalculate price if pricing-sensitive fields changed
        if (needsReprice)
        {
            var (driverPrice, accountPrice, mileage, mileageText, durationText) =
                await _pricing.CalculatePriceAsync(booking, ct);

            booking.Price = driverPrice;
            booking.PriceAccount = accountPrice;
            booking.Mileage = mileage;
            booking.MileageText = mileageText;
            booking.DurationText = durationText;
        }

        await _db.SaveChangesAsync(ct);
        await _publisher.Publish(new BookingAmendedEvent(booking.Id), ct);

        // Reload with navigation properties
        var result = await _db.Bookings
            .AsNoTracking()
            .Include(x => x.Vias)
            .Include(x => x.UserProfile)
            .FirstAsync(x => x.Id == booking.Id, ct);

        string? accountName = null;
        if (result.AccountNumber.HasValue)
        {
            accountName = await _db.Accounts
                .Where(a => a.AccountNumber == result.AccountNumber)
                .Select(a => a.CompanyName)
                .FirstOrDefaultAsync(ct);
        }

        return BookingMapper.ToDto(result, accountName);
    }
}
