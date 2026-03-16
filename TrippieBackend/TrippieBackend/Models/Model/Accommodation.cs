using System;
using System.Collections.Generic;

namespace TrippieBackend.Models.Model;

public class Accommodation
{
    public Guid Id { get; set; }

    public Guid? TripId { get; set; }

    public Guid? PlaceId { get; set; }

    public DateTime? CheckIn { get; set; }

    public DateTime? CheckOut { get; set; }

    public DateTime CreatedAt { get; set; }

    public DateTime UpdatedAt { get; set; }
    
    
    public Trip? Trip { get; set; }
    
    public Place? Place { get; set; }
}
