using System.Security.Claims;
using Microsoft.AspNetCore.Mvc;
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
        Guid userId = Guid.Parse(User.FindFirstValue(ClaimTypes.NameIdentifier)!);

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
        Guid userId = Guid.Parse(User.FindFirstValue(ClaimTypes.NameIdentifier)!);
        
        await _userService.PutMe(userId, userPutRequest);
        // optimisticky update, nema sa co pokazit :3
        return NoContent();
    }

    [HttpPatch]
    public async Task<IActionResult> UpdateUserTheme()
    {
        Guid userId = Guid.Parse(User.FindFirstValue(ClaimTypes.NameIdentifier)!);

        await _userService.UpdateUserTheme(userId);

        // optimisticky update, nema sa co pokazit :3
        return NoContent();
    }
}
