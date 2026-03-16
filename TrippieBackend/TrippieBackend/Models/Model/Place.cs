using System;
using System.Collections.Generic;

namespace TrippieBackend.Models.Model;

public class Place
{
    public Guid Id { get; set; }

    public string Name { get; set; } = null!;
    
    public string? Address { get; set; }
    
    public string? City { get; set; }
    
    public string? Country { get; set; }

    public decimal Latitude { get; set; }
    public decimal Longitude { get; set; }

    public string? GooglePlaceId { get; set; }

    public DateTime CreatedAt { get; set; }
    
    public DateTime UpdatedAt { get; set; }
    
    
    
    public ICollection<Trip> Trips { get; set; } = new List<Trip>();
}
