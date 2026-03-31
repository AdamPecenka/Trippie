using Microsoft.EntityFrameworkCore;
using TrippieBackend.Models.Enums;
using TrippieBackend.Models.Model;

namespace TrippieBackend.Seeds;

public static class FlightSeeder
{
    public static async Task SeedAsync(DbContext db, CancellationToken ct = default)
    {
        if (await db.Set<Flight>().AnyAsync(ct))
        {
            Console.WriteLine("[i] Flights already seeded, skipping");
            return;
        }
        
        var seededTrip = await db.Set<Trip>()
            .Where(x => x.Name == "Barcelona trip")
                .FirstOrDefaultAsync(ct);

        Guid btsAirportId = await db.Set<Airport>()
            .Where(x => x.IataCode == "BTS")
                .Select(x => x.Id)
                .FirstOrDefaultAsync(ct);
        
        Guid bcnAirportId = await db.Set<Airport>()
            .Where(x => x.IataCode == "BCN")
            .Select(x => x.Id)
            .FirstOrDefaultAsync(ct);
        
        await db.Set<Flight>().AddRangeAsync(
            new Flight
            {
                TripId = seededTrip.Id,
                TravelDirection = TravelDirectionEnum.OUTBOUND,
                FlightNumber = "AA1111",
                DepartureAirportId =  btsAirportId,
                ArrivalAirportId =  bcnAirportId,
                DepartureTime = seededTrip.StartDate,
                ArrivalTime = seededTrip.StartDate.AddMinutes(155), // 2h 35min
            },
            new Flight
            {
                TripId = seededTrip.Id,
                TravelDirection = TravelDirectionEnum.RETURN,
                FlightNumber = "BB2222",
                DepartureAirportId =  bcnAirportId,
                ArrivalAirportId =  btsAirportId,
                DepartureTime = seededTrip.EndDate,
                ArrivalTime = seededTrip.EndDate.AddMinutes(155), // 2h 35min
            }
        );
        
        await db.SaveChangesAsync(ct);
        Console.WriteLine("[+] Flights seeded");
    }
}