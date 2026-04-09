using TrippieBackend.Models;
using TrippieBackend.Models.DTOs.Favorites;

namespace TrippieBackend.Services.IService;

public interface IFavoriteService
{
    Task<ServiceResult<List<FavoriteDto>>> GetFavorites(Guid userId);
    Task<ServiceResult<FavoriteDto>> CreateFavorite(Guid userId, Guid placeId);
    Task<ServiceResult<bool>> DeleteFavorite(Guid userId, Guid placeId);
}