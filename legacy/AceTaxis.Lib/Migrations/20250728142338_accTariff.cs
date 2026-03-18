using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace AceTaxis.Migrations
{
    /// <inheritdoc />
    public partial class accTariff : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<int>(
                name: "AccountTariffId",
                table: "Accounts",
                type: "int",
                nullable: true);

            migrationBuilder.CreateTable(
                name: "AccountTariffs",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    Name = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    AccountInitialCharge = table.Column<double>(type: "float", nullable: false),
                    DriverInitialCharge = table.Column<double>(type: "float", nullable: false),
                    AccountFirstMileCharge = table.Column<double>(type: "float", nullable: false),
                    DriverFirstMileCharge = table.Column<double>(type: "float", nullable: false),
                    AccountAdditionalMileCharge = table.Column<double>(type: "float", nullable: false),
                    DriverAdditionalMileCharge = table.Column<double>(type: "float", nullable: false),
                    DateCreated = table.Column<DateTime>(type: "datetime2", nullable: false),
                    DateUpdated = table.Column<DateTime>(type: "datetime2", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_AccountTariffs", x => x.Id);
                });

            migrationBuilder.CreateIndex(
                name: "IX_Accounts_AccountTariffId",
                table: "Accounts",
                column: "AccountTariffId");

            migrationBuilder.AddForeignKey(
                name: "FK_Accounts_AccountTariffs_AccountTariffId",
                table: "Accounts",
                column: "AccountTariffId",
                principalTable: "AccountTariffs",
                principalColumn: "Id",
                onDelete: ReferentialAction.Restrict);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_Accounts_AccountTariffs_AccountTariffId",
                table: "Accounts");

            migrationBuilder.DropTable(
                name: "AccountTariffs");

            migrationBuilder.DropIndex(
                name: "IX_Accounts_AccountTariffId",
                table: "Accounts");

            migrationBuilder.DropColumn(
                name: "AccountTariffId",
                table: "Accounts");
        }
    }
}
