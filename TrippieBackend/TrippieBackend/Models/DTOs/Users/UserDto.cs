using TrippieBackend.Models.Enums;

namespace TrippieBackend.Models.DTOs;

public class UserDto
{
    public Guid Id { get; init; }   
    public string Firstname { get; init; }
    public string Lastname { get; init; }
    public string Email { get; init; }
    public string PhoneNumber { get; init; }
    public ThemeEnum Theme { get; init; }
}