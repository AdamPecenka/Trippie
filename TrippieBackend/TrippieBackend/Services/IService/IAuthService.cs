using TrippieBackend.Models.DTOs;
using TrippieBackend.Models.Enums;

namespace TrippieBackend.Services.IService;

public interface IAuthService {
    Task<ServiceResult<AuthResponseDto>> Login(string username, string password);
    Task<ServiceResult<AuthResponseDto>> RegisterNewUser(RegisterRequestDto registerRequestDto);
    Task<ServiceResult<RefreshResponseDto>> RefreshTokens(string refreshTokenValue);
    Task<ServiceResult<bool>> Logout(string refreshTokenValue);
}
