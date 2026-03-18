using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace AceTaxis.Migrations
{
    /// <inheritdoc />
    public partial class newFieldWebBooking : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "Accepted",
                table: "WebBookings");

            migrationBuilder.AddColumn<int>(
                name: "Status",
                table: "WebBookings",
                type: "int",
                nullable: false,
                defaultValue: 0);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "Status",
                table: "WebBookings");

            migrationBuilder.AddColumn<bool>(
                name: "Accepted",
                table: "WebBookings",
                type: "bit",
                nullable: false,
                defaultValue: false);
        }
    }
}
