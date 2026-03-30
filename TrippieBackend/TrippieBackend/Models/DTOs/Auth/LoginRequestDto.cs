using System.ComponentModel.DataAnnotations;

namespace TrippieBackend.Models.DTOs;

public class LoginRequestDto
{
    [Required, EmailAddress, MaxLength(320)]
    public string Email { get; init; }
    
    [Required, MinLength(10)]
    public string Password { get; init; }
}