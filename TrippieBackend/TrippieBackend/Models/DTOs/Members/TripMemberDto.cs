using TrippieBackend.Models.Enums;

namespace TrippieBackend.Models.DTOs.Members;

public class TripMemberDto
{
    public Guid UserId { get; init; }
    
    public string Firstname { get; init; }
    
    public string Lastname { get; init; }
    
    public string Email { get; init; }
    
    public TripRoleEnum TripRole { get; init; }
    
    public DateTime JoinedAt { get; init; }
}