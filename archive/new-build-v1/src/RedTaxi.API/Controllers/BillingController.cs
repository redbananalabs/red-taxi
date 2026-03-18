using MediatR;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using RedTaxi.Application.Billing.Commands;
using RedTaxi.Application.Billing.Queries;
using RedTaxi.Shared.DTOs;

namespace RedTaxi.API.Controllers;

[ApiController]
[Route("api/[controller]")]
[Authorize(Roles = "Admin")]
public class BillingController : ControllerBase
{
    private readonly IMediator _mediator;

    public BillingController(IMediator mediator)
    {
        _mediator = mediator;
    }

    // ---- Invoicing ----

    [HttpGet("chargeable-jobs")]
    public async Task<ActionResult<List<ChargeableJobDto>>> GetChargeableJobs(
        [FromQuery] int accountNumber,
        [FromQuery] DateTime from,
        [FromQuery] DateTime to)
    {
        var result = await _mediator.Send(new GetChargeableJobsQuery(accountNumber, from, to));
        return Ok(result);
    }

    [HttpGet("chargeable-grouped")]
    public async Task<ActionResult<GroupedJobsResult>> GetGroupedChargeableJobs(
        [FromQuery] int accountNumber,
        [FromQuery] DateTime from,
        [FromQuery] DateTime to)
    {
        var result = await _mediator.Send(new GetGroupedChargeableJobsQuery(accountNumber, from, to));
        return Ok(result);
    }

    [HttpPost("post-for-invoicing")]
    public async Task<ActionResult<int>> PostJobsForInvoicing([FromBody] PostJobsForInvoicingCommand command)
    {
        var count = await _mediator.Send(command);
        return Ok(new { jobsPosted = count });
    }

    [HttpPost("invoices")]
    public async Task<ActionResult<InvoiceDto>> CreateInvoice([FromBody] CreateInvoiceCommand command)
    {
        try
        {
            var result = await _mediator.Send(command);
            return CreatedAtAction(nameof(GetInvoices), null, result);
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

    [HttpGet("invoices")]
    public async Task<ActionResult<List<InvoiceDto>>> GetInvoices(
        [FromQuery] int? accountNumber = null,
        [FromQuery] bool? unpaidOnly = null)
    {
        var result = await _mediator.Send(new GetInvoicesQuery(accountNumber, unpaidOnly));
        return Ok(result);
    }

    [HttpPost("invoices/{id:int}/mark-paid")]
    public async Task<IActionResult> MarkInvoicePaid(int id)
    {
        var result = await _mediator.Send(new MarkInvoicePaidCommand(id));
        return result ? NoContent() : NotFound();
    }

    [HttpPost("credit-notes")]
    public async Task<ActionResult<int>> CreateCreditNote([FromBody] CreateCreditNoteCommand command)
    {
        try
        {
            var id = await _mediator.Send(command);
            return CreatedAtAction(nameof(GetInvoices), null, new { id });
        }
        catch (KeyNotFoundException ex)
        {
            return NotFound(new { message = ex.Message });
        }
    }

    // ---- Statements ----

    [HttpPost("post-for-statement")]
    public async Task<ActionResult<int>> PostJobsForStatement([FromBody] PostJobsForStatementCommand command)
    {
        var count = await _mediator.Send(command);
        return Ok(new { jobsPosted = count });
    }

    [HttpPost("statements")]
    public async Task<ActionResult<StatementDto>> CreateStatement([FromBody] CreateStatementCommand command)
    {
        try
        {
            var result = await _mediator.Send(command);
            return CreatedAtAction(nameof(GetStatements), null, result);
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

    [HttpGet("statements")]
    public async Task<ActionResult<List<StatementDto>>> GetStatements(
        [FromQuery] int? driverUserId = null)
    {
        var result = await _mediator.Send(new GetStatementsQuery(driverUserId));
        return Ok(result);
    }

    // ---- VAT ----

    [HttpGet("vat-outputs")]
    public async Task<ActionResult<VatOutputDto>> GetVatOutputs(
        [FromQuery] DateTime from,
        [FromQuery] DateTime to)
    {
        var result = await _mediator.Send(new GetVatOutputsQuery(from, to));
        return Ok(result);
    }
}
