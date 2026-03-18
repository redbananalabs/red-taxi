using System.Text.Json;
using Hangfire;
using MediatR;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;
using RedTaxi.Application.Payments.Commands;
using RedTaxi.Domain.Enums;
using RedTaxi.Domain.Events;
using RedTaxi.Domain.Interfaces;
using RedTaxi.Infrastructure.ExternalServices;
using RedTaxi.Infrastructure.Persistence;
using Stripe;

namespace RedTaxi.API.Controllers;

[ApiController]
[Route("api/payments")]
[Authorize(Roles = "Admin,User")]
public class PaymentsController : ControllerBase
{
    private readonly IMediator _mediator;
    private readonly IPaymentService _paymentService;
    private readonly TenantDbContext _db;
    private readonly ILogger<PaymentsController> _logger;
    private readonly IPublisher _publisher;

    public PaymentsController(
        IMediator mediator,
        IPaymentService paymentService,
        TenantDbContext db,
        ILogger<PaymentsController> logger,
        IPublisher publisher)
    {
        _mediator = mediator;
        _paymentService = paymentService;
        _db = db;
        _logger = logger;
        _publisher = publisher;
    }

    /// <summary>Creates a payment link for a booking and optionally sends it to the customer.</summary>
    [HttpPost("create-link")]
    [Authorize(Roles = "Admin,Dispatcher,Controller")]
    public async Task<IActionResult> CreatePaymentLink([FromBody] CreatePaymentLinkRequest request)
    {
        var result = await _mediator.Send(new CreatePaymentLinkCommand(request.BookingId, request.Channel));
        return Ok(new { result.PaymentLink, result.OrderId });
    }

    /// <summary>Refunds a payment by order ID.</summary>
    [HttpPost("refund")]
    [Authorize(Roles = "Admin")]
    public async Task<IActionResult> Refund([FromBody] RefundRequest request)
    {
        var success = await _paymentService.RefundAsync(request.OrderId, request.Amount);

        if (success)
        {
            // Update booking payment status
            var booking = await _db.Bookings
                .FirstOrDefaultAsync(b => b.PaymentOrderId == request.OrderId);

            if (booking != null)
            {
                booking.PaymentStatus = PaymentStatus.None;
                await _db.SaveChangesAsync();
            }

            return Ok(new { refunded = true });
        }

        return BadRequest(new { refunded = false, error = "Refund failed." });
    }

    /// <summary>Revolut webhook handler for tenant ride payments.</summary>
    [HttpPost("webhook/revolut")]
    [AllowAnonymous]
    public async Task<IActionResult> RevolutWebhook()
    {
        var json = await new StreamReader(HttpContext.Request.Body).ReadToEndAsync();

        _logger.LogInformation("Revolut webhook received.");

        try
        {
            using var doc = JsonDocument.Parse(json);
            var root = doc.RootElement;

            var eventType = root.TryGetProperty("event", out var evt) ? evt.GetString() : null;
            var orderId = root.TryGetProperty("order_id", out var oid) ? oid.GetString() : null;

            if (eventType == "ORDER_COMPLETED" && !string.IsNullOrEmpty(orderId))
            {
                var booking = await _db.Bookings
                    .FirstOrDefaultAsync(b => b.PaymentOrderId == orderId);

                if (booking != null)
                {
                    booking.PaymentStatus = PaymentStatus.Paid;
                    await _db.SaveChangesAsync();
                    _logger.LogInformation("Booking {BookingId} marked as paid via Revolut order {OrderId}.",
                        booking.Id, orderId);

                    // PM09: Generate and send payment receipt
                    if (!string.IsNullOrEmpty(booking.Email) && !booking.PaymentReceiptSent)
                    {
                        BackgroundJob.Enqueue<PaymentReceiptJob>(job =>
                            job.SendAsync(booking.Id));
                    }
                }
            }
            else if (eventType == "ORDER_PAYMENT_FAILED" && !string.IsNullOrEmpty(orderId))
            {
                _logger.LogWarning("Revolut payment failed for order {OrderId}.", orderId);
            }
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error processing Revolut webhook.");
        }

        return Ok();
    }

