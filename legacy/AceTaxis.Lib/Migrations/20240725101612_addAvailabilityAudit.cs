using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace AceTaxis.Migrations
{
    /// <inheritdoc />
    public partial class addAvailabilityAudit : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateTable(
                name: "DriverAvailabilityAudits",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    UserId = table.Column<int>(type: "int", nullable: false),
                    ForDate = table.Column<DateTime>(type: "datetime2", nullable: false),
                    TheChange = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    ChangeBy = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    ChangedOn = table.Column<DateTime>(type: "datetime2", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_DriverAvailabilityAudits", x => x.Id);
                });
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "DriverAvailabilityAudits");
        }
    }
}
