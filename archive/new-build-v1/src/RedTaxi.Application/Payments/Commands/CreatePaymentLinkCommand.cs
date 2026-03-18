using MediatR;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;
using RedTaxi.Domain.Enums;
using RedTaxi.Domain.Interfaces;
using RedTaxi.Infrastructure.Persistence;

namespace RedTaxi.Application.Payments.Commands;

public record CreatePaymentLinkCommand(
    int BookingId,
    string? Channel) : IRequest<CreatePaymentLinkResult>;

public record CreatePaymentLinkResult(
    string PaymentLink,
    string OrderId);

public class CreatePaymentLinkCommandHandler : IRequestHandler<CreatePaymentLinkCommand, CreatePaymentLinkResult>
{
    private readonly TenantDbContext _db;
    private readonly IPaymentService _paymentService;
    private readonly IMessageService _messageService;
    private readonly ICurrentUserService _currentUser;
    private readonly ILogger<CreatePaymentLinkCommandHandler> _logger;

    public CreatePaymentLinkCommandHandler(
        TenantDbContext db,
        IPaymentService paymentService,
        IMessageService messageService,
        ICurrentUserService currentUser,
        ILogger<CreatePaymentLinkCommandHandler> logger)
    {
        _db = db;
        _paymentService = paymentService;
        _messageService = messageService;
        _currentUser = currentUser;
        _logger = logger;
    }

    public async Task<CreatePaymentLinkResult> Handle(CreatePaymentLinkCommand request, CancellationToken ct)
    {
        var booking = await _db.Bookings
            .FirstOrDefaultAsync(b => b.Id == request.BookingId, ct)
            ?? throw new InvalidOperationException($"Booking {request.BookingId} not found.");

        if (booking.Price <= 0)
            throw new InvalidOperationException("Booking has no price set.");

        var phone = booking.PhoneNumber
            ?? throw new InvalidOperationException("Booking has no phone number for payment link delivery.");

        // Create payment link
        var (paymentLink, orderId) = await _paymentService.CreatePaymentLinkAsync(
            booking.Id, booking.Price, phone, ct);

        // Update booking with payment info
        booking.PaymentLink = paymentLink;
        booking.PaymentOrderId = orderId;
        booking.PaymentLinkSentBy = _currentUser.UserName ?? "System";
        booking.PaymentLinkSentOn = DateTime.UtcNow;
        booking.PaymentStatus = PaymentStatus.AwaitingPayment;

        await _db.SaveChangesAsync(ct);

        // Send payment link to customer via configured channel
        var channel = ResolveChannel(request.Channel);
        if (channel != SendMessageOfType.None)
        {
            var config = await _db.CompanyConfigs.AsNoTracking().FirstOrDefaultAsync(ct);
            var companyName = config?.CompanyName ?? "Red Taxi";
            var message = $"Hi {booking.PassengerName ?? "there"}, please pay for your booking with {companyName}: {paymentLink}";

            try
            {
                await _messageService.SendAsync(channel, phone, message, ct);
                _logger.LogInformation("Payment link sent to {Phone} via {Channel} for booking {BookingId}.",
                    phone, channel, booking.Id);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Failed to send payment link to {Phone} via {Channel}.", phone, channel);
                // Don't fail the whole operation — link was still created
            }
        }

        return new CreatePaymentLinkResult(paymentLink, orderId);
    }

    private static SendMessageOfType ResolveChannel(string? channel) => channel?.ToLowerInvariant() switch
    {
        "sms" => SendMessageOfType.Sms,
        "whatsapp" => SendMessageOfType.WhatsApp,
        "push" => SendMessageOfType.Push,
        _ => SendMessageOfType.Sms, // Default to SMS
    };
}
