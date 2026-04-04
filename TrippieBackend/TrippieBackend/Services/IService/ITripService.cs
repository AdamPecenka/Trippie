using TrippieBackend.Models.DTOs;
using TrippieBackend.Models.DTOs.Trips;
using TrippieBackend.Models.Enums;

namespace TrippieBackend.Services.IService;

public interface ITripService
{
    public Task<ServiceResult<List<TripsDto>>> GetTrips(Guid userId);
    public Task<ServiceResult<CreateTripResponseDto>> CreateTrip(Guid userId, CreateTripRequestDto tripRequest);
    public Task<ServiceResult<TripDetailDto>> GetTripById(Guid userId, Guid tripId);
    public Task<ServiceResult<bool>> PatchTrip(Guid userId, Guid tripId, PatchTripRequestDto request);
    public Task<ServiceResult<bool>> PatchTripStatus(Guid userId, Guid tripId, TripStatusEnum newStatus);
}