using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace TrippieBackend.Migrations
{
    /// <inheritdoc />
    public partial class ChangeInviteCodeType : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.Sql(
                "ALTER TABLE trip_invites ALTER COLUMN invite_code TYPE integer USING invite_code::integer;"
            );
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AlterColumn<string>(
                name: "invite_code",
                table: "trip_invites",
                type: "character varying(255)",
                maxLength: 255,
                nullable: true,
                oldClrType: typeof(int),
                oldType: "integer");
        }
    }
}
