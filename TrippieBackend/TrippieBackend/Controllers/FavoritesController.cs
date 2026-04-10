using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using TrippieBackend.Common;
using TrippieBackend.Models;
using TrippieBackend.Models.DTOs;
using TrippieBackend.Models.DTOs.Favorites;
using TrippieBackend.Services.IService;

namespace TrippieBackend.Controllers;

[Authorize]
[ApiController]
[Route("api/[controller]")]
public class FavoritesController : ControllerBase
{
    private readonly IFavoriteService _favoriteService;

    public FavoritesController(IFavoriteService favoriteService)
    {
        _favoriteService = favoriteService;
    }

    /// <summary>Get all favorites for the authenticated user.</summary>
    /// <response code="200">Favorites returned successfully</response>
    [HttpGet]
    public async Task<IActionResult> GetFavorites()
    {
        Guid userId = Utils.GetUserId(User);

        var result = await _favoriteService.GetFavorites(userId);

        return Ok(ApiResponse<List<FavoriteDto>>.Success(result.Value!));
    }
    
    /// <summary>Add a place to favorites.</summary>
    /// <response code="201">Favorite created successfully</response>
    /// <response code="404">Place not found</response>
    /// <response code="409">Place already in favorites</response>
    [HttpPost]
    public async Task<IActionResult> CreateFavorite([FromBody] CreateFavoriteRequestDto request)
    {
        Guid userId = Utils.GetUserId(User);

        var result = await _favoriteService.CreateFavorite(userId, request.PlaceId);

        if (!result.IsSuccess)
            return StatusCode(result.Code, ApiResponse<object>.Failure(new ErrorDto
            {
                Status = "error",
                Code = result.Code,
                Message = result.Error!,
                Field = result.Field
            }));

        return StatusCode(201, ApiResponse<FavoriteDto>.Success(result.Value!));
    }

    /// <summary>Remove a place from favorites.</summary>
    /// <response code="204">Favorite deleted successfully</response>
    /// <response code="404">Favorite not found</response>
    [HttpDelete("{placeId:guid}")]
    public async Task<IActionResult> DeleteFavorite([FromRoute] Guid placeId)
    {
        Guid userId = Utils.GetUserId(User);

        var result = await _favoriteService.DeleteFavorite(userId, placeId);

        if (!result.IsSuccess)
            return StatusCode(result.Code, ApiResponse<object>.Failure(new ErrorDto
            {
                Status = "error",
                Code = result.Code,
                Message = result.Error!,
                Field = result.Field
            }));

        return NoContent();
    }
}