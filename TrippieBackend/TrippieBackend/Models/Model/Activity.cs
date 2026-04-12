using System;
using System.Collections.Generic;

namespace TrippieBackend.Models.Model;

public class Activity
{
    public Guid Id { get; set; }

    public Guid? TripId { get; set; }

    public Guid? PlaceId { get; set; }
    
    public string Name { get; set; }

    public DateOnly? ActivityDate { get; set; }

    public TimeOnly? StartTime { get; set; }

    public TimeOnly? EndTime { get; set; }

    public string? Notes { get; set; }

    public Guid? CreatedBy { get; set; }

    public DateTime CreatedAt { get; set; }

    public DateTime UpdatedAt { get; set; }
    
    public Trip? Trip { get; set; }
    
    public Place? Place { get; set; }
    
    public User? Creator { get; set; }
}
