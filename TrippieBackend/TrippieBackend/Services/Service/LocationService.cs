using Microsoft.AspNetCore.SignalR;
using Microsoft.EntityFrameworkCore;
using TrippieBackend.Hubs;
using TrippieBackend.Models;
using TrippieBackend.Models.DTOs.Location;
using TrippieBackend.Models.Enums;
using TrippieBackend.Models.Model;
using TrippieBackend.Services.IService;

namespace TrippieBackend.Services.Service;

public class LocationService : ILocationService
{
    private readonly TrippieContext _context;
    private readonly IHubContext<TripHub> _hubContext;

    public LocationService(TrippieContext context, IHubContext<TripHub> hubContext)
    {
        _context = context;
        _hubContext = hubContext;
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
                Longitude = request.Longitude,
                CreatedAt = DateTime.UtcNow,
                UpdatedAt = DateTime.UtcNow
            });
        }

        await _context.SaveChangesAsync();

        await _hubContext.Clients
            .Group($"trip:{tripId}")
            .SendAsync("location:member_offline", new
            {
                UserId = userId,
                TripId = tripId,
                Latitude = request.Latitude,
                Longitude = request.Longitude,
            });

        Console.WriteLine($"[i] location tombstone saved | user:{userId} trip:{tripId}");

        return ServiceResult<bool>.Ok(true);
    }

    public async Task<ServiceResult<List<MemberLocationDto>>> GetTripMemberLocations(Guid userId, Guid tripId)
    {
        var isMember = await _context.TripMembers
            .AnyAsync(tm => tm.TripId == tripId && tm.UserId == userId);

        if (!isMember)
        {
            return ServiceResult<List<MemberLocationDto>>.Fail(403, AppErrorEnum.Trip_Access_Denied.ToString());
        }

        var members = await _context.TripMembers
            .Where(tm => tm.TripId == tripId)
            .Include(tm => tm.User)
            .ToListAsync();

        var locations = await _context.UserLastLocations
            .Where(l => l.TripId == tripId)
            .ToListAsync();

        var result = members
            .Where(tm => tm.UserId != userId)  // exclude self
            .Select(tm =>
            {
                var loc = locations.SingleOrDefault(l => l.UserId == tm.UserId);
                return new MemberLocationDto
                {
                    UserId = tm.UserId,
                    Firstname = tm.User.Firstname,
                    Lastname = tm.User.Lastname,
                    Latitude = loc?.Latitude,
                    Longitude = loc?.Longitude,
                };
            }).ToList();

        return ServiceResult<List<MemberLocationDto>>.Ok(result);
    }
}