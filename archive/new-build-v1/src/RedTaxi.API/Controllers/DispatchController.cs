using MediatR;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using RedTaxi.Application.Dispatch.Commands;
using RedTaxi.Application.Dispatch.Queries;
using RedTaxi.Shared.DTOs;

namespace RedTaxi.API.Controllers;

[ApiController]
[Route("api/[controller]")]
[Authorize(Roles = "Admin,User")]
public class DispatchController : ControllerBase
{
    private readonly IMediator _mediator;

    public DispatchController(IMediator mediator) => _mediator = mediator;

    /// <summary>GET api/dispatch/drivers?activeOnly=true</summary>
    [HttpGet("drivers")]
    public async Task<ActionResult<List<DriverDto>>> GetDrivers(
        [FromQuery] bool activeOnly = true, CancellationToken ct = default)
    {
        var result = await _mediator.Send(new GetDriverListQuery(activeOnly), ct);
        return Ok(result);
    }

    /// <summary>POST api/dispatch/allocate</summary>
    [HttpPost("allocate")]
    public async Task<ActionResult> Allocate([FromBody] AllocateRequest request, CancellationToken ct)
    {
        await _mediator.Send(new AllocateBookingCommand(request.BookingId, request.DriverUserId), ct);
        return Ok();
    }

    /// <summary>POST api/dispatch/soft-allocate</summary>
    [HttpPost("soft-allocate")]
    public async Task<ActionResult> SoftAllocate([FromBody] AllocateRequest request, CancellationToken ct)
    {
        await _mediator.Send(new SoftAllocateCommand(request.BookingId, request.DriverUserId), ct);
        return Ok();
    }

    /// <summary>POST api/dispatch/confirm-soft-allocates?date=2026-03-18</summary>
    [HttpPost("confirm-soft-allocates")]
    public async Task<ActionResult<int>> ConfirmSoftAllocates([FromQuery] DateTime date, CancellationToken ct)
    {
        var count = await _mediator.Send(new ConfirmSoftAllocatesCommand(date), ct);
        return Ok(new { confirmed = count });
    }

    /// <summary>POST api/dispatch/unallocate/{bookingId}</summary>
    [HttpPost("unallocate/{bookingId:int}")]
    public async Task<ActionResult> Unallocate(int bookingId, CancellationToken ct)
    {
        var result = await _mediator.Send(new UnallocateBookingCommand(bookingId), ct);
        return result ? Ok() : BadRequest("Booking was not allocated.");
    }

    /// <summary>POST api/dispatch/turn-down</summary>
    [HttpPost("turn-down")]
    public async Task<ActionResult> RecordTurnDown([FromBody] TurnDownRequest request, CancellationToken ct)
    {
        await _mediator.Send(new RecordTurnDownCommand(request.BookingId, request.DriverUserId, request.Reason), ct);
        return Ok();
    }
}

// ── Request DTOs (controller-level) ──────────────────────────────────────────
public record AllocateRequest(int BookingId, int DriverUserId);
public record TurnDownRequest(int BookingId, int? DriverUserId, string? Reason);
