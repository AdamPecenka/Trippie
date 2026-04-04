using System.ComponentModel.DataAnnotations;

namespace TrippieBackend.Models.DTOs.Accomodations;

public class CreateAccommodationRequestDto : IValidatableObject
{
    [Required]
    public Guid PlaceId { get; init; }

    public DateTime? CheckIn { get; init; }

    public DateTime? CheckOut { get; init; }

    public IEnumerable<ValidationResult> Validate(ValidationContext validationContext)
    {
        if (CheckIn.HasValue && CheckOut.HasValue && CheckOut <= CheckIn)
        {
            yield return new ValidationResult(
                "[!] CheckOut must be after CheckIn.",
                [nameof(CheckOut)]
            );
        }
    }
}