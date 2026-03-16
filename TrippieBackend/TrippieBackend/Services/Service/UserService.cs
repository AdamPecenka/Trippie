using TrippieBackend.Models;
using TrippieBackend.Models.Model;
using TrippieBackend.Services.IService;

namespace TrippieBackend.Services.Service;

public class UserService : IUserService{
    private readonly TrippieContext _context;

    public UserService(TrippieContext context) {
        _context = context;
    }

    public async Task<User?> GetUserById(Guid userId) {
        return await _context.Users.FindAsync(userId);
    }

    public async Task CreateUser(User user) {
        await _context.Users.AddAsync(user);
        await _context.SaveChangesAsync();
    }
}
