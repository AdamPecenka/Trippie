using TrippieBackend.Models.DTOs;
using TrippieBackend.Models;

namespace TrippieBackend.Services.IService;

public interface IUserService {
    public Task<ServiceResult<UserDto>> GetMe(Guid userId);
    public Task<ServiceResult<bool>> PutMe(Guid userId, UserPutRequestDto userPutRequest);
    public Task<ServiceResult<bool>> UpdateUserTheme(Guid userId);
    public Task<ServiceResult<bool>> UploadAvatar(Guid userId, IFormFile file);
    public Task<ServiceResult<(byte[] Data, string ContentType)>> GetAvatar(Guid userId);
}
