using Microsoft.EntityFrameworkCore;
using TrippieBackend.Models.Enums;
using TrippieBackend.Models.Model;

namespace TrippieBackend.Seeds;

public static class TripMemberSeeder
{
    public static async Task SeedAsync(DbContext db, CancellationToken ct = default)
    {
        if (await db.Set<TripMember>().AnyAsync(ct))
        {
            Console.WriteLine("[i] Member seeded, skipping");
            return;
        }
        
        Guid seededUserId = await db.Set<User>()
            .Where(x => x.Firstname == "Johannka")
                .Select(x => x.Id)
                .FirstOrDefaultAsync(ct);
        
        Guid seededTripId = await db.Set<Trip>()
            .Where(x => x.Name == "Barcelona trip")
                .Select(x => x.Id)
                .FirstOrDefaultAsync(ct);

        db.Set<TripMember>().AddAsync(
            new TripMember 
            {
                TripId = seededTripId,
                UserId = seededUserId,
                TripRole = TripRoleEnum.TRIP_MANAGER,
                JoinedAt =  DateTime.UtcNow,
            },
            ct
        );
        
        db.SaveChangesAsync(ct);
        Console.WriteLine("[+] Trip member seeded");
    }
}