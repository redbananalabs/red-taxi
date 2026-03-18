using MediatR;
using Microsoft.EntityFrameworkCore;
using RedTaxi.Domain.Entities;
using RedTaxi.Domain.Enums;
using RedTaxi.Infrastructure.Persistence;
using RedTaxi.Shared.DTOs;

namespace RedTaxi.Application.Billing.Commands;

/// <summary>
/// Creates an AccountInvoice from posted (but not yet invoiced) account jobs.
/// Uses PriceAccount for invoice amounts.
/// </summary>
public record CreateInvoiceCommand(
    int AccountNumber,
    DateTime PeriodStart,
    DateTime PeriodEnd) : IRequest<InvoiceDto>;

public class CreateInvoiceCommandHandler : IRequestHandler<CreateInvoiceCommand, InvoiceDto>
{
    private readonly TenantDbContext _db;

    public CreateInvoiceCommandHandler(TenantDbContext db)
    {
        _db = db;
    }

    public async Task<InvoiceDto> Handle(CreateInvoiceCommand request, CancellationToken cancellationToken)
    {
        var account = await _db.Accounts
            .FirstOrDefaultAsync(a => a.AccountNumber == request.AccountNumber, cancellationToken)
            ?? throw new KeyNotFoundException($"Account {request.AccountNumber} not found.");

        // Get posted but not yet invoiced jobs
        var jobs = await _db.Bookings
            .Where(b => b.AccountNumber == request.AccountNumber
                && b.Scope == BookingScope.Account
                && b.PostedForInvoicing
                && !b.Cancelled
                && b.InvoiceNumber == null
                && b.PickupDateTime >= request.PeriodStart
                && b.PickupDateTime <= request.PeriodEnd)
            .ToListAsync(cancellationToken);

        if (jobs.Count == 0)
            throw new InvalidOperationException("No posted jobs found for the given period.");

        // Calculate totals using PriceAccount (what goes on the invoice)
        var netAmount = jobs.Sum(j => j.PriceAccount
            + j.WaitingTimePriceAccount
            + j.ParkingCharge);
        var vatAmount = jobs.Sum(j => j.VatAmountAdded);
        var totalAmount = netAmount + vatAmount;

        // Next invoice number
        var maxInvoice = await _db.AccountInvoices
            .MaxAsync(i => (int?)i.InvoiceNumber, cancellationToken) ?? 0;

        var invoice = new AccountInvoice
        {
            AccountId = account.Id,
            AccountNumber = account.AccountNumber,
            InvoiceNumber = maxInvoice + 1,
            InvoiceDate = DateTime.UtcNow,
            PeriodStart = request.PeriodStart,
            PeriodEnd = request.PeriodEnd,
            NetAmount = Math.Round(netAmount, 2),
            VatAmount = Math.Round(vatAmount, 2),
            TotalAmount = Math.Round(totalAmount, 2),
            IsPaid = false,
            DateCreated = DateTime.UtcNow,
        };

        _db.AccountInvoices.Add(invoice);

        // Link jobs to the invoice
        foreach (var job in jobs)
            job.InvoiceNumber = invoice.InvoiceNumber;

        await _db.SaveChangesAsync(cancellationToken);

        return new InvoiceDto(
            invoice.Id, invoice.AccountId, invoice.AccountNumber, account.CompanyName,
            invoice.InvoiceNumber, invoice.InvoiceDate,
            invoice.PeriodStart, invoice.PeriodEnd,
            invoice.TotalAmount, invoice.VatAmount, invoice.NetAmount,
            invoice.IsPaid, invoice.PaidDate);
    }
}
