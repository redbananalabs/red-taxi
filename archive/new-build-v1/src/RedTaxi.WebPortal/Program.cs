using Microsoft.AspNetCore.Components.Web;
using Microsoft.AspNetCore.Components.WebAssembly.Hosting;
using Microsoft.AspNetCore.Components.Authorization;
using Blazored.LocalStorage;
using RedTaxi.WebPortal;
using RedTaxi.WebPortal.Services;

var builder = WebAssemblyHostBuilder.CreateDefault(args);
builder.RootComponents.Add<App>("#app");
builder.RootComponents.Add<HeadOutlet>("head::after");

builder.Services.AddBlazoredLocalStorage();
builder.Services.AddAuthorizationCore();
builder.Services.AddScoped<PortalAuthProvider>();
builder.Services.AddScoped<AuthenticationStateProvider>(sp => sp.GetRequiredService<PortalAuthProvider>());

builder.Services.AddScoped(sp =>
{
    var client = new HttpClient { BaseAddress = new Uri("https://localhost:5001") };
    return client;
});

builder.Services.AddScoped<PortalApiClient>();

await builder.Build().RunAsync();
