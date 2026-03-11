using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using TrippieBackend.Services.IService;

namespace TrippieBackend.Controllers;

[Route("api/[controller]")]
[ApiController]
public class AuthController: ControllerBase {
    private readonly IAuthService _authService;

    public AuthController(IAuthService authService) {
        _authService = authService;
    }

    [AllowAnonymous]
    [HttpPost("login")]
    public async Task<IActionResult> Login() {
        var token = await _authService.GenerateJwtToken(Guid.NewGuid(), "test@example.com");

        return Ok(token);
    }
}
