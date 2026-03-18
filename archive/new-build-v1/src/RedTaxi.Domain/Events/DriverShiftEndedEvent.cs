using MediatR;

namespace RedTaxi.Domain.Events;

public record DriverShiftEndedEvent(int UserId) : INotification;
