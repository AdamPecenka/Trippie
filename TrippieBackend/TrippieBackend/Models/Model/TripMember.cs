using System;
using System.Collections.Generic;
using TrippieBackend.Models.Enums;

namespace TrippieBackend.Models.Model;

public class TripMember
{
    public Guid Id { get; set; }

    public Guid TripId { get; set; }
    
    public Guid UserId { get; set; }
    
    public TripRoleEnum TripRole { get; set; }

    public DateTime JoinedAt { get; set; }

    public DateTime CreatedAt { get; set; }
    
    public DateTime UpdatedAt { get; set; }
    
    
    
    public User User { get; set; } = null!;
    
    public Trip Trip { get; set; } = null!;
}
