using Microsoft.IdentityModel.Tokens;
using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;
using TrippieBackend.Models;
using TrippieBackend.Services.IService;

namespace TrippieBackend.Services.Service;

public class AuthService : IAuthService {
    private readonly TrippieContext _context;
    private readonly IConfiguration _configuration;

    public AuthService(TrippieContext context, IConfiguration configuration) {
        _context = context;
        _configuration = configuration;
    }

    public Task<string> GenerateJwtToken(Guid userId, string email) {
        var claims = new List<Claim> {
            new Claim(JwtRegisteredClaimNames.Sub, userId.ToString()),
            new Claim(JwtRegisteredClaimNames.Jti, Guid.NewGuid().ToString()),
            new Claim(JwtRegisteredClaimNames.Email, email)
        };
    
        var key = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(_configuration["API:JwtSecretKey"]));
        var creds = new SigningCredentials(key, SecurityAlgorithms.HmacSha256);

        var token = new JwtSecurityToken(
            issuer: "yourdomain.com",
            audience: "yourdomain.com",
            claims: claims,
            expires: DateTime.Now.AddMinutes(30),
            signingCredentials: creds);

        return Task.FromResult(new JwtSecurityTokenHandler().WriteToken(token));
    }
}
