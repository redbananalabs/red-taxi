using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace AceTaxis.Migrations
{
    /// <inheritdoc />
    public partial class onShiftLog : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "OnShiftDrivers");

            migrationBuilder.CreateTable(
                name: "DriversOnShift",
                columns: table => new
                {
                    UserId = table.Column<int>(type: "int", nullable: false),
                    StartFinishAt = table.Column<DateTime>(type: "datetime2", nullable: false),
                    OnBreak = table.Column<bool>(type: "bit", nullable: false),
                    BreakStartFinishAt = table.Column<DateTime>(type: "datetime2", nullable: true),
                    ActiveBookingId = table.Column<int>(type: "int", nullable: false),
                    Status = table.Column<int>(type: "int", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_DriversOnShift", x => x.UserId);
                    table.ForeignKey(
                        name: "FK_DriversOnShift_AppUserProfiles_UserId",
                        column: x => x.UserId,
                        principalTable: "AppUserProfiles",
                        principalColumn: "UserId",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_DriversOnShift_Bookings_ActiveBookingId",
                        column: x => x.ActiveBookingId,
                        principalTable: "Bookings",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateTable(
                name: "DriversShiftLogs",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    UserId = table.Column<int>(type: "int", nullable: false),
                    TimeStamp = table.Column<DateTime>(type: "datetime2", nullable: true),
                    EntryType = table.Column<int>(type: "int", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_DriversShiftLogs", x => x.Id);
                });

            migrationBuilder.CreateIndex(
                name: "IX_DriversOnShift_ActiveBookingId",
                table: "DriversOnShift",
                column: "ActiveBookingId");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "DriversOnShift");

            migrationBuilder.DropTable(
                name: "DriversShiftLogs");

            migrationBuilder.CreateTable(
                name: "OnShiftDrivers",
                columns: table => new
                {
                    UserId = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    BreakStartFinishAt = table.Column<DateTime>(type: "datetime2", nullable: true),
                    OnBreak = table.Column<bool>(type: "bit", nullable: false),
                    StartFinishAt = table.Column<DateTime>(type: "datetime2", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_OnShiftDrivers", x => x.UserId);
                });
        }
    }
}
