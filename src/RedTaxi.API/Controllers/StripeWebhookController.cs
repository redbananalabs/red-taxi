using MediatR;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging;
using RedTaxi.Application.Tenancy.Commands;
using Stripe;

namespace RedTaxi.API.Controllers;

[ApiController]
[Route("api/stripe/webhook")]
public class StripeWebhookController : ControllerBase
{
    private readonly IConfiguration _configuration;
    private readonly IMediator _mediator;
    private readonly ILogger<StripeWebhookController> _logger;

    public StripeWebhookController(
        IConfiguration configuration,
        IMediator mediator,
        ILogger<StripeWebhookController> logger)
    {
        _configuration = configuration;
        _mediator = mediator;
        _logger = logger;
    }

    [HttpPost]
    public async Task<IActionResult> HandleWebhook()
    {
        var json = await new StreamReader(HttpContext.Request.Body).ReadToEndAsync();
        var webhookSecret = _configuration["Stripe:WebhookSecret"];

        Event stripeEvent;
        try
        {
            stripeEvent = EventUtility.ConstructEvent(
                json,
                Request.Headers["Stripe-Signature"],
                webhookSecret);
        }
        catch (StripeException ex)
        {
            _logger.LogWarning(ex, "Invalid Stripe webhook signature.");
            return BadRequest("Invalid signature.");
        }

        _logger.LogInformation("Stripe webhook received: {EventType} ({EventId})", stripeEvent.Type, stripeEvent.Id);

        try
        {
            switch (stripeEvent.Type)
            {
                case "checkout.session.completed":
                {
                    var session = stripeEvent.Data.Object as Stripe.Checkout.Session;
                    if (session?.CustomerId != null)
                    {
                        await _mediator.Send(new ProvisionTenantCommand(
                            StripeCustomerId: session.CustomerId,
                            StripeSubscriptionId: session.SubscriptionId,
                            CustomerEmail: session.CustomerEmail));
                    }
                    break;
                }

                case "customer.subscription.created":
                {
                    var subscription = stripeEvent.Data.Object as Subscription;
                    if (subscription != null)
                    {
                        await _mediator.Send(new UpdateTenantSubscriptionCommand(
                            StripeCustomerId: subscription.CustomerId,
                            StripeSubscriptionId: subscription.Id,
                            Status: subscription.Status,
                            EventType: stripeEvent.Type,
                            PriceId: subscription.Items?.Data?.FirstOrDefault()?.Price?.Id,
                            CurrentPeriodEnd: subscription.CurrentPeriodEnd,
                            CancelAtPeriodEnd: subscription.CancelAtPeriodEnd));
                    }
                    break;
                }

                case "customer.subscription.updated":
                {
                    var subscription = stripeEvent.Data.Object as Subscription;
                    if (subscription != null)
                    {
                        await _mediator.Send(new UpdateTenantSubscriptionCommand(
                            StripeCustomerId: subscription.CustomerId,
                            StripeSubscriptionId: subscription.Id,
                            Status: subscription.Status,
                            EventType: stripeEvent.Type,
                            PriceId: subscription.Items?.Data?.FirstOrDefault()?.Price?.Id,
                            CurrentPeriodEnd: subscription.CurrentPeriodEnd,
                            CancelAtPeriodEnd: subscription.CancelAtPeriodEnd));
                    }
                    break;
                }

                case "customer.subscription.deleted":
                {
                    var subscription = stripeEvent.Data.Object as Subscription;
                    if (subscription != null)
                    {
                        await _mediator.Send(new UpdateTenantSubscriptionCommand(
                            StripeCustomerId: subscription.CustomerId,
                            StripeSubscriptionId: subscription.Id,
                            Status: "canceled",
                            EventType: stripeEvent.Type,
                            PriceId: null,
                            CurrentPeriodEnd: subscription.CurrentPeriodEnd,
                            CancelAtPeriodEnd: subscription.CancelAtPeriodEnd));
                    }
                    break;
                }

                case "invoice.paid":
                {
                    var invoice = stripeEvent.Data.Object as Invoice;
                    _logger.LogInformation("Invoice {InvoiceId} paid for customer {CustomerId}.",
                        invoice?.Id, invoice?.CustomerId);
                    // Payment recorded — no further action needed for MVP
                    break;
                }

                case "invoice.payment_failed":
                {
                    var invoice = stripeEvent.Data.Object as Invoice;
                    _logger.LogWarning("Invoice {InvoiceId} payment failed for customer {CustomerId}.",
                        invoice?.Id, invoice?.CustomerId);
                    // TODO: Send failure email via messaging service
                    break;
                }

                case "customer.subscription.trial_will_end":
                {
                    var subscription = stripeEvent.Data.Object as Subscription;
                    _logger.LogInformation("Trial ending soon for customer {CustomerId}, subscription {SubscriptionId}.",
                        subscription?.CustomerId, subscription?.Id);
                    // TODO: Send trial-ending reminder email
                    break;
                }

                default:
                    _logger.LogDebug("Unhandled Stripe event type: {EventType}", stripeEvent.Type);
                    break;
            }
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error processing Stripe webhook {EventType}.", stripeEvent.Type);
            // Return 200 to prevent Stripe from retrying — we log the error
        }

        return Ok();
    }
}
