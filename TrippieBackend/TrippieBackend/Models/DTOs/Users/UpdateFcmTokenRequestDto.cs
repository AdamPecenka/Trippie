using System.ComponentModel.DataAnnotations;
namespace TrippieBackend.Models.DTOs;

public class UpdateFcmTokenRequestDto
{
    [Required]
    public string FcmToken { get; set; } = null!;
}