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

        db.Set<User>().AddRange(
            new User
            {
                Firstname = "Marek",
                Lastname = "Novák",
                Email = "marek.novak@example.com",
                PhoneNumber = "+421901234567",
                PasswordHash = "placeholder_hash_1",
                Theme = ThemeEnum.LIGHT
            },
            new User
            {
                Firstname = "Jana",
                Lastname = "Kováčová",
                Email = "jana.kovacova@example.com",
                PhoneNumber = "+421902345678",
                PasswordHash = "placeholder_hash_2",
                Theme = ThemeEnum.DARK
            },
            new User
            {
                Firstname = "Tomáš",
                Lastname = "Horváth",
                Email = "tomas.horvath@example.com",
                PhoneNumber = "+421903456789",
                PasswordHash = "placeholder_hash_3",
                Theme = ThemeEnum.LIGHT
            }
        );

        await db.SaveChangesAsync(ct);
        Console.WriteLine("[+] Users seeded");
    }
}