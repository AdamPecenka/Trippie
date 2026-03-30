namespace TrippieBackend.Models.DTOs;

public class AirportDto
{
    public Guid Id { get; init; }
    public string Name { get; init; }
    public string City { get; init; }
    public string Country { get; init; }
    public string IataCode { get; init; }
    public decimal Latitude { get; init; }
    public decimal Longitude { get; init; }
    public decimal Timezone { get; init; }
}