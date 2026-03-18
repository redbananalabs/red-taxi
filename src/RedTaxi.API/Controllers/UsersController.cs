using MediatR;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using RedTaxi.Application.Identity.Queries;
using RedTaxi.Domain.Enums;
using RedTaxi.Shared.DTOs;

namespace RedTaxi.API.Controllers;

[ApiController]
[Route("api/[controller]")]
[Authorize]
public class UsersController : ControllerBase
{
    private readonly IMediator _mediator;

    public UsersController(IMediator mediator)
    {
        _mediator = mediator;
    }

    [HttpGet("{userId:int}")]
    public async Task<ActionResult<UserInfoDto>> Get(int userId)
    {
        var result = await _mediator.Send(new GetUserQuery(userId));
        return result == null ? NotFound() : Ok(result);
    }

    [HttpGet]
    public async Task<ActionResult<List<UserInfoDto>>> List(
        [FromQuery] UserRole? role = null,
        [FromQuery] bool? activeOnly = null)
    {
        var result = await _mediator.Send(new ListUsersQuery(role, activeOnly));
        return Ok(result);
    }
}
