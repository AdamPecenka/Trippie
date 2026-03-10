using System.Net;

namespace TrippieBackend.Common;

public class Utils {

    public string GetLocalIpAdress() {
        var host = Dns.GetHostEntry(Dns.GetHostName());
        var ipAddress = host.AddressList
            .FirstOrDefault(ip => ip.AddressFamily == System.Net.Sockets.AddressFamily.InterNetwork);

        if (ipAddress == null)
            throw new Exception("[!] No IPv4 address found for this machine.");

        return ipAddress.ToString();
    }
}
