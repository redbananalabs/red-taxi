
using RedTaxi.Domain;

namespace RedTaxi.Interfaces
{
    public interface IGetBookingsRequestDto
    {
        DateTime From { get; set; }
        DateTime? To { get; set; }
    }

    public interface IListedUser
    {
        string ColorRGB { get; set; }
        string FullName { get; set; }
        int Id { get; set; }
        string RegNo { get; set; }
        string PhoneNumber { get; set; }
        AceRoles Role { get; set; }
        string RoleString { get; set; }
    }

    public interface IUserLocation
    {
        double Latitude { get; set; }
        double Longitude { get; set; }
        double Heading { get; set; }
        double Speed { get; set; }
    }
}
