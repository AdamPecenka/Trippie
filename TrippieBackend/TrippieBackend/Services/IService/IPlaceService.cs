using TrippieBackend.Models.DTOs;

namespace TrippieBackend.Services.IService;

public interface IPlaceService
{
    public Task<ServiceResult<List<PlaceSuggestionDto>>> Autocomplete(string query, double? lat, double? lng);

    public Task<ServiceResult<PlaceDto>> Resolve(string googlePlaceId);
}