using Microsoft.EntityFrameworkCore;
using TrippieBackend.Models;
using TrippieBackend.Models.DTOs;
using TrippieBackend.Services.IService;

namespace TrippieBackend.Services.Service;

public class AirportService : IAirportService
{
    private readonly TrippieContext _context;
    
    public AirportService(TrippieContext context)
    {
        _context = context;
    }
    
    public async Task<ServiceResult<List<AirportDto>>> Search(string search, int limit)
    {
        // Prazdny string nemusi obtazovat DB, ale nieje to Error
        if (string.IsNullOrWhiteSpace(search))
        {
            return ServiceResult<List<AirportDto>>.Ok(new List<AirportDto>());
        }
        
        string query = search.ToLower();
        
        var airports = await _context.Airports
            .Where(x => 
                x.Name.ToLower().Contains(query) || 
                x.City.ToLower().Contains(query) ||
                x.Country.ToLower().Contains(query) ||
                x.IataCode.ToLower().Contains(query)
            ).Take(limit).ToListAsync();

        var result = airports.Select(x => new AirportDto
        {
            Id = x.Id,
            Name = x.Name,
            City = x.City,
            Country = x.Country,
            IataCode = x.IataCode,
            Latitude = x.Latitude,
            Longitude = x.Longitude
        }).ToList();

        return ServiceResult<List<AirportDto>>.Ok(result);
    }
}