namespace TrippieBackend.Models;

public class ServiceResult<T>
{
    public T? Value { get; }
    public string? Error { get; }
    public string? Field { get; }
    public short Code { get; }
    public bool IsSuccess => Error == null;

    private ServiceResult(T value) { Value = value; Code = 200; }
    private ServiceResult(short code, string error, string? field = null)
    {
        Code = code; Error = error; Field = field;
    }

    public static ServiceResult<T> Ok(T value) 
        => new(value);
    public static ServiceResult<T> Fail(short code, string error, string? field = null) 
        => new(code, error, field);
}