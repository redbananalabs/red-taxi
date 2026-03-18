using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace AceTaxis.Migrations
{
    /// <inheritdoc />
    public partial class messagingNotifyConfig : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateTable(
                name: "MessagingNotifyConfig",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    DriverOnAllocate = table.Column<int>(type: "int", nullable: false),
                    DriverOnUnAllocate = table.Column<int>(type: "int", nullable: false),
                    CustomerOnAllocate = table.Column<int>(type: "int", nullable: false),
                    CustomerOnUnAllocate = table.Column<int>(type: "int", nullable: false),
                    DriverOnAmend = table.Column<int>(type: "int", nullable: false),
                    CustomerOnAmend = table.Column<int>(type: "int", nullable: false),
                    DriverOnCancel = table.Column<int>(type: "int", nullable: false),
                    CustomerOnCancel = table.Column<int>(type: "int", nullable: false),
                    CustomerOnComplete = table.Column<int>(type: "int", nullable: false),
                    IgnoreAccountNos = table.Column<string>(type: "nvarchar(max)", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_MessagingNotifyConfig", x => x.Id);
                });
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "MessagingNotifyConfig");
        }
    }
}
