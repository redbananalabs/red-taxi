using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace AceTaxis.Migrations
{
    /// <inheritdoc />
    public partial class newFeilds : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<decimal>(
                name: "AccountPrice",
                table: "Bookings",
                type: "decimal(18,2)",
                precision: 18,
                scale: 2,
                nullable: false,
                defaultValue: 0m);

            //migrationBuilder.AddColumn<int>(
            //    name: "InvoiceNumber",
            //    table: "Bookings",
            //    type: "int",
            //    nullable: true);

            migrationBuilder.AddColumn<int>(
                name: "VehicleType",
                table: "Bookings",
                type: "int",
                nullable: false,
                defaultValue: 0);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "AccountPrice",
                table: "Bookings");

            migrationBuilder.DropColumn(
                name: "InvoiceNumber",
                table: "Bookings");

            migrationBuilder.DropColumn(
                name: "VehicleType",
                table: "Bookings");
        }
    }
}
