using System.ComponentModel.DataAnnotations;
using TrippieBackend.Models.Enums;

namespace TrippieBackend.Models.DTOs.Trips;

public class PatchTripStatusRequestDto
{
    [Required]
    public TripStatusEnum Status { get; init; }
}