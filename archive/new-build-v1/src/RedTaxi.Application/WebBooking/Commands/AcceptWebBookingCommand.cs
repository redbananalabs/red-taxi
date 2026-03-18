using MediatR;
using Microsoft.EntityFrameworkCore;
using RedTaxi.Domain.Entities;
using RedTaxi.Domain.Enums;
using RedTaxi.Domain.Interfaces;
using RedTaxi.Infrastructure.Persistence;

namespace RedTaxi.Application.WebBooking.Commands;

public record AcceptWebBookingCommand(int WebBookingId) : IRequest<int>;

public class AcceptWebBookingCommandHandler : IRequestHandler<AcceptWebBookingCommand, int>
{
    private readonly TenantDbContext _db;
    private readonly ICurrentUserService _currentUser;

    public AcceptWebBookingCommandHandler(TenantDbContext db, ICurrentUserService currentUser)
    {
        _db = db;
        _currentUser = currentUser;
    }

    public async Task<int> Handle(AcceptWebBookingCommand request, CancellationToken cancellationToken)
    {
        var webBooking = await _db.WebBookings
            .FirstOrDefaultAsync(w => w.Id == request.WebBookingId, cancellationToken)
            ?? throw new KeyNotFoundException($"WebBooking {request.WebBookingId} not found.");

        if (webBooking.Status != WebBookingStatus.Default)
            throw new InvalidOperationException($"WebBooking {request.WebBookingId} has already been processed.");

        // Create real booking from web booking
        var booking = new Booking
        {
            PickupAddress = webBooking.PickupAddress,
            PickupPostCode = webBooking.PickupPostCode ?? string.Empty,
            DestinationAddress = webBooking.DestinationAddress,
            DestinationPostCode = webBooking.DestinationPostCode,
            PassengerName = webBooking.PassengerName,
            PhoneNumber = webBooking.PhoneNumber,
            Email = webBooking.Email,
            PickupDateTime = webBooking.PickupDateTime,
            Details = webBooking.Details,
            Passengers = webBooking.Passengers,
            VehicleType = webBooking.VehicleType,
            AccountNumber = webBooking.AccountNumber,
            Scope = webBooking.AccountNumber.HasValue ? BookingScope.Account : BookingScope.Cash,
            Price = webBooking.Price ?? 0,
            BookedByName = "Web Booking",
            DateCreated = DateTime.UtcNow,
        };

        _db.Bookings.Add(booking);

        webBooking.Status = WebBookingStatus.Accepted;
        webBooking.ProcessedByName = _currentUser.UserName;
        webBooking.ProcessedAt = DateTime.UtcNow;

        await _db.SaveChangesAsync(cancellationToken);

        webBooking.ConvertedBookingId = booking.Id;
        await _db.SaveChangesAsync(cancellationToken);

        return booking.Id;
    }
}
