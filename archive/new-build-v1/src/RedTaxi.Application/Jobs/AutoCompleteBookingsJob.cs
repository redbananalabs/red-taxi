using MediatR;
using Microsoft.Extensions.Logging;
using RedTaxi.Application.Bookings.Commands;

namespace RedTaxi.Application.Jobs;

public class AutoCompleteBookingsJob
{
    private readonly IMediator _mediator;
    private readonly ILogger<AutoCompleteBookingsJob> _logger;

    public AutoCompleteBookingsJob(IMediator mediator, ILogger<AutoCompleteBookingsJob> logger)
    {
        _mediator = mediator;
        _logger = logger;
    }

    public async Task ExecuteAsync()
    {
        _logger.LogInformation("AutoCompleteBookingsJob started");
        var count = await _mediator.Send(new AutoCompleteBookingsCommand());
        _logger.LogInformation("AutoCompleteBookingsJob completed — {Count} bookings auto-completed", count);
    }
}
