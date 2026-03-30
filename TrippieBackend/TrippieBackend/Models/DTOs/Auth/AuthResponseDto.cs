namespace TrippieBackend.Models.DTOs;

public class AuthResponseDto
{
    public UserDto UserDto { get; init; }
    public string AccessToken { get; init; }
    public string RefreshToken { get; init; }
}