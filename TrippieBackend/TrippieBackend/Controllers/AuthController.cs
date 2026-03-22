using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using TrippieBackend.Models;
using TrippieBackend.Models.DTOs;
using TrippieBackend.Models.Enums;
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
        var (result, error) = await _authService.Login(loginRequestDto.Email, loginRequestDto.Password);

        if (error != null)
        {
            if (error == AppErrorEnum.InvalidCredentials)
            {
                return Unauthorized(ApiResponse<object>.Failure(error.ToString(), "Incorrect email or password"));
            }
            
            return StatusCode(500, ApiResponse<object>.Failure("InternalServerError", "Unexpected error"));
        }
        
        return Ok(ApiResponse<AuthResponseDto>.Success(result!));
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
        var (result, error) = await _authService.RefreshTokens(refreshRequestDto.RefreshToken);

        if (error != null)
        {
            if (error == AppErrorEnum.InvalidRefreshToken)
            {
                return Unauthorized(ApiResponse<object>.Failure(error.ToString(), "Invalid refresh token"));
            }

            if (error == AppErrorEnum.RefreshTokenExpired)
            {
                return Unauthorized(ApiResponse<object>.Failure(error.ToString(), "Refresh token expired"));
            }

            return StatusCode(500, ApiResponse<object>.Failure("InternalServerError", "Unexpected error"));
        }

        return Ok(ApiResponse<RefreshResponseDto>.Success(result!));
    }
    
    
    /// <summary>Register a new user account</summary>
    /// <param name="registerRequestDto">User registration details</param>
    /// <returns>User data with access and refresh tokens</returns>
    /// <response code="200">Registration successful</response>
    /// <response code="400">Validation failed</response>
    /// <response code="409">Email or phone number already in use</response>
    [AllowAnonymous]
    [HttpPost("register")]
    public async Task<IActionResult> Register([FromBody] RegisterRequestDto registerRequestDto)
    {
        var (result, error) = await _authService.RegisterNewUser(registerRequestDto);
        
        if (error != null)
        {
            if (error == AppErrorEnum.EmailAlreadyExists)
            {
                return Conflict(ApiResponse<object>.Failure(error.ToString(), "Email already in use"));
            }
            if (error == AppErrorEnum.PhoneAlreadyExists)
            {
                return Conflict(ApiResponse<object>.Failure(error.ToString(), "Phone number already in use"));
            }
            
            return StatusCode(500, ApiResponse<object>.Failure("InternalServerError", "Unexpected error"));
        }
        
        return Ok(ApiResponse<AuthResponseDto>.Success(result!));
    }
    
    
    /// <summary>Logout and invalidate the current refresh token</summary>
    /// <param name="refreshRequestDto">Current refresh token</param>
    /// <response code="204">Logout successful</response>
    /// <response code="401">Refresh token is invalid</response>
    [Authorize]
    [HttpPost("logout")]
    public async Task<IActionResult> Logout([FromBody] RefreshRequestDto refreshRequestDto)
    {
        var error = await _authService.Logout(refreshRequestDto.RefreshToken);

        if (error != null)
        {
            if (error == AppErrorEnum.InvalidRefreshToken)
            {
                Console.WriteLine("[!]  Refresh token is invalid");
                return Unauthorized(ApiResponse<object>.Failure(error.ToString(), "Invalid refresh token"));
            }
            if (error == AppErrorEnum.RefreshTokenRevoked)
            {
                return Unauthorized(ApiResponse<object>.Failure(error.ToString(), "Refresh token already revoked, possibility of theft!"));
            } 
            
            return StatusCode(500, ApiResponse<object>.Failure("InternalServerError", "Unexpected error"));
        }

        return NoContent();
    }
}
