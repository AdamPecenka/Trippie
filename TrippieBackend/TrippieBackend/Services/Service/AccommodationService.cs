using Microsoft.EntityFrameworkCore;
using TrippieBackend.Models;
using TrippieBackend.Models.DTOs;
using TrippieBackend.Models.DTOs.Accomodations;
using TrippieBackend.Models.Enums;
using TrippieBackend.Models.Model;
using TrippieBackend.Services.IService;

namespace TrippieBackend.Services.Service;

public class AccommodationService : IAccommodationService
{
    private readonly TrippieContext _context;

    public AccommodationService(TrippieContext context)
    {
        _context = context;
    }

    public async Task<ServiceResult<AccommodationDto>> GetAccommodation(Guid userId, Guid tripId)
    {
        var isMember = await _context.TripMembers
            .AnyAsync(tm => tm.TripId == tripId && tm.UserId == userId);

        if (!isMember)
        {
            return ServiceResult<AccommodationDto>.Fail(403, AppErrorEnum.Trip_Access_Denied.ToString());
        }

        var accommodation = await _context.Accommodations
            .Where(a => a.TripId == tripId)
            .Include(a => a.Place)
            .FirstOrDefaultAsync();

        if (accommodation == null)
        {
            return ServiceResult<AccommodationDto>.Fail(404, AppErrorEnum.Accommodation_Not_Found.ToString());
        }

        return ServiceResult<AccommodationDto>.Ok(new AccommodationDto
        {
            Id = accommodation.Id,
            PlaceName = accommodation.Place!.Name,
            Address = accommodation.Place.Address,
            CheckIn = accommodation.CheckIn,
            CheckOut = accommodation.CheckOut
        });
    }

    public async Task<ServiceResult<bool>> PatchAccommodation(Guid userId, Guid tripId, Guid accommodationId, PatchAccommodationRequestDto request)
    {
        var member = await _context.TripMembers
            .SingleOrDefaultAsync(tm => tm.TripId == tripId && tm.UserId == userId);

        if (member == null)
        {
            return ServiceResult<bool>.Fail(403, AppErrorEnum.Trip_Access_Denied.ToString());
        }

        if (member.TripRole != TripRoleEnum.TRIP_MANAGER)
        {
            return ServiceResult<bool>.Fail(403, AppErrorEnum.Trip_Manager_Required.ToString());
        }

        var accommodation = await _context.Accommodations
            .SingleOrDefaultAsync(a => a.Id == accommodationId && a.TripId == tripId);

        if (accommodation == null)
        {
            return ServiceResult<bool>.Fail(404, AppErrorEnum.Accommodation_Not_Found.ToString());
        }

        if (request.PlaceId.HasValue)
        {
            var placeExists = await _context.Places.AnyAsync(p => p.Id == request.PlaceId);
            if (!placeExists)
            {
                return ServiceResult<bool>.Fail(404, AppErrorEnum.Place_Not_Found.ToString());
            }
            accommodation.PlaceId = request.PlaceId;
        }

        accommodation.CheckIn = request.CheckIn ?? accommodation.CheckIn;
        accommodation.CheckOut = request.CheckOut ?? accommodation.CheckOut;
        accommodation.UpdatedAt = DateTime.UtcNow;

        await _context.SaveChangesAsync();

        // TODO: SignalR -> broadcast accommodation update to trip room

        return ServiceResult<bool>.Ok(true);
    }
    
    public async Task<ServiceResult<AccommodationDto>> CreateAccommodation(Guid userId, Guid tripId, CreateAccommodationRequestDto request)
    {
        var member = await _context.TripMembers
            .SingleOrDefaultAsync(tm => tm.TripId == tripId && tm.UserId == userId);

        if (member == null)
        {
            return ServiceResult<AccommodationDto>.Fail(403, AppErrorEnum.Trip_Access_Denied.ToString());
        }

        if (member.TripRole != TripRoleEnum.TRIP_MANAGER)
        {
            return ServiceResult<AccommodationDto>.Fail(403, AppErrorEnum.Trip_Manager_Required.ToString());
        }

        var alreadyExists = await _context.Accommodations
            .AnyAsync(a => a.TripId == tripId);

        if (alreadyExists)
        {
            return ServiceResult<AccommodationDto>.Fail(409, AppErrorEnum.Accommodation_Already_Exists.ToString());
        }

        var placeExists = await _context.Places.AnyAsync(p => p.Id == request.PlaceId);
        if (!placeExists)
        {
            return ServiceResult<AccommodationDto>.Fail(404, AppErrorEnum.Place_Not_Found.ToString());
        }

        var accommodation = new Accommodation
        {
            TripId = tripId,
            PlaceId = request.PlaceId,
            CheckIn = request.CheckIn,
            CheckOut = request.CheckOut,
            CreatedAt = DateTime.UtcNow,
            UpdatedAt = DateTime.UtcNow
        };

        await _context.Accommodations.AddAsync(accommodation);
        await _context.SaveChangesAsync();

        var place = await _context.Places.SingleAsync(p => p.Id == request.PlaceId);

        return ServiceResult<AccommodationDto>.Ok(new AccommodationDto
        {
            Id = accommodation.Id,
            PlaceName = place.Name,
            Address = place.Address,
            CheckIn = accommodation.CheckIn,
            CheckOut = accommodation.CheckOut
        });
    }
    
    public async Task<ServiceResult<bool>> DeleteAccommodation(Guid userId, Guid tripId, Guid accommodationId)
    {
        var member = await _context.TripMembers
            .SingleOrDefaultAsync(tm => tm.TripId == tripId && tm.UserId == userId);

        if (member == null)
            return ServiceResult<bool>.Fail(403, AppErrorEnum.Trip_Access_Denied.ToString());

        if (member.TripRole != TripRoleEnum.TRIP_MANAGER)
            return ServiceResult<bool>.Fail(403, AppErrorEnum.Trip_Manager_Required.ToString());

        var accommodation = await _context.Accommodations
            .SingleOrDefaultAsync(a => a.Id == accommodationId && a.TripId == tripId);

        if (accommodation == null)
            return ServiceResult<bool>.Fail(404, AppErrorEnum.Accommodation_Not_Found.ToString());

        _context.Accommodations.Remove(accommodation);
        await _context.SaveChangesAsync();

        return ServiceResult<bool>.Ok(true);
    }
}