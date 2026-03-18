using MediatR;

namespace RedTaxi.Domain.Events;

public record DriverGpsUpdatedEvent(int UserId, decimal Lat, decimal Lng) : INotification;
