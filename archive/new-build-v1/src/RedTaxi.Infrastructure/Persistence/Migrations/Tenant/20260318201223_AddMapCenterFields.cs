using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace RedTaxi.Infrastructure.Persistence.Migrations.Tenant
{
    /// <inheritdoc />
    public partial class AddMapCenterFields : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<decimal>(
                name: "MapCenterLatitude",
                table: "CompanyConfigs",
                type: "decimal(10,6)",
                nullable: false,
                defaultValue: 0m);

            migrationBuilder.AddColumn<decimal>(
                name: "MapCenterLongitude",
                table: "CompanyConfigs",
                type: "decimal(10,6)",
                nullable: false,
                defaultValue: 0m);

            migrationBuilder.AddColumn<int>(
                name: "MapDefaultZoom",
                table: "CompanyConfigs",
                type: "int",
                nullable: false,
                defaultValue: 0);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "MapCenterLatitude",
                table: "CompanyConfigs");

            migrationBuilder.DropColumn(
                name: "MapCenterLongitude",
                table: "CompanyConfigs");

            migrationBuilder.DropColumn(
                name: "MapDefaultZoom",
                table: "CompanyConfigs");
        }
    }
}
