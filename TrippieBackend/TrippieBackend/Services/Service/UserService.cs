using Microsoft.EntityFrameworkCore;
using TrippieBackend.Models;
using TrippieBackend.Models.DTOs;
using TrippieBackend.Models.Enums;
using TrippieBackend.Models.Model;
using TrippieBackend.Services.IService;

namespace TrippieBackend.Services.Service;

public class UserService : IUserService{
    private readonly TrippieContext _context;
    private readonly IConfiguration _configuration;
    private readonly string _avatarsDir;

    public UserService(TrippieContext context, IConfiguration configuration, IWebHostEnvironment env) {
        _context = context;
        _configuration = configuration;
        _avatarsDir = Path.Combine(env.ContentRootPath, 
            configuration["Storage:AvatarsPath"] ?? "Storage/Avatars");
    }

    public async Task<ServiceResult<UserDto>> GetMe(Guid userId)
    {
        var user = await _context.Users.Where(x => x.Id == userId).SingleOrDefaultAsync();

        if (user == null)
        {
            // ak neexistuje v DB user pre validny token, nieco je zle na serveri
            throw new InvalidOperationException($"[!!!] Authenticated user {userId} not found in DB");
        }
        
        return ServiceResult<UserDto>.Ok(MapToDto(user));
    }

    public async Task<ServiceResult<bool>> PutMe(Guid userId, UserPutRequestDto userPutRequest)
    {
        var user = await _context.Users.Where(x => x.Id == userId).SingleOrDefaultAsync();

        if (user == null)
        {
            // ak neexistuje v DB user pre validny token, nieco je zle na serveri
            throw new InvalidOperationException($"[!!!] Authenticated user {userId} not found in DB");
        }
        
        user.Firstname =  userPutRequest.Firstname;
        user.Lastname = userPutRequest.Lastname;
        user.PhoneNumber = userPutRequest.PhoneNumber;
        
        _context.Users.Update(user);
        await _context.SaveChangesAsync();
        
        return ServiceResult<bool>.Ok(true);
    }

    public async Task<ServiceResult<bool>> UpdateUserTheme(Guid userId)
    {
        var user = await _context.Users.Where(x => x.Id == userId).SingleOrDefaultAsync();

        if (user == null)
        {
            // ak neexistuje v DB user pre validny token, nieco je zle na serveri
            throw new InvalidOperationException($"[!!!] Authenticated user {userId} not found in DB");
        }
        
        user.Theme = user.Theme == ThemeEnum.LIGHT ? ThemeEnum.DARK : ThemeEnum.LIGHT;
        
        _context.Users.Update(user);
        await _context.SaveChangesAsync();
        
        return ServiceResult<bool>.Ok(true);
    }

    public async Task<ServiceResult<bool>> UploadAvatar(Guid userId, IFormFile file)
    {
        var user = await _context.Users.SingleOrDefaultAsync(u => u.Id == userId);
        if (user == null)
        {
            throw new InvalidOperationException($"[!!!] Authenticated user {userId} not found in DB");
        }

        var allowedTypes = new[] { "image/jpeg", "image/png", "image/webp" };
        if (!allowedTypes.Contains(file.ContentType))
        {
            return ServiceResult<bool>.Fail(400, AppErrorEnum.Avatar_Invalid_Format.ToString());
        }

        const long maxSizeBytes = 5 * 1024 * 1024; // 5MB
        if (file.Length > maxSizeBytes)
        {
            return ServiceResult<bool>.Fail(400, AppErrorEnum.Avatar_Too_Large.ToString());
        }

        Directory.CreateDirectory(_avatarsDir);

        // delete old avatar file if exists
        if (user.AvatarPath != null && File.Exists(user.AvatarPath))
        {
            File.Delete(user.AvatarPath);
            Console.WriteLine($"[-] deleted old avatar for user {userId}");
        }

        var extension = Path.GetExtension(file.FileName).ToLowerInvariant();
        var fileName = $"{userId}{extension}";
        var filePath = Path.Combine(_avatarsDir, fileName);

        await using var stream = new FileStream(filePath, FileMode.Create);
        await file.CopyToAsync(stream);

        Console.WriteLine($"[+] avatar saved for user {userId} at {filePath}");

        user.AvatarPath = filePath;
        user.UpdatedAt = DateTime.UtcNow;
        await _context.SaveChangesAsync();

        return ServiceResult<bool>.Ok(true);
    }
    
    public async Task<ServiceResult<(byte[] Data, string ContentType)>> GetAvatar(Guid userId)
    {
        var user = await _context.Users.SingleOrDefaultAsync(u => u.Id == userId);
        if (user == null)
        {
            throw new InvalidOperationException($"[!!!] Authenticated user {userId} not found in DB");
        }

        if (user.AvatarPath == null || !File.Exists(user.AvatarPath))
        {
            return ServiceResult<(byte[], string)>.Fail(404, AppErrorEnum.Avatar_Not_Found.ToString());
        }

        var data = await File.ReadAllBytesAsync(user.AvatarPath);
        var contentType = Path.GetExtension(user.AvatarPath).ToLowerInvariant() switch
        {
            ".jpg" or ".jpeg" => "image/jpeg",
            ".png" => "image/png",
            ".webp" => "image/webp",
            _ => "application/octet-stream"
        };

        return ServiceResult<(byte[], string)>.Ok((data, contentType));
    }
    
    private UserDto MapToDto(User user)
    {
        return new UserDto()
        {
            Id = user.Id,
            Email = user.Email,
            Firstname = user.Firstname,
            Lastname = user.Lastname,
            PhoneNumber = user.PhoneNumber,
            Theme = user.Theme
        };
    }
}
