using Microsoft.EntityFrameworkCore;
using TrippieBackend.Models.Model;

namespace TrippieBackend.Seeds;

public static class PlaceSeeder
{
    public static async Task SeedAsync(DbContext db, CancellationToken ct = default)
    {
        if (await db.Set<Place>().AnyAsync(ct))
        {
            Console.WriteLine("[i] Places already seeded, skipping");
            return;
        }

        db.Set<Place>().AddRange(
            new Place
            {
                Address = "Barcelona, Spain",
                Name = "Barcelona",
                City = "Barcelona",
                Country = "Spain",
                Latitude = 41.387437399999996,
                Longitude = 2.1686495999999997,
                GooglePlaceId = "ChIJ5TCOcRaYpBIRCmZHTz37sEQ",
            },
            new Place
            {
                Address = "Otto-Flimm-Straße, 53520 Nürburg, Germany",
                Name = "Nürburgring",
                City = "Nürburg",
                Country = "Germany",
                Latitude = 50.3327834,
                Longitude = 6.9450233999999993,
                GooglePlaceId = "ChIJWcUQkDatv0cRmljKcxvC24A",
            },
            new Place
            {
                Address = "Pg. de Gràcia, 55, Eixample, 08007 Eixample, Barcelona, Spain",
                Name = "White Rabbit · The Immersive Experience of Barcelona",
                City = "Barcelona",
                Country = "Spain",
                Latitude = 41.3926379,
                Longitude = 2.163732,
                GooglePlaceId = "ChIJebQOLzqjpBIRr9udRFMaKDk",
            }
        );
        
        await db.SaveChangesAsync(ct);
        Console.WriteLine("[+] Users seeded");
    }
}