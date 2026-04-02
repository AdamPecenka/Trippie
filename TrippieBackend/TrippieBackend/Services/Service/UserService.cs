using Microsoft.EntityFrameworkCore;
using TrippieBackend.Models;
using TrippieBackend.Models.DTOs;
using TrippieBackend.Models.Enums;
using TrippieBackend.Models.Model;
using TrippieBackend.Services.IService;

namespace TrippieBackend.Services.Service;

public class UserService : IUserService{
    private readonly TrippieContext _context;

    public UserService(TrippieContext context) {
        _context = context;
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
