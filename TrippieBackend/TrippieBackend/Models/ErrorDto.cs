namespace TrippieBackend.Models.DTOs;

public class ErrorDto
{
    public string Status { get; init; }
    public short Code { get; init; }
    public string Message { get; init; }
    public string? Field { get; init; }
}