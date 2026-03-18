using Hangfire;
using MediatR;
using Microsoft.EntityFrameworkCore;
using RedTaxi.Domain.Entities;
using RedTaxi.Domain.Enums;
using RedTaxi.Infrastructure.ExternalServices;
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
    private readonly PdfService _pdfService;
    private readonly IEmailService _emailService;

    public CreateInvoiceCommandHandler(TenantDbContext db, PdfService pdfService, IEmailService emailService)
    {
        _db = db;
        _pdfService = pdfService;
        _emailService = emailService;
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

        // AB10: Send invoice email if account has ContactEmail
        if (!string.IsNullOrEmpty(account.ContactEmail))
        {
            var config = await _db.CompanyConfigs.AsNoTracking().FirstOrDefaultAsync(cancellationToken);
            var companyName = config?.CompanyName ?? "Red Taxi";
            var pdfData = new InvoicePdfData(
                companyName,
                invoice.InvoiceNumber.ToString(),
                account.CompanyName,
                account.AccountNumber.ToString(),
                invoice.PeriodStart,
                invoice.PeriodEnd,
                jobs.Select(j => new InvoiceJobLine(
                    j.PickupDateTime, j.PickupAddress, j.DestinationAddress ?? "",
                    j.PassengerName ?? "", j.Mileage ?? 0, j.PriceAccount)).ToList(),
                invoice.NetAmount, invoice.VatAmount, invoice.TotalAmount);
            var contactEmail = account.ContactEmail;
            var invoiceNumber = invoice.InvoiceNumber;

            BackgroundJob.Enqueue<InvoiceEmailJob>(job =>
                job.SendAsync(contactEmail, companyName, invoiceNumber, pdfData));
        }

        return new InvoiceDto(
            invoice.Id, invoice.AccountId, invoice.AccountNumber, account.CompanyName,
            invoice.InvoiceNumber, invoice.InvoiceDate,
            invoice.PeriodStart, invoice.PeriodEnd,
            invoice.TotalAmount, invoice.VatAmount, invoice.NetAmount,
            invoice.IsPaid, invoice.PaidDate);
    }
}

public class InvoiceEmailJob
{
    private readonly PdfService _pdfService;
    private readonly IEmailService _emailService;

    public InvoiceEmailJob(PdfService pdfService, IEmailService emailService)
    {
        _pdfService = pdfService;
        _emailService = emailService;
    }

    public async Task SendAsync(string email, string companyName, int invoiceNumber, InvoicePdfData pdfData)
    {
        var pdfBytes = _pdfService.GenerateInvoicePdf(pdfData);
        var base64 = Convert.ToBase64String(pdfBytes);
        var html = $"<p>Please find attached Invoice #{invoiceNumber} from {companyName}.</p>"
            + $"<p>Total: &pound;{pdfData.TotalAmount:F2}</p>";
        await _emailService.SendAsync(email, $"Invoice #{invoiceNumber} from {companyName}", html);
    }
}
