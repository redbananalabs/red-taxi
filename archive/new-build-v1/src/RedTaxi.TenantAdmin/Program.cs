using Microsoft.AspNetCore.Components.Authorization;
using Microsoft.AspNetCore.Components.Web;
using Microsoft.AspNetCore.Components.WebAssembly.Hosting;
using RedTaxi.TenantAdmin;
using RedTaxi.TenantAdmin.Services;

var builder = WebAssemblyHostBuilder.CreateDefault(args);
builder.RootComponents.Add<App>("#app");
builder.RootComponents.Add<HeadOutlet>("head::after");

var apiBase = builder.Configuration["ApiBaseUrl"] ?? "https://localhost:5001";

builder.Services.AddScoped(sp =>
{
    var client = new HttpClient { BaseAddress = new Uri(apiBase) };
    client.DefaultRequestHeaders.Add("X-Tenant-Slug", "ace");
    return client;
});
builder.Services.AddScoped<AdminApiClient>();
builder.Services.AddScoped<AuthStateProvider>();
builder.Services.AddScoped<AuthenticationStateProvider>(sp => sp.GetRequiredService<AuthStateProvider>());
builder.Services.AddAuthorizationCore();

await builder.Build().RunAsync();
