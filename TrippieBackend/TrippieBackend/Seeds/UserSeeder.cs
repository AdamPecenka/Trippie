using Microsoft.EntityFrameworkCore;
using TrippieBackend.Models.Enums;
using TrippieBackend.Models.Model;

namespace TrippieBackend.Seeds;

public static class UserSeeder
{
    public static async Task SeedAsync(DbContext db, CancellationToken ct = default)
    {
        if (await db.Set<User>().AnyAsync(ct))
        {
            Console.WriteLine("[i] User already seeded, skipping");
            return;
        }

        await db.Set<User>().AddRangeAsync(
            new User
            {
                Firstname = "Johannka",
                Lastname = "Tilesova",
                Email = "johannka.tilesova@example.com",
                PhoneNumber = "+421901234567",
                PasswordHash = BCrypt.Net.BCrypt.HashPassword("Heslo@1234", workFactor: 12),
                Theme = ThemeEnum.LIGHT
            },
            new User
            {
                Firstname = "Adam",
                Lastname = "Pecenka",
                Email = "adam.pecenka@example.com",
                PhoneNumber = "+421902345678",
                PasswordHash = BCrypt.Net.BCrypt.HashPassword("Heslo@1234", workFactor: 12),
                Theme = ThemeEnum.DARK
            }
        );

        await db.SaveChangesAsync(ct);
        Console.WriteLine("[+] Users seeded");
    }
}