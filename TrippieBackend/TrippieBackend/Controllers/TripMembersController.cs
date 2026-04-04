using Microsoft.AspNetCore.Mvc;
using TrippieBackend.Common;
using TrippieBackend.Models;
using TrippieBackend.Models.DTOs;
using TrippieBackend.Models.DTOs.Members;
using TrippieBackend.Services.IService;

namespace TrippieBackend.Controllers;

[ApiController]
[Route("api/trips/{tripId:guid}/members")]
public class TripMembersController : ControllerBase
{
    private readonly ITripMemberService _tripMemberService;

    public TripMembersController(ITripMemberService tripMemberService)
    {
        _tripMemberService = tripMemberService;
    }

    /// <summary>Returns all members of a trip.</summary>
    /// <param name="tripId">Trip ID</param>
    /// <returns>List of trip members with their roles</returns>
    /// <response code="200">Members returned successfully</response>
    /// <response code="401">Token is missing or invalid</response>
    /// <response code="403">Caller is not a member of this trip</response>
    /// <response code="404">Trip not found</response>
    [HttpGet]
    public async Task<IActionResult> GetTripMembers([FromRoute] Guid tripId)
    {
        Guid userId = Utils.GetUserId(User);

        var result = await _tripMemberService.GetTripMembers(userId, tripId);

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

        return Ok(ApiResponse<List<TripMemberDto>>.Success(result.Value!));
    }

    /// <summary>Leave a trip. Trip Manager cannot leave — transfer ownership first.</summary>
    /// <param name="tripId">Trip ID</param>
    /// <response code="204">Successfully left the trip</response>
    /// <response code="401">Token is missing or invalid</response>
    /// <response code="403">Caller is not a member of this trip</response>
    /// <response code="404">Trip not found</response>
    /// <response code="409">Trip Manager cannot leave the trip</response>
    [HttpDelete("me")]
    public async Task<IActionResult> LeaveTrip([FromRoute] Guid tripId)
    {
        Guid userId = Utils.GetUserId(User);

        var result = await _tripMemberService.LeaveTrip(userId, tripId);

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

        return NoContent();
    }
}