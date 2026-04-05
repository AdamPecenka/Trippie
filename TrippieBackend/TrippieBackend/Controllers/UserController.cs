using System.Security.Claims;
using Microsoft.AspNetCore.Mvc;
using TrippieBackend.Common;
using TrippieBackend.Models;
using TrippieBackend.Models.DTOs;
using TrippieBackend.Services.IService;

namespace TrippieBackend.Controllers;

[ApiController]
[Route("api/[controller]/me")]
public class UserController: ControllerBase {
    private readonly IUserService _userService;
    
    public UserController(IUserService userService) {
        _userService = userService;
    }

    /// <summary>Returns the authenticated user's profile.</summary>
    /// <returns>The authenticated user's profile data.</returns>
    /// <response code="200">User profile returned successfully.</response>
    /// <response code="401">Token is missing or invalid.</response>
    /// <response code="500">Valid token but no matching user found in DB.</response>
    [HttpGet]
    public async Task<IActionResult> GetMe()
    {
        Guid userId = Utils.GetUserId(User);

        var result = await _userService.GetMe(userId);

        // service throws exception, middleware catches it and creates 500 response automatically
        return Ok(ApiResponse<UserDto>.Success(result.Value!));
    }
    
    /// <summary>Updates the authenticated user's profile. Email is not updatable.</summary>
    /// <param name="userPutRequest">Fields to update on the authenticated user.</param>
    /// <returns>Doesn't return anything. Optimistic update -> relying on client to keep his updated data</returns>
    /// <response code="204">User updated successfully.</response>
    /// <response code="400">Request body failed validation.</response>
    /// <response code="401">Token is missing or invalid.</response>
    /// <response code="500">Valid token but no matching user found in DB.</response>
    [HttpPut]
    public async Task<IActionResult> PutMe([FromBody] UserPutRequestDto userPutRequest)
    {
        Guid userId = Utils.GetUserId(User);
        
        await _userService.PutMe(userId, userPutRequest);
        // optimisticky update, nema sa co pokazit :3
        return NoContent();
    }

    /// <summary>Toggle the authenticated user's theme between LIGHT and DARK.</summary>
    /// <response code="204">Theme updated successfully</response>
    /// <response code="401">Token is missing or invalid</response>
    [HttpPatch("theme")]
    public async Task<IActionResult> UpdateUserTheme()
    {
        Guid userId = Utils.GetUserId(User);

        await _userService.UpdateUserTheme(userId);

        // optimisticky update, nema sa co pokazit :3
        return NoContent();
    }
    
    /// <summary>Upload or replace the authenticated user's avatar.</summary>
    /// <param name="file">Image file (JPEG, PNG or WebP, max 5MB)</param>
    /// <response code="204">Avatar uploaded successfully</response>
    /// <response code="400">Invalid file format or file too large</response>
    /// <response code="401">Token is missing or invalid</response>
    [HttpPut("avatar")]
    public async Task<IActionResult> UploadAvatar(IFormFile file)
    {
        Guid userId = Utils.GetUserId(User);

        var result = await _userService.UploadAvatar(userId, file);

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

    /// <summary>Get the authenticated user's avatar as binary image data.</summary>
    /// <returns>Raw image file</returns>
    /// <response code="200">Avatar returned as binary</response>
    /// <response code="401">Token is missing or invalid</response>
    /// <response code="404">User has no avatar uploaded</response>
    [HttpGet("avatar")]
    public async Task<IActionResult> GetAvatar()
    {
        Guid userId = Utils.GetUserId(User);

        var result = await _userService.GetAvatar(userId);

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

        var (data, contentType) = result.Value;
        return File(data, contentType);
    }
}
