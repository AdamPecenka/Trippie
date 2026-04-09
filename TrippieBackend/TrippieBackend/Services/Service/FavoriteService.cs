using Microsoft.EntityFrameworkCore;
using TrippieBackend.Models;
using TrippieBackend.Models.DTOs;
using TrippieBackend.Models.DTOs.Favorites;
using TrippieBackend.Models.Model;
using TrippieBackend.Models.Enums;
using TrippieBackend.Services.IService;

namespace TrippieBackend.Services.Service;

public class FavoriteService : IFavoriteService
{
    private readonly TrippieContext _context;

    public FavoriteService(TrippieContext context)
    {
        _context = context;
    }

    public async Task<ServiceResult<List<FavoriteDto>>> GetFavorites(Guid userId)
    {
        var favorites = await _context.Favorites
            .Where(f => f.UserId == userId)
            .Include(f => f.Place)
            .OrderByDescending(f => f.CreatedAt)
            .ToListAsync();

        return ServiceResult<List<FavoriteDto>>.Ok(favorites.Select(MapToDto).ToList());
    }
    
    public async Task<ServiceResult<FavoriteDto>> CreateFavorite(Guid userId, Guid placeId)
    {
        var place = await _context.Places.SingleOrDefaultAsync(p => p.Id == placeId);

        if (place == null)
            return ServiceResult<FavoriteDto>.Fail(404, AppErrorEnum.Place_Not_Found.ToString());

        var alreadyExists = await _context.Favorites
            .AnyAsync(f => f.UserId == userId && f.PlaceId == placeId);

        if (alreadyExists)
            return ServiceResult<FavoriteDto>.Fail(409, AppErrorEnum.Favorite_Already_Exists.ToString());

        var favorite = new Favorite
        {
            UserId = userId,
            PlaceId = placeId,
            Place = place
        };

        _context.Favorites.Add(favorite);
        await _context.SaveChangesAsync();

        return ServiceResult<FavoriteDto>.Ok(MapToDto(favorite));
    }

    public async Task<ServiceResult<bool>> DeleteFavorite(Guid userId, Guid placeId)
    {
        var favorite = await _context.Favorites
            .SingleOrDefaultAsync(f => f.UserId == userId && f.PlaceId == placeId);

        if (favorite == null)
            return ServiceResult<bool>.Fail(404, AppErrorEnum.Favorite_Not_Found.ToString());

        _context.Favorites.Remove(favorite);
        await _context.SaveChangesAsync();

        return ServiceResult<bool>.Ok(true);
    }

    private static FavoriteDto MapToDto(Favorite f) => new()
    {
        Id = f.Id,
        Place = new PlaceDto
        {
            Id = f.Place.Id,
            Name = f.Place.Name,
            Address = f.Place.Address,
            City = f.Place.City,
            Country = f.Place.Country,
            Latitude = f.Place.Latitude,
            Longitude = f.Place.Longitude,
            GooglePlaceId = f.Place.GooglePlaceId
        }
    };
}