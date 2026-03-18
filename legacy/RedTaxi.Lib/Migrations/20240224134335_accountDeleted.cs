using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace AceTaxis.Migrations
{
    /// <inheritdoc />
    public partial class accountDeleted : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.RenameColumn(
                name: "VatAmount",
                table: "AccountInvoices",
                newName: "VatTotal");

            migrationBuilder.RenameColumn(
                name: "Amount",
                table: "AccountInvoices",
                newName: "Total");

            //migrationBuilder.AddColumn<bool>(
            //    name: "Deleted",
            //    table: "Accounts",
            //    type: "bit",
            //    nullable: false,
            //    defaultValue: false);

            migrationBuilder.AddColumn<decimal>(
                name: "JourneysTotalExVat",
                table: "AccountInvoices",
                type: "decimal(18,2)",
                precision: 18,
                scale: 2,
                nullable: false,
                defaultValue: 0m);

            migrationBuilder.AddColumn<int>(
                name: "NumberOfJourneys",
                table: "AccountInvoices",
                type: "int",
                nullable: false,
                defaultValue: 0);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "Deleted",
                table: "Accounts");

            migrationBuilder.DropColumn(
                name: "JourneysTotalExVat",
                table: "AccountInvoices");

            migrationBuilder.DropColumn(
                name: "NumberOfJourneys",
                table: "AccountInvoices");

            migrationBuilder.RenameColumn(
                name: "VatTotal",
                table: "AccountInvoices",
                newName: "VatAmount");

            migrationBuilder.RenameColumn(
                name: "Total",
                table: "AccountInvoices",
                newName: "Amount");
        }
    }
}
