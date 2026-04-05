using TrippieBackend.Models;
using TrippieBackend.Models.DTOs.Invites;

namespace TrippieBackend.Services.IService;

public interface IInviteService
{
    public Task<ServiceResult<InviteResponseDto>> GetOrCreateInviteCode(Guid userId, Guid tripId);
    public Task<ServiceResult<JoinTripResponseDto>> JoinTrip(Guid userId, Guid tripId, string inviteCode);
}