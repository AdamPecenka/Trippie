using System.ComponentModel.DataAnnotations;

namespace TrippieBackend.Models.DTOs;

public class RefreshRequestDto
{
    [Required]
    public string RefreshToken { get; init; }
}