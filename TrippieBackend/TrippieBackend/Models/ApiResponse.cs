using TrippieBackend.Models.DTOs;

namespace TrippieBackend.Models;

public class ApiResponse<T>
{
    public T? Data { get; set; }
    public ErrorDto? Error { get; set; }

    public static ApiResponse<T> Success(T data)
    {
        return new()
        {
            Data = data
        };
    }

    public static ApiResponse<T> Failure(ErrorDto error)
    {
        return new()
        {
            Error = error
        };
    }
}