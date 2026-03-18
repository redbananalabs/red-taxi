using MediatR;

namespace RedTaxi.Domain.Events;

public record BookingCompletedEvent(int BookingId) : INotification;
