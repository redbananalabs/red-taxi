using QuestPDF.Fluent;
using QuestPDF.Helpers;
using QuestPDF.Infrastructure;

namespace RedTaxi.Infrastructure.ExternalServices;

// ── Data models ──────────────────────────────────────────────────────

public record InvoiceJobLine(
    DateTime Date,
    string Pickup,
    string Destination,
    string Passenger,
    decimal Miles,
    decimal Price);

public record InvoicePdfData(
    string CompanyName,
    string InvoiceNumber,
    string AccountName,
    string AccountNumber,
    DateTime PeriodStart,
    DateTime PeriodEnd,
    IReadOnlyList<InvoiceJobLine> Jobs,
    decimal NetAmount,
    decimal VatAmount,
    decimal TotalAmount);

public record StatementJobLine(
    DateTime Date,
    string Scope,
    decimal Price,
    decimal Commission);

public record StatementPdfData(
    string CompanyName,
    string DriverName,
    DateTime PeriodStart,
    DateTime PeriodEnd,
    decimal EarningsCash,
    decimal EarningsCard,
    decimal EarningsAccount,
    decimal EarningsRank,
    decimal TotalCommission,
    decimal CardFees,
    decimal Expenses,
    decimal NetPayable,
    IReadOnlyList<StatementJobLine> Jobs);

public record CreditNoteJobLine(
    DateTime Date,
    string Pickup,
    string Destination,
    decimal Amount);

public record CreditNotePdfData(
    string CompanyName,
    string CreditNoteNumber,
    string AccountName,
    string AccountNumber,
    DateTime IssueDate,
    string Reason,
    IReadOnlyList<CreditNoteJobLine> Jobs,
    decimal NetAmount,
    decimal VatAmount,
    decimal TotalAmount);

// ── PDF generation service ───────────────────────────────────────────

public class PdfService
{
    public byte[] GenerateInvoicePdf(InvoicePdfData data)
    {
        QuestPDF.Settings.License = LicenseType.Community;

        var document = Document.Create(container =>
        {
            container.Page(page =>
            {
                page.Size(PageSizes.A4);
                page.Margin(40);

                page.Header().Row(row =>
                {
                    row.RelativeItem().Text(data.CompanyName).FontSize(20).Bold();
                    row.ConstantItem(150).AlignRight().Text($"INVOICE #{data.InvoiceNumber}").FontSize(14).Bold();
                });

                page.Content().PaddingVertical(20).Column(col =>
                {
                    // Account info
                    col.Item().Text($"Account: {data.AccountName} ({data.AccountNumber})").FontSize(12);
                    col.Item().Text($"Period: {data.PeriodStart:dd/MM/yyyy} - {data.PeriodEnd:dd/MM/yyyy}");
                    col.Item().PaddingTop(15);

                    // Jobs table
                    col.Item().Table(table =>
                    {
                        table.ColumnsDefinition(cols =>
                        {
                            cols.ConstantColumn(60);  // Date
                            cols.RelativeColumn(2);   // Pickup
                            cols.RelativeColumn(2);   // Destination
                            cols.RelativeColumn(1);   // Passenger
                            cols.ConstantColumn(50);  // Miles
                            cols.ConstantColumn(60);  // Price
                        });

                        // Header
                        table.Header(header =>
                        {
                            header.Cell().Text("Date").Bold();
                            header.Cell().Text("Pickup").Bold();
                            header.Cell().Text("Destination").Bold();
                            header.Cell().Text("Passenger").Bold();
                            header.Cell().Text("Miles").Bold();
                            header.Cell().Text("Price").Bold();
                        });

                        foreach (var job in data.Jobs)
                        {
                            table.Cell().Text(job.Date.ToString("dd/MM"));
                            table.Cell().Text(job.Pickup);
                            table.Cell().Text(job.Destination);
                            table.Cell().Text(job.Passenger);
                            table.Cell().Text(job.Miles.ToString("F1"));
                            table.Cell().AlignRight().Text($"\u00a3{job.Price:F2}");
                        }
                    });

                    col.Item().PaddingTop(15);
                    col.Item().AlignRight().Text($"Net: \u00a3{data.NetAmount:F2}").FontSize(12);
                    col.Item().AlignRight().Text($"VAT: \u00a3{data.VatAmount:F2}").FontSize(12);
                    col.Item().AlignRight().Text($"Total: \u00a3{data.TotalAmount:F2}").FontSize(14).Bold();
                });

                page.Footer().AlignCenter().Text(x =>
                {
                    x.Span($"{data.CompanyName} \u2014 Generated {DateTime.Now:dd/MM/yyyy}");
                });
            });
        });

        return document.GeneratePdf();
    }

