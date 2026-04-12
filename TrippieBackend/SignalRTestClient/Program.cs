using Microsoft.AspNetCore.SignalR.Client;

namespace SignalRTestClient;

class Program
{
    static async Task Main(string[] args)
    {
        var connection = new HubConnectionBuilder()
            .WithUrl("https://127.0.0.1:5002/hubs/trip", options =>
            {
                options.AccessTokenProvider = () => Task.FromResult("eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJiYjg1YmIwMC03N2M0LTQ4MzUtYjIzNC03ZTRlN2NkYzkyOWIiLCJqdGkiOiJhZWE1NGU3NS0xM2RkLTQzYTEtODlkYS00ZDkwMjY1MzNhZWUiLCJlbWFpbCI6ImpvaGFubmthLnRpbGVzb3ZhQGV4YW1wbGUuY29tIiwiZXhwIjoxNzc2MDE3NTM4LCJpc3MiOiJUcmlwcGllRG90bmV0QVBJIiwiYXVkIjoiVHJpcHBpZUZsdXR0ZXJDbGllbnQifQ.QWCW5ktu5kQ8Mb4eJ05Nxq_ztjYU12_mC6es1KKnyjk")!;
            })
            .Build();

        connection.On<object>("trip:member_joined", data =>
        {
            Console.WriteLine($"[+] trip:member_joined | {data}");
        });
        
        connection.On<object>("trip:member_left", data =>
        {
            Console.WriteLine($"[+] trip:member_left | {data}");
        });
        
        
        await connection.StartAsync();
        Console.WriteLine("[+] connected");

        await connection.InvokeAsync("trip:join_room", "833efe24-0c3b-49d9-aa2d-9a977a3c5c52");
        Console.WriteLine("[i] joined room, waiting for events...");
        Console.ReadLine();
    }
}