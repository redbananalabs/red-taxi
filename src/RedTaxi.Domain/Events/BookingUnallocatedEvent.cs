using MediatR;

namespace RedTaxi.Domain.Events;

public record BookingUnallocatedEvent(int BookingId, int DriverUserId) : INotification;
