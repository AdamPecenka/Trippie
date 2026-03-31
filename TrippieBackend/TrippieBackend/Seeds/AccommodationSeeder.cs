using Microsoft.EntityFrameworkCore;
using TrippieBackend.Models.Model;

namespace TrippieBackend.Seeds;

public static class AccommodationSeeder
{
    public static async Task SeedAsync(DbContext db, CancellationToken ct = default)
    {
        if (await db.Set<Trip>().AnyAsync(ct))
        {
            Console.WriteLine("[i] Trip already seeded, skipping");
            return;
        }
        
        var seededTrip = await db.Set<Trip>()
            .Where(x => x.Name == "Barcelona trip")
                .FirstOrDefaultAsync(ct);
        
        Guid seededPlaceId = await db.Set<Place>()
            .Where(x => x.Name == "Onefam Batlló")
                .Select(x => x.Id)  
                .FirstOrDefaultAsync(ct);

        await db.Set<Accommodation>().AddAsync(
            new Accommodation
            {
                TripId = seededTrip.Id,
                PlaceId = seededPlaceId,
                CheckIn = seededTrip.StartDate.AddHours(10),
                CheckOut = seededTrip.EndDate.AddHours(-10)
            }
        );
        
        await db.SaveChangesAsync(ct);
        Console.WriteLine("[+] Trip seeded");
    }
}