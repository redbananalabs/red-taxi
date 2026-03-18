namespace RedTaxi.Domain.Interfaces;

public interface IPaymentService
{
    Task<(string paymentLink, string orderId)> CreatePaymentLinkAsync(
        int bookingId,
        decimal amount,
        string customerPhone,
        CancellationToken ct = default);

    Task<bool> RefundAsync(
        string orderId,
        decimal amount,
        CancellationToken ct = default);
}
