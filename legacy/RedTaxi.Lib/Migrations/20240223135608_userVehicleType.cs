using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace AceTaxis.Migrations
{
    /// <inheritdoc />
    public partial class userVehicleType : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<string>(
                name: "VehicleColour",
                table: "AppUserProfiles",
                type: "nvarchar(20)",
                maxLength: 20,
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "VehicleMake",
                table: "AppUserProfiles",
                type: "nvarchar(20)",
                maxLength: 20,
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "VehicleModel",
                table: "AppUserProfiles",
                type: "nvarchar(30)",
                maxLength: 30,
                nullable: true);

            migrationBuilder.AddColumn<int>(
                name: "VehicleType",
                table: "AppUserProfiles",
                type: "int",
                nullable: false,
                defaultValue: 0);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "VehicleColour",
                table: "AppUserProfiles");

            migrationBuilder.DropColumn(
                name: "VehicleMake",
                table: "AppUserProfiles");

            migrationBuilder.DropColumn(
                name: "VehicleModel",
                table: "AppUserProfiles");

            migrationBuilder.DropColumn(
                name: "VehicleType",
                table: "AppUserProfiles");
        }
    }
}
