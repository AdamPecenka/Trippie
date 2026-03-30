using Microsoft.AspNetCore.SignalR.Client;

namespace SignalRTestClient;

class Program
{
    static async Task Main(string[] args)
    {
        var connection = new HubConnectionBuilder()
            .WithUrl("https://127.0.0.1:5002/hubs/trip", options =>
            {
                options.AccessTokenProvider = () => Task.FromResult("<jwt_token>")!;
            })
            .Build();

        connection.On<object>("test:event", data =>
        {
            Console.WriteLine($"[i] received: {data}");
        });
        
        
        await connection.StartAsync();
        Console.WriteLine("[+] connected");

        await connection.InvokeAsync("TestMethod");

        Console.WriteLine("[i] waiting for events...");
        Console.ReadLine();
    }
}