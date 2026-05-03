using System.Security.Cryptography;
using Microsoft.AspNetCore.SignalR;
using Microsoft.EntityFrameworkCore;
using TrippieBackend.Hubs;
using TrippieBackend.Models;
using TrippieBackend.Models.DTOs.Invites;
using TrippieBackend.Models.Enums;
using TrippieBackend.Models.Model;
using TrippieBackend.Services.IService;

namespace TrippieBackend.Services.Service;

public class InviteService : IInviteService
{
    private readonly TrippieContext _context;
    private readonly IHubContext<TripHub> _hubContext;
    private readonly FcmService _fcmService;

    public InviteService(TrippieContext context, IHubContext<TripHub> hubContext, FcmService fcmService)
    {
        _context = context;
        _hubContext = hubContext;
        _fcmService = fcmService;
    }

    public async Task<ServiceResult<InviteResponseDto>> GetOrCreateInviteCode(Guid userId, Guid tripId)
    {
        var trip = await _context.Trips.SingleOrDefaultAsync(t => t.Id == tripId);

        if (trip == null)
        {
            return ServiceResult<InviteResponseDto>.Fail(404, AppErrorEnum.Trip_Not_Found.ToString());
        }

        var isMember = await _context.TripMembers
            .AnyAsync(tm => tm.TripId == tripId && tm.UserId == userId);

        if (!isMember)
        {
            return ServiceResult<InviteResponseDto>.Fail(403, AppErrorEnum.Trip_Access_Denied.ToString());
        }

        if (trip.TripStatus == TripStatusEnum.FINISHED)
        {
            return ServiceResult<InviteResponseDto>.Fail(409, AppErrorEnum.Trip_Already_Finished.ToString());
        }

        var existingInvite = await _context.TripInvites
            .SingleOrDefaultAsync(i => i.TripId == tripId);

        if (existingInvite != null)
        {
            return ServiceResult<InviteResponseDto>.Ok(new InviteResponseDto
            {
                InviteCode = existingInvite.InviteCode!
            });
        }

        var code = RandomNumberGenerator.GetInt32(100000, 999999);

        var invite = new TripInvite
        {
            TripId = tripId,
            InviteCode = code,
            CreatedBy = userId
        };

        await _context.TripInvites.AddAsync(invite);
        await _context.SaveChangesAsync();

        return ServiceResult<InviteResponseDto>.Ok(new InviteResponseDto
        {
            InviteCode = code
        });
    }

    public async Task<ServiceResult<JoinTripResponseDto>> JoinTrip(Guid userId, Guid tripId, int inviteCode)
    {
        var trip = await _context.Trips.SingleOrDefaultAsync(t => t.Id == tripId);

        if (trip == null)
        {
            return ServiceResult<JoinTripResponseDto>.Fail(404, AppErrorEnum.Trip_Not_Found.ToString());
        }

        if (trip.TripStatus == TripStatusEnum.FINISHED)
        {
            return ServiceResult<JoinTripResponseDto>.Fail(409, AppErrorEnum.Trip_Already_Finished.ToString());
        }

        var invite = await _context.TripInvites
            .SingleOrDefaultAsync(i => i.TripId == tripId && i.InviteCode == inviteCode);

        if (invite == null)
        {
            return ServiceResult<JoinTripResponseDto>.Fail(404, AppErrorEnum.Invite_Invalid_Code.ToString());
        }

        var alreadyMember = await _context.TripMembers
            .AnyAsync(tm => tm.TripId == tripId && tm.UserId == userId);

        if (alreadyMember)
        {
            return ServiceResult<JoinTripResponseDto>.Fail(409, AppErrorEnum.Trip_Already_Member.ToString());
        }

        var member = new TripMember
        {
            TripId = tripId,
            UserId = userId,
            TripRole = TripRoleEnum.TRIP_MEMBER,
            JoinedAt = DateTime.UtcNow,
            CreatedAt = DateTime.UtcNow,
            UpdatedAt = DateTime.UtcNow
        };

        await _context.TripMembers.AddAsync(member);
        await _context.SaveChangesAsync();

        var newMember = await _context.Users.SingleAsync(u => u.Id == userId);

        await _hubContext.Clients
            .Group($"trip:{tripId}")
            .SendAsync("trip:member_joined", new MemberJoinedTripEventDto
            {
                UserId = userId,
                Firstname = newMember.Firstname,
                Lastname = newMember.Lastname,
                Email = newMember.Email,
                PhoneNumber = newMember.PhoneNumber,
                TripRole = TripRoleEnum.TRIP_MEMBER.ToString(),
            });

        await _fcmService.SendMemberJoinedAsync(
            tripId,
            userId,
            $"{newMember.Firstname} {newMember.Lastname}",
            trip.Name
        );

        Console.WriteLine($"[+] member joined by code | user:{userId} trip:{tripId}");

        return ServiceResult<JoinTripResponseDto>.Ok(new JoinTripResponseDto
        {
            TripId = trip.Id,
            TripName = trip.Name
        });
    }

    public async Task<ServiceResult<JoinTripResponseDto>> JoinTripByCode(Guid userId, int inviteCode)
    {
        var invite = await _context.TripInvites
            .Include(i => i.Trip)
            .SingleOrDefaultAsync(i => i.InviteCode == inviteCode);

        if (invite == null)
        {
            return ServiceResult<JoinTripResponseDto>.Fail(404, AppErrorEnum.Invite_Invalid_Code.ToString());
        }

        var trip = invite.Trip;

        if (trip.TripStatus == TripStatusEnum.FINISHED)
        {
            return ServiceResult<JoinTripResponseDto>.Fail(409, AppErrorEnum.Trip_Already_Finished.ToString());
        }

        var alreadyMember = await _context.TripMembers
            .AnyAsync(tm => tm.TripId == trip.Id && tm.UserId == userId);

        if (alreadyMember)
        {
            return ServiceResult<JoinTripResponseDto>.Fail(409, AppErrorEnum.Trip_Already_Member.ToString());
        }

        var member = new TripMember
        {
            TripId = trip.Id,
            UserId = userId,
            TripRole = TripRoleEnum.TRIP_MEMBER,
            JoinedAt = DateTime.UtcNow,
            CreatedAt = DateTime.UtcNow,
            UpdatedAt = DateTime.UtcNow
        };

        await _context.TripMembers.AddAsync(member);
        await _context.SaveChangesAsync();

        var newMember = await _context.Users.SingleAsync(u => u.Id == userId);

        await _hubContext.Clients
            .Group($"trip:{trip.Id}")
            .SendAsync("trip:member_joined", new MemberJoinedTripEventDto
            {
                UserId = userId,
                Firstname = newMember.Firstname,
                Lastname = newMember.Lastname,
                Email = newMember.Email,
                PhoneNumber = newMember.PhoneNumber,
                TripRole = TripRoleEnum.TRIP_MEMBER.ToString(),
            });

        await _fcmService.SendMemberJoinedAsync(
            trip.Id,
            userId,
            $"{newMember.Firstname} {newMember.Lastname}",
            trip.Name
        );

        Console.WriteLine($"[+] member joined by code | user:{userId} trip:{trip.Id}");

        return ServiceResult<JoinTripResponseDto>.Ok(new JoinTripResponseDto
        {
            TripId = trip.Id,
            TripName = trip.Name
        });
    }
}