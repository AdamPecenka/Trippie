using System.ComponentModel.DataAnnotations;

namespace TrippieBackend.Models.DTOs;

public class UserPutRequestDto
{
    [Required]
    [MinLength(1)]
    [MaxLength(50)]
    public string Firstname { get; init; }
    
    [Required]
    [MinLength(1)]
    [MaxLength(50)]
    public string Lastname { get; init; }
    
    [Required]
    [Phone]
    public string PhoneNumber { get; init; }
}