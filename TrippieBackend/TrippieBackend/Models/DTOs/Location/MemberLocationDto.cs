namespace TrippieBackend.Models.DTOs.Location;

public class MemberLocationDto
{
    public Guid UserId { get; set; }
    public string Firstname { get; set; } = string.Empty;
    public string Lastname { get; set; } = string.Empty;
    public double? Latitude { get; set; }
    public double? Longitude { get; set; }
}