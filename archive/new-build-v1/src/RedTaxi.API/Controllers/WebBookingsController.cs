using MediatR;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using RedTaxi.Application.WebBooking.Commands;
using RedTaxi.Application.WebBooking.Queries;

namespace RedTaxi.API.Controllers;

[ApiController]
[Route("api/web-bookings")]
[Authorize(Roles = "Admin,User")]
public class WebBookingsController : ControllerBase
{
    private readonly IMediator _mediator;

    public WebBookingsController(IMediator mediator)
    {
        _mediator = mediator;
    }

    [HttpGet("pending")]
    public async Task<ActionResult<List<PendingWebBookingDto>>> GetPending()
    {
        var result = await _mediator.Send(new GetPendingWebBookingsQuery());
        return Ok(result);
    }

    [HttpPost("{id:int}/accept")]
    [Authorize(Roles = "Admin,Dispatcher,Controller")]
    public async Task<IActionResult> Accept(int id)
    {
        try
        {
            var bookingId = await _mediator.Send(new AcceptWebBookingCommand(id));
            return Ok(new { bookingId });
        }
        catch (KeyNotFoundException ex)
        {
            return NotFound(new { message = ex.Message });
        }
        catch (InvalidOperationException ex)
        {
            return BadRequest(new { message = ex.Message });
        }
    }

    [HttpPost("{id:int}/reject")]
    [Authorize(Roles = "Admin,Dispatcher,Controller")]
    public async Task<IActionResult> Reject(int id, [FromBody] RejectWebBookingRequest request)
    {
        try
        {
            await _mediator.Send(new RejectWebBookingCommand(id, request.Reason));
            return NoContent();
        }
        catch (KeyNotFoundException ex)
        {
            return NotFound(new { message = ex.Message });
        }
        catch (InvalidOperationException ex)
        {
            return BadRequest(new { message = ex.Message });
        }
    }

    public record RejectWebBookingRequest(string? Reason);
}
