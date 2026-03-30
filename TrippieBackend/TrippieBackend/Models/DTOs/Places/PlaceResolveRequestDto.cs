using System.ComponentModel.DataAnnotations;

namespace TrippieBackend.Models.DTOs;

public class PlaceResolveRequestDto
{
    [Required]
    public string GooglePlaceId { get; init; }
}