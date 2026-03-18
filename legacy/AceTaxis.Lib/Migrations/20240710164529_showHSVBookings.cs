using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace AceTaxis.Migrations
{
    /// <inheritdoc />
    public partial class showHSVBookings : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<bool>(
                name: "ShowHVSBookings",
                table: "AppUserProfiles",
                type: "bit",
                nullable: false,
                defaultValue: false);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "ShowHVSBookings",
                table: "AppUserProfiles");
        }
    }
}
