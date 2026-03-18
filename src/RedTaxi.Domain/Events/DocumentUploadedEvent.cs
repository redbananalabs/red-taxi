using MediatR;

namespace RedTaxi.Domain.Events;

public record DocumentUploadedEvent(int UserId, string DocumentType) : INotification;
