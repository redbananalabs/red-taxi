using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace AceTaxis.Migrations
{
    /// <inheritdoc />
    public partial class onShift : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.RenameColumn(
                name: "Added",
                table: "OnShiftDrivers",
                newName: "StartFinishAt");

            migrationBuilder.AddColumn<DateTime>(
                name: "BreakStartFinishAt",
                table: "OnShiftDrivers",
                type: "datetime2",
                nullable: true);

            migrationBuilder.AddColumn<bool>(
                name: "OnBreak",
                table: "OnShiftDrivers",
                type: "bit",
                nullable: false,
                defaultValue: false);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "BreakStartFinishAt",
                table: "OnShiftDrivers");

            migrationBuilder.DropColumn(
                name: "OnBreak",
                table: "OnShiftDrivers");

            migrationBuilder.RenameColumn(
                name: "StartFinishAt",
                table: "OnShiftDrivers",
                newName: "Added");
        }
    }
}
