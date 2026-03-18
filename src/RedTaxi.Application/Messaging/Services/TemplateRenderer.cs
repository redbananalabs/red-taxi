using RedTaxi.Domain.Entities;

namespace RedTaxi.Application.Messaging.Services;

public class TemplateRenderer
{
    /// <summary>
    /// Renders a message template by replacing {Variable} placeholders with actual values
    /// from booking, driver, and company data.
    /// </summary>
    public string Render(string template, TemplateContext context)
    {
        if (string.IsNullOrEmpty(template)) return string.Empty;

        var result = template;

        result = result.Replace("{PassengerName}", context.PassengerName ?? "Customer");
        result = result.Replace("{DriverName}", context.DriverName ?? string.Empty);
        result = result.Replace("{PickupAddress}", context.PickupAddress ?? string.Empty);
        result = result.Replace("{DestinationAddress}", context.DestinationAddress ?? string.Empty);
        result = result.Replace("{PickupTime}", context.PickupTime?.ToString("dd/MM/yyyy HH:mm") ?? string.Empty);
        result = result.Replace("{BookingId}", context.BookingId?.ToString() ?? string.Empty);
        result = result.Replace("{VehicleReg}", context.VehicleReg ?? string.Empty);
        result = result.Replace("{Price}", context.Price?.ToString("F2") ?? string.Empty);
        result = result.Replace("{CompanyName}", context.CompanyName ?? "Red Taxi");
        result = result.Replace("{TrackingUrl}", context.TrackingUrl ?? string.Empty);
        result = result.Replace("{PaymentUrl}", context.PaymentUrl ?? string.Empty);

        return result;
    }

    /// <summary>
    /// Builds a TemplateContext from booking, driver, and company data.
    /// </summary>
    public static TemplateContext FromBooking(
        Booking booking,
        UserProfile? driver = null,
        CompanyConfig? config = null)
    {
        return new TemplateContext
        {
            BookingId = booking.Id,
            PassengerName = booking.PassengerName,
            DriverName = driver?.FullName,
            PickupAddress = booking.PickupAddress,
            DestinationAddress = booking.DestinationAddress,
            PickupTime = booking.PickupDateTime,
            VehicleReg = driver?.RegNo,
            Price = booking.Price,
            CompanyName = config?.CompanyName,
            TrackingUrl = null, // Set by caller if available
            PaymentUrl = booking.PaymentLink,
        };
    }
}

public class TemplateContext
{
    public int? BookingId { get; set; }
    public string? PassengerName { get; set; }
    public string? DriverName { get; set; }
    public string? PickupAddress { get; set; }
    public string? DestinationAddress { get; set; }
    public DateTime? PickupTime { get; set; }
    public string? VehicleReg { get; set; }
    public decimal? Price { get; set; }
    public string? CompanyName { get; set; }
    public string? TrackingUrl { get; set; }
    public string? PaymentUrl { get; set; }
}
