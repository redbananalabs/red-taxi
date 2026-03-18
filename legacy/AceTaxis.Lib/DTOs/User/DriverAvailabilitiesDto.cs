using AceTaxis.Domain;

namespace AceTaxis.DTOs.User
{
    public class DriverAvailabilitiesDto
    {
        public List<DriverAvailabilityDto> Drivers { get; set; } = new();
    }

    public class DriverAvailabilityDto
    {
        public int? Id { get; set; }
        public int UserId { get; set; }
        public string FullName { get; set; }
        public DateTime Date { get; set; }
        public string Description { get; set; }
        public string ColorCode { get; set; }
        public DriverAvailabilityType AvailabilityType { get; set; }
        public TimeSpan? From { get; set; } = new TimeSpan(0, 0, 0);
        public TimeSpan? To { get; set; } = new TimeSpan(0, 0, 0);
        public bool GiveOrTake { get; set; }
        public string AvailableHours
        {
            get 
            {
                var got = GiveOrTake ? " (+/-)" : string.Empty;
                if (!string.IsNullOrEmpty(Description))
                {
                    if(Description == "AM School Run Only" || Description == "PM School Run Only")
                        return $"({Description}) {got}";
                    else
                        return $"{From.Value.ToString(@"hh\:mm")} - {To.Value.ToString(@"hh\:mm")} {got} ({Description})"; 
                }
                else
                    return $"{From.Value.ToString(@"hh\:mm")} - {To.Value.ToString(@"hh\:mm")} {got}";
            }
        }
    }

    public class Availability
    {
        public Availability()
        {
            AvailableHours = new();
            UnAvailableHours = new();
            AllocatedHours = new();
        }
        public int UserId { get; set; }
        public string FullName { get; set; }
        public DateTime Date { get; set; }
        public string ColorCode { get; set; }
        public VehicleType VehicleType { get; set; }
        public List<Hours> AvailableHours { get; set; }
        public List<Hours> UnAvailableHours { get; set; }
        public List<Hours> AllocatedHours { get; set; }

    }

    public class Hours
    {
        public TimeSpan? From { get; set; } = new TimeSpan(7, 0, 0);
        public TimeSpan? To { get; set; } = new TimeSpan(17, 0, 0);
        public string Note { get; set; }
    }
}
