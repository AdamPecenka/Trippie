using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace TrippieBackend.Migrations
{
    /// <inheritdoc />
    public partial class TripInviteCodeMultipleUseFix : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "used",
                table: "trip_invites");

            migrationBuilder.DropColumn(
                name: "used_at",
                table: "trip_invites");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<bool>(
                name: "used",
                table: "trip_invites",
                type: "boolean",
                nullable: true);

            migrationBuilder.AddColumn<DateTime>(
                name: "used_at",
                table: "trip_invites",
                type: "timestamp with time zone",
                nullable: true);
        }
    }
}
