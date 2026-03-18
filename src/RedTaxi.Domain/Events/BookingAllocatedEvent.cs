using MediatR;

namespace RedTaxi.Domain.Events;

public record BookingAllocatedEvent(int BookingId, int DriverUserId, int? PreviousDriverUserId) : INotification;
