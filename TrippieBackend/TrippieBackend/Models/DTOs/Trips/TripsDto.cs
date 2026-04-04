using TrippieBackend.Models.Enums;

namespace TrippieBackend.Models.DTOs.Trips;

public class TripsDto
{
    public Guid Id { get; init; }

    public string Name { get; init; }
    
    public TripStatusEnum TripStatus { get; init; }
    
    public DateTime StartDate { get; init; }
    
    public DateTime EndDate { get; init; }
}