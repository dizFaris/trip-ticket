using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace tripTicket.Services.Migrations
{
    /// <inheritdoc />
    public partial class ChangePasswordType : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.RenameColumn(
                name: "isCanceled",
                table: "Trips",
                newName: "IsCanceled");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.RenameColumn(
                name: "IsCanceled",
                table: "Trips",
                newName: "isCanceled");
        }
    }
}
