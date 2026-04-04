using TrippieBackend.Models.DTOs.Accomodations;
using TrippieBackend.Models.DTOs.Flights;
using TrippieBackend.Models.Enums;

namespace TrippieBackend.Models.DTOs.Trips;

public class TripDetailDto
{
    public Guid Id { get; set; }
    public string Name { get; set; } = string.Empty;
    public TripStatusEnum TripStatus { get; set; }
    public DateTime StartDate { get; set; }
    public DateTime EndDate { get; set; }

    public AccommodationDto? Accommodation { get; set; }
    public List<FlightDto> Flights { get; set; } = new(2);
}