using TrippieBackend.Models.DTOs;
using TrippieBackend.Models.Model;

namespace TrippieBackend.Services.IService;

public interface IUserService {
    public Task<ServiceResult<UserDto>> GetMe(Guid userId);
    public Task<ServiceResult<bool>> PutMe(Guid userId, UserPutRequestDto userPutRequest);
    public Task<ServiceResult<bool>> UpdateUserTheme(Guid userId);
}
