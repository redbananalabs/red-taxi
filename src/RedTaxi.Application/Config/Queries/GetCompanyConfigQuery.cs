using MediatR;
using Microsoft.EntityFrameworkCore;
using RedTaxi.Infrastructure.Persistence;
using RedTaxi.Shared.DTOs;

namespace RedTaxi.Application.Config.Queries;

public record GetCompanyConfigQuery : IRequest<CompanyConfigDto?>;

public class GetCompanyConfigQueryHandler : IRequestHandler<GetCompanyConfigQuery, CompanyConfigDto?>
{
    private readonly TenantDbContext _db;

    public GetCompanyConfigQueryHandler(TenantDbContext db)
    {
        _db = db;
    }

    public async Task<CompanyConfigDto?> Handle(GetCompanyConfigQuery request, CancellationToken cancellationToken)
    {
        var config = await _db.CompanyConfigs.FirstOrDefaultAsync(cancellationToken);
        if (config == null) return null;

        return new CompanyConfigDto(
            config.Id, config.CompanyName, config.BasePostcode,
            config.CashCommissionRate, config.RankCommissionRate, config.CardTopupRate,
            config.AddVatOnCardPayments,
            config.DriverWaitingRatePerMinute, config.AccountWaitingRatePerMinute,
            config.JobOfferTimeoutSeconds, config.AutoDispatchEnabled,
            config.LogoUrl, config.PrimaryColour, config.PaymentProcessor,
            config.MapCenterLatitude, config.MapCenterLongitude, config.MapDefaultZoom);
    }
}
