using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using TrippieBackend.Common;
using TrippieBackend.Models;
using TrippieBackend.Models.DTOs;
using TrippieBackend.Models.DTOs.Flights;
using TrippieBackend.Services.IService;

namespace TrippieBackend.Controllers;

[Authorize]
[ApiController]
[Route("api/trips/{tripId:guid}/flights")]
public class FlightsController : ControllerBase
{
    private readonly IFlightService _flightService;

    public FlightsController(IFlightService flightService)
    {
        _flightService = flightService;
    }

    /// <summary>Get all flights for a trip.</summary>
    /// <response code="200">Flights returned successfully</response>
    /// <response code="403">User is not a member of the trip</response>
    [HttpGet]
    public async Task<IActionResult> GetFlights([FromRoute] Guid tripId)
    {
        Guid userId = Utils.GetUserId(User);

        var result = await _flightService.GetFlights(userId, tripId);

        if (!result.IsSuccess)
            return StatusCode(result.Code, ApiResponse<object>.Failure(new ErrorDto
            {
                Status = "error",
                Code = result.Code,
                Message = result.Error!,
                Field = result.Field
            }));

        return Ok(ApiResponse<List<FlightDto>>.Success(result.Value!));
    }
    
    /// <summary>Create a new flight for a trip.</summary>
    /// <response code="201">Flight created successfully</response>
    /// <response code="403">User is not a member of the trip</response>
    /// <response code="404">Departure or arrival airport not found</response>
    [HttpPost]
    public async Task<IActionResult> CreateFlight([FromRoute] Guid tripId, [FromBody] CreateFlightRequestDto request)
    {
        Guid userId = Utils.GetUserId(User);

        var result = await _flightService.CreateFlight(userId, tripId, request);

        if (!result.IsSuccess)
            return StatusCode(result.Code, ApiResponse<object>.Failure(new ErrorDto
            {
                Status = "error",
                Code = result.Code,
                Message = result.Error!,
                Field = result.Field
            }));

        return StatusCode(201, ApiResponse<FlightDto>.Success(result.Value!));
    }
    
    /// <summary>Patch an existing flight.</summary>
    /// <response code="204">Flight updated successfully</response>
    /// <response code="403">User is not a member of the trip</response>
    /// <response code="404">Flight or airport not found</response>
    [HttpPatch("{flightId:guid}")]
    public async Task<IActionResult> PatchFlight([FromRoute] Guid tripId, [FromRoute] Guid flightId, [FromBody] PatchFlightRequestDto request)
    {
        Guid userId = Utils.GetUserId(User);

        var result = await _flightService.PatchFlight(userId, tripId, flightId, request);

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
    
    /// <summary>Delete a flight.</summary>
    /// <response code="204">Flight deleted successfully</response>
    /// <response code="403">User is not a member of the trip</response>
    /// <response code="404">Flight not found</response>
    [HttpDelete("{flightId:guid}")]
    public async Task<IActionResult> DeleteFlight([FromRoute] Guid tripId, [FromRoute] Guid flightId)
    {
        Guid userId = Utils.GetUserId(User);

        var result = await _flightService.DeleteFlight(userId, tripId, flightId);

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