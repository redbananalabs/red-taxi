using MediatR;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using RedTaxi.Application.Bookings.Commands;
using RedTaxi.Application.Bookings.Queries;
using RedTaxi.Shared.DTOs;

namespace RedTaxi.API.Controllers;

[ApiController]
[Route("api/[controller]")]
[Authorize]
public class BookingsController : ControllerBase
{
    private readonly IMediator _mediator;

    public BookingsController(IMediator mediator) => _mediator = mediator;

    /// <summary>GET api/bookings/{id}</summary>
    [HttpGet("{id:int}")]
    public async Task<ActionResult<BookingDto>> GetById(int id, CancellationToken ct)
    {
        var result = await _mediator.Send(new GetBookingByIdQuery(id), ct);
        return result is null ? NotFound() : Ok(result);
    }

    /// <summary>GET api/bookings/today?date=2026-03-18</summary>
    [HttpGet("today")]
    [AllowAnonymous]
    public async Task<ActionResult<List<BookingDto>>> GetToday([FromQuery] DateTime? date, CancellationToken ct)
    {
        var result = await _mediator.Send(new GetBookingsTodayQuery(date), ct);
        return Ok(result);
    }

    /// <summary>GET api/bookings/scheduler?start=...&end=...</summary>
    [HttpGet("scheduler")]
    public async Task<ActionResult<List<BookingDto>>> GetSchedulerView(
        [FromQuery] DateTime start, [FromQuery] DateTime end, CancellationToken ct)
    {
        var result = await _mediator.Send(new GetSchedulerViewQuery(start, end), ct);
        return Ok(result);
    }

    /// <summary>GET api/bookings/search?searchTerm=...&page=1&pageSize=50</summary>
    [HttpGet("search")]
    public async Task<ActionResult<FindBookingsResult>> Search(
        [FromQuery] string? searchTerm,
        [FromQuery] DateTime? fromDate,
        [FromQuery] DateTime? toDate,
        [FromQuery] int? accountNumber,
        [FromQuery] int? driverUserId,
        [FromQuery] bool includeCancelled = false,
        [FromQuery] int page = 1,
        [FromQuery] int pageSize = 50,
        CancellationToken ct = default)
    {
        var result = await _mediator.Send(new FindBookingsQuery(
            searchTerm, fromDate, toDate, accountNumber, driverUserId,
            includeCancelled, page, pageSize), ct);
        return Ok(result);
    }

    /// <summary>GET api/bookings/by-driver/{driverUserId}?date=...</summary>
    [HttpGet("by-driver/{driverUserId:int}")]
    public async Task<ActionResult<List<BookingDto>>> GetByDriver(
        int driverUserId, [FromQuery] DateTime? date, CancellationToken ct)
    {
        var result = await _mediator.Send(new GetBookingsByDriverQuery(driverUserId, date), ct);
        return Ok(result);
    }

    /// <summary>POST api/bookings</summary>
    [HttpPost]
    public async Task<ActionResult<BookingDto>> Create([FromBody] BookingCreateDto dto, CancellationToken ct)
    {
        var result = await _mediator.Send(new CreateBookingCommand(dto), ct);
        return CreatedAtAction(nameof(GetById), new { id = result.Id }, result);
    }

    /// <summary>PUT api/bookings</summary>
    [HttpPut]
    public async Task<ActionResult<BookingDto>> Update([FromBody] BookingUpdateDto dto, CancellationToken ct)
    {
        var result = await _mediator.Send(new UpdateBookingCommand(dto), ct);
        return Ok(result);
    }

    /// <summary>POST api/bookings/{id}/cancel?isCOA=false</summary>
    [HttpPost("{id:int}/cancel")]
    public async Task<ActionResult> Cancel(int id, [FromQuery] bool isCOA = false, CancellationToken ct = default)
    {
        var result = await _mediator.Send(new CancelBookingCommand(id, isCOA), ct);
        return result ? Ok() : BadRequest("Booking already cancelled.");
    }

