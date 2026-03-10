using Microsoft.AspNetCore.Mvc;
using TrippieBackend.Models;
using TrippieBackend.Services.IService;

namespace TrippieBackend.Controllers;

[ApiController]
[Route("api/[controller]")]
public class UserController: ControllerBase {
    private readonly IUserService _userService;
    
    public UserController(IUserService userService) {
        _userService = userService;
    }

    [HttpGet("{id:int}")]
    public async Task<ActionResult<User>> GetUserById(int id) {
        var user = await _userService.GetUserById(id);

        if(user == null) { 
            return NotFound();
        }
        
        return Ok(user);
    }

    [HttpPost]
    public async Task<ActionResult<User>> CreateUser(User user) {
        if (user == null) {
            return BadRequest();
        }

        await _userService.CreateUser(user);

        return Ok();
    }
}
