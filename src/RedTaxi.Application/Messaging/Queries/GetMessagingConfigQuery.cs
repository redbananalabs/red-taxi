using MediatR;
using Microsoft.EntityFrameworkCore;
using RedTaxi.Infrastructure.Persistence;
using RedTaxi.Shared.DTOs;

namespace RedTaxi.Application.Messaging.Queries;

public record GetMessagingConfigQuery : IRequest<List<MessagingConfigDto>>;

public class GetMessagingConfigQueryHandler : IRequestHandler<GetMessagingConfigQuery, List<MessagingConfigDto>>
{
    private readonly TenantDbContext _db;

    public GetMessagingConfigQueryHandler(TenantDbContext db)
    {
        _db = db;
    }

    public async Task<List<MessagingConfigDto>> Handle(GetMessagingConfigQuery request, CancellationToken cancellationToken)
    {
        return await _db.MessagingNotifyConfigs
            .OrderBy(c => c.EventType)
            .Select(c => new MessagingConfigDto(
                c.Id, (int)c.EventType, (int)c.Channel,
                c.IsEnabled, c.TemplateText))
            .ToListAsync(cancellationToken);
    }
}
