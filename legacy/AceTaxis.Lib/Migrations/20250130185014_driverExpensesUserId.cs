using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace AceTaxis.Migrations
{
    /// <inheritdoc />
    public partial class driverExpensesUserId : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<int>(
                name: "UserId",
                table: "DriverExpenses",
                type: "int",
                nullable: false,
                defaultValue: 0);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "UserId",
                table: "DriverExpenses");
        }
    }
}
