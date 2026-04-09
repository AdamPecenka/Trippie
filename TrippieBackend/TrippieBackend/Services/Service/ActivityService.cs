using Microsoft.EntityFrameworkCore;
using TrippieBackend.Models;
using TrippieBackend.Models.DTOs;
using TrippieBackend.Models.DTOs.Activities;
using TrippieBackend.Models.Enums;
using TrippieBackend.Services.IService;
using TrippieBackend.Models.Model;

namespace TrippieBackend.Services.Service;

public class ActivityService : IActivityService
{
    private readonly TrippieContext _context;

    public ActivityService(TrippieContext context)
    {
        _context = context;
    }

    public async Task<ServiceResult<List<ActivityDto>>> GetActivities(Guid userId, Guid tripId)
    {
        var isMember = await _context.TripMembers
            .AnyAsync(tm => tm.TripId == tripId && tm.UserId == userId);

        if (!isMember)
            return ServiceResult<List<ActivityDto>>.Fail(403, AppErrorEnum.Trip_Access_Denied.ToString());

        var activities = await _context.Activities
            .Where(a => a.TripId == tripId)
            .Include(a => a.Place)
            .OrderBy(a => a.ActivityDate)
            .ThenBy(a => a.StartTime)
            .Select(a => MapToDto(a))
            .ToListAsync();

        return ServiceResult<List<ActivityDto>>.Ok(activities);
    }
    
    public async Task<ServiceResult<ActivityDto>> CreateActivity(Guid userId, Guid tripId, CreateActivityRequestDto request)
    {
        var isMember = await _context.TripMembers
            .AnyAsync(tm => tm.TripId == tripId && tm.UserId == userId);

        if (!isMember)
            return ServiceResult<ActivityDto>.Fail(403, AppErrorEnum.Trip_Access_Denied.ToString());

        var activity = new TrippieBackend.Models.Model.Activity
        {
            TripId = tripId,
            Name = request.Name,
            PlaceId = request.PlaceId,
            ActivityDate = request.ActivityDate,
            StartTime = request.StartTime,
            EndTime = request.EndTime,
            Notes = request.Notes,
            CreatedBy = userId
        };

        _context.Activities.Add(activity);
        await _context.SaveChangesAsync();

        // načítaj Place ak existuje
        if (activity.PlaceId != null)
            await _context.Entry(activity).Reference(a => a.Place).LoadAsync();

        return ServiceResult<ActivityDto>.Ok(MapToDto(activity));
    }
    
    public async Task<ServiceResult<ActivityDto>> GetActivity(Guid userId, Guid tripId, Guid activityId)
    {
        var isMember = await _context.TripMembers
            .AnyAsync(tm => tm.TripId == tripId && tm.UserId == userId);

        if (!isMember)
            return ServiceResult<ActivityDto>.Fail(403, AppErrorEnum.Trip_Access_Denied.ToString());

        var activity = await _context.Activities
            .Include(a => a.Place)
            .SingleOrDefaultAsync(a => a.Id == activityId && a.TripId == tripId);

        if (activity == null)
            return ServiceResult<ActivityDto>.Fail(404, AppErrorEnum.Activity_Not_Found.ToString());

        return ServiceResult<ActivityDto>.Ok(MapToDto(activity));
    }
    
    public async Task<ServiceResult<bool>> PatchActivity(Guid userId, Guid tripId, Guid activityId, PatchActivityRequestDto request)
    {
        var isMember = await _context.TripMembers
            .AnyAsync(tm => tm.TripId == tripId && tm.UserId == userId);

        if (!isMember)
            return ServiceResult<bool>.Fail(403, AppErrorEnum.Trip_Access_Denied.ToString());

        var activity = await _context.Activities
            .SingleOrDefaultAsync(a => a.Id == activityId && a.TripId == tripId);

        if (activity == null)
            return ServiceResult<bool>.Fail(404, AppErrorEnum.Activity_Not_Found.ToString());

        if (request.Name != null) activity.Name = request.Name;
        if (request.PlaceId != null) activity.PlaceId = request.PlaceId;
        if (request.ActivityDate != null) activity.ActivityDate = request.ActivityDate;
        if (request.StartTime != null) activity.StartTime = request.StartTime;
        if (request.EndTime != null) activity.EndTime = request.EndTime;
        if (request.Notes != null) activity.Notes = request.Notes;

        activity.UpdatedAt = DateTime.UtcNow;

        await _context.SaveChangesAsync();

        return ServiceResult<bool>.Ok(true);
    }
    
    public async Task<ServiceResult<bool>> DeleteActivity(Guid userId, Guid tripId, Guid activityId)
    {
        var isMember = await _context.TripMembers
            .AnyAsync(tm => tm.TripId == tripId && tm.UserId == userId);

        if (!isMember)
            return ServiceResult<bool>.Fail(403, AppErrorEnum.Trip_Access_Denied.ToString());

        var activity = await _context.Activities
            .SingleOrDefaultAsync(a => a.Id == activityId && a.TripId == tripId);

        if (activity == null)
            return ServiceResult<bool>.Fail(404, AppErrorEnum.Activity_Not_Found.ToString());

        _context.Activities.Remove(activity);
        await _context.SaveChangesAsync();

        return ServiceResult<bool>.Ok(true);
    }

    private static ActivityDto MapToDto(Activity a) => new()
    {
        Id = a.Id,
        Name = a.Name,
        ActivityDate = a.ActivityDate,
        StartTime = a.StartTime,
        EndTime = a.EndTime,
        Notes = a.Notes,
        CreatedBy = a.CreatedBy,
        Place = a.Place == null ? null : new PlaceDto
        {
            Id = a.Place.Id,
            Name = a.Place.Name,
            Address = a.Place.Address,
            City = a.Place.City,
            Country = a.Place.Country,
            Latitude = a.Place.Latitude,
            Longitude = a.Place.Longitude,
            GooglePlaceId = a.Place.GooglePlaceId
        }
    };
}