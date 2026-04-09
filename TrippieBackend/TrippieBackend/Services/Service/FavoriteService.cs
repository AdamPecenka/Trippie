using Microsoft.EntityFrameworkCore;
using TrippieBackend.Models;
using TrippieBackend.Models.DTOs;
using TrippieBackend.Models.DTOs.Favorites;
using TrippieBackend.Models.Model;
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