using System.ComponentModel.DataAnnotations;

namespace TrippieBackend.Models.DTOs;

public class AirportSearchRequestDto
{
    [Required]
    [MinLength(1)]
    [MaxLength(100)]
    public string Search { get; init; }
    
    [Range(1, 50)]
    public int Limit { get; init; } = 10;
}