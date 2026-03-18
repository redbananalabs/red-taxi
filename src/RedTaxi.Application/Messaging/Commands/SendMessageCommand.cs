using MediatR;
using RedTaxi.Domain.Entities;
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
}
