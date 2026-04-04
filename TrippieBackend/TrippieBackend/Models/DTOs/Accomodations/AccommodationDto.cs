namespace TrippieBackend.Models.DTOs.Accomodations;

public class AccommodationDto
{
    public Guid Id { get; set; }
    
    public string PlaceName { get; set; } = string.Empty;
    
    public string? Address { get; set; }
    
    public DateTime? CheckIn { get; set; }
    
    public DateTime? CheckOut { get; set; }
}