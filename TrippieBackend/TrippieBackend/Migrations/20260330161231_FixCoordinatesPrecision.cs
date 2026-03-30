using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace TrippieBackend.Migrations
{
    /// <inheritdoc />
    public partial class FixCoordinatesPrecision : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AlterColumn<double>(
                name: "longitude",
                table: "user_last_location",
                type: "double precision",
                nullable: true,
                oldClrType: typeof(double),
                oldType: "numeric(9,6)",
                oldNullable: true);

            migrationBuilder.AlterColumn<double>(
                name: "latitude",
                table: "user_last_location",
                type: "double precision",
                nullable: true,
                oldClrType: typeof(double),
                oldType: "numeric(9,6)",
                oldNullable: true);

            migrationBuilder.AlterColumn<double>(
                name: "longitude",
                table: "places",
                type: "double precision",
                nullable: false,
                oldClrType: typeof(double),
                oldType: "numeric(9,6)");

            migrationBuilder.AlterColumn<double>(
                name: "latitude",
                table: "places",
                type: "double precision",
                nullable: false,
                oldClrType: typeof(double),
                oldType: "numeric(9,6)");

            migrationBuilder.AlterColumn<double>(
                name: "longitude",
                table: "airports",
                type: "double precision",
                nullable: false,
                oldClrType: typeof(double),
                oldType: "numeric(9,6)");

            migrationBuilder.AlterColumn<double>(
                name: "latitude",
                table: "airports",
                type: "double precision",
                nullable: false,
                oldClrType: typeof(double),
                oldType: "numeric(9,6)");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AlterColumn<double>(
                name: "longitude",
                table: "user_last_location",
                type: "numeric(9,6)",
                nullable: true,
                oldClrType: typeof(double),
                oldType: "double precision",
                oldNullable: true);

            migrationBuilder.AlterColumn<double>(
                name: "latitude",
                table: "user_last_location",
                type: "numeric(9,6)",
                nullable: true,
                oldClrType: typeof(double),
                oldType: "double precision",
                oldNullable: true);

            migrationBuilder.AlterColumn<double>(
                name: "longitude",
                table: "places",
                type: "numeric(9,6)",
                nullable: false,
                oldClrType: typeof(double),
                oldType: "double precision");

            migrationBuilder.AlterColumn<double>(
                name: "latitude",
                table: "places",
                type: "numeric(9,6)",
                nullable: false,
                oldClrType: typeof(double),
                oldType: "double precision");

            migrationBuilder.AlterColumn<double>(
                name: "longitude",
                table: "airports",
                type: "numeric(9,6)",
                nullable: false,
                oldClrType: typeof(double),
                oldType: "double precision");

            migrationBuilder.AlterColumn<double>(
                name: "latitude",
                table: "airports",
                type: "numeric(9,6)",
                nullable: false,
                oldClrType: typeof(double),
                oldType: "double precision");
        }
    }
}
