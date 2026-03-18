using MediatR;
using RedTaxi.Domain.Entities;
using RedTaxi.Domain.Enums;
using RedTaxi.Infrastructure.Persistence;

namespace RedTaxi.Application.Fleet.Commands;

public record AddExpenseCommand(
    int UserId,
    ExpenseCategory Category,
    string? Description,
    decimal Amount,
    DateTime Date,
    string? ReceiptUrl) : IRequest<int>;

public class AddExpenseCommandHandler : IRequestHandler<AddExpenseCommand, int>
{
    private readonly TenantDbContext _db;

    public AddExpenseCommandHandler(TenantDbContext db) => _db = db;

    public async Task<int> Handle(AddExpenseCommand request, CancellationToken cancellationToken)
    {
        var expense = new DriverExpense
        {
            UserId = request.UserId,
            Category = request.Category,
            Description = request.Description,
            Amount = request.Amount,
            Date = request.Date,
            ReceiptUrl = request.ReceiptUrl,
            DateCreated = DateTime.UtcNow,
        };

        _db.DriverExpenses.Add(expense);
        await _db.SaveChangesAsync(cancellationToken);
        return expense.Id;
    }
}
