using RedTaxi.Domain;
using RedTaxi.DTOs.LocalPOI;


namespace RedTaxi.DTOs.Booking
{
    public class GetBookingsResponseDto
    {
        public GetBookingsResponseDto()
        {
            Bookings = new List<PersistedBookingModel>();
        }
        public List<PersistedBookingModel> Bookings { get; set; }

        public bool Logout { get; set; }
    }


    public class KeywordSearchResponseDto
    {
        public int? FocusBookingId { get; set; }
        public List<ResultItem> Results { get; set; }

        public class ResultItem
        {
            public int BookingId { get; set; }

            public BookingScope? Scope { get; set; }

            public string CellText
            {
                get
                {
                    if (Scope == BookingScope.Account)
                        return Passenger;
                    else
                        return Pickup + " -- " + Destination;
                }
            }

            public DateTime PickupDate { get; set; }
            public DateTime? EndDate { get; set; }
            public string Pickup { get; set; }
            public int DurationMinutes { get; set; }
            public string Destination { get; set; }
            public string Passenger { get; set; }
            public int? UserId { get; set; }
            public string? Color { get; set; }
            public bool Cancelled { get; set; }
        }
    }

    public class GetPriceResponseDto
    {
        public bool FromBase { get; set; }
        public string Tariff { get; set; }

        public double DeadMileage { get; set; }
        public int DeadMinutes { get; set; }

        public double JourneyMileage { get; set; }
        public int JourneyMinutes { get; set; }


        public double TotalMileage { get { return Math.Round(DeadMileage + JourneyMileage,1); } }
        public int TotalMinutes { get { return DeadMinutes + JourneyMinutes; } }
        public double PriceAccount { get; set; }
        public double PriceDriver { get; set; }
        public string PriceReference { get; set; }

        public string MileageText 
        {
            get 
            {
                if (FromBase)
                {
                    return $"{TotalMileage:N1} Miles - (Dead Miles: {Math.Round(DeadMileage, 1)}) + (Trip Miles: {Math.Round(JourneyMileage, 1)})";
                }
                else
                {
                    return $"{TotalMileage:N1} Miles";
                }
                
                
            }
        }
        public string DurationText 
        {
            get 
            {
                var duration = new TimeSpan(0, TotalMinutes, 0);
                return $"{duration.Hours} Hour(s) {duration.Minutes} Minutes";
            }
        }

        public int Legs { get; set; }
    }

    public class GetLocalPoiResponseDto
    {
        public List<LocalPOIModel> POIs { get; set; }
    }
}
