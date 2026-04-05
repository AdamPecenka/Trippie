using TrippieBackend.Models;
using TrippieBackend.Models.DTOs;

namespace TrippieBackend.Services.IService;

public interface IAirportService
{
    public Task<ServiceResult<List<AirportDto>>> Search(string search, int limit);
}