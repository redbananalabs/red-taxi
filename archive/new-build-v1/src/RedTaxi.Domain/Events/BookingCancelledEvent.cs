using MediatR;

namespace RedTaxi.Domain.Events;

public record BookingCancelledEvent(int BookingId, bool IsCOA) : INotification;