    /// <summary>POST api/bookings/{id}/complete</summary>
    [HttpPost("{id:int}/complete")]
    public async Task<ActionResult> Complete(int id, CancellationToken ct)
    {
        var result = await _mediator.Send(new CompleteBookingCommand(id), ct);
        return result ? Ok() : BadRequest("Booking already completed.");
    }

    /// <summary>POST api/bookings/{id}/duplicate?newPickupDateTime=...</summary>
    [HttpPost("{id:int}/duplicate")]
    public async Task<ActionResult<BookingDto>> Duplicate(
        int id, [FromQuery] DateTime newPickupDateTime, CancellationToken ct)
    {
        var result = await _mediator.Send(new DuplicateBookingCommand(id, newPickupDateTime), ct);
        return CreatedAtAction(nameof(GetById), new { id = result.Id }, result);
    }

    /// <summary>POST api/bookings/merge — Merge two school run bookings</summary>
    [HttpPost("merge")]
    public async Task<ActionResult<BookingDto>> MergeSchoolRuns(
        [FromBody] MergeSchoolRunsRequest request, CancellationToken ct)
    {
        var result = await _mediator.Send(
            new MergeSchoolRunsCommand(request.SourceBookingId, request.TargetBookingId), ct);
        return Ok(result);
    }

    /// <summary>POST api/bookings/{id}/generate-block — Generate individual bookings from recurrence rules</summary>
    [HttpPost("{id:int}/generate-block")]
    public async Task<ActionResult<List<BookingDto>>> GenerateBlock(int id, CancellationToken ct)
    {
        var result = await _mediator.Send(new GenerateBlockBookingsCommand(id), ct);
        return Ok(result);
    }

    /// <summary>POST api/bookings/{id}/return — Create a return booking with reversed addresses</summary>
    [HttpPost("{id:int}/return")]
    public async Task<ActionResult<BookingDto>> CreateReturn(
        int id, [FromQuery] DateTime returnPickupDateTime, CancellationToken ct)
    {
        var result = await _mediator.Send(new CreateReturnBookingCommand(id, returnPickupDateTime), ct);
        return CreatedAtAction(nameof(GetById), new { id = result.Id }, result);
    }

    /// <summary>POST api/bookings/auto-complete — Hangfire job endpoint to auto-complete forgotten bookings</summary>
    [HttpPost("auto-complete")]
    public async Task<ActionResult<int>> AutoComplete(CancellationToken ct)
    {
        var count = await _mediator.Send(new AutoCompleteBookingsCommand(), ct);
        return Ok(count);
    }

    /// <summary>GET api/bookings/phone-lookup?phone={number} — BK27: Phone Number History Lookup</summary>
    [HttpGet("phone-lookup")]
    public async Task<ActionResult<PhoneLookupResult>> PhoneLookup(
        [FromQuery] string phone, CancellationToken ct)
    {
        if (string.IsNullOrWhiteSpace(phone))
            return BadRequest("Phone number is required.");

        var result = await _mediator.Send(new PhoneLookupQuery(phone), ct);
        return Ok(result);
    }

    /// <summary>POST api/bookings/cancel-range — Cancel a range of block bookings</summary>
    [HttpPost("cancel-range")]
    public async Task<ActionResult<int>> CancelRange(
        [FromBody] CancelBookingRangeRequest request, CancellationToken ct)
    {
        var count = await _mediator.Send(
            new CancelBookingRangeCommand(request.BookingId, request.CancelAll, request.CancelFromDate), ct);
        return Ok(count);
    }
}

// ── Request DTOs for controller endpoints ───────────────────────────────────
public record MergeSchoolRunsRequest(int SourceBookingId, int TargetBookingId);
public record CancelBookingRangeRequest(int BookingId, bool CancelAll, DateTime? CancelFromDate);
