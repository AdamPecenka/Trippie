using Microsoft.AspNetCore.Mvc;
using TrippieBackend.Common;
using TrippieBackend.Models;
using TrippieBackend.Models.DTOs;
using TrippieBackend.Models.DTOs.Activities;
using TrippieBackend.Services.IService;

namespace TrippieBackend.Controllers;

[ApiController]
[Route("api/trips/{tripId:guid}/activities")]
public class ActivitiesController : ControllerBase
{
    private readonly IActivityService _activityService;

    public ActivitiesController(IActivityService activityService)
    {
        _activityService = activityService;
    }

    /// <summary>Get all activities for a trip.</summary>
    /// <response code="200">Activities returned successfully</response>
    /// <response code="403">User is not a member of the trip</response>
    [HttpGet]
    public async Task<IActionResult> GetActivities([FromRoute] Guid tripId)
    {
        Guid userId = Utils.GetUserId(User);

        var result = await _activityService.GetActivities(userId, tripId);

        if (!result.IsSuccess)
            return StatusCode(result.Code, ApiResponse<object>.Failure(new ErrorDto
            {
                Status = "error",
                Code = result.Code,
                Message = result.Error!,
                Field = result.Field
            }));

        return Ok(ApiResponse<List<ActivityDto>>.Success(result.Value!));
    }
    
    /// <summary>Create a new activity for a trip.</summary>
    /// <response code="201">Activity created successfully</response>
    /// <response code="403">User is not a member of the trip</response>
    [HttpPost]
    public async Task<IActionResult> CreateActivity([FromRoute] Guid tripId, [FromBody] CreateActivityRequestDto request)
    {
        Guid userId = Utils.GetUserId(User);

        var result = await _activityService.CreateActivity(userId, tripId, request);

        if (!result.IsSuccess)
            return StatusCode(result.Code, ApiResponse<object>.Failure(new ErrorDto
            {
                Status = "error",
                Code = result.Code,
                Message = result.Error!,
                Field = result.Field
            }));

        return StatusCode(201, ApiResponse<ActivityDto>.Success(result.Value!));
    }
    
    /// <summary>Get a single activity by ID.</summary>
    /// <response code="200">Activity returned successfully</response>
    /// <response code="403">User is not a member of the trip</response>
    /// <response code="404">Activity not found</response>
    [HttpGet("{activityId:guid}")]
    public async Task<IActionResult> GetActivity([FromRoute] Guid tripId, [FromRoute] Guid activityId)
    {
        Guid userId = Utils.GetUserId(User);

        var result = await _activityService.GetActivity(userId, tripId, activityId);

        if (!result.IsSuccess)
            return StatusCode(result.Code, ApiResponse<object>.Failure(new ErrorDto
            {
                Status = "error",
                Code = result.Code,
                Message = result.Error!,
                Field = result.Field
            }));

        return Ok(ApiResponse<ActivityDto>.Success(result.Value!));
    }
    
    /// <summary>Patch an existing activity.</summary>
    /// <response code="204">Activity updated successfully</response>
    /// <response code="403">User is not a member of the trip</response>
    /// <response code="404">Activity not found</response>
    [HttpPatch("{activityId:guid}")]
    public async Task<IActionResult> PatchActivity([FromRoute] Guid tripId, [FromRoute] Guid activityId, [FromBody] PatchActivityRequestDto request)
    {
        Guid userId = Utils.GetUserId(User);

        var result = await _activityService.PatchActivity(userId, tripId, activityId, request);

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
    
    /// <summary>Delete an activity.</summary>
    /// <response code="204">Activity deleted successfully</response>
    /// <response code="403">User is not a member of the trip</response>
    /// <response code="404">Activity not found</response>
    [HttpDelete("{activityId:guid}")]
    public async Task<IActionResult> DeleteActivity([FromRoute] Guid tripId, [FromRoute] Guid activityId)
    {
        Guid userId = Utils.GetUserId(User);

        var result = await _activityService.DeleteActivity(userId, tripId, activityId);

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