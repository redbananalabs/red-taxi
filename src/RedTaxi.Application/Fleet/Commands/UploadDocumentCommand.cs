using MediatR;
using RedTaxi.Domain.Entities;
using RedTaxi.Domain.Enums;
using RedTaxi.Infrastructure.Persistence;

namespace RedTaxi.Application.Fleet.Commands;

public record UploadDocumentCommand(
    int UserId,
    DocumentType DocumentType,
    string DocumentUrl,
    DateTime? ExpiryDate,
    string? Notes) : IRequest<int>;

public class UploadDocumentCommandHandler : IRequestHandler<UploadDocumentCommand, int>
{
    private readonly TenantDbContext _db;

    public UploadDocumentCommandHandler(TenantDbContext db)
    {
        _db = db;
    }

    public async Task<int> Handle(UploadDocumentCommand request, CancellationToken cancellationToken)
    {
        var doc = new DocumentExpiry
        {
            UserId = request.UserId,
            DocumentType = request.DocumentType,
            DocumentUrl = request.DocumentUrl,
            ExpiryDate = request.ExpiryDate,
            UploadedAt = DateTime.UtcNow,
            Notes = request.Notes,
        };

        _db.DocumentExpiries.Add(doc);
        await _db.SaveChangesAsync(cancellationToken);

        return doc.Id;
    }
}
