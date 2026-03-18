using MediatR;

namespace RedTaxi.Domain.Events;

public record DriverShiftStartedEvent(int UserId) : INotification;
