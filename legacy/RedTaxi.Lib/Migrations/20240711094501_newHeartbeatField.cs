using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace AceTaxis.Migrations
{
    /// <inheritdoc />
    public partial class newHeartbeatField : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<DateTime>(
                name: "SmsPhoneHeartBeat",
                table: "MessagingNotifyConfig",
                type: "datetime2",
                nullable: true);

            migrationBuilder.AddColumn<int>(
                name: "CashCommissionRate",
                table: "AppUserProfiles",
                type: "int",
                nullable: false,
                defaultValue: 0);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "SmsPhoneHeartBeat",
                table: "MessagingNotifyConfig");

            migrationBuilder.DropColumn(
                name: "CashCommissionRate",
                table: "AppUserProfiles");
        }
    }
}
