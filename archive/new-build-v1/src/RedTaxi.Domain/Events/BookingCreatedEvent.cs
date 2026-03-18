using MediatR;

namespace RedTaxi.Domain.Events;

public record BookingCreatedEvent(int BookingId) : INotification;
