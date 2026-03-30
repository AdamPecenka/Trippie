using Microsoft.AspNetCore.Mvc;
using TrippieBackend.Models.DTOs;
using TrippieBackend.Services.IService;

namespace TrippieBackend.Controllers;

[ApiController]
[Route("api/[controller]")]
public class AirportsController : ControllerBase
{
    private readonly IAirportService _airportService;

    public AirportsController(IAirportService airportService)
    {
        _airportService = airportService;
    }
    
    /// <summary>Search airports by name, city, country or IATA code.</summary>
    /// <code>Example: GET /api/airports?search=vienna&amp;limit=5</code>
    /// <param name="search">Search query string</param>
    /// <param name="limit">Max number of results to return (default: 10)</param>
    /// <returns>List of matching airports</returns>
    [HttpGet]
    public async Task<IActionResult> Search([FromQuery] AirportSearchRequestDto searchRequest)
    {
        var result = await _airportService.Search(searchRequest.Search, searchRequest.Limit);
        return Ok(result);
    }
}