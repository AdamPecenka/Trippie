using Microsoft.EntityFrameworkCore;
using TrippieBackend.Models;
using TrippieBackend.Models.DTOs.Flights;
using TrippieBackend.Models.Enums;
using TrippieBackend.Models.Model;
using TrippieBackend.Services.IService;

namespace TrippieBackend.Services.Service;

public class FlightService : IFlightService
{
    private readonly TrippieContext _context;

    public FlightService(TrippieContext context)
    {
        _context = context;
    }

    public async Task<ServiceResult<List<FlightDto>>> GetFlights(Guid userId, Guid tripId)
    {
        var isMember = await _context.TripMembers
            .AnyAsync(tm => tm.TripId == tripId && tm.UserId == userId);

        if (!isMember)
            return ServiceResult<List<FlightDto>>.Fail(403, AppErrorEnum.Trip_Access_Denied.ToString());

        var flights = await _context.Flights
            .Where(f => f.TripId == tripId)
            .Include(f => f.DepartureAirport)
            .Include(f => f.ArrivalAirport)
            .OrderBy(f => f.DepartureTime)
            .ToListAsync();

        return ServiceResult<List<FlightDto>>.Ok(flights.Select(MapToDto).ToList());
    }
    
    public async Task<ServiceResult<FlightDto>> CreateFlight(Guid userId, Guid tripId, CreateFlightRequestDto request)
    {
        var isMember = await _context.TripMembers
            .AnyAsync(tm => tm.TripId == tripId && tm.UserId == userId);

        if (!isMember)
            return ServiceResult<FlightDto>.Fail(403, AppErrorEnum.Trip_Access_Denied.ToString());

        var departureAirport = await _context.Airports
            .SingleOrDefaultAsync(a => a.Id == request.DepartureAirportId);

        if (departureAirport == null)
            return ServiceResult<FlightDto>.Fail(404, AppErrorEnum.Airport_Not_Found.ToString());

        var arrivalAirport = await _context.Airports
            .SingleOrDefaultAsync(a => a.Id == request.ArrivalAirportId);

        if (arrivalAirport == null)
            return ServiceResult<FlightDto>.Fail(404, AppErrorEnum.Airport_Not_Found.ToString());

        var flight = new Flight
        {
            TripId = tripId,
            TravelDirection = request.TravelDirection,
            FlightNumber = request.FlightNumber,
            DepartureAirportId = request.DepartureAirportId,
            ArrivalAirportId = request.ArrivalAirportId,
            DepartureTime = request.DepartureTime,
            ArrivalTime = request.ArrivalTime,
            DepartureAirport = departureAirport,
            ArrivalAirport = arrivalAirport
        };

        _context.Flights.Add(flight);
        await _context.SaveChangesAsync();

        return ServiceResult<FlightDto>.Ok(MapToDto(flight));
    }
    
    public async Task<ServiceResult<bool>> PatchFlight(Guid userId, Guid tripId, Guid flightId, PatchFlightRequestDto request)
    {
        var isMember = await _context.TripMembers
            .AnyAsync(tm => tm.TripId == tripId && tm.UserId == userId);

        if (!isMember)
            return ServiceResult<bool>.Fail(403, AppErrorEnum.Trip_Access_Denied.ToString());

        var flight = await _context.Flights
            .SingleOrDefaultAsync(f => f.Id == flightId && f.TripId == tripId);

        if (flight == null)
            return ServiceResult<bool>.Fail(404, AppErrorEnum.Flight_Not_Found.ToString());

        if (request.TravelDirection.HasValue) flight.TravelDirection = request.TravelDirection.Value;
        if (request.FlightNumber != null) flight.FlightNumber = request.FlightNumber;
        if (request.DepartureTime.HasValue) 
            flight.DepartureTime = DateTime.SpecifyKind(request.DepartureTime.Value, DateTimeKind.Utc);
        if (request.ArrivalTime.HasValue) 
            flight.ArrivalTime = DateTime.SpecifyKind(request.ArrivalTime.Value, DateTimeKind.Utc);

        if (request.DepartureAirportId.HasValue)
        {
            var airport = await _context.Airports
                .SingleOrDefaultAsync(a => a.Id == request.DepartureAirportId.Value);
            if (airport == null)
                return ServiceResult<bool>.Fail(404, AppErrorEnum.Airport_Not_Found.ToString());
            flight.DepartureAirportId = request.DepartureAirportId.Value;
        }

        if (request.ArrivalAirportId.HasValue)
        {
            var airport = await _context.Airports
                .SingleOrDefaultAsync(a => a.Id == request.ArrivalAirportId.Value);
            if (airport == null)
                return ServiceResult<bool>.Fail(404, AppErrorEnum.Airport_Not_Found.ToString());
            flight.ArrivalAirportId = request.ArrivalAirportId.Value;
        }

        flight.UpdatedAt = DateTime.UtcNow;
        await _context.SaveChangesAsync();

        return ServiceResult<bool>.Ok(true);
    }
    
    public async Task<ServiceResult<bool>> DeleteFlight(Guid userId, Guid tripId, Guid flightId)
    {
        var isMember = await _context.TripMembers
            .AnyAsync(tm => tm.TripId == tripId && tm.UserId == userId);

        if (!isMember)
            return ServiceResult<bool>.Fail(403, AppErrorEnum.Trip_Access_Denied.ToString());

        var flight = await _context.Flights
            .SingleOrDefaultAsync(f => f.Id == flightId && f.TripId == tripId);

        if (flight == null)
            return ServiceResult<bool>.Fail(404, AppErrorEnum.Flight_Not_Found.ToString());

        _context.Flights.Remove(flight);
        await _context.SaveChangesAsync();

        return ServiceResult<bool>.Ok(true);
    }

    private static FlightDto MapToDto(Flight f) => new()
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
    };
}