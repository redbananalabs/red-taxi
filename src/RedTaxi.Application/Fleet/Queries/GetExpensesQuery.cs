using MediatR;
using Microsoft.EntityFrameworkCore;
using RedTaxi.Infrastructure.Persistence;

namespace RedTaxi.Application.Fleet.Queries;

public record ExpenseDto(
    int Id,
    int UserId,
    int Category,
    string? Description,
    decimal Amount,
    DateTime Date,
    string? ReceiptUrl,
    DateTime DateCreated);

public record GetExpensesQuery(int UserId) : IRequest<List<ExpenseDto>>;

public class GetExpensesQueryHandler : IRequestHandler<GetExpensesQuery, List<ExpenseDto>>
{
    private readonly TenantDbContext _db;

    public GetExpensesQueryHandler(TenantDbContext db) => _db = db;

    public async Task<List<ExpenseDto>> Handle(GetExpensesQuery request, CancellationToken cancellationToken)
    {
        return await _db.DriverExpenses
            .Where(e => e.UserId == request.UserId)
            .OrderByDescending(e => e.Date)
            .Select(e => new ExpenseDto(
                e.Id, e.UserId, (int)e.Category, e.Description,
                e.Amount, e.Date, e.ReceiptUrl, e.DateCreated))
            .ToListAsync(cancellationToken);
    }
}
