using MediatR;

namespace RedTaxi.Domain.Events;

public record BookingAmendedEvent(int BookingId) : INotification;
