namespace RedTaxi.Domain.Interfaces;

public interface IPushNotificationService
{
    Task SendToDeviceAsync(
        string deviceToken,
        string title,
        string body,
        Dictionary<string, string>? data = null,
        CancellationToken ct = default);

    Task SendToUserAsync(
        int userId,
        string title,
        string body,
        Dictionary<string, string>? data = null,
        CancellationToken ct = default);
}
