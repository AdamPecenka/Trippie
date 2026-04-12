namespace TrippieBackend.Models.DTOs.Invites;

public class MemberJoinedTripEventDto
{
    public Guid UserId { get; init; }
    public string Firstname { get; init; }
    public string Lastname { get; init; }
    public string Email { get; init; }
    public string? PhoneNumber { get; init; }
    public string TripRole { get; init; }
}