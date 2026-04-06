using System.Text.Json;
using Microsoft.EntityFrameworkCore;
using TrippieBackend.Models;
using TrippieBackend.Models.DTOs;
using TrippieBackend.Models.Enums;
using TrippieBackend.Models.GooglePlaces;
using TrippieBackend.Models.Model;
using TrippieBackend.Services.IService;

namespace TrippieBackend.Services.Service;

public class PlaceService : IPlaceService
{
    private readonly TrippieContext _context;
    private readonly HttpClient _httpClient;

    public PlaceService(TrippieContext context, HttpClient httpClient, IConfiguration configuration)
    {
        _context = context;
        _httpClient = httpClient;
        _httpClient.DefaultRequestHeaders.Add("X-Goog-Api-Key", configuration["GooglePlaces:ApiKey"]);
    }
    
    public async Task<ServiceResult<List<PlaceSuggestionDto>>> Autocomplete(string query, double? lat, double? lng)
    {
        var requestBody = new AutocompleteRequestBody
        {
            Input = query,
            LocationBias = lat.HasValue ? new LocationBias
            {
                Circle = new Circle
                {
                    Center = new Center { Latitude = lat.Value, Longitude = lng.Value },
                    Radius = 50000.0
                }
            } : null
        };

        var response = await _httpClient.PostAsJsonAsync(
            $"https://places.googleapis.com/v1/places:autocomplete",
            requestBody
        );

        var json = await response.Content.ReadFromJsonAsync<JsonElement>();
    
        var suggestions = json.GetProperty("suggestions")
            .EnumerateArray()
            .Select(s =>
            {
                var prediction = s.GetProperty("placePrediction");
                return new PlaceSuggestionDto
                {
                    GooglePlaceId = prediction.GetProperty("placeId").GetString()!,
                    DisplayName = prediction.GetProperty("text").GetProperty("text").GetString()!
                };
            }).ToList();

        return ServiceResult<List<PlaceSuggestionDto>>.Ok(suggestions);
    }
    
    public async Task<ServiceResult<PlaceDto>> Resolve(string googlePlaceId)
    {
        var request = new HttpRequestMessage(
            HttpMethod.Get,
            $"https://places.googleapis.com/v1/places/{googlePlaceId}"
        );
        request.Headers.Add("X-Goog-FieldMask", "id,displayName,formattedAddress,location,addressComponents");

        var response = await _httpClient.SendAsync(request);

        if (!response.IsSuccessStatusCode)
        {
            return ServiceResult<PlaceDto>.Fail(404, AppErrorEnum.Place_Not_Found.ToString());
        }

        var json = await response.Content.ReadFromJsonAsync<JsonElement>();

        var name = json.GetProperty("displayName").GetProperty("text").GetString()!;
        var address = json.GetProperty("formattedAddress").GetString()!;
        var lat = json.GetProperty("location").GetProperty("latitude").GetDouble();
        var lng = json.GetProperty("location").GetProperty("longitude").GetDouble();
        var addressComponents = json.GetProperty("addressComponents").EnumerateArray();

        string? city = null;
        string? country = null;

        foreach (var component in addressComponents)
        {
            var types = component.GetProperty("types").EnumerateArray().Select(t => t.GetString()).ToList();
    
            if (types.Contains("locality"))
                city = component.GetProperty("longText").GetString();
    
            if (types.Contains("country"))
                country = component.GetProperty("longText").GetString();
        }
        
        // check if already exists in DB
        var existing = await _context.Places.SingleOrDefaultAsync(x => x.GooglePlaceId == googlePlaceId);
        if (existing != null)
        {
            return ServiceResult<PlaceDto>.Ok(MapToDto(existing));
        }

        var place = new Place
        {
            Id = Guid.NewGuid(),
            Name = name,
            Address = address,
            City = city,
            Country = country,
            Latitude = lat,
            Longitude = lng,
            GooglePlaceId = googlePlaceId,
            CreatedAt = DateTime.UtcNow,
            UpdatedAt = DateTime.UtcNow
        };

        _context.Places.Add(place);
        await _context.SaveChangesAsync();

        return ServiceResult<PlaceDto>.Ok(MapToDto(place));
    }
    
    public async Task<ServiceResult<PlaceDto>> GetPlace(Guid placeId)
    {
        var place = await _context.Places.SingleOrDefaultAsync(x => x.Id == placeId);

        if (place == null)
            return ServiceResult<PlaceDto>.Fail(404, AppErrorEnum.Place_Not_Found.ToString());

        return ServiceResult<PlaceDto>.Ok(MapToDto(place));
    }
    
    
    
    private PlaceDto MapToDto(Place place)
    {
        return new()
        {
            Id = place.Id,
            Name = place.Name,
            Address = place.Address,
            City = place.City,
            Country = place.Country,
            Latitude = place.Latitude,
            Longitude = place.Longitude,
            GooglePlaceId = place.GooglePlaceId
        };
    }
}