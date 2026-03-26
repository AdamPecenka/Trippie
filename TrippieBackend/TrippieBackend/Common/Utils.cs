using System.Net;
using System.Net.Sockets;

namespace TrippieBackend.Common;

public class Utils {

    public string GetLocalIpAdress()
    {
        using var socket = new Socket(AddressFamily.InterNetwork, SocketType.Dgram, 0);
        socket.Connect("8.8.8.8", 65530);
        var endPoint = socket.LocalEndPoint as IPEndPoint;
        if (endPoint == null)
            throw new Exception("[!] No IPv4 address found for this machine.");
        return endPoint.Address.ToString();
    }
}