using MediatR;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using RedTaxi.Application.Pricing.Commands;
using RedTaxi.Application.Pricing.Queries;
using RedTaxi.Shared.DTOs;

namespace RedTaxi.API.Controllers;

[ApiController]
[Route("api/[controller]")]
[Authorize]
public class PricingController : ControllerBase
{
    private readonly IMediator _mediator;

    public PricingController(IMediator mediator) => _mediator = mediator;

    /// <summary>POST api/pricing/quote — get a price preview without saving.</summary>
    [HttpPost("quote")]
    public async Task<ActionResult<PriceResultDto>> GetQuote([FromBody] PriceQuoteRequest request, CancellationToken ct)
    {
        var result = await _mediator.Send(new GetPriceQuery(
            request.PickupAddress, request.PickupPostCode,
            request.DestinationAddress, request.DestinationPostCode,
            request.PickupDateTime, request.Passengers,
            request.VehicleType, request.AccountNumber, request.ChargeFromBase), ct);
        return Ok(result);
    }

    /// <summary>POST api/pricing/{bookingId}/recalculate — force recalculation on an existing booking.</summary>
    [HttpPost("{bookingId:int}/recalculate")]
    public async Task<ActionResult<PriceResultDto>> Recalculate(int bookingId, CancellationToken ct)
    {
        var result = await _mediator.Send(new RecalculatePriceCommand(bookingId), ct);
        return Ok(result);
    }

    /// <summary>PUT api/pricing/{bookingId}/manual — set a manual price override.</summary>
    [HttpPut("{bookingId:int}/manual")]
    public async Task<ActionResult<PriceResultDto>> SetManualPrice(
        int bookingId, [FromBody] ManualPriceRequest request, CancellationToken ct)
    {
        var result = await _mediator.Send(
            new ManualPriceUpdateCommand(bookingId, request.DriverPrice, request.AccountPrice), ct);
        return Ok(result);
    }
}

// ── Request DTOs (controller-level) ──────────────────────────────────────────
public record PriceQuoteRequest(
    string PickupAddress, string? PickupPostCode,
    string? DestinationAddress, string? DestinationPostCode,
    DateTime PickupDateTime, int Passengers, int VehicleType,
    int? AccountNumber, bool ChargeFromBase);

public record ManualPriceRequest(decimal DriverPrice, decimal AccountPrice);
