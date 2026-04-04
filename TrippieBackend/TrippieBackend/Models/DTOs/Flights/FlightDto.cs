using TrippieBackend.Models.Enums;

namespace TrippieBackend.Models.DTOs.Flights;

public class FlightDto
{
    public Guid Id { get; set; }
    
    public TravelDirectionEnum TravelDirection { get; set; }
    
    public string? FlightNumber { get; set; }
    
    public string DepartureIataCode { get; set; } = string.Empty;
    
    public string DepartureCityName { get; set; } = string.Empty;
    
    public string ArrivalIataCode { get; set; } = string.Empty;
    
    public string ArrivalCityName { get; set; } = string.Empty;
    
    public DateTime? DepartureTime { get; set; }
    
    public DateTime? ArrivalTime { get; set; }
}