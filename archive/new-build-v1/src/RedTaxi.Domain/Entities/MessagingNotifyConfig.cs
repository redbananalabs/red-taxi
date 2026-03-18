using RedTaxi.Domain.Enums;

namespace RedTaxi.Domain.Entities;

public class MessagingNotifyConfig
{
    public int Id { get; set; }
    public SentMessageType EventType { get; set; }
    public SendMessageOfType Channel { get; set; }
    public bool IsEnabled { get; set; }
    public string? TemplateText { get; set; }
}
