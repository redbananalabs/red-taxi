using MediatR;
using Microsoft.EntityFrameworkCore;
using RedTaxi.Domain.Entities;
using RedTaxi.Domain.Enums;
using RedTaxi.Infrastructure.Persistence;
using RedTaxi.Shared.DTOs;

namespace RedTaxi.Application.Messaging.Commands;

public record UpdateMessagingConfigCommand(
    int Id,
    SentMessageType EventType,
    SendMessageOfType Channel,
    bool IsEnabled,
    string? TemplateText) : IRequest<MessagingConfigDto>;

public class UpdateMessagingConfigCommandHandler : IRequestHandler<UpdateMessagingConfigCommand, MessagingConfigDto>
{
    private readonly TenantDbContext _db;

    public UpdateMessagingConfigCommandHandler(TenantDbContext db)
    {
        _db = db;
    }

    public async Task<MessagingConfigDto> Handle(UpdateMessagingConfigCommand request, CancellationToken cancellationToken)
    {
        var config = await _db.MessagingNotifyConfigs
            .FirstOrDefaultAsync(c => c.Id == request.Id, cancellationToken);

        if (config == null)
        {
            // Create new config entry
            config = new MessagingNotifyConfig
            {
                EventType = request.EventType,
                Channel = request.Channel,
                IsEnabled = request.IsEnabled,
                TemplateText = request.TemplateText,
            };
            _db.MessagingNotifyConfigs.Add(config);
        }
        else
        {
            config.EventType = request.EventType;
            config.Channel = request.Channel;
            config.IsEnabled = request.IsEnabled;
            config.TemplateText = request.TemplateText;
        }

        await _db.SaveChangesAsync(cancellationToken);

        return new MessagingConfigDto(
            config.Id, (int)config.EventType, (int)config.Channel,
            config.IsEnabled, config.TemplateText);
    }
}
