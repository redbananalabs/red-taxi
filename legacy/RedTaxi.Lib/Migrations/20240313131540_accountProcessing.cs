using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace AceTaxis.Migrations
{
    /// <inheritdoc />
    public partial class accountProcessing : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.RenameColumn(
                name: "JourneysTotalExVat",
                table: "AccountInvoices",
                newName: "NetTotal");

            migrationBuilder.AddColumn<string>(
                name: "PurchaseOrderNo",
                table: "Accounts",
                type: "nvarchar(max)",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "Reference",
                table: "Accounts",
                type: "nvarchar(max)",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "PurchaseOrderNo",
                table: "AccountInvoices",
                type: "nvarchar(max)",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "Reference",
                table: "AccountInvoices",
                type: "nvarchar(max)",
                nullable: true);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "PurchaseOrderNo",
                table: "Accounts");

            migrationBuilder.DropColumn(
                name: "Reference",
                table: "Accounts");

            migrationBuilder.DropColumn(
                name: "PurchaseOrderNo",
                table: "AccountInvoices");

            migrationBuilder.DropColumn(
                name: "Reference",
                table: "AccountInvoices");

            migrationBuilder.RenameColumn(
                name: "NetTotal",
                table: "AccountInvoices",
                newName: "JourneysTotalExVat");
        }
    }
}
