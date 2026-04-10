using TrippieBackend.Models.Enums;

namespace TrippieBackend.Models.DTOs.Flights;

public class PatchFlightRequestDto
{
    public TravelDirectionEnum? TravelDirection { get; init; }
    public string? FlightNumber { get; init; }
    public Guid? DepartureAirportId { get; init; }
    public Guid? ArrivalAirportId { get; init; }
    public DateTime? DepartureTime { get; init; }
    public DateTime? ArrivalTime { get; init; }
}