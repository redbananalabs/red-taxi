using MediatR;
using Microsoft.EntityFrameworkCore;
using RedTaxi.Domain.Entities;
using RedTaxi.Domain.Enums;
using RedTaxi.Infrastructure.Persistence;

namespace RedTaxi.Application.Messaging.Commands;

public record SendMessageCommand(
    int? DriverUserId,
    string MessageText) : IRequest<int>;

public class SendMessageCommandHandler : IRequestHandler<SendMessageCommand, int>
{
    private readonly TenantDbContext _db;

    public SendMessageCommandHandler(TenantDbContext db)
    {
        _db = db;
    }

    public async Task<int> Handle(SendMessageCommand request, CancellationToken cancellationToken)
    {
        if (request.DriverUserId.HasValue)
        {
            // MS09: Direct message to specific driver
            var message = new DriverMessage
            {
                UserId = request.DriverUserId,
                Message = request.MessageText,
                Read = false,
                DateCreated = DateTime.UtcNow,
            };

            _db.DriverMessages.Add(message);
            await _db.SaveChangesAsync(cancellationToken);
            return message.Id;
        }
        else
        {
            // MS10: Broadcast to all active drivers
            var activeDriverIds = await _db.UserProfiles
                .AsNoTracking()
                .Where(u => u.IsActive && u.Role == UserRole.Driver)
                .Select(u => u.UserId)
                .ToListAsync(cancellationToken);

            var firstId = 0;
            foreach (var driverId in activeDriverIds)
            {
                var message = new DriverMessage
                {
                    UserId = driverId,
                    Message = request.MessageText,
                    Read = false,
                    DateCreated = DateTime.UtcNow,
                };
                _db.DriverMessages.Add(message);
            }

            // Also add a broadcast record with null UserId for audit
            var broadcastMessage = new DriverMessage
            {
                UserId = null,
                Message = request.MessageText,
                Read = false,
                DateCreated = DateTime.UtcNow,
            };
            _db.DriverMessages.Add(broadcastMessage);

            await _db.SaveChangesAsync(cancellationToken);
            return broadcastMessage.Id;
        }
    }
}
