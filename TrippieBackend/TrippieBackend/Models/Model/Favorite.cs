using System;
using System.Collections.Generic;

namespace TrippieBackend.Models.Model;

public class Favorite
{
    public Guid Id { get; set; }

    public Guid? UserId { get; set; }

    public Guid? PlaceId { get; set; }

    public DateTime CreatedAt { get; set; }

    public DateTime UpdatedAt { get; set; }
    
    

    public Place Place { get; set; } = null!;

    public User User { get; set; } = null!;
}
