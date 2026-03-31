using Microsoft.EntityFrameworkCore;
using TrippieBackend.Models.Enums;
using TrippieBackend.Models.Model;

namespace TrippieBackend.Seeds;

public static class TripSeeder
{
    public static async Task SeedAsync(DbContext db, CancellationToken ct = default)
    {
        if (await db.Set<Trip>().AnyAsync(ct))
        {
            Console.WriteLine("[i] Trip already seeded, skipping");
            return;
        }
        
        Guid seededUserId = await db.Set<User>()
            .Where(x => x.Firstname == "Johannka")
                .Select(x => x.Id)
                .FirstOrDefaultAsync(ct);

        Guid seededPlaceId = await db.Set<Place>()
            .Where(x => x.City == "Barcelona")
                .Select(x => x.Id)
                .FirstOrDefaultAsync(ct);
        
        await db.Set<Trip>().AddAsync(
            new Trip
            {
                Name = "Barcelona trip",
                DestinationPlaceId =  seededPlaceId,
                TransportType = TransportTypeEnum.FLIGHT,
                TripStatus =  TripStatusEnum.PLANNING,
                StartDate =  DateTime.UtcNow,
                EndDate = DateTime.UtcNow.AddDays(31),
                CreatedBy =  seededUserId
            },
            ct
        );
        
        await db.SaveChangesAsync(ct);
        Console.WriteLine("[+] Trip seeded");
    }
}