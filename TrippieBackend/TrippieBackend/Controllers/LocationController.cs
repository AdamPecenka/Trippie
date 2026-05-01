using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using TrippieBackend.Common;
using TrippieBackend.Models;
using TrippieBackend.Models.DTOs;
using TrippieBackend.Models.DTOs.Location;
using TrippieBackend.Services.IService;

namespace TrippieBackend.Controllers;

[Authorize]
[ApiController]
[Route("api/location")]
public class LocationController : ControllerBase
{
    private readonly ILocationService _locationService;

    public LocationController(ILocationService locationService)
    {
        _locationService = locationService;
    }

    /// <summary>Save user's last known location for a trip.</summary>
    /// <response code="204">Location updated successfully</response>
    /// <response code="403">User is not a member of the trip</response>
    [HttpPost("trips/{tripId:guid}/me")]
    public async Task<IActionResult> UpdateLocation([FromRoute] Guid tripId, [FromBody] UpdateLocationRequestDto request)
    {
        Guid userId = Utils.GetUserId(User);

        var result = await _locationService.UpdateLocation(userId, tripId, request);

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

    /// <summary>Get last known locations of all members in a trip.</summary>
    /// <param name="tripId">Trip identifier.</param>
    /// <returns>List of member locations; lat/lng null if member has never shared location.</returns>
    /// <response code="200">Member locations returned.</response>
    /// <response code="403">Caller is not a member of the trip.</response>
    [HttpGet("trips/{tripId:guid}/members")]
    public async Task<IActionResult> GetTripMemberLocations([FromRoute] Guid tripId)
    {
        Guid userId = Utils.GetUserId(User);

        var result = await _locationService.GetTripMemberLocations(userId, tripId);

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

        return Ok(ApiResponse<List<MemberLocationDto>>.Success(result.Value!));
    }
}