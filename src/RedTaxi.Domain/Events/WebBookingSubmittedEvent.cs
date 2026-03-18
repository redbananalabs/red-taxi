using MediatR;

namespace RedTaxi.Domain.Events;

public record WebBookingSubmittedEvent(int WebBookingId) : INotification;
