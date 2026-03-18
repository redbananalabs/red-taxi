using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace RedTaxi.Infrastructure.Persistence.Migrations.Tenant
{
    /// <inheritdoc />
    public partial class AddAuthFieldsToUserProfile : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<string>(
                name: "Email",
                table: "UserProfiles",
                type: "nvarchar(max)",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "PasswordHash",
                table: "UserProfiles",
                type: "nvarchar(max)",
                nullable: true);

            migrationBuilder.AddColumn<int>(
                name: "Role",
                table: "UserProfiles",
                type: "int",
                nullable: false,
                defaultValue: 0);

            migrationBuilder.AlterColumn<decimal>(
                name: "Longitude",
                table: "LocalPOIs",
                type: "decimal(10,6)",
                nullable: true,
                oldClrType: typeof(decimal),
                oldType: "decimal(18,2)",
                oldNullable: true);

            migrationBuilder.AlterColumn<decimal>(
                name: "Latitude",
                table: "LocalPOIs",
                type: "decimal(10,6)",
                nullable: true,
                oldClrType: typeof(decimal),
                oldType: "decimal(18,2)",
                oldNullable: true);

            migrationBuilder.AlterColumn<decimal>(
                name: "AddressLookupLng",
                table: "CompanyConfigs",
                type: "decimal(10,6)",
                nullable: true,
                oldClrType: typeof(decimal),
                oldType: "decimal(18,2)",
                oldNullable: true);

            migrationBuilder.AlterColumn<decimal>(
                name: "AddressLookupLat",
                table: "CompanyConfigs",
                type: "decimal(10,6)",
                nullable: true,
                oldClrType: typeof(decimal),
                oldType: "decimal(18,2)",
                oldNullable: true);

            migrationBuilder.AddColumn<int>(
                name: "AutoCompleteHours",
                table: "CompanyConfigs",
                type: "int",
                nullable: false,
                defaultValue: 0);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "Email",
                table: "UserProfiles");

            migrationBuilder.DropColumn(
                name: "PasswordHash",
                table: "UserProfiles");

            migrationBuilder.DropColumn(
                name: "Role",
                table: "UserProfiles");

            migrationBuilder.DropColumn(
                name: "AutoCompleteHours",
                table: "CompanyConfigs");

            migrationBuilder.AlterColumn<decimal>(
                name: "Longitude",
                table: "LocalPOIs",
                type: "decimal(18,2)",
                nullable: true,
                oldClrType: typeof(decimal),
                oldType: "decimal(10,6)",
                oldNullable: true);

            migrationBuilder.AlterColumn<decimal>(
                name: "Latitude",
                table: "LocalPOIs",
                type: "decimal(18,2)",
                nullable: true,
                oldClrType: typeof(decimal),
                oldType: "decimal(10,6)",
                oldNullable: true);

            migrationBuilder.AlterColumn<decimal>(
                name: "AddressLookupLng",
                table: "CompanyConfigs",
                type: "decimal(18,2)",
                nullable: true,
                oldClrType: typeof(decimal),
                oldType: "decimal(10,6)",
                oldNullable: true);

            migrationBuilder.AlterColumn<decimal>(
                name: "AddressLookupLat",
                table: "CompanyConfigs",
                type: "decimal(18,2)",
                nullable: true,
                oldClrType: typeof(decimal),
                oldType: "decimal(10,6)",
                oldNullable: true);
        }
    }
}
