using MediatR;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using RedTaxi.Application.Fleet.Commands;
using RedTaxi.Application.Fleet.Queries;
using RedTaxi.Shared.DTOs;
using DriverDocumentDto = RedTaxi.Shared.DTOs.DriverDocumentDto;
using ExpenseDto = RedTaxi.Application.Fleet.Queries.ExpenseDto;

namespace RedTaxi.API.Controllers;

[ApiController]
[Route("api/[controller]")]
[Authorize]
public class DriversController : ControllerBase
{
    private readonly IMediator _mediator;

    public DriversController(IMediator mediator)
    {
        _mediator = mediator;
    }

    [HttpGet("{userId:int}/profile")]
    public async Task<ActionResult<DriverDto>> GetProfile(int userId)
    {
        var result = await _mediator.Send(new GetDriverProfileQuery(userId));
        return result == null ? NotFound() : Ok(result);
    }

    [HttpPut("{userId:int}/profile")]
    public async Task<ActionResult<DriverDto>> UpdateProfile(int userId, [FromBody] UpdateDriverProfileCommand command)
    {
        if (userId != command.UserId)
            return BadRequest(new { message = "UserId mismatch." });

        try
        {
            var result = await _mediator.Send(command);
            return Ok(result);
        }
        catch (KeyNotFoundException)
        {
            return NotFound();
        }
    }

    [HttpGet("{userId:int}/availability")]
    public async Task<ActionResult<List<DriverAvailabilityDto>>> GetAvailability(
        int userId,
        [FromQuery] DateTime? from = null,
        [FromQuery] DateTime? to = null)
    {
        var result = await _mediator.Send(new GetDriverAvailabilityQuery(userId, from, to));
        return Ok(result);
    }

    [HttpPost("{userId:int}/availability")]
    public async Task<ActionResult<DriverAvailabilityDto>> SetAvailability(
        int userId, [FromBody] SetDriverAvailabilityCommand command)
    {
        if (userId != command.UserId)
            return BadRequest(new { message = "UserId mismatch." });

        var result = await _mediator.Send(command);
        return CreatedAtAction(nameof(GetAvailability), new { userId }, result);
    }

    [HttpPost("{userId:int}/gps")]
    public async Task<ActionResult<DriverLocationDto>> UpdateGps(
        int userId, [FromBody] UpdateDriverGpsCommand command)
    {
        if (userId != command.UserId)
            return BadRequest(new { message = "UserId mismatch." });

        var result = await _mediator.Send(command);
        return Ok(result);
    }

    [HttpPost("{userId:int}/shift")]
    public async Task<IActionResult> Shift(int userId, [FromBody] DriverShiftCommand command)
    {
        if (userId != command.UserId)
            return BadRequest(new { message = "UserId mismatch." });

        await _mediator.Send(command);
        return NoContent();
    }

    [HttpGet("{userId:int}/documents")]
    public async Task<ActionResult<List<DriverDocumentDto>>> GetDocuments(int userId)
    {
        var result = await _mediator.Send(new GetDriverDocumentsQuery(userId));
        return Ok(result);
    }

    [HttpPost("{userId:int}/documents")]
    public async Task<IActionResult> UploadDocument(int userId, [FromBody] UploadDocumentCommand command)
    {
        if (userId != command.UserId)
            return BadRequest(new { message = "UserId mismatch." });

        var id = await _mediator.Send(command);
        return CreatedAtAction(nameof(GetDocuments), new { userId }, new { id });
    }

    // ---- Expenses ----

    [HttpGet("{userId:int}/expenses")]
    public async Task<ActionResult<List<ExpenseDto>>> GetExpenses(int userId)
    {
        var result = await _mediator.Send(new GetExpensesQuery(userId));
        return Ok(result);
    }

    [HttpPost("{userId:int}/expenses")]
    public async Task<ActionResult<int>> AddExpense(int userId, [FromBody] AddExpenseCommand command)
    {
        if (userId != command.UserId)
            return BadRequest(new { message = "UserId mismatch." });

        var id = await _mediator.Send(command);
        return CreatedAtAction(nameof(GetExpenses), new { userId }, new { id });
    }
}
