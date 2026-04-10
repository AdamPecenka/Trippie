using System.ComponentModel.DataAnnotations;

namespace TrippieBackend.Models.DTOs;

public class GoogleAuthRequestDto
{
    [Required]
    public string IdToken { get; init; }
}