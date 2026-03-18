using AceTaxis.Domain;
using AceTaxis.Interfaces;
using Microsoft.AspNetCore.Identity;
using System.ComponentModel.DataAnnotations;

namespace AceTaxis.DTOs.User.Responses
{
    public class UsersListResponseDto
    {
        public IList<ListedUser> Users { get; set; }

        public UsersListResponseDto()
        {
            Users = new List<ListedUser>();
        }
    }

    public class UserGPSResponseDto 
    {
        public int UserId { get; set; }
        public string Fullname { get; set; }
        public string RegNo { get; set; }
        public string HtmlColor { get; set; }
        public string Username { get; set; }

        public double Longitude { get; set; }
        public double Latitude { get; set; }
        public decimal Heading { get; set; }
        public double Speed { get; set; }
        public DateTime GpsLastUpdated { get; set; }
    }



    public class ListedUser : IListedUser
    {
        public int Id { get; set; }
        public string FullName { get; set; }
        public string PhoneNumber { get; set; }
        public string Email { get; set; }
        public string RegNo { get; set; }
        public string ColorRGB { get; set; }

        public AceRoles Role { get; set; }
        public string RoleString { get; set; }

        public DateTime? LastLogin { get; set; }

        public bool IsLockedOut { get; set; }
        public bool ShowAllBookings { get; set; }
        public bool NonAce { get; set; }

        public bool ShowHVSBookings { get; set; }
        public int CashCommisionRate { get; set; }

        public string? VehicleMake { get; set; }
        public string? VehicleModel { get; set; }
        public string? VehicleColour { get; set; }
        public VehicleType VehicleType { get; set; } = VehicleType.Unknown;
        public SendMessageOfType Comms { get; set; }
        public bool LockoutEnabled { get; set; }
        public string? Username { get; set; }
    }
}