    public byte[] GenerateStatementPdf(StatementPdfData data)
    {
        QuestPDF.Settings.License = LicenseType.Community;

        var document = Document.Create(container =>
        {
            container.Page(page =>
            {
                page.Size(PageSizes.A4);
                page.Margin(40);

                page.Header().Row(row =>
                {
                    row.RelativeItem().Text(data.CompanyName).FontSize(20).Bold();
                    row.ConstantItem(200).AlignRight().Text("DRIVER STATEMENT").FontSize(14).Bold();
                });

                page.Content().PaddingVertical(20).Column(col =>
                {
                    col.Item().Text($"Driver: {data.DriverName}").FontSize(12);
                    col.Item().Text($"Period: {data.PeriodStart:dd/MM/yyyy} - {data.PeriodEnd:dd/MM/yyyy}");
                    col.Item().PaddingTop(15);

                    // Earnings breakdown
                    col.Item().Text("Earnings by Scope").FontSize(12).Bold();
                    col.Item().Text($"  Cash:    \u00a3{data.EarningsCash:F2}");
                    col.Item().Text($"  Card:    \u00a3{data.EarningsCard:F2}");
                    col.Item().Text($"  Account: \u00a3{data.EarningsAccount:F2}");
                    col.Item().Text($"  Rank:    \u00a3{data.EarningsRank:F2}");
                    col.Item().PaddingTop(10);

                    // Deductions
                    col.Item().Text("Deductions").FontSize(12).Bold();
                    col.Item().Text($"  Commission: \u00a3{data.TotalCommission:F2}");
                    col.Item().Text($"  Card Fees:  \u00a3{data.CardFees:F2}");
                    col.Item().Text($"  Expenses:   \u00a3{data.Expenses:F2}");
                    col.Item().PaddingTop(10);

                    col.Item().AlignRight().Text($"Net Payable: \u00a3{data.NetPayable:F2}").FontSize(14).Bold();

                    col.Item().PaddingTop(15);

                    // Jobs table
                    col.Item().Table(table =>
                    {
                        table.ColumnsDefinition(cols =>
                        {
                            cols.ConstantColumn(80);  // Date
                            cols.RelativeColumn(1);   // Scope
                            cols.ConstantColumn(80);  // Price
                            cols.ConstantColumn(80);  // Commission
                        });

                        table.Header(header =>
                        {
                            header.Cell().Text("Date").Bold();
                            header.Cell().Text("Scope").Bold();
                            header.Cell().Text("Price").Bold();
                            header.Cell().Text("Commission").Bold();
                        });

                        foreach (var job in data.Jobs)
                        {
                            table.Cell().Text(job.Date.ToString("dd/MM"));
                            table.Cell().Text(job.Scope);
                            table.Cell().AlignRight().Text($"\u00a3{job.Price:F2}");
                            table.Cell().AlignRight().Text($"\u00a3{job.Commission:F2}");
                        }
                    });
                });

                page.Footer().AlignCenter().Text(x =>
                {
                    x.Span($"{data.CompanyName} \u2014 Generated {DateTime.Now:dd/MM/yyyy}");
                });
            });
        });

        return document.GeneratePdf();
    }

    public byte[] GenerateCreditNotePdf(CreditNotePdfData data)
    {
        QuestPDF.Settings.License = LicenseType.Community;

        var document = Document.Create(container =>
        {
            container.Page(page =>
            {
                page.Size(PageSizes.A4);
                page.Margin(40);

                page.Header().Row(row =>
                {
                    row.RelativeItem().Text(data.CompanyName).FontSize(20).Bold();
                    row.ConstantItem(200).AlignRight().Text($"CREDIT NOTE #{data.CreditNoteNumber}").FontSize(14).Bold();
                });

                page.Content().PaddingVertical(20).Column(col =>
                {
                    col.Item().Text($"Account: {data.AccountName} ({data.AccountNumber})").FontSize(12);
                    col.Item().Text($"Issue Date: {data.IssueDate:dd/MM/yyyy}");
                    col.Item().Text($"Reason: {data.Reason}");
                    col.Item().PaddingTop(15);

                    // Jobs table
                    col.Item().Table(table =>
                    {
                        table.ColumnsDefinition(cols =>
                        {
                            cols.ConstantColumn(80);  // Date
                            cols.RelativeColumn(2);   // Pickup
                            cols.RelativeColumn(2);   // Destination
                            cols.ConstantColumn(80);  // Amount
                        });

                        table.Header(header =>
                        {
                            header.Cell().Text("Date").Bold();
                            header.Cell().Text("Pickup").Bold();
                            header.Cell().Text("Destination").Bold();
                            header.Cell().Text("Amount").Bold();
                        });

                        foreach (var job in data.Jobs)
                        {
                            table.Cell().Text(job.Date.ToString("dd/MM"));
                            table.Cell().Text(job.Pickup);
                            table.Cell().Text(job.Destination);
                            table.Cell().AlignRight().Text($"\u00a3{job.Amount:F2}");
                        }
                    });

                    col.Item().PaddingTop(15);
                    col.Item().AlignRight().Text($"Net: \u00a3{data.NetAmount:F2}").FontSize(12);
                    col.Item().AlignRight().Text($"VAT: \u00a3{data.VatAmount:F2}").FontSize(12);
                    col.Item().AlignRight().Text($"Total Credit: \u00a3{data.TotalAmount:F2}").FontSize(14).Bold();
                });

                page.Footer().AlignCenter().Text(x =>
                {
                    x.Span($"{data.CompanyName} \u2014 Generated {DateTime.Now:dd/MM/yyyy}");
                });
            });
        });

        return document.GeneratePdf();
    }
}
