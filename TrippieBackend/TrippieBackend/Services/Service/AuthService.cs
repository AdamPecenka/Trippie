using Microsoft.IdentityModel.Tokens;
using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Security.Cryptography;
using System.Text;
using Microsoft.EntityFrameworkCore;
using TrippieBackend.Models;
using TrippieBackend.Models.DTOs;
using TrippieBackend.Models.Enums;
using TrippieBackend.Models.Model;
using TrippieBackend.Services.IService;

namespace TrippieBackend.Services.Service;

public class AuthService : IAuthService
{
    private readonly TrippieContext _context;
    private readonly IConfiguration _configuration;

    public AuthService(TrippieContext context, IConfiguration configuration)
    {
        _context = context;
        _configuration = configuration;
    }

    public async Task<(AuthResponseDto? authResponseDto, AppErrorEnum? error)> Login(string email, string password)
    {
        User? user = await _context.Users.SingleOrDefaultAsync(x => x.Email == email);

        if (user == null)
        {
            return (null, AppErrorEnum.InvalidCredentials);
        }

        bool isValid = BCrypt.Net.BCrypt.Verify(password, user.PasswordHash);
        if (!isValid)
        {
            return (null, AppErrorEnum.InvalidCredentials);
        }

        var existingToken = await _context.RefreshTokens
            .FirstOrDefaultAsync(x => x.UserId == user.Id && !x.Revoked);

        if (existingToken != null)
        {
            existingToken.Revoked = true;
            existingToken.UpdatedAt = DateTime.UtcNow;
            await _context.SaveChangesAsync();
        }

        var refreshToken = await GenerateRefreshToken(user.Id);
        string accessToken = await GenerateJwtToken(user.Id, user.Email);

        AuthResponseDto authResponseDto = new()
        {
            UserDto = new UserDto()
            {
                Id = user.Id,
                Firstname = user.Firstname,
                Lastname = user.Lastname,
                Email = user.Email,
                PhoneNumber = user.PhoneNumber,
                Theme = user.Theme
            },
            AccessToken = accessToken,
            RefreshToken = refreshToken.TokenValue,
        };

        return (authResponseDto, null);
    }

    public async Task<(AuthResponseDto? authResponseDto, AppErrorEnum? error)> RegisterNewUser(
        RegisterRequestDto registerRequestDto)
    {
        if (await _context.Users.AnyAsync(x => x.Email == registerRequestDto.Email))
        {
            return (null, AppErrorEnum.EmailAlreadyExists);
        }

        if (await _context.Users.AnyAsync(x => x.PhoneNumber == registerRequestDto.PhoneNumber))
        {
            return (null, AppErrorEnum.PhoneAlreadyExists);
        }

        User newUser = new()
        {
            Firstname = registerRequestDto.Firstname,
            Lastname = registerRequestDto.Lastname,
            Email = registerRequestDto.Email,
            PhoneNumber = registerRequestDto.PhoneNumber,
            PasswordHash = BCrypt.Net.BCrypt.HashPassword(registerRequestDto.Password, workFactor: 12),
            Theme = ThemeEnum.LIGHT
        };


        await _context.Users.AddAsync(newUser);
        await _context.SaveChangesAsync();

        string accessToken = await GenerateJwtToken(newUser.Id, newUser.Email);
        RefreshToken refreshToken = await GenerateRefreshToken(newUser.Id);

        AuthResponseDto authResponseDto = new()
        {
            UserDto = new UserDto()
            {
                Id = newUser.Id,
                Firstname = newUser.Firstname,
                Lastname = newUser.Lastname,
                Email = newUser.Email,
                PhoneNumber = newUser.PhoneNumber,
                Theme = newUser.Theme
            },
            AccessToken = accessToken,
            RefreshToken = refreshToken.TokenValue,
        };

        return (authResponseDto, null);
    }

    public async Task<(RefreshResponseDto? refreshResponseDto, AppErrorEnum? error)> RefreshTokens(string refreshTokenValue)
    {
        var storedRefreshToken = await _context.RefreshTokens
            .Include(x => x.User)
                .SingleOrDefaultAsync(x => x.TokenValue == refreshTokenValue);

        if (storedRefreshToken == null)
        {
            return (null, AppErrorEnum.InvalidRefreshToken);
        }

        if (storedRefreshToken.ExpiresAt < DateTime.UtcNow)
        {
            storedRefreshToken.Revoked = true;
            await _context.SaveChangesAsync();
            return (null, AppErrorEnum.RefreshTokenExpired);
        }

        storedRefreshToken.Revoked = true;
        await _context.SaveChangesAsync();

        var newRefreshToken = await GenerateRefreshToken(storedRefreshToken.UserId);
        var newAccessToken = await GenerateJwtToken(storedRefreshToken.UserId, storedRefreshToken.User.Email);

        RefreshResponseDto refreshResponseDto = new()
        {
            AccessToken = newAccessToken,
            RefreshToken = newRefreshToken.TokenValue
        };

        return (refreshResponseDto, null);
    }

    public async Task<AppErrorEnum?> Logout(string refreshTokenValue)
    {
        var storedToken = await _context.RefreshTokens
            .SingleOrDefaultAsync(x => x.TokenValue == refreshTokenValue);

        if (storedToken == null)
        {
            return AppErrorEnum.InvalidRefreshToken;
        }
        
        if (storedToken.Revoked == true)
        {
            var allUserTokens = await _context.RefreshTokens
                .Where(x => x.UserId == storedToken.UserId)
                .ToListAsync();
    
            foreach (var token in allUserTokens)
            {
                token.Revoked = true;
                token.UpdatedAt = DateTime.UtcNow;
            }
    
            await _context.SaveChangesAsync();
            return AppErrorEnum.RefreshTokenRevoked;
        }

        storedToken.Revoked = true;
        storedToken.UpdatedAt = DateTime.UtcNow;
        await _context.SaveChangesAsync();

        return null;
    } 
    
    
    
    
    private Task<string> GenerateJwtToken(Guid userId, string email)
    {
        var claims = new List<Claim>
        {
            new Claim(JwtRegisteredClaimNames.Sub, userId.ToString()),
            new Claim(JwtRegisteredClaimNames.Jti, Guid.NewGuid().ToString()),
            new Claim(JwtRegisteredClaimNames.Email, email)
        };

        var key = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(_configuration["Auth:JwtSecretKey"]));
        var creds = new SigningCredentials(key, SecurityAlgorithms.HmacSha256);

        var token = new JwtSecurityToken(
            issuer: _configuration["Auth:JwtIssuer"],
            audience: _configuration["Auth:JwtAudience"],
            claims: claims,
            expires: DateTime.Now.AddMinutes(15),
            signingCredentials: creds);

        return Task.FromResult(new JwtSecurityTokenHandler().WriteToken(token));
    }

    private async Task<RefreshToken> GenerateRefreshToken(Guid userId)
    {
        var tokenValue = Convert.ToBase64String(RandomNumberGenerator.GetBytes(64));

        RefreshToken refreshToken = new()
        {
            UserId = userId,
            TokenValue = tokenValue,
            ExpiresAt = DateTime.UtcNow.AddDays(7),
            Revoked = false,
        };

        await _context.RefreshTokens.AddAsync(refreshToken);
        await _context.SaveChangesAsync();

        return refreshToken;
    }
}