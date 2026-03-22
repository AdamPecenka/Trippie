using System.ComponentModel.DataAnnotations;

namespace TrippieBackend.Models.DTOs;

public class RegisterRequestDto
{
    [Required, MaxLength(50)]
    public string Firstname { get; init; }

    [Required, MaxLength(50)]
    public string Lastname { get; init; }
    
    [Required, EmailAddress, MaxLength(320)]
    public string Email { get; init; }
    
    [Required, Phone, MaxLength(20)]
    public string PhoneNumber { get; init; }
    
    [Required, MinLength(10)]
    public string Password { get; init; }
}