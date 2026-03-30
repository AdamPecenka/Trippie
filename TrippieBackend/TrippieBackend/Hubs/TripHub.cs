using System.Collections.Concurrent;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.SignalR;

namespace TrippieBackend.Hubs;

[Authorize]
public class TripHub : Hub
{
    private static readonly ConcurrentDictionary<string, List<string>> _connectionRooms = new();

    public async Task TestMethod()
    {
        for (int i = 0; i < 10; i++)
        {
            Console.WriteLine($"[i] sending test event #{i}");
            await Clients.Caller.SendAsync("test:event", new { Index = i, Message = $"ping {i}" });
            await Task.Delay(500);
        }
    }
    
    public override async Task OnConnectedAsync()
    {
        _connectionRooms[Context.ConnectionId] = new List<string>();
        Console.WriteLine($"[+] connected | user:{Context.UserIdentifier} conn:{Context.ConnectionId}");
        await base.OnConnectedAsync();
    }
    
    public override async Task OnDisconnectedAsync(Exception? exception)
    {
        if (exception is not null)
        {
            Console.WriteLine($"[E] disconnected with error | user:{Context.UserIdentifier} — {exception.Message}");
        }
        else
        {
            Console.WriteLine($"[-] disconnected cleanly | user:{Context.UserIdentifier}");
        }

        if (_connectionRooms.TryRemove(Context.ConnectionId, out var rooms))
        {
            foreach (var tripId in rooms)
            {
                await Clients.Group($"trip:{tripId}").SendAsync("trip:member_disconnected", new
                {
                    UserId = Context.UserIdentifier,
                    TripId = tripId
                });
            }
        }

        await base.OnDisconnectedAsync(exception);
    }
}