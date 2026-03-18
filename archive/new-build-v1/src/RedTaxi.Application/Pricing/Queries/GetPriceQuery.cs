using MediatR;
using RedTaxi.Domain.Entities;
using RedTaxi.Domain.Enums;
using RedTaxi.Domain.Interfaces;
using RedTaxi.Shared.DTOs;

namespace RedTaxi.Application.Pricing.Queries;

/// <summary>
/// Calculates a price quote without persisting anything. Used for price previews.
/// </summary>
public record GetPriceQuery(
    string PickupAddress,
    string? PickupPostCode,
    string? DestinationAddress,
    string? DestinationPostCode,
    DateTime PickupDateTime,
    int Passengers,
    int VehicleType,
    int? AccountNumber,
    bool ChargeFromBase) : IRequest<PriceResultDto>;

public class GetPriceQueryHandler : IRequestHandler<GetPriceQuery, PriceResultDto>
{
    private readonly IPricingService _pricing;

    public GetPriceQueryHandler(IPricingService pricing) => _pricing = pricing;

    public async Task<PriceResultDto> Handle(GetPriceQuery request, CancellationToken ct)
    {
        // Build a transient booking object for the pricing engine
        var booking = new Booking
        {
            PickupAddress = request.PickupAddress,
            PickupPostCode = request.PickupPostCode ?? string.Empty,
            DestinationAddress = request.DestinationAddress,
            DestinationPostCode = request.DestinationPostCode,
            PickupDateTime = request.PickupDateTime,
            Passengers = request.Passengers,
            VehicleType = (VehicleType)request.VehicleType,
            AccountNumber = request.AccountNumber,
            ChargeFromBase = request.ChargeFromBase,
        };

        var (driverPrice, accountPrice, mileage, mileageText, durationText) =
            await _pricing.CalculatePriceAsync(booking, ct);

        return new PriceResultDto(driverPrice, accountPrice, mileage, mileageText, durationText, "Quoted");
    }
}
