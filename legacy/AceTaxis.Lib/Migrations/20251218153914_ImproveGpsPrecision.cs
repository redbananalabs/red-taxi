using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace AceTaxis.Migrations
{
    /// <inheritdoc />
    public partial class ImproveGpsPrecision : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AlterColumn<decimal>(
                name: "Speed",
                table: "DriverLocationHistories",
                type: "decimal(6,2)",
                precision: 6,
                scale: 2,
                nullable: true,
                oldClrType: typeof(double),
                oldType: "float");

            migrationBuilder.AlterColumn<decimal>(
                name: "Longitude",
                table: "DriverLocationHistories",
                type: "decimal(10,7)",
                precision: 10,
                scale: 7,
                nullable: true,
                oldClrType: typeof(double),
                oldType: "float");

            migrationBuilder.AlterColumn<decimal>(
                name: "Latitude",
                table: "DriverLocationHistories",
                type: "decimal(9,7)",
                precision: 9,
                scale: 7,
                nullable: true,
                oldClrType: typeof(double),
                oldType: "float");

            migrationBuilder.AlterColumn<decimal>(
                name: "Heading",
                table: "DriverLocationHistories",
                type: "decimal(6,3)",
                precision: 6,
                scale: 3,
                nullable: true,
                oldClrType: typeof(double),
                oldType: "float");

            migrationBuilder.AlterColumn<decimal>(
                name: "Speed",
                table: "AppUserProfiles",
                type: "decimal(6,2)",
                precision: 6,
                scale: 2,
                nullable: true,
                oldClrType: typeof(double),
                oldType: "float(12)",
                oldPrecision: 12,
                oldScale: 12,
                oldNullable: true);

            migrationBuilder.AlterColumn<decimal>(
                name: "Longitude",
                table: "AppUserProfiles",
                type: "decimal(10,7)",
                precision: 10,
                scale: 7,
                nullable: true,
                oldClrType: typeof(double),
                oldType: "float(12)",
                oldPrecision: 12,
                oldScale: 12,
                oldNullable: true);

            migrationBuilder.AlterColumn<decimal>(
                name: "Latitude",
                table: "AppUserProfiles",
                type: "decimal(9,7)",
                precision: 9,
                scale: 7,
                nullable: true,
                oldClrType: typeof(double),
                oldType: "float(12)",
                oldPrecision: 12,
                oldScale: 12,
                oldNullable: true);

            migrationBuilder.AlterColumn<decimal>(
                name: "Heading",
                table: "AppUserProfiles",
                type: "decimal(6,3)",
                precision: 6,
                scale: 3,
                nullable: true,
                oldClrType: typeof(decimal),
                oldType: "decimal(12,12)",
                oldPrecision: 12,
                oldScale: 12,
                oldNullable: true);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AlterColumn<double>(
                name: "Speed",
                table: "DriverLocationHistories",
                type: "float",
                nullable: false,
                defaultValue: 0.0,
                oldClrType: typeof(decimal),
                oldType: "decimal(6,2)",
                oldPrecision: 6,
                oldScale: 2,
                oldNullable: true);

            migrationBuilder.AlterColumn<double>(
                name: "Longitude",
                table: "DriverLocationHistories",
                type: "float",
                nullable: false,
                defaultValue: 0.0,
                oldClrType: typeof(decimal),
                oldType: "decimal(10,7)",
                oldPrecision: 10,
                oldScale: 7,
                oldNullable: true);

            migrationBuilder.AlterColumn<double>(
                name: "Latitude",
                table: "DriverLocationHistories",
                type: "float",
                nullable: false,
                defaultValue: 0.0,
                oldClrType: typeof(decimal),
                oldType: "decimal(9,7)",
                oldPrecision: 9,
                oldScale: 7,
                oldNullable: true);

            migrationBuilder.AlterColumn<double>(
                name: "Heading",
                table: "DriverLocationHistories",
                type: "float",
                nullable: false,
                defaultValue: 0.0,
                oldClrType: typeof(decimal),
                oldType: "decimal(6,3)",
                oldPrecision: 6,
                oldScale: 3,
                oldNullable: true);

            migrationBuilder.AlterColumn<double>(
                name: "Speed",
                table: "AppUserProfiles",
                type: "float(12)",
                precision: 12,
                scale: 12,
                nullable: true,
                oldClrType: typeof(decimal),
                oldType: "decimal(6,2)",
                oldPrecision: 6,
                oldScale: 2,
                oldNullable: true);

            migrationBuilder.AlterColumn<double>(
                name: "Longitude",
                table: "AppUserProfiles",
                type: "float(12)",
                precision: 12,
                scale: 12,
                nullable: true,
                oldClrType: typeof(decimal),
                oldType: "decimal(10,7)",
                oldPrecision: 10,
                oldScale: 7,
                oldNullable: true);

            migrationBuilder.AlterColumn<double>(
                name: "Latitude",
                table: "AppUserProfiles",
                type: "float(12)",
                precision: 12,
                scale: 12,
                nullable: true,
                oldClrType: typeof(decimal),
                oldType: "decimal(9,7)",
                oldPrecision: 9,
                oldScale: 7,
                oldNullable: true);

            migrationBuilder.AlterColumn<decimal>(
                name: "Heading",
                table: "AppUserProfiles",
                type: "decimal(12,12)",
                precision: 12,
                scale: 12,
                nullable: true,
                oldClrType: typeof(decimal),
                oldType: "decimal(6,3)",
                oldPrecision: 6,
                oldScale: 3,
                oldNullable: true);
        }
    }
}
