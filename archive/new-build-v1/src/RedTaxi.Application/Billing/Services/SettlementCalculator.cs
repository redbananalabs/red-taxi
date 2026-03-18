using RedTaxi.Domain.Entities;
using RedTaxi.Domain.Enums;

namespace RedTaxi.Application.Billing.Services;

/// <summary>
/// Implements the exact legacy settlement formula (section 105).
/// </summary>
public static class SettlementCalculator
{
    public record SettlementResult(
        decimal EarningsCash,
        decimal EarningsCard,
        decimal EarningsAccount,
        decimal EarningsRank,
        decimal TotalCommission,
        decimal CardFees,
        decimal SubTotal);

    public static SettlementResult Calculate(
        IReadOnlyList<Booking> jobs,
        decimal? driverCommissionRate,
        CompanyConfig config)
    {
        // Commission rates
        var cashCommRate = driverCommissionRate ?? config.CashCommissionRate;
        var rankCommRate = config.RankCommissionRate;
        var cardRate = config.CardTopupRate;

        // EarningsCash = sum(Price) where Scope = Cash AND !Cancelled
        var earningsCash = jobs
            .Where(j => j.Scope == BookingScope.Cash && !j.Cancelled)
            .Sum(j => j.Price);

        // EarningsCard = sum(Price) where Scope = Card AND PaymentStatus = Paid
        //   If AddVatOnCardPayments: EarningsCard = sum(Price / 1.2)
        var cardJobs = jobs
            .Where(j => j.Scope == BookingScope.Card && j.PaymentStatus == PaymentStatus.Paid)
            .ToList();

        var earningsCard = config.AddVatOnCardPayments
            ? cardJobs.Sum(j => j.Price / 1.2m)
            : cardJobs.Sum(j => j.Price);

        // EarningsAccount = sum(Price) where Scope = Account AND !Cancelled
        //   + sum(ParkingCharge) for account jobs
        //   + sum(WaitingTimePriceDriver) for account jobs
        var accountJobs = jobs
            .Where(j => j.Scope == BookingScope.Account && !j.Cancelled)
            .ToList();

        var earningsAccount = accountJobs.Sum(j => j.Price)
            + accountJobs.Sum(j => j.ParkingCharge)
            + accountJobs.Sum(j => j.WaitingTimePriceDriver);

        // EarningsRank = sum(Price) where Scope = Rank AND !Cancelled
        var earningsRank = jobs
            .Where(j => j.Scope == BookingScope.Rank && !j.Cancelled)
            .Sum(j => j.Price);

        // CardFees = (EarningsCard / 100) * CardRate
        var cardFees = (earningsCard / 100m) * cardRate;

        // TotalCommission = ((EarningsCash + EarningsCard) / 100 * CashCommRate)
        //                 + (EarningsRank / 100 * RankCommRate)
        //                 + CardFees
        var totalCommission =
            ((earningsCash + earningsCard) / 100m * cashCommRate)
            + (earningsRank / 100m * rankCommRate)
            + cardFees;

        // SubTotal = (EarningsCash + EarningsCard + EarningsRank) - TotalCommission + EarningsAccount
        var subTotal = (earningsCash + earningsCard + earningsRank)
            - totalCommission
            + earningsAccount;

        return new SettlementResult(
            Math.Round(earningsCash, 2),
            Math.Round(earningsCard, 2),
            Math.Round(earningsAccount, 2),
            Math.Round(earningsRank, 2),
            Math.Round(totalCommission, 2),
            Math.Round(cardFees, 2),
            Math.Round(subTotal, 2));
    }
}
