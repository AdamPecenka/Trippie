using TrippieBackend.Models.DTOs;
using TrippieBackend.Models.Enums;

namespace TrippieBackend.Services.IService;

public interface IAuthService {
    Task<(AuthResponseDto? authResponseDto, AppErrorEnum? error)> Login(string username, string password);
    Task<(AuthResponseDto? authResponseDto, AppErrorEnum? error)> RegisterNewUser(RegisterRequestDto registerRequestDto);
    Task<(RefreshResponseDto? refreshResponseDto, AppErrorEnum? error)> RefreshTokens(string refreshTokenValue);
    Task<AppErrorEnum?> Logout(string refreshTokenValue);
}
