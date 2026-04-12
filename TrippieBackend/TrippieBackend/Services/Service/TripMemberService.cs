using Microsoft.AspNetCore.SignalR;
using Microsoft.EntityFrameworkCore;
using TrippieBackend.Hubs;
using TrippieBackend.Models;
using TrippieBackend.Models.DTOs;
using TrippieBackend.Models.DTOs.Members;
using TrippieBackend.Models.Enums;
using TrippieBackend.Services.IService;

namespace TrippieBackend.Services.Service;

public class TripMemberService: ITripMemberService
{
    private readonly TrippieContext _context;
    private readonly IHubContext<TripHub> _hubContext;

    public TripMemberService(TrippieContext context,  IHubContext<TripHub> hubContext)
    {
        _context = context;
        _hubContext = hubContext;
    }
    
    public async Task<ServiceResult<List<TripMemberDto>>> GetTripMembers(Guid userId, Guid tripId)
    {
        var tripExists = await _context.Trips.AnyAsync(t => t.Id == tripId);
        if (!tripExists)
        {
            return ServiceResult<List<TripMemberDto>>.Fail(404, AppErrorEnum.Trip_Not_Found.ToString());
        }

        var isMember = await _context.TripMembers
            .AnyAsync(tm => tm.TripId == tripId && tm.UserId == userId);

        if (!isMember)
        {
            return ServiceResult<List<TripMemberDto>>.Fail(403, AppErrorEnum.Trip_Access_Denied.ToString());
        }

        var members = await _context.TripMembers
            .Where(tm => tm.TripId == tripId)
            .Include(tm => tm.User)
            .Select(tm => new TripMemberDto
            {
                UserId = tm.UserId,
                Firstname = tm.User.Firstname,
                Lastname = tm.User.Lastname,
                Email = tm.User.Email,
                TripRole = tm.TripRole,
                JoinedAt = tm.JoinedAt
            })
            .ToListAsync();

        return ServiceResult<List<TripMemberDto>>.Ok(members);
    }

    public async Task<ServiceResult<bool>> LeaveTrip(Guid userId, Guid tripId)
    {
        var tripExists = await _context.Trips.AnyAsync(t => t.Id == tripId);
        if (!tripExists)
        {
            return ServiceResult<bool>.Fail(404, AppErrorEnum.Trip_Not_Found.ToString());
        }

        var member = await _context.TripMembers
            .SingleOrDefaultAsync(tm => tm.TripId == tripId && tm.UserId == userId);

        if (member == null)
        {
            return ServiceResult<bool>.Fail(403, AppErrorEnum.Trip_Access_Denied.ToString());
        }

        if (member.TripRole == TripRoleEnum.TRIP_MANAGER)
        {
            return ServiceResult<bool>.Fail(409, AppErrorEnum.Trip_Manager_Cannot_Leave.ToString());
        }

        _context.TripMembers.Remove(member);
        await _context.SaveChangesAsync();

        await _hubContext.Clients
            .Group($"trip:{tripId}")
            .SendAsync("trip:member_left", new MemberLeftTripEventDto
            {
                UserId = userId,
            });

        Console.WriteLine($"[-] member left | user:{userId} trip:{tripId}");
        
        return ServiceResult<bool>.Ok(true);
    }
}