using Microsoft.EntityFrameworkCore;
using TrippieBackend.Models;
using TrippieBackend.Models.DTOs.Location;
using TrippieBackend.Models.Enums;
using TrippieBackend.Models.Model;
using TrippieBackend.Services.IService;

namespace TrippieBackend.Services.Service;

public class LocationService : ILocationService
{
    private readonly TrippieContext _context;

    public LocationService(TrippieContext context)
    {
        _context = context;
    }

    public async Task<ServiceResult<bool>> UpdateLocation(Guid userId, Guid tripId, UpdateLocationRequestDto request)
    {
        var isMember = await _context.TripMembers
            .AnyAsync(tm => tm.TripId == tripId && tm.UserId == userId);

        if (!isMember)
            return ServiceResult<bool>.Fail(403, AppErrorEnum.Trip_Access_Denied.ToString());

        var existing = await _context.UserLastLocations
            .SingleOrDefaultAsync(x => x.UserId == userId && x.TripId == tripId);

        if (existing != null)
        {
            existing.Latitude = request.Latitude;
            existing.Longitude = request.Longitude;
            existing.UpdatedAt = DateTime.UtcNow;
        }
        else
        {
            _context.UserLastLocations.Add(new UserLastLocation
            {
                UserId = userId,
                TripId = tripId,
                Latitude = request.Latitude,
                Longitude = request.Longitude
            });
        }

        await _context.SaveChangesAsync();
        return ServiceResult<bool>.Ok(true);
    }
}