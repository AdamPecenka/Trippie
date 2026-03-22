namespace TrippieBackend.Models;

public class ApiResponse<T>
{
    public T? Data { get; set; }
    public string? Error { get; set; }
    public string? Message { get; set; }

    public static ApiResponse<T> Success(T data)
    {
        return new()
        {
            Data = data
        };
    }

    public static ApiResponse<T> Failure(string error, string message)
    {
        return new()
        {
            Error = error,
            Message = message
        };
    }
}