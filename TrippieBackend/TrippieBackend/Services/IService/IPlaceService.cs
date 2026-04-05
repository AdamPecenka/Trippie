using TrippieBackend.Models.DTOs;
using TrippieBackend.Models;

namespace TrippieBackend.Services.IService;

public interface IPlaceService
{
    public Task<ServiceResult<List<PlaceSuggestionDto>>> Autocomplete(string query, double? lat, double? lng);

    public Task<ServiceResult<PlaceDto>> Resolve(string googlePlaceId);
}