using MediatR;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using RedTaxi.Application.Config.Commands;
using RedTaxi.Application.Config.Queries;
using RedTaxi.Shared.DTOs;

namespace RedTaxi.API.Controllers;

[ApiController]
[Route("api/[controller]")]
[Authorize]
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
}
