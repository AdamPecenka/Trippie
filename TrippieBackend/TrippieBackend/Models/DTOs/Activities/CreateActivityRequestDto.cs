namespace TrippieBackend.Models.DTOs.Activities;

public class CreateActivityRequestDto
{
    public string? Name { get; init; }
    public Guid? PlaceId { get; init; }
    public DateOnly? ActivityDate { get; init; }
    public TimeOnly? StartTime { get; init; }
    public TimeOnly? EndTime { get; init; }
    public string? Notes { get; init; }
}