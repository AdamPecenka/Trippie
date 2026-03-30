using TrippieBackend.Models.Model;

namespace TrippieBackend.Models.DTOs;

public class PlaceDto
{
    public Guid Id { get; init; }

    public string Name { get; init; }
    
    public string? Address { get; init; }
    
    public string? City { get; init; }
    
    public string? Country { get; init; }

    public double Latitude { get; init; }
    public double Longitude { get; init; }

    public string? GooglePlaceId { get; init; }
}