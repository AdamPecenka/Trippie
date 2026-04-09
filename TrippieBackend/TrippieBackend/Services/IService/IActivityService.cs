using TrippieBackend.Models;
using TrippieBackend.Models.DTOs.Activities;

namespace TrippieBackend.Services.IService;

public interface IActivityService
{
    Task<ServiceResult<List<ActivityDto>>> GetActivities(Guid userId, Guid tripId);
    Task<ServiceResult<ActivityDto>> CreateActivity(Guid userId, Guid tripId, CreateActivityRequestDto request);
    Task<ServiceResult<ActivityDto>> GetActivity(Guid userId, Guid tripId, Guid activityId);
    Task<ServiceResult<bool>> PatchActivity(Guid userId, Guid tripId, Guid activityId, PatchActivityRequestDto request);
    
    Task<ServiceResult<bool>> DeleteActivity(Guid userId, Guid tripId, Guid activityId);
}