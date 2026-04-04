using System.ComponentModel.DataAnnotations;
using TrippieBackend.Models.Enums;

namespace TrippieBackend.Models.DTOs.Trips;

public class PatchTripRequestDto: IValidatableObject
{
    [MaxLength(255)]
    [MinLength(1)]
    public string? Name { get; init; }

    public Guid? DestinationPlaceId { get; init; }

    public TransportTypeEnum? TransportType { get; init; }

    public DateTime? StartDate { get; init; }

    public DateTime? EndDate { get; init; }

    public IEnumerable<ValidationResult> Validate(ValidationContext validationContext)
    {
        if (StartDate.HasValue && EndDate.HasValue && EndDate <= StartDate)
        {
            yield return new ValidationResult(
                "[!] EndDate must be after StartDate.",
                [nameof(EndDate)]
            );
        }
    }
}