using RedTaxi.Blazor.Components;
using RedTaxi.Blazor.Services;
using Syncfusion.Blazor;

var builder = WebApplication.CreateBuilder(args);

builder.Services.AddRazorComponents()
    .AddInteractiveServerComponents();

builder.Services.AddScoped(sp =>
{
    var handler = new HttpClientHandler
    {
        ServerCertificateCustomValidationCallback = (_, _, _, _) => true
    };
    var client = new HttpClient(handler)
    {
        BaseAddress = new Uri(builder.Configuration.GetValue<string>("ApiBaseUrl") ?? "https://localhost:5001")
    };
    client.DefaultRequestHeaders.Add("X-Tenant-Slug", "ace");
    return client;
});

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
