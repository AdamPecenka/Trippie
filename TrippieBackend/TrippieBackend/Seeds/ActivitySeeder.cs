using Microsoft.EntityFrameworkCore;
using TrippieBackend.Models.Model;

namespace TrippieBackend.Seeds;

public static class ActivitySeeder
{
    public static async Task SeedAsync(DbContext db, CancellationToken ct = default)
    {
        if (await db.Set<Activity>().AnyAsync(ct))
        {
            Console.WriteLine("[i] Activities already seeded, skipping");
            return;
        }

        var seededTrip = await db.Set<Trip>()
            .Where(x => x.Name == "Barcelona trip")
            .FirstOrDefaultAsync(ct);

        Guid seededUserId = await db.Set<User>()
            .Where(x => x.Firstname == "Johannka")
            .Select(x => x.Id)
            .FirstOrDefaultAsync(ct);

        Guid whiteRabbitPlaceId = await db.Set<Place>()
            .Where(x => x.Name == "White Rabbit · The Immersive Experience of Barcelona")
            .Select(x => x.Id)
            .FirstOrDefaultAsync(ct);

        Guid onefamPlaceId = await db.Set<Place>()
            .Where(x => x.Name == "Onefam Batlló")
            .Select(x => x.Id)
            .FirstOrDefaultAsync(ct);

        await db.Set<Activity>().AddRangeAsync(
            new Activity
            {
                TripId = seededTrip.Id,
                PlaceId = whiteRabbitPlaceId,
                ActivityDate = DateOnly.FromDateTime(seededTrip.StartDate),
                StartTime = new TimeOnly(10, 0),
                EndTime = new TimeOnly(12, 0),
                Notes = "Book tickets in advance!",
                CreatedBy = seededUserId
            },
            new Activity
            {
                TripId = seededTrip.Id,
                PlaceId = onefamPlaceId,
                ActivityDate = DateOnly.FromDateTime(seededTrip.StartDate.AddDays(1)),
                StartTime = new TimeOnly(14, 0),
                EndTime = new TimeOnly(16, 30),
                Notes = "Lunch nearby beforehand",
                CreatedBy = seededUserId
            },
            new Activity
            {
                TripId = seededTrip.Id,
                PlaceId = null, // aktivita bez miesta je tiez validna
                ActivityDate = DateOnly.FromDateTime(seededTrip.StartDate.AddDays(2)),
                StartTime = new TimeOnly(9, 0),
                EndTime = new TimeOnly(10, 0),
                Notes = "Morning run along the beach",
                CreatedBy = seededUserId
            }
        );

        await db.SaveChangesAsync(ct);
        Console.WriteLine("[+] Activities seeded");
    }
}