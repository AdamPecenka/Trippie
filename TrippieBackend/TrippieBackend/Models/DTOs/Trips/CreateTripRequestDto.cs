using System.ComponentModel.DataAnnotations;
using TrippieBackend.Models.Enums;

namespace TrippieBackend.Models.DTOs.Trips;

public class CreateTripRequestDto : IValidatableObject
{
    [Required]
    [MinLength(1)]
    [MaxLength(255)]
    public string Name { get; init; }

    [Required]
    public Guid DestinationPlaceId { get; init; }

    [Required]
    public TransportTypeEnum TransportType { get; init; }

    [Required]
    public DateTime StartDate { get; set; }

    [Required]
    public DateTime EndDate { get; set; }

    public IEnumerable<ValidationResult> Validate(ValidationContext validationContext)
    {
        if (EndDate <= StartDate)
        {
            yield return new ValidationResult(
                "[!] EndDate must be after StartDate.",
                [nameof(EndDate)]
            );
        }
    }
}