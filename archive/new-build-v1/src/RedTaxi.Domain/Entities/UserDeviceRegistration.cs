using System;

namespace RedTaxi.Domain.Entities;

public class UserDeviceRegistration
{
    public int Id { get; set; }
    public int UserId { get; set; }
    public string DeviceToken { get; set; } = string.Empty;

    /// <summary>Push notification platform: "ios", "android", or "web".</summary>
    public string? Platform { get; set; }

    public DateTime RegisteredAt { get; set; }
    public DateTime? LastUsedAt { get; set; }
}
