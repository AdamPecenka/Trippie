using System.Text.Json.Serialization;

namespace TrippieBackend.Models.GooglePlaces;

public class AutocompleteRequestBody
{
    [JsonPropertyName("input")]
    public string Input { get; init; }
    
    [JsonPropertyName("locationBias")]
    public LocationBias? LocationBias { get; init; }
}

public class LocationBias
{
    [JsonPropertyName("circle")]
    public Circle Circle { get; init; }
}

public class Circle
{
    [JsonPropertyName("center")]
    public Center Center { get; init; }
    
    [JsonPropertyName("radius")]
    public double Radius { get; init; }
}

public class Center
{
    [JsonPropertyName("latitude")]
    public double Latitude { get; init; }
    
    [JsonPropertyName("longitude")]
    public double Longitude { get; init; }
}