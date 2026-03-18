using Microsoft.AspNetCore.SignalR.Client;
using Microsoft.Extensions.Logging;
using RedTaxi.Shared.DTOs;

namespace RedTaxi.Blazor.Services;

public class SignalRService : IAsyncDisposable
{
    private readonly HubConnection _hub;
    private readonly DispatchState _state;
    private readonly ILogger<SignalRService> _logger;
    private bool _started;

    public SignalRService(
        IConfiguration configuration,
        DispatchState state,
        ILogger<SignalRService> logger)
    {
        _state = state;
        _logger = logger;

        var apiBase = configuration.GetValue<string>("ApiBaseUrl") ?? "https://localhost:5001";
        var hubUrl = $"{apiBase.TrimEnd('/')}/hubs/dispatch";

        _hub = new HubConnectionBuilder()
            .WithUrl(hubUrl)
            .WithAutomaticReconnect(new[]
            {
                TimeSpan.Zero,
                TimeSpan.FromSeconds(2),
                TimeSpan.FromSeconds(5),
                TimeSpan.FromSeconds(10),
                TimeSpan.FromSeconds(30),
                TimeSpan.FromSeconds(60)
            })
            .Build();

        RegisterHandlers();

        _hub.Reconnecting += ex =>
        {
            _logger.LogWarning(ex, "SignalR reconnecting...");
            IsConnected = false;
            OnConnectionChanged?.Invoke();
            return Task.CompletedTask;
        };

        _hub.Reconnected += connectionId =>
        {
            _logger.LogInformation("SignalR reconnected with connection {ConnectionId}.", connectionId);
            IsConnected = true;
            OnConnectionChanged?.Invoke();
            return Task.CompletedTask;
        };

        _hub.Closed += ex =>
        {
            _logger.LogWarning(ex, "SignalR connection closed.");
            IsConnected = false;
            OnConnectionChanged?.Invoke();
            return Task.CompletedTask;
        };
    }

    public bool IsConnected { get; private set; }

    /// <summary>Raised when a SignalR event is received and state has been updated.</summary>
    public event Action? OnStateUpdated;

    /// <summary>Raised when connection status changes.</summary>
    public event Action? OnConnectionChanged;

    public async Task StartAsync(CancellationToken ct = default)
    {
        if (_started) return;

        try
        {
            await _hub.StartAsync(ct);
            IsConnected = true;
            _started = true;
            _logger.LogInformation("SignalR connected to dispatch hub.");
            OnConnectionChanged?.Invoke();
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Failed to start SignalR connection. Will retry on next call.");
        }
    }

    private void RegisterHandlers()
    {
        _hub.On<BookingDto>("BookingCreated", dto =>
        {
            _logger.LogDebug("Received BookingCreated for booking {BookingId}.", dto.Id);
            OnStateUpdated?.Invoke();
        });

        _hub.On<BookingDto>("BookingUpdated", dto =>
        {
            _logger.LogDebug("Received BookingUpdated for booking {BookingId}.", dto.Id);

            // If the currently selected booking was updated, refresh it
            if (_state.SelectedBooking?.Id == dto.Id)
            {
                _state.SelectBooking(dto);
            }

            OnStateUpdated?.Invoke();
        });

        _hub.On<BookingCancelledPayload>("BookingCancelled", payload =>
        {
            _logger.LogDebug("Received BookingCancelled for booking {BookingId}.", payload.BookingId);

            // Close detail panel if the cancelled booking is selected
            if (_state.SelectedBooking?.Id == payload.BookingId)
            {
                _state.CloseBookingDetail();
            }

            OnStateUpdated?.Invoke();
        });

        _hub.On<BookingCompletedPayload>("BookingCompleted", payload =>
        {
            _logger.LogDebug("Received BookingCompleted for booking {BookingId}.", payload.BookingId);
            OnStateUpdated?.Invoke();
        });

        _hub.On<DriverLocationPayload>("DriverLocationUpdate", payload =>
        {
            // GPS updates are high-frequency — no debug log
            OnStateUpdated?.Invoke();
        });

        _hub.On<DriverShiftPayload>("DriverShiftChanged", payload =>
        {
            _logger.LogDebug("Received DriverShiftChanged for user {UserId} — online={IsOnline}.", payload.UserId, payload.IsOnline);
            OnStateUpdated?.Invoke();
        });

        _hub.On<WebBookingDto>("WebBookingSubmitted", dto =>
        {
            _logger.LogDebug("Received WebBookingSubmitted for web booking {WebBookingId}.", dto.Id);
            OnStateUpdated?.Invoke();
        });
    }

    public async ValueTask DisposeAsync()
    {
        if (_hub is not null)
        {
            await _hub.DisposeAsync();
        }
    }

    // Payload records for deserialization
    private record BookingCancelledPayload(int BookingId, bool IsCOA);
    private record BookingCompletedPayload(int BookingId);
    private record DriverLocationPayload(int UserId, decimal Lat, decimal Lng);
    private record DriverShiftPayload(int UserId, bool IsOnline);
}
