using System.Collections.Concurrent;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.SignalR;

namespace TrippieBackend.Hubs;

[Authorize]
public class TripHub : Hub
{
    private static readonly ConcurrentDictionary<string, List<string>> _connectionRooms = new();
    
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
    
    
    [HubMethodName("trip:join_room")]
    public async Task JoinRoom(string tripId)
    {
        await Groups.AddToGroupAsync(Context.ConnectionId, $"trip:{tripId}");

        if (_connectionRooms.TryGetValue(Context.ConnectionId, out var rooms))
        {
            rooms.Add(tripId);
        }

        Console.WriteLine($"[+] joined room | user:{Context.UserIdentifier} trip:{tripId}");
    }
    
    [HubMethodName("trip:leave_room")]
    public async Task LeaveRoom(string tripId)
    {
        await Groups.RemoveFromGroupAsync(Context.ConnectionId, $"trip:{tripId}");

        if (_connectionRooms.TryGetValue(Context.ConnectionId, out var rooms))
        {
            rooms.Remove(tripId);
        }

        Console.WriteLine($"[-] left room | user:{Context.UserIdentifier} trip:{tripId}");
    }
}