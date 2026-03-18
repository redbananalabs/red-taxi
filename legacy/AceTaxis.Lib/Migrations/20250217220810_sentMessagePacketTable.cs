using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace AceTaxis.Migrations
{
    /// <inheritdoc />
    public partial class sentMessagePacketTable : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "ManuallyPriced",
                table: "Bookings");

            migrationBuilder.CreateTable(
                name: "SentMessagePackets",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    UserId = table.Column<int>(type: "int", nullable: false),
                    BookingId = table.Column<int>(type: "int", nullable: true),
                    FcmOrPhoneNo = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    MessageType = table.Column<int>(type: "int", nullable: false),
                    SentByType = table.Column<int>(type: "int", nullable: false),
                    SentAt = table.Column<DateTime>(type: "datetime2", nullable: false),
                    MessageText = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    MessageData = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    Response = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    Status = table.Column<int>(type: "int", nullable: false),
                    ResendCount = table.Column<int>(type: "int", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_SentMessagePackets", x => x.Id);
                });
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "SentMessagePackets");

            migrationBuilder.AddColumn<bool>(
                name: "ManuallyPriced",
                table: "Bookings",
                type: "bit",
                nullable: false,
                defaultValue: false);
        }
    }
}
