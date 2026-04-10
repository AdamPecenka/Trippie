using Microsoft.AspNetCore.Mvc;
using TrippieBackend.Models;
using TrippieBackend.Models.DTOs;
using TrippieBackend.Models.Enums;
using TrippieBackend.Services.IService;

namespace TrippieBackend.Controllers;

[ApiController]
[Route("api/[controller]")]
public class PlacesController : ControllerBase
{
    private readonly IPlaceService _placeService;

    public PlacesController(IPlaceService placeService)
    {
        _placeService = placeService;
    }
    
    /// <summary>Autocomplete place search using Google Places API.</summary>
    /// <param name="searchRequest">Search query with optional lat/lng bias</param>
    /// <returns>List of place suggestions with Google Place ID and display name</returns>
    /// <response code="200">List of suggestions returned successfully</response>
    /// <response code="400">Only one of Latitude or Longitude was provided</response>
    [HttpGet("search")]
    public async Task<IActionResult> Autocomplete([FromQuery] PlacesSearchRequestDto searchRequest)
    {
        if (searchRequest.Latitude.HasValue != searchRequest.Longitude.HasValue)
        {
            return StatusCode(400, ApiResponse<object>.Failure(new ErrorDto
            {
                Status = "error",
                Code = 400,
                Message = AppErrorEnum.Places_Autocomplete_Lat_Or_Lng_Not_Provided.ToString(),
                Field = null
            }));
        }
        
        var result = await _placeService.Autocomplete(searchRequest.Query, searchRequest.Latitude, searchRequest.Longitude);
        return Ok(ApiResponse<List<PlaceSuggestionDto>>.Success(result.Value!));
    }

    /// <summary>Resolve a Google Place ID into a stored Place entity.</summary>
    /// <param name="resolveRequest">Google Place ID to resolve</param>
    /// <returns>Internal Place object stored in the database</returns>
    /// <response code="200">Place resolved and returned successfully</response>
    /// <response code="404">Google Place ID not found</response>
    [HttpPost("resolve")]
    public async Task<IActionResult> Resolve([FromBody] PlaceResolveRequestDto resolveRequest)
    {
        var result = await _placeService.Resolve(resolveRequest.GooglePlaceId);
        
        if (!result.IsSuccess)
        {
            return StatusCode(result.Code, ApiResponse<object>.Failure(new ErrorDto
            {
                Status = "error",
                Code = result.Code,
                Message = result.Error!,
                Field = result.Field
            }));
        }

        return Ok(ApiResponse<PlaceDto>.Success(result.Value!));
    }
    
    /// <summary>Get a place by its internal ID.</summary>
    /// <param name="placeId">Internal Place UUID</param>
    /// <returns>Place details</returns>
    /// <response code="200">Place returned successfully</response>
    /// <response code="404">Place not found</response>
    [HttpGet("{placeId:guid}")]
    public async Task<IActionResult> GetPlace([FromRoute] Guid placeId)
    {
        var result = await _placeService.GetPlace(placeId);

        if (!result.IsSuccess)
        {
            return StatusCode(result.Code, ApiResponse<object>.Failure(new ErrorDto
            {
                Status = "error",
                Code = result.Code,
                Message = result.Error!,
                Field = result.Field
            }));
        }

        return Ok(ApiResponse<PlaceDto>.Success(result.Value!));
    }
}