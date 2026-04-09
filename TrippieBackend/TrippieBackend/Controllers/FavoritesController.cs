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
}