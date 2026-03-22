namespace TrippieBackend.Models.DTOs;

public class RefreshResponseDto
{
    public string AccessToken { get; init; }
    public string RefreshToken { get; init; }
}