using MediatR;

namespace RedTaxi.Domain.Events;

public record PaymentReceivedEvent(int BookingId, string PaymentOrderId) : INotification;