    /// <summary>Tenant Stripe webhook handler for ride payments (different from platform Stripe webhook).</summary>
    [HttpPost("webhook/stripe")]
    [AllowAnonymous]
    public async Task<IActionResult> TenantStripeWebhook()
    {
        var json = await new StreamReader(HttpContext.Request.Body).ReadToEndAsync();

        _logger.LogInformation("Tenant Stripe payment webhook received.");

        try
        {
            // Note: For tenant Stripe webhooks, we cannot verify signature without knowing
            // which tenant's webhook secret to use. In production, use tenant-specific endpoints
            // or a shared webhook secret stored in CompanyConfig.
            using var doc = JsonDocument.Parse(json);
            var root = doc.RootElement;

            var eventType = root.TryGetProperty("type", out var typeProp) ? typeProp.GetString() : null;

            if (eventType == "checkout.session.completed")
            {
                var data = root.GetProperty("data").GetProperty("object");
                var metadata = data.TryGetProperty("metadata", out var meta) ? meta : (JsonElement?)null;
                var bookingIdStr = metadata?.TryGetProperty("booking_id", out var bid) == true ? bid.GetString() : null;

                if (int.TryParse(bookingIdStr, out var bookingId))
                {
                    var booking = await _db.Bookings
                        .FirstOrDefaultAsync(b => b.Id == bookingId);

                    if (booking != null)
                    {
                        booking.PaymentStatus = PaymentStatus.Paid;
                        await _db.SaveChangesAsync();
                        _logger.LogInformation("Booking {BookingId} marked as paid via tenant Stripe.", bookingId);

                        // PM09: Generate and send payment receipt
                        if (!string.IsNullOrEmpty(booking.Email) && !booking.PaymentReceiptSent)
                        {
                            BackgroundJob.Enqueue<PaymentReceiptJob>(job =>
                                job.SendAsync(booking.Id));
                        }
                    }
                }
            }
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error processing tenant Stripe webhook.");
        }

        return Ok();
    }

    public record CreatePaymentLinkRequest(int BookingId, string? Channel);
    public record RefundRequest(string OrderId, decimal Amount);
}

public class PaymentReceiptJob
{
    private readonly TenantDbContext _db;
    private readonly IEmailService _emailService;
    private readonly ILogger<PaymentReceiptJob> _logger;

    public PaymentReceiptJob(TenantDbContext db, IEmailService emailService, ILogger<PaymentReceiptJob> logger)
    {
        _db = db;
        _emailService = emailService;
        _logger = logger;
    }

    public async Task SendAsync(int bookingId)
    {
        var booking = await _db.Bookings.FirstOrDefaultAsync(b => b.Id == bookingId);
        if (booking == null || string.IsNullOrEmpty(booking.Email) || booking.PaymentReceiptSent)
            return;

        var config = await _db.CompanyConfigs.AsNoTracking().FirstOrDefaultAsync();
        var companyName = config?.CompanyName ?? "Red Taxi";

        var html = $"<h2>Payment Receipt</h2>"
            + $"<p>Thank you for your payment.</p>"
            + $"<p><strong>Company:</strong> {companyName}</p>"
            + $"<p><strong>Booking:</strong> #{booking.Id}</p>"
            + $"<p><strong>Pickup:</strong> {booking.PickupAddress}</p>"
            + $"<p><strong>Destination:</strong> {booking.DestinationAddress}</p>"
            + $"<p><strong>Amount Paid:</strong> &pound;{booking.Price:F2}</p>"
            + $"<p><strong>Date:</strong> {booking.PickupDateTime:dd/MM/yyyy HH:mm}</p>";

        await _emailService.SendAsync(booking.Email, $"Payment Receipt - {companyName}", html);

        booking.PaymentReceiptSent = true;
        await _db.SaveChangesAsync();

        _logger.LogInformation("Payment receipt sent for booking {BookingId} to {Email}.", bookingId, booking.Email);
    }
}
