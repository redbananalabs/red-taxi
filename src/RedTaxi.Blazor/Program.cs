using RedTaxi.Blazor.Components;
using RedTaxi.Blazor.Services;
using Syncfusion.Blazor;

var builder = WebApplication.CreateBuilder(args);

builder.Services.AddRazorComponents()
    .AddInteractiveServerComponents();

builder.Services.AddTransient<BearerTokenHandler>();
builder.Services.AddScoped(sp =>
{
    var tokenHandler = sp.GetRequiredService<BearerTokenHandler>();
    tokenHandler.InnerHandler = new HttpClientHandler
    {
        ServerCertificateCustomValidationCallback = (_, _, _, _) => true
    };
    return new HttpClient(tokenHandler)
    {
        BaseAddress = new Uri(builder.Configuration.GetValue<string>("ApiBaseUrl") ?? "https://localhost:5001")
    };
});

Syncfusion.Licensing.SyncfusionLicenseProvider.RegisterLicense(
    builder.Configuration["Syncfusion:LicenseKey"] ?? "");
builder.Services.AddSyncfusionBlazor();
builder.Services.AddScoped<ApiService>();
builder.Services.AddScoped<DispatchState>();
builder.Services.AddScoped<SignalRService>();

var app = builder.Build();

if (!app.Environment.IsDevelopment())
{
    app.UseExceptionHandler("/Error", createScopeForErrors: true);
    app.UseHsts();
}

app.UseHttpsRedirection();
app.UseStaticFiles();
app.UseAntiforgery();

app.MapRazorComponents<App>()
    .AddInteractiveServerRenderMode();

app.Run();
