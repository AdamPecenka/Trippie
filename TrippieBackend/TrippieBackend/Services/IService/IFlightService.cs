using TrippieBackend.Models;
using TrippieBackend.Models.DTOs.Flights;

namespace TrippieBackend.Services.IService;

public interface IFlightService
{
    Task<ServiceResult<List<FlightDto>>> GetFlights(Guid userId, Guid tripId);
    Task<ServiceResult<FlightDto>> CreateFlight(Guid userId, Guid tripId, CreateFlightRequestDto request);
    Task<ServiceResult<bool>> PatchFlight(Guid userId, Guid tripId, Guid flightId, PatchFlightRequestDto request);
    Task<ServiceResult<bool>> DeleteFlight(Guid userId, Guid tripId, Guid flightId);
}