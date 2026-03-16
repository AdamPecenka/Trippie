using System;
using System.Collections.Generic;
using TrippieBackend.Models.Enums;

namespace TrippieBackend.Models.Model;

public class Trip
{
    public Guid Id { get; set; }

    public string Name { get; set; } = null!;

    public Guid? DestinationPlaceId { get; set; }

    public TransportTypeEnum TransportType { get; set; }
    
    public TripStatusEnum TripStatus { get; set; } = TripStatusEnum.PLANNING;

    public DateTime StartDate { get; set; }
    
    public DateTime EndDate { get; set; }

    public Guid CreatedBy { get; set; }
    
    public DateTime CreatedAt { get; set; }
    
    public DateTime UpdatedAt { get; set; }
    
    
    
    public User Creator { get; set; } = null!;
    
    public Place? DestinationPlace { get; set; }
    
    public ICollection<TripMember> Members { get; set; } = new List<TripMember>();
}
