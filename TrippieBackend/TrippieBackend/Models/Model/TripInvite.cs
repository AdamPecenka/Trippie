using System;
using System.Collections.Generic;

namespace TrippieBackend.Models.Model;

public class TripInvite
{
    public Guid Id { get; set; }

    public Guid? TripId { get; set; }

    public string? InviteCode { get; set; }

    public Guid? CreatedBy { get; set; }

    public bool? Used { get; set; }

    public DateTime? UsedAt { get; set; }

    public DateTime CreatedAt { get; set; }

    public DateTime UpdatedAt { get; set; }
    
    
    public Trip? Trip { get; set; }
    
    public User? Creator { get; set; }
}
