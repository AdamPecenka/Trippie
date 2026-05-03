using System.Text;
using System.Text.Json;
using Google.Apis.Auth.OAuth2;
using Microsoft.EntityFrameworkCore;
using TrippieBackend.Models;

namespace TrippieBackend.Services.Service;

public class FcmService
{
    private readonly TrippieContext _context;
    private readonly HttpClient _httpClient;
    private readonly string _projectId;
    private readonly string _serviceAccountPath;

    public FcmService(TrippieContext context, IConfiguration configuration, IHttpClientFactory httpClientFactory)
    {
        _context = context;
        _httpClient = httpClientFactory.CreateClient();
        _projectId = configuration["Fcm:ProjectId"]!;
        _serviceAccountPath = configuration["Fcm:ServiceAccountPath"]!;
    }

    private async Task<string> GetAccessTokenAsync()
    {
        var credential = GoogleCredential
            .FromFile(_serviceAccountPath)
            .CreateScoped("https://www.googleapis.com/auth/firebase.messaging");

        return await credential.UnderlyingCredential.GetAccessTokenForRequestAsync();
    }

    public async Task SendMemberJoinedAsync(Guid tripId, Guid newMemberId, string newMemberFullName, string tripName)
    {
        var tokens = await _context.TripMembers
            .Where(tm => tm.TripId == tripId && tm.UserId != newMemberId && tm.User.FcmToken != null)
            .Select(tm => new { tm.UserId, tm.User.FcmToken })
            .ToListAsync();

        if (tokens.Count == 0)
        {
            Console.WriteLine($"[i] No FCM tokens for trip:{tripId}, skipping");
            return;
        }

        Console.WriteLine($"[i] Sending notification to {tokens.Count} members for trip:{tripId}");

        var accessToken = await GetAccessTokenAsync();
        var url = $"https://fcm.googleapis.com/v1/projects/{_projectId}/messages:send";

        foreach (var recipient in tokens)
        {
            var payload = new
            {
                message = new
                {
                    token = recipient.FcmToken,
                    notification = new
                    {
                        title = $"New member joined {tripName}!",
                        body = $"{newMemberFullName} just joined your trip."
                    },
                    data = new Dictionary<string, string>
                    {
                        { "tripId", tripId.ToString() },
                        { "route", $"/home/trip/{tripId}" }
                    }
                }
            };

            var request = new HttpRequestMessage(HttpMethod.Post, url)
            {
                Content = new StringContent(JsonSerializer.Serialize(payload), Encoding.UTF8, "application/json")
            };
            request.Headers.Authorization = new System.Net.Http.Headers.AuthenticationHeaderValue("Bearer", accessToken);

            var response = await _httpClient.SendAsync(request);

            if (response.IsSuccessStatusCode)
            {
                Console.WriteLine($"[+] FCM sent | user:{recipient.UserId}");
            }
            else
            {
                var body = await response.Content.ReadAsStringAsync();
                Console.WriteLine($"[E] FCM failed | user:{recipient.UserId} | {response.StatusCode} | {body}");
            }
        }

        Console.WriteLine($"[+] member joined notification sent | trip:{tripId}");
    }
}