using System.Net;
using System.Net.Sockets;
using System.Security.Claims;
using TrippieBackend.Models.Model;

namespace TrippieBackend.Common;

public static class Utils {

    public static string GetLocalIpAdress()
    {
        using var socket = new Socket(AddressFamily.InterNetwork, SocketType.Dgram, 0);
        socket.Connect("8.8.8.8", 65530);
        var endPoint = socket.LocalEndPoint as IPEndPoint;
        if (endPoint == null)
            throw new Exception("[!] No IPv4 address found for this machine.");
        return endPoint.Address.ToString();
    }

    public static Guid GetUserId(ClaimsPrincipal user)
    {
        var claim = user.FindFirstValue(ClaimTypes.NameIdentifier)
                    ?? throw new UnauthorizedAccessException("User ID claim not found.");

        return Guid.Parse(claim);
    }
}