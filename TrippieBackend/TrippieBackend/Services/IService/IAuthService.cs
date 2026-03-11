namespace TrippieBackend.Services.IService;

public interface IAuthService {
    Task<string> GenerateJwtToken(Guid userId, string email);
}
