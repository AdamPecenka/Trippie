namespace TrippieBackend.Models.DTOs.Activities;

public class ActivityDto
{
    public Guid Id { get; init; }
    public string? Name { get; init; }
    public DateOnly? ActivityDate { get; init; }
    public TimeOnly? StartTime { get; init; }
    public TimeOnly? EndTime { get; init; }
    public string? Notes { get; init; }
    public Guid? CreatedBy { get; init; }
    public PlaceDto? Place { get; init; }
}