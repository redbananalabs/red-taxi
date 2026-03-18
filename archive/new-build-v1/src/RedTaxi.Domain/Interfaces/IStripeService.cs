namespace RedTaxi.Domain.Interfaces;

public interface IStripeService
{
    Task SeedProductsAsync(CancellationToken ct = default);
    Task<string> CreateCustomerAsync(string email, string name, CancellationToken ct = default);
    Task<string> CreateCheckoutSessionAsync(string customerId, string priceId, string successUrl, string cancelUrl, CancellationToken ct = default);
    Task<string> CreateBillingPortalSessionAsync(string customerId, string returnUrl, CancellationToken ct = default);
}
