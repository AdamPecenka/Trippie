using Microsoft.AspNetCore.Mvc;
using TrippieBackend.Common;
using TrippieBackend.Models;
using TrippieBackend.Models.DTOs;
using TrippieBackend.Models.DTOs.Invites;
using TrippieBackend.Services.IService;

namespace TrippieBackend.Controllers;

[ApiController]
[Route("api/trips/{tripId:guid}/invites")]
public class InvitesController : ControllerBase
{
    private readonly IInviteService _inviteService;

    public InvitesController(IInviteService inviteService)
    {
        _inviteService = inviteService;
    }

    /// <summary>Generate or retrieve the invite code for a trip. Any trip member can call this.</summary>
    /// <param name="tripId">Trip ID</param>
    /// <returns>Invite code for the trip</returns>
    /// <response code="200">Invite code returned successfully</response>
    /// <response code="401">Token is missing or invalid</response>
    /// <response code="403">Caller is not a member of this trip</response>
    /// <response code="404">Trip not found</response>
    /// <response code="409">Trip is already finished</response>
    [HttpPost]
    public async Task<IActionResult> GetOrCreateInviteCode([FromRoute] Guid tripId)
    {
        Guid userId = Utils.GetUserId(User);

        var result = await _inviteService.GetOrCreateInviteCode(userId, tripId);

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

        return Ok(ApiResponse<InviteResponseDto>.Success(result.Value!));
    }
    
    /// <summary>Join a trip using an invite code.</summary>
    /// <param name="tripId">Trip ID</param>
    /// <param name="inviteCode">Invite code from QR or manual entry</param>
    /// <returns>Trip ID and name for the splash screen</returns>
    /// <response code="200">Successfully joined the trip</response>
    /// <response code="401">Token is missing or invalid</response>
    /// <response code="404">Trip not found or invite code is invalid</response>
    /// <response code="409">Trip is already finished or caller is already a member</response>
    [HttpPost("{inviteCode:int}/join")]
    public async Task<IActionResult> JoinTrip([FromRoute] Guid tripId, [FromRoute] int inviteCode)
    {
        Guid userId = Utils.GetUserId(User);

        var result = await _inviteService.JoinTrip(userId, tripId, inviteCode);

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

        return Ok(ApiResponse<JoinTripResponseDto>.Success(result.Value!));
    }
}