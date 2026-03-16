using TrippieBackend.Models.Enums;

namespace TrippieBackend.Models.Model;

public class User
{
    public Guid Id { get; set; }

    public string Firstname { get; set; } = null!;
    
    public string Lastname { get; set; } = null!;

    public string Email { get; set; } = null!;
    
    public string PhoneNumber { get; set; } = null!;

    public string PasswordHash { get; set; } = null!;

    public ThemeEnum Theme { get; set; } = ThemeEnum.LIGHT;

    public DateTime CreatedAt { get; set; }
    
    public DateTime UpdatedAt { get; set; }
    
    
    public ICollection<Trip> CreatedTrips { get; set; } = new List<Trip>();
    
    public ICollection<TripMember> TripMemberships { get; set; } = new List<TripMember>();
}
