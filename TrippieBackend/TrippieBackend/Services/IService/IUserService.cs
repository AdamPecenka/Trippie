using TrippieBackend.Models;

namespace TrippieBackend.Services.IService;

public interface IUserService {
    public Task<User?> GetUserById(int id);

    public Task CreateUser(User user);
}
