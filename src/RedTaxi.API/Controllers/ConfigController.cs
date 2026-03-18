using MediatR;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using RedTaxi.Application.Config.Commands;
using RedTaxi.Application.Config.Queries;
using RedTaxi.Shared.DTOs;

namespace RedTaxi.API.Controllers;

[ApiController]
[Route("api/[controller]")]
[Authorize(Roles = "Admin")]
public class ConfigController : ControllerBase
{
    private readonly IMediator _mediator;

    public ConfigController(IMediator mediator)
    {
        _mediator = mediator;
    }

    [HttpGet]
    public async Task<ActionResult<CompanyConfigDto>> Get()
    {
        var result = await _mediator.Send(new GetCompanyConfigQuery());
        return result == null ? NotFound() : Ok(result);
    }

    [HttpPut]
    [Authorize(Roles = "Admin")]
    public async Task<ActionResult<CompanyConfigDto>> Update([FromBody] UpdateCompanyConfigCommand command)
    {
        var result = await _mediator.Send(command);
        return Ok(result);
    }

    // ---- Local POIs ----

    [HttpGet("pois")]
    public async Task<ActionResult<List<LocalPOIDto>>> GetPOIs()
    {
        var result = await _mediator.Send(new GetLocalPOIsQuery());
        return Ok(result);
    }

    [HttpPost("pois")]
    [Authorize(Roles = "Admin")]
    public async Task<ActionResult<int>> CreatePOI([FromBody] CreateLocalPOICommand command)
    {
        var id = await _mediator.Send(command);
        return CreatedAtAction(nameof(GetPOIs), null, new { id });
    }

    [HttpPut("pois/{id:int}")]
    [Authorize(Roles = "Admin")]
    public async Task<IActionResult> UpdatePOI(int id, [FromBody] UpdateLocalPOICommand command)
    {
        if (id != command.Id)
            return BadRequest(new { message = "Id mismatch." });

        try
        {
            await _mediator.Send(command);
            return NoContent();
        }
        catch (KeyNotFoundException)
        {
            return NotFound();
        }
    }

    [HttpDelete("pois/{id:int}")]
    [Authorize(Roles = "Admin")]
    public async Task<IActionResult> DeletePOI(int id)
    {
        var result = await _mediator.Send(new DeleteLocalPOICommand(id));
        return result ? NoContent() : NotFound();
    }
}
