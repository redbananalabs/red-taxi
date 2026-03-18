using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace AceTaxis.Migrations
{
    /// <inheritdoc />
    public partial class onShiftChanges : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.RenameColumn(
                name: "StartFinishAt",
                table: "DriversOnShift",
                newName: "StartAt");

            migrationBuilder.RenameColumn(
                name: "BreakStartFinishAt",
                table: "DriversOnShift",
                newName: "BreakStartAt");

            migrationBuilder.AddColumn<DateTime>(
                name: "ClearAt",
                table: "DriversOnShift",
                type: "datetime2",
                nullable: false,
                defaultValue: new DateTime(1, 1, 1, 0, 0, 0, 0, DateTimeKind.Unspecified));
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "ClearAt",
                table: "DriversOnShift");

            migrationBuilder.RenameColumn(
                name: "StartAt",
                table: "DriversOnShift",
                newName: "StartFinishAt");

            migrationBuilder.RenameColumn(
                name: "BreakStartAt",
                table: "DriversOnShift",
                newName: "BreakStartFinishAt");
        }
    }
}
