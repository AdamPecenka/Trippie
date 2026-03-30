using System.ComponentModel.DataAnnotations;

namespace TrippieBackend.Models.DTOs;

public class PlacesSearchRequestDto
{
    [Required]
    [MinLength(1)]
    [MaxLength(100)]
    public string Query { get; init; }

    [Range(-90, 90)]
    public double? Latitude { get; init; }
    
    [Range(-180, 180)]
    public double? Longitude { get; init; }
}