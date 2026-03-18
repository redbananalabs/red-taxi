using RedTaxi.Domain.Enums;

namespace RedTaxi.Domain.Interfaces;

public interface IMessageService
{
    Task SendAsync(SendMessageOfType channel, string recipient, string message, CancellationToken ct = default);
}
