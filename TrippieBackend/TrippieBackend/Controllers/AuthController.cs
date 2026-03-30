using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using TrippieBackend.Models;
using TrippieBackend.Models.DTOs;
using TrippieBackend.Services.IService;

namespace TrippieBackend.Controllers;

[Route("api/[controller]")]
[ApiController]
public class AuthController: ControllerBase {
    private readonly IAuthService _authService;

    public AuthController(IAuthService authService) {
        _authService = authService;
    }

    
    /// <summary>Login with email and password</summary>
    /// <param loginRequestDto="loginRequestDto">User credentials</param>
    /// <returns>User data with access and refresh tokens</returns>
    /// <response code="200">Login successful</response>
    /// <response code="401">Incorrect email or password</response>
    [AllowAnonymous]
    [HttpPost("login")]
    public async Task<IActionResult> Login([FromBody] LoginRequestDto loginRequestDto)
    {
        var result = await _authService.Login(loginRequestDto.Email, loginRequestDto.Password);

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

        return Ok(ApiResponse<AuthResponseDto>.Success(result.Value!));
    }
    
    
    /// <summary>Issue new tokens using a valid refresh token</summary>
    /// <param name="refreshRequestDto">Current refresh token</param>
    /// <returns>New access and refresh tokens</returns>
    /// <response code="200">Tokens refreshed successfully</response>
    /// <response code="401">Refresh token is invalid or expired</response>
    [AllowAnonymous]
    [HttpPost("refresh")]
    public async Task<IActionResult> Refresh([FromBody] RefreshRequestDto refreshRequestDto)
    {
        var result = await _authService.RefreshTokens(refreshRequestDto.RefreshToken);

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

        return Ok(ApiResponse<RefreshResponseDto>.Success(result.Value!));
    }
    
    
    /// <summary>Register a new user account</summary>
    /// <param name="registerRequestDto">User registration details</param>
    /// <returns>User data with access and refresh tokens</returns>
    /// <response code="200">Registration successful</response>
    /// <response code="409">Email or phone number already in use</response>
    [AllowAnonymous]
    [HttpPost("register")]
    public async Task<IActionResult> Register([FromBody] RegisterRequestDto registerRequestDto)
    {
        var result = await _authService.RegisterNewUser(registerRequestDto);

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

        return Ok(ApiResponse<AuthResponseDto>.Success(result.Value!));
    }
    
    
    /// <summary>Logout and invalidate the current refresh token</summary>
    /// <param name="refreshRequestDto">Current refresh token</param>
    /// <response code="204">Logout successful</response>
    /// <response code="401">Refresh token is invalid</response>
    [Authorize]
    [HttpPost("logout")]
    public async Task<IActionResult> Logout([FromBody] RefreshRequestDto refreshRequestDto)
    {
        var result = await _authService.Logout(refreshRequestDto.RefreshToken);

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
