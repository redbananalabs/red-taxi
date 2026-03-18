using MediatR;
using Microsoft.EntityFrameworkCore;
using RedTaxi.Infrastructure.Persistence;
using RedTaxi.Shared.DTOs;

namespace RedTaxi.Application.Config.Commands;

public record UpdateCompanyConfigCommand(
    string? CompanyName,
    string? BasePostcode,
    decimal CashCommissionRate,
    decimal RankCommissionRate,
    decimal CardTopupRate,
    bool AddVatOnCardPayments,
    decimal DriverWaitingRatePerMinute,
    decimal AccountWaitingRatePerMinute,
    int JobOfferTimeoutSeconds,
    bool AutoDispatchEnabled,
    string? LogoUrl,
    string? PrimaryColour,
    string? PaymentProcessor) : IRequest<CompanyConfigDto>;

public class UpdateCompanyConfigCommandHandler : IRequestHandler<UpdateCompanyConfigCommand, CompanyConfigDto>
{
    private readonly TenantDbContext _db;

    public UpdateCompanyConfigCommandHandler(TenantDbContext db)
    {
        _db = db;
    }

    public async Task<CompanyConfigDto> Handle(UpdateCompanyConfigCommand request, CancellationToken cancellationToken)
    {
        var config = await _db.CompanyConfigs.FirstOrDefaultAsync(cancellationToken);

        if (config == null)
        {
            config = new Domain.Entities.CompanyConfig();
            _db.CompanyConfigs.Add(config);
        }

        config.CompanyName = request.CompanyName;
        config.BasePostcode = request.BasePostcode;
        config.CashCommissionRate = request.CashCommissionRate;
        config.RankCommissionRate = request.RankCommissionRate;
        config.CardTopupRate = request.CardTopupRate;
        config.AddVatOnCardPayments = request.AddVatOnCardPayments;
        config.DriverWaitingRatePerMinute = request.DriverWaitingRatePerMinute;
        config.AccountWaitingRatePerMinute = request.AccountWaitingRatePerMinute;
        config.JobOfferTimeoutSeconds = request.JobOfferTimeoutSeconds;
        config.AutoDispatchEnabled = request.AutoDispatchEnabled;
        config.LogoUrl = request.LogoUrl;
        config.PrimaryColour = request.PrimaryColour;
        config.PaymentProcessor = request.PaymentProcessor;

        await _db.SaveChangesAsync(cancellationToken);

        return new CompanyConfigDto(
            config.Id, config.CompanyName, config.BasePostcode,
            config.CashCommissionRate, config.RankCommissionRate, config.CardTopupRate,
            config.AddVatOnCardPayments,
            config.DriverWaitingRatePerMinute, config.AccountWaitingRatePerMinute,
            config.JobOfferTimeoutSeconds, config.AutoDispatchEnabled,
            config.LogoUrl, config.PrimaryColour, config.PaymentProcessor);
    }
}
