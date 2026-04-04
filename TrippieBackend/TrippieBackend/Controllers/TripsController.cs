using System.Security.Claims;
using Microsoft.AspNetCore.Mvc;
using TrippieBackend.Common;
using TrippieBackend.Models;
using TrippieBackend.Models.DTOs;
using TrippieBackend.Models.DTOs.Trips;
using TrippieBackend.Services.IService;

namespace TrippieBackend.Controllers;

[ApiController]
[Route("api/[controller]")]
public class TripsController : ControllerBase
{
    private readonly ITripService _tripService;

    public TripsController(ITripService tripService)
    {
        _tripService = tripService;
    }

    /// <summary>Returns all trips the authenticated user is a member of.</summary>
    /// <returns>List of trips the user belongs to</returns>
    /// <response code="200">Trips returned successfully</response>
    /// <response code="401">Token is missing or invalid</response>
    [HttpGet]
    public async Task<IActionResult> GetTrips()
    {
        Guid userId = Utils.GetUserId(User);

        var result = await _tripService.GetTrips(userId);

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

        return Ok(ApiResponse<List<TripsDto>>.Success(result.Value!));
    }

    /// <summary>Create a new trip. Caller is automatically assigned as Trip Manager.</summary>
    /// <param name="tripRequest">Trip creation details</param>
    /// <returns>Newly created trip</returns>
    /// <response code="200">Trip created successfully</response>
    /// <response code="400">Request body failed validation</response>
    /// <response code="401">Token is missing or invalid</response>
    /// <response code="404">Destination place not found</response>
    [HttpPost]
    public async Task<IActionResult> CreateTrip([FromBody] CreateTripRequestDto tripRequest)
    {
        Guid userId = Utils.GetUserId(User);

        var result = await _tripService.CreateTrip(userId, tripRequest);

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

        return Ok(ApiResponse<CreateTripResponseDto>.Success(result.Value!));
    }

    /// <summary> Retrieves detailed information about a specific trip. </summary>
    /// <param name="tripId">The unique identifier of the trip.</param>
    /// <returns>Detailed trip information including accommodation and flights.</returns>
    /// <response code="200">Trip detail returned successfully.</response>
    /// <response code="403">Requesting user is not a member of the trip.</response>
    /// <response code="404">Trip not found.</response>
    [HttpGet("{tripId:guid}")]
    public async Task<IActionResult> GetTripById([FromRoute] Guid tripId)
    {
        var userId = Utils.GetUserId(User);

        var result = await _tripService.GetTripById(userId, tripId);

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

        return Ok(ApiResponse<TripDetailDto>.Success(result.Value!));
    }

    /// <summary>Update trip details. Only accessible by the Trip Manager.</summary>
    /// <param name="tripId">Trip ID</param>
    /// <param name="request">Fields to update (all optional)</param>
    /// <response code="204">Trip updated successfully</response>
    /// <response code="400">Invalid date range</response>
    /// <response code="403">Caller is not a member or not the Trip Manager</response>
    /// <response code="404">Trip or destination place not found</response>
    [HttpPatch("{tripId:guid}")]
    public async Task<IActionResult> PatchTrip([FromRoute] Guid tripId, [FromBody] PatchTripRequestDto request)
    {
        Guid userId = Utils.GetUserId(User);

        var result = await _tripService.PatchTrip(userId, tripId, request);

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

    /// <summary>Advance the trip status. Only accessible by the Trip Manager.</summary>
    /// <param name="tripId">Trip ID</param>
    /// <param name="request">New status value</param>
    /// <remarks>Valid transitions: PLANNING → ACTIVE → FINISHED</remarks>
    /// <response code="204">Status updated successfully</response>
    /// <response code="403">Caller is not a member or not the Trip Manager</response>
    /// <response code="404">Trip not found</response>
    /// <response code="409">Requested status transition is not allowed</response>
    [HttpPatch("{tripId:guid}/status")]
    public async Task<IActionResult> PatchTripStatus([FromRoute] Guid tripId,
        [FromBody] PatchTripStatusRequestDto request)
    {
        Guid userId = Utils.GetUserId(User);

        var result = await _tripService.PatchTripStatus(userId, tripId, request.Status);

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