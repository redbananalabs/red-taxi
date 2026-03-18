using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace AceTaxis.Migrations
{
    /// <inheritdoc />
    public partial class RejectedReason : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.RenameColumn(
                name: "AcceptedOn",
                table: "WebBookings",
                newName: "AcceptedRejectedOn");

            migrationBuilder.RenameColumn(
                name: "AcceptedBy",
                table: "WebBookings",
                newName: "AcceptedRejectedBy");

            migrationBuilder.AddColumn<string>(
                name: "RejectedReason",
                table: "WebBookings",
                type: "nvarchar(max)",
                nullable: true);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "RejectedReason",
                table: "WebBookings");

            migrationBuilder.RenameColumn(
                name: "AcceptedRejectedOn",
                table: "WebBookings",
                newName: "AcceptedOn");

            migrationBuilder.RenameColumn(
                name: "AcceptedRejectedBy",
                table: "WebBookings",
                newName: "AcceptedBy");
        }
    }
}
