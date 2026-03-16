using TrippieBackend.Models.Model;

namespace TrippieBackend.Services.IService;

public interface IUserService {
    public Task<User?> GetUserById(Guid userId);

    public Task CreateUser(User user);
}
