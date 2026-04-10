using Microsoft.EntityFrameworkCore;
using TrippieBackend.Models.Model;

namespace TrippieBackend.Seeds;

public static class FavoriteSeeder
{
    public static async Task SeedAsync(DbContext db, CancellationToken ct = default)
    {
        if (await db.Set<Favorite>().AnyAsync(ct))
        {
            Console.WriteLine("[i] Favorites already seeded, skipping");
            return;
        }

        Guid johannkaId = await db.Set<User>()
            .Where(x => x.Firstname == "Johannka")
            .Select(x => x.Id)
            .FirstOrDefaultAsync(ct);

        Guid barcelonaId = await db.Set<Place>()
            .Where(x => x.Name == "Barcelona")
            .Select(x => x.Id)
            .FirstOrDefaultAsync(ct);

        Guid nurburgringId = await db.Set<Place>()
            .Where(x => x.Name == "Nürburgring")
            .Select(x => x.Id)
            .FirstOrDefaultAsync(ct);

        Guid whiteRabbitId = await db.Set<Place>()
            .Where(x => x.Name == "White Rabbit · The Immersive Experience of Barcelona")
            .Select(x => x.Id)
            .FirstOrDefaultAsync(ct);

        await db.Set<Favorite>().AddRangeAsync(
            new Favorite { UserId = johannkaId, PlaceId = barcelonaId },
            new Favorite { UserId = johannkaId, PlaceId = nurburgringId },
            new Favorite { UserId = johannkaId, PlaceId = whiteRabbitId }
        );

        await db.SaveChangesAsync(ct);
        Console.WriteLine("[+] Favorites seeded");
    }
}