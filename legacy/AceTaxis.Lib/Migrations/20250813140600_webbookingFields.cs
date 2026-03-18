using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace AceTaxis.Migrations
{
    /// <inheritdoc />
    public partial class webbookingFields : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<int>(
                name: "DurationMinutes",
                table: "WebBookings",
                type: "int",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "DurationText",
                table: "WebBookings",
                type: "nvarchar(max)",
                nullable: true);

            migrationBuilder.AddColumn<int>(
                name: "Luggage",
                table: "WebBookings",
                type: "int",
                nullable: true);

            migrationBuilder.AddColumn<decimal>(
                name: "Mileage",
                table: "WebBookings",
                type: "decimal(18,2)",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "MileageText",
                table: "WebBookings",
                type: "nvarchar(max)",
                nullable: true);

            migrationBuilder.AddColumn<double>(
                name: "Price",
                table: "WebBookings",
                type: "float",
                nullable: true);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "DurationMinutes",
                table: "WebBookings");

            migrationBuilder.DropColumn(
                name: "DurationText",
                table: "WebBookings");

            migrationBuilder.DropColumn(
                name: "Luggage",
                table: "WebBookings");

            migrationBuilder.DropColumn(
                name: "Mileage",
                table: "WebBookings");

            migrationBuilder.DropColumn(
                name: "MileageText",
                table: "WebBookings");

            migrationBuilder.DropColumn(
                name: "Price",
                table: "WebBookings");
        }
    }
}
