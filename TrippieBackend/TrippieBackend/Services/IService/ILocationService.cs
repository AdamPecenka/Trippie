using TrippieBackend.Models;
using TrippieBackend.Models.DTOs.Location;

namespace TrippieBackend.Services.IService;

public interface ILocationService
{
    Task<ServiceResult<bool>> UpdateLocation(Guid userId, Guid tripId, UpdateLocationRequestDto request);
    Task<ServiceResult<List<MemberLocationDto>>> GetTripMemberLocations(Guid userId, Guid tripId);
}