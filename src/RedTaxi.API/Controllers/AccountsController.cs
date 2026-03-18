using MediatR;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using RedTaxi.Application.Accounts.Commands;
using RedTaxi.Application.Accounts.Queries;
using RedTaxi.Shared.DTOs;

namespace RedTaxi.API.Controllers;

[ApiController]
[Route("api/[controller]")]
[Authorize(Roles = "Admin,User")]
public class AccountsController : ControllerBase
{
    private readonly IMediator _mediator;

    public AccountsController(IMediator mediator)
    {
        _mediator = mediator;
    }

    [HttpGet]
    public async Task<ActionResult<List<AccountDto>>> List(
        [FromQuery] bool? activeOnly = null,
        [FromQuery] string? search = null)
    {
        var result = await _mediator.Send(new GetAccountsQuery(activeOnly, search));
        return Ok(result);
    }

    [HttpGet("{id:int}")]
    public async Task<ActionResult<AccountDto>> Get(int id)
    {
        var result = await _mediator.Send(new GetAccountByIdQuery(id));
        return result == null ? NotFound() : Ok(result);
    }

    [HttpPost]
    public async Task<ActionResult<AccountDto>> Create([FromBody] CreateAccountCommand command)
    {
        var result = await _mediator.Send(command);
        return CreatedAtAction(nameof(Get), new { id = result.Id }, result);
    }

    [HttpPut("{id:int}")]
    public async Task<ActionResult<AccountDto>> Update(int id, [FromBody] UpdateAccountCommand command)
    {
        if (id != command.Id)
            return BadRequest(new { message = "ID mismatch." });

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

    [HttpGet("{accountId:int}/passengers")]
    public async Task<ActionResult<List<AccountPassengerDto>>> GetPassengers(int accountId)
    {
        var result = await _mediator.Send(new GetAccountPassengersQuery(accountId));
        return Ok(result);
    }

    [HttpPost("{accountId:int}/passengers")]
    public async Task<ActionResult<AccountPassengerDto>> CreatePassenger(
        int accountId, [FromBody] CreateAccountPassengerCommand command)
    {
        if (accountId != command.AccountId)
            return BadRequest(new { message = "AccountId mismatch." });

        var result = await _mediator.Send(command);
        return CreatedAtAction(nameof(GetPassengers), new { accountId = result.AccountId }, result);
    }

    [HttpDelete("passengers/{id:int}")]
    public async Task<IActionResult> DeletePassenger(int id)
    {
        var result = await _mediator.Send(new DeleteAccountPassengerCommand(id));
        return result ? NoContent() : NotFound();
    }
}
