using Microsoft.EntityFrameworkCore.Migrations;
using TrippieBackend.Models.Enums;

#nullable disable

namespace TrippieBackend.Migrations
{
    /// <inheritdoc />
    public partial class InitUsers : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.InsertData(
                table: "users",
                columns: new[] { "id", "firstname", "lastname", "email", "phone_number", "password_hash", "theme" },
                values: new object[,]
                {
                    {
                        Guid.Parse("a1b2c3d4-0001-0001-0001-000000000001"),
                        "Alice",
                        "Johnson",
                        "alice.johnson@example.com",
                        "+421901111111",
                        "$2a$12$eImiTXuWVxfM37uY4JANjQ==:hashedpassword1",
                        ThemeEnum.LIGHT
                    },
                    {
                        Guid.Parse("a1b2c3d4-0002-0002-0002-000000000002"),
                        "Bob",
                        "Smith",
                        "bob.smith@example.com",
                        "+421902222222",
                        "$2a$12$eImiTXuWVxfM37uY4JANjQ==:hashedpassword2",
                        ThemeEnum.LIGHT
                    },
                    {
                        Guid.Parse("a1b2c3d4-0003-0003-0003-000000000003"),
                        "Carol",
                        "Williams",
                        "carol.williams@example.com",
                        "+421903333333",
                        "$2a$12$eImiTXuWVxfM37uY4JANjQ==:hashedpassword3",
                        ThemeEnum.LIGHT
                    }
                }
            );
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DeleteData(
                table: "users",
                keyColumn: "id",
                keyValues: new object[]
                {
                    Guid.Parse("a1b2c3d4-0001-0001-0001-000000000001"),
                    Guid.Parse("a1b2c3d4-0002-0002-0002-000000000002"),
                    Guid.Parse("a1b2c3d4-0003-0003-0003-000000000003")
                }
            );
        }
    }
}
