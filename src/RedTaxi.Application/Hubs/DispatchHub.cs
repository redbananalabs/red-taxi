using System.Security.Claims;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.SignalR;

namespace RedTaxi.Application.Hubs;

[Authorize]
public class DispatchHub : Hub
{
    public override async Task OnConnectedAsync()
    {
        var userId = Context.User?.FindFirstValue(ClaimTypes.NameIdentifier)
                  ?? Context.User?.FindFirstValue("sub");

        if (!string.IsNullOrEmpty(userId))
        {
            await Groups.AddToGroupAsync(Context.ConnectionId, $"driver-{userId}");
        }

        var role = Context.User?.FindFirstValue(ClaimTypes.Role)
                ?? Context.User?.FindFirstValue("role");

        if (role is "Admin" or "Dispatcher" or "Controller")
        {
            await Groups.AddToGroupAsync(Context.ConnectionId, "dispatch");
        }

        await base.OnConnectedAsync();
    }

    public override async Task OnDisconnectedAsync(Exception? exception)
    {
        var userId = Context.User?.FindFirstValue(ClaimTypes.NameIdentifier)
                  ?? Context.User?.FindFirstValue("sub");

        if (!string.IsNullOrEmpty(userId))
        {
            await Groups.RemoveFromGroupAsync(Context.ConnectionId, $"driver-{userId}");
        }

        await Groups.RemoveFromGroupAsync(Context.ConnectionId, "dispatch");
        await base.OnDisconnectedAsync(exception);
    }

    public async Task JoinDriverGroup(int driverUserId)
    {
        await Groups.AddToGroupAsync(Context.ConnectionId, $"driver-{driverUserId}");
    }
}
