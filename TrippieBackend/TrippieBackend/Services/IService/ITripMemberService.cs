using TrippieBackend.Models;
using TrippieBackend.Models.DTOs.Members;

namespace TrippieBackend.Services.IService;

public interface ITripMemberService
{
    public Task<ServiceResult<List<TripMemberDto>>> GetTripMembers(Guid userId, Guid tripId);
    public Task<ServiceResult<bool>> LeaveTrip(Guid userId, Guid tripId);
}