using System;
using System.Collections.Generic;
using TrippieBackend.Models.Enums;

namespace TrippieBackend.Models.Model;

public class Flight
{
    public Guid Id { get; set; }

    public Guid TripId { get; set; }
    
    public TravelDirectionEnum TravelDirection { get; set; }

    public string? FlightNumber { get; set; }

    public string? DepartureAirport { get; set; }

    public string? ArrivalAirport { get; set; }

    public DateTime? DepartureTime { get; set; }

    public DateTime? ArrivalTime { get; set; }

    public DateTime CreatedAt { get; set; }

    public DateTime UpdatedAt { get; set; }
    
    
    public Trip Trip { get; set; } = null!;
}
