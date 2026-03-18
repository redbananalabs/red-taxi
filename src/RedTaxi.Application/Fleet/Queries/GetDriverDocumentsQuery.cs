using MediatR;
using Microsoft.EntityFrameworkCore;
using RedTaxi.Infrastructure.Persistence;

namespace RedTaxi.Application.Fleet.Queries;

public record DriverDocumentDto(
    int Id,
    int UserId,
    int DocumentType,
    DateTime? ExpiryDate,
    string? DocumentUrl,
    DateTime? UploadedAt,
    string? Notes);

public record GetDriverDocumentsQuery(int UserId) : IRequest<List<DriverDocumentDto>>;

public class GetDriverDocumentsQueryHandler : IRequestHandler<GetDriverDocumentsQuery, List<DriverDocumentDto>>
{
    private readonly TenantDbContext _db;

    public GetDriverDocumentsQueryHandler(TenantDbContext db)
    {
        _db = db;
    }

    public async Task<List<DriverDocumentDto>> Handle(GetDriverDocumentsQuery request, CancellationToken cancellationToken)
    {
        return await _db.DocumentExpiries
            .Where(d => d.UserId == request.UserId)
            .OrderBy(d => d.DocumentType)
            .Select(d => new DriverDocumentDto(
                d.Id, d.UserId, (int)d.DocumentType,
                d.ExpiryDate, d.DocumentUrl, d.UploadedAt, d.Notes))
            .ToListAsync(cancellationToken);
    }
}
