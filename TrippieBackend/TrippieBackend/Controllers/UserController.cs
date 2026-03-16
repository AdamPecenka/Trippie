using Microsoft.AspNetCore.Mvc;
using TrippieBackend.Models.Model;
using TrippieBackend.Services.IService;

namespace TrippieBackend.Controllers;

[ApiController]
[Route("api/[controller]")]
public class UserController: ControllerBase {
    private readonly IUserService _userService;
    
    public UserController(IUserService userService) {
        _userService = userService;
    }

    /// <summary>
    /// Retrieves a user by their unique identifier.
    /// </summary>
    /// <param name="id">The unique identifier of the user.</param>
    /// <returns>The user with the specified ID, or NotFound if the user does not exist.</returns>
    [HttpGet("{id:Guid}")]
    public async Task<ActionResult<User>> GetUserById(Guid id) {
        var user = await _userService.GetUserById(id);

        if(user == null) {
            return NotFound();
        }
        
        return Ok(user);
    }

    /// <summary>
    /// Creates a new user in the system.
    /// </summary>
    /// <param name="user">The user object containing the details of the user to create.</param>
    /// <returns>Ok if the user is created successfully, or BadRequest if the user object is null.</returns>
    [HttpPost]
    public async Task<ActionResult<User>> CreateUser(User user) {
        if (user == null) {
            return BadRequest();
        }

        await _userService.CreateUser(user);

        return Ok();
    }
}
