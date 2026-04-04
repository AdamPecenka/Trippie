using Microsoft.AspNetCore.Mvc;
using TrippieBackend.Common;
using TrippieBackend.Models;
using TrippieBackend.Models.DTOs;
using TrippieBackend.Models.DTOs.Accomodations;
using TrippieBackend.Services.IService;

namespace TrippieBackend.Controllers;

[ApiController]
[Route("api/trips/{tripId:guid}/accommodations")]
public class AccommodationsController : ControllerBase
{
    private readonly IAccommodationService _accommodationService;

    public AccommodationsController(IAccommodationService accommodationService)
    {
        _accommodationService = accommodationService;
    }

    /// <summary>Returns the accommodation for a trip.</summary>
    /// <param name="tripId">Trip ID</param>
    /// <returns>Accommodation details including place and check-in/out times</returns>
    /// <response code="200">Accommodation returned successfully</response>
    /// <response code="401">Token is missing or invalid</response>
    /// <response code="403">Caller is not a member of this trip</response>
    /// <response code="404">Trip or accommodation not found</response>
    [HttpGet]
    public async Task<IActionResult> GetAccommodation([FromRoute] Guid tripId)
    {
        Guid userId = Utils.GetUserId(User);

        var result = await _accommodationService.GetAccommodation(userId, tripId);

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

        return Ok(ApiResponse<AccommodationDto>.Success(result.Value!));
    }

    /// <summary>Update accommodation details. Only accessible by the Trip Manager.</summary>
    /// <param name="tripId">Trip ID</param>
    /// <param name="accommodationId">Accommodation ID</param>
    /// <param name="request">Fields to update (all optional)</param>
    /// <response code="204">Accommodation updated successfully</response>
    /// <response code="400">Invalid check-in/check-out range</response>
    /// <response code="401">Token is missing or invalid</response>
    /// <response code="403">Caller is not a member or not the Trip Manager</response>
    /// <response code="404">Trip, accommodation or place not found</response>
    [HttpPatch("{accommodationId:guid}")]
    public async Task<IActionResult> PatchAccommodation([FromRoute] Guid tripId, [FromRoute] Guid accommodationId, [FromBody] PatchAccommodationRequestDto request)
    {
        Guid userId = Utils.GetUserId(User);

        var result = await _accommodationService.PatchAccommodation(userId, tripId, accommodationId, request);

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
    
    /// <summary>Create accommodation for a trip. Only one allowed per trip. Only accessible by the Trip Manager.</summary>
    /// <param name="tripId">Trip ID</param>
    /// <param name="request">Accommodation details</param>
    /// <returns>Newly created accommodation</returns>
    /// <response code="200">Accommodation created successfully</response>
    /// <response code="400">Invalid check-in/check-out range</response>
    /// <response code="401">Token is missing or invalid</response>
    /// <response code="403">Caller is not a member or not the Trip Manager</response>
    /// <response code="404">Trip or place not found</response>
    /// <response code="409">Accommodation already exists for this trip</response>
    [HttpPost]
    public async Task<IActionResult> CreateAccommodation([FromRoute] Guid tripId, [FromBody] CreateAccommodationRequestDto request)
    {
        Guid userId = Utils.GetUserId(User);
    
        var result = await _accommodationService.CreateAccommodation(userId, tripId, request);
    
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
    
        return Ok(ApiResponse<AccommodationDto>.Success(result.Value!));
    }
}