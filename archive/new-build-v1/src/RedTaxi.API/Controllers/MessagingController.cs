using MediatR;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using RedTaxi.Application.Messaging.Commands;
using RedTaxi.Application.Messaging.Queries;
using RedTaxi.Shared.DTOs;

namespace RedTaxi.API.Controllers;

[ApiController]
[Route("api/[controller]")]
[Authorize(Roles = "Admin,User")]
public class MessagingController : ControllerBase
{
    private readonly IMediator _mediator;

    public MessagingController(IMediator mediator)
    {
        _mediator = mediator;
    }

    [HttpGet("config")]
    public async Task<ActionResult<List<MessagingConfigDto>>> GetConfig()
    {
        var result = await _mediator.Send(new GetMessagingConfigQuery());
        return Ok(result);
    }

    [HttpPut("config/{id:int}")]
    [Authorize(Roles = "Admin")]
    public async Task<ActionResult<MessagingConfigDto>> UpdateConfig(
        int id, [FromBody] UpdateMessagingConfigCommand command)
    {
        if (id != command.Id)
            return BadRequest(new { message = "ID mismatch." });

        var result = await _mediator.Send(command);
        return Ok(result);
    }

    [HttpPost("send")]
    public async Task<IActionResult> SendMessage([FromBody] SendMessageCommand command)
    {
        var id = await _mediator.Send(command);
        return Ok(new { id });
    }
}
