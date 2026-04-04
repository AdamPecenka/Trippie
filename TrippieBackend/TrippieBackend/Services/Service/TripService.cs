using Microsoft.EntityFrameworkCore;
using TrippieBackend.Models;
using TrippieBackend.Models.DTOs;
using TrippieBackend.Models.DTOs.Accomodations;
using TrippieBackend.Models.DTOs.Flights;
using TrippieBackend.Models.DTOs.Trips;
using TrippieBackend.Models.Enums;
using TrippieBackend.Models.Model;
using TrippieBackend.Services.IService;

namespace TrippieBackend.Services.Service;

public class TripService : ITripService
{
    private readonly TrippieContext _context;

    public TripService(TrippieContext context)
    {
        _context = context;
    }
    
    public async Task<ServiceResult<List<TripsDto>>> GetTrips(Guid userId)
    {
        var user = await _context.Users.Where(x => x.Id == userId).SingleOrDefaultAsync();

        if (user == null)
        {
            // ak neexistuje v DB user pre validny token, nieco je zle na serveri
            throw new InvalidOperationException($"[!!!] Authenticated user {userId} not found in DB");
        }
        
        var trips = await _context.TripMembers
            .Where(tm => tm.UserId == userId)
            .Select(tm => new TripsDto
            {
                Id = tm.Trip.Id,
                Name = tm.Trip.Name,
                TripStatus = tm.Trip.TripStatus,
                StartDate = tm.Trip.StartDate,
                EndDate = tm.Trip.EndDate
            })
            .ToListAsync();

        return ServiceResult<List<TripsDto>>.Ok(trips);
    }

    public async Task<ServiceResult<CreateTripResponseDto>> CreateTrip(Guid userId, CreateTripRequestDto tripRequest)
    {
        var user = await _context.Users.Where(x => x.Id == userId).SingleOrDefaultAsync();

        if (user == null)
        {
            // ak neexistuje v DB user pre validny token, nieco je zle na serveri
            throw new InvalidOperationException($"[!!!] Authenticated user {userId} not found in DB");
        }
        
        var placeExists = await _context.Places.AnyAsync(p => p.Id == tripRequest.DestinationPlaceId);
        if (!placeExists)
        {
            return ServiceResult<CreateTripResponseDto>.Fail(404, AppErrorEnum.Destination_Place_Not_Found.ToString());
        }
        
        var trip = new Trip
        {
            Name = tripRequest.Name,
            DestinationPlaceId = tripRequest.DestinationPlaceId,
            TransportType = tripRequest.TransportType,
            TripStatus = TripStatusEnum.PLANNING,
            StartDate = tripRequest.StartDate,
            EndDate = tripRequest.EndDate,
            CreatedBy = userId,
            CreatedAt = DateTime.UtcNow,
            UpdatedAt = DateTime.UtcNow
        };

        await _context.Trips.AddAsync(trip);
        await _context.SaveChangesAsync();

        var tripMember = new TripMember
        {
            TripId = trip.Id,
            UserId = userId,
            TripRole = TripRoleEnum.TRIP_MANAGER,
            JoinedAt = DateTime.UtcNow,
            CreatedAt = DateTime.UtcNow,
            UpdatedAt = DateTime.UtcNow
        };

        await _context.TripMembers.AddAsync(tripMember);
        await _context.SaveChangesAsync();

        return ServiceResult<CreateTripResponseDto>.Ok(new CreateTripResponseDto
        {
            TripId = trip.Id
        });
    }
    
