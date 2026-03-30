using System;
using System.Collections.Generic;

namespace TrippieBackend.Models.Model;

public class UserLastLocation
{
    public Guid UserId { get; set; }

    public Guid TripId { get; set; }

    public double? Latitude { get; set; }

    public double? Longitude { get; set; }

    public DateTime CreatedAt { get; set; }

    public DateTime UpdatedAt { get; set; }
    
    
    public User User { get; set; } = null!;
    
    public Trip Trip { get; set; } = null!;
}
