using System.Globalization;
using System.Text;
using Microsoft.EntityFrameworkCore;
using TrippieBackend.Models.Model;

namespace TrippieBackend.Seeds;

public static class AirportSeeder
{
    private const int BatchSize = 100;

    public static async Task SeedAsync(DbContext db, CancellationToken ct = default)
    {
        if (await db.Set<Airport>().AnyAsync(ct))
        {
            Console.WriteLine("[i] Airports already seeded, skipping.");
            return;
        }

        var csvPath = Path.Combine(AppContext.BaseDirectory, "Seeds", "Data", "airports_clean.csv");
        if (!File.Exists(csvPath))
        {
            Console.WriteLine($"[!] Airport CSV not found at: {csvPath}");
            return;
        }

        var lines = await File.ReadAllLinesAsync(csvPath, ct);
        var airports = new Dictionary<string, Airport>(); // keyed by IATA — deduplicates in-place
        int skipped = 0;

        foreach (var line in lines)
        {
            if (string.IsNullOrWhiteSpace(line)) { skipped++; continue; }

            var cols = ParseCsvLine(line);
            if (cols.Length < 9) { skipped++; continue; }

            if (!decimal.TryParse(cols[5], NumberStyles.Any, CultureInfo.InvariantCulture, out var lat) ||
                !decimal.TryParse(cols[6], NumberStyles.Any, CultureInfo.InvariantCulture, out var lon))
            {
                Console.WriteLine($"[E] Failed to parse lat/lon: {line[..Math.Min(60, line.Length)]}");
                skipped++;
                continue;
            }
            
            var rawTz = cols[8].Trim('"');
            var tz = rawTz == "\\N" || string.IsNullOrWhiteSpace(rawTz)
                ? 0m
                : decimal.Parse(rawTz, NumberStyles.Any, CultureInfo.InvariantCulture);

            var iata = cols[3].Trim('"');
            airports.TryAdd(iata, new Airport
            {
                Name      = cols[0].Trim('"'),
                City      = cols[1].Trim('"'),
                Country   = cols[2].Trim('"'),
                IataCode  = iata,
                Latitude  = lat,
                Longitude = lon,
                Timezone  = tz
            });
        }

        var batch = airports.Values.ToList();
        int total = batch.Count;
        int inserted = 0;

        for (int i = 0; i < total; i += BatchSize)
        {
            var chunk = batch.Skip(i).Take(BatchSize).ToList();
            await db.Set<Airport>().AddRangeAsync(chunk, ct);
            await db.SaveChangesAsync(ct);
            db.ChangeTracker.Clear();
            inserted += chunk.Count;
            Console.WriteLine($"[i] Inserted {inserted}/{total} airports...");
        }

        Console.WriteLine($"[+] Seeded {inserted} airports.");
        Console.WriteLine($"[-] Skipped {skipped} rows, {lines.Length - skipped - inserted} duplicates removed.");
    }

    private static string[] ParseCsvLine(string line)
    {
        var result = new List<string>();
        var current = new StringBuilder();
        bool inQuotes = false;

        foreach (char c in line)
        {
            if (c == '"') { inQuotes = !inQuotes; current.Append(c); }
            else if (c == ',' && !inQuotes) { result.Add(current.ToString()); current.Clear(); }
            else current.Append(c);
        }

        result.Add(current.ToString());
        return result.ToArray();
    }
}