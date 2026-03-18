namespace RedTaxi.Shared.DTOs;

public record MessagingConfigDto(int Id, int EventType, int Channel, bool IsEnabled, string? TemplateText);
