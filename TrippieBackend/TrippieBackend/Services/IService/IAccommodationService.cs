using TrippieBackend.Models;
using TrippieBackend.Models.DTOs.Accomodations;

namespace TrippieBackend.Services.IService;

public interface IAccommodationService
{
    Task<ServiceResult<AccommodationDto>> GetAccommodation(Guid userId, Guid tripId);
    Task<ServiceResult<bool>> PatchAccommodation(Guid userId, Guid tripId, Guid accommodationId, PatchAccommodationRequestDto request);
    Task<ServiceResult<AccommodationDto>> CreateAccommodation(Guid userId, Guid tripId, CreateAccommodationRequestDto request);
}