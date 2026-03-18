using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace RedTaxi.Infrastructure.Persistence.Migrations.Tenant
{
    /// <inheritdoc />
    public partial class AddBankHolidaysToCompanyConfig : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<string>(
                name: "BankHolidays",
                table: "CompanyConfigs",
                type: "nvarchar(max)",
                nullable: true);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "BankHolidays",
                table: "CompanyConfigs");
        }
    }
}
