using RedTaxi.Domain.Enums;
using RedTaxi.Domain.Interfaces;

namespace RedTaxi.Domain.Entities;

public class UserProfile : ISoftDeletable
{
    public bool IsDeleted { get; set; }
    public DateTime? DeletedAt { get; set; }

    public int Id { get; set; }

    /// <summary>FK to ASP.NET Identity user.</summary>
    public int UserId { get; set; }

    public string? ColorCodeRGB { get; set; }
    public string? RegNo { get; set; }
    public VehicleType VehicleType { get; set; }
    public string? VehicleMake { get; set; }
    public string? VehicleModel { get; set; }
    public string? VehicleColour { get; set; }

    public bool IsSubstitute { get; set; }
    public decimal? CommissionRate { get; set; }
    public bool IsActive { get; set; }
    public bool ShowAllBookings { get; set; }
    public bool ShowHVSBookings { get; set; }
    public bool NonAce { get; set; }

    public CommsPlatform CommsPlatform { get; set; }

    // GPS / location
    public decimal? Heading { get; set; }
    public decimal? Speed { get; set; }

    // Push notifications
    public string? ChromeFCM { get; set; }

    // Session
    public DateTime? LastLogin { get; set; }

    // Display
    public string? FullName { get; set; }
    public string? PhoneNumber { get; set; }

    // Auth
    public string? Email { get; set; }
    public string? PasswordHash { get; set; }
    public UserRole Role { get; set; }
}