    public async Task<ServiceResult<TripDetailDto>> GetTripById(Guid userId, Guid tripId)
    {
        
        var trip = await _context.Trips
            .Where(t => t.Id == tripId)
            .SingleOrDefaultAsync();

        if (trip == null)
        {
            return ServiceResult<TripDetailDto>.Fail(404, AppErrorEnum.Trip_Not_Found.ToString());
        }

        var isMember = await _context.TripMembers
            .AnyAsync(tm => tm.TripId == tripId && tm.UserId == userId);

        if (!isMember)
        {
            return ServiceResult<TripDetailDto>.Fail(403, AppErrorEnum.Forbidden.ToString());
        }

        var accommodation = await _context.Accommodations
            .Where(a => a.TripId == tripId)
            .Include(a => a.Place)
            .FirstOrDefaultAsync();

        var flights = await _context.Flights
            .Where(f => f.TripId == tripId)
            .Include(f => f.DepartureAirport)
            .Include(f => f.ArrivalAirport)
            .ToListAsync();

        var tripDetail = new TripDetailDto
        {
            Id = trip.Id,
            Name = trip.Name,
            TripStatus = trip.TripStatus,
            StartDate = trip.StartDate,
            EndDate = trip.EndDate,
            Accommodation = accommodation == null ? null : new AccommodationDto
            {
                Id = accommodation.Id,
                PlaceName = accommodation.Place.Name,
                Address = accommodation.Place.Address,
                CheckIn = accommodation.CheckIn,
                CheckOut = accommodation.CheckOut
            },
            Flights = flights.Select(f => new FlightDto
            {
                Id = f.Id,
                TravelDirection = f.TravelDirection,
                FlightNumber = f.FlightNumber,
                DepartureIataCode = f.DepartureAirport.IataCode,
                DepartureCityName = f.DepartureAirport.City,
                ArrivalIataCode = f.ArrivalAirport.IataCode,
                ArrivalCityName = f.ArrivalAirport.City,
                DepartureTime = f.DepartureTime,
                ArrivalTime = f.ArrivalTime
            }).ToList()
        };

        return ServiceResult<TripDetailDto>.Ok(tripDetail);
    }
    
    public async Task<ServiceResult<bool>> PatchTrip(Guid userId, Guid tripId, PatchTripRequestDto request)
    {
        var trip = await _context.Trips
            .Include(t => t.Members)
            .SingleOrDefaultAsync(t => t.Id == tripId);

        if (trip == null)
        {
            return ServiceResult<bool>.Fail(404, AppErrorEnum.Trip_Not_Found.ToString());
        }

        var member = trip.Members.SingleOrDefault(m => m.UserId == userId);

        if (member == null)
        {
            return ServiceResult<bool>.Fail(403, AppErrorEnum.Trip_Access_Denied.ToString());
        }

        if (member.TripRole != TripRoleEnum.TRIP_MANAGER)
        {
            return ServiceResult<bool>.Fail(403, AppErrorEnum.Trip_Manager_Required.ToString());
        }

        if (request.DestinationPlaceId.HasValue)
        {
            var placeExists = await _context.Places.AnyAsync(p => p.Id == request.DestinationPlaceId);
            if (!placeExists)
            {
                return ServiceResult<bool>.Fail(404, AppErrorEnum.Place_Not_Found.ToString());
            }
        }

        trip.Name = request.Name ?? trip.Name;
        trip.DestinationPlaceId = request.DestinationPlaceId ?? trip.DestinationPlaceId;
        trip.TransportType = request.TransportType ?? trip.TransportType;
        trip.StartDate = request.StartDate ?? trip.StartDate;
        trip.EndDate = request.EndDate ?? trip.EndDate;
        trip.UpdatedAt = DateTime.UtcNow;

        await _context.SaveChangesAsync();

        return ServiceResult<bool>.Ok(true);
    }
    
    public async Task<ServiceResult<bool>> PatchTripStatus(Guid userId, Guid tripId, TripStatusEnum newStatus)
    {
        var trip = await _context.Trips
            .Include(t => t.Members)
            .SingleOrDefaultAsync(t => t.Id == tripId);

        if (trip == null)
        {
            return ServiceResult<bool>.Fail(404, AppErrorEnum.Trip_Not_Found.ToString());
        }

        var member = trip.Members.SingleOrDefault(m => m.UserId == userId);

        if (member == null)
        {
            return ServiceResult<bool>.Fail(403, AppErrorEnum.Trip_Access_Denied.ToString());
        }

        if (member.TripRole != TripRoleEnum.TRIP_MANAGER)
        {
            return ServiceResult<bool>.Fail(403, AppErrorEnum.Trip_Manager_Required.ToString());
        }

        // enforce valid transitions: PLANNING -> ACTIVE -> FINISHED
        bool validTransition = (trip.TripStatus, newStatus) switch
        {
            (TripStatusEnum.PLANNING, TripStatusEnum.ACTIVE) => true,
            (TripStatusEnum.ACTIVE, TripStatusEnum.FINISHED) => true,
            _ => false
        };

        if (!validTransition)
        {
            return ServiceResult<bool>.Fail(409, AppErrorEnum.Trip_Invalid_Status_Transition.ToString());
        }

        trip.TripStatus = newStatus;
        trip.UpdatedAt = DateTime.UtcNow;
        await _context.SaveChangesAsync();

        // TODO: SignalR -> broadcast trip:status_changed to trip room

        return ServiceResult<bool>.Ok(true);
    }
}