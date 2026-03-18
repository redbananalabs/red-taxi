using AceTaxis.Data.Models;
using AceTaxis.Domain;
using AceTaxis.Interfaces;
using Newtonsoft.Json;
using System.ComponentModel;
using System.ComponentModel.DataAnnotations;
using System.Diagnostics.CodeAnalysis;
using System.Globalization;
using static AceTaxis.DTOs.Booking.AvailableHours;

namespace AceTaxis.DTOs.Booking
{
    public class CreatedBookingResultDto
    {
        public int BookingId { get; set; }
        public DateTime Date { get; set; }
        public string Passenger { get; set; }
        public string BookedBy { get; set; }
        public int AccNo { get; set; }
    }

    public class SendQuoteDto : ModelValidator
    {
        public string? Subject { get; set; } = "Ace Taxis - Quotation";

        [Required]
        public DateTime Date { get; set; }
        [Required]
        public string Pickup { get; set; }

        public List<string> Vias { get; set; }
        [Required]
        public string Destination { get; set; }
        [Required]
        public string Passenger { get; set; }
        [Required]
        public int Passengers { get; set; }
        [Required]
        public double Price { get; set; }

        public string Phone { get; set; }
        public string Email { get; set; }
        public DateTime? ReturnTime { get; set; }
        public double? ReturnPrice { get; set; }
    }

    public class WebBookingAcceptDto : ModelValidator
    {
        [Required]
        public int Id { get; set; }

        [Required]
        public string ByName { get; set; }

        [Required]
        public string RequiredTime { get; set; }

        public double Price { get; set; }

    }

    public class WebBookingRejectDto : ModelValidator
    {
        [Required]
        public int Id { get; set; }

        [Required]
        public string ByName { get; set; }

        [Required]
        public string? Reason { get; set; }
    }

    public class WebBookingAmendAcceptDto : ModelValidator
    {
        [Required]
        public int Id { get; set; }

        [Required]
        public string ByName { get; set; }

        [Required]
        public DateTime PickupDateTime { get; set; }

        [Required]
        public int Passengers { get; set; }

        [Required]
        public int Vehicles { get; set; } = 1;
    }



    public class WebBookingDto : ModelValidator
    {
        [Required]
        public int AccNo { get; set; }
        [Required]
        public DateTime PickupDateTime { get; set; }
        public bool ArriveBy { get; set; }

        public string? RecurrenceRule { get; set; } = string.Empty;

        [Required]
        [MaxLength(250)]
        public string PickupAddress { get; set; } = string.Empty;

        [Required]
        [StringLength(9, ErrorMessage = "Pickup postcode should not exceed 9 characters")]
        [MaxLength(9)]
        public string PickupPostCode { get; set; } = string.Empty;

        [Required]
        [MaxLength(250)]
        public string DestinationAddress { get; set; } = string.Empty;

        [Required]
        [StringLength(9, ErrorMessage = "Destination postcode should not exceed 9 characters")]
        [MaxLength(9)]
        public string DestinationPostCode { get; set; } = string.Empty;

        [MaxLength(2000)]
        public string? Details { get; set; } = string.Empty;

        [Required]
        [MaxLength(250)]
        public string? PassengerName { get; set; } = string.Empty;

        public int Passengers { get; set; }

        [MaxLength(20)]
        public string? PhoneNumber { get; set; } = string.Empty;

        [MaxLength(250)]
        public string? Email { get; set; } = string.Empty;
    }

    public class CashWebBookingDto : WebBookingDto
    {
        public BookingScope? Scope { get; set; }
        public int Passengers { get; set; }
        public int Luggage { get; set; }

        public int DurationMinutes { get; set; }
        public decimal? Mileage { get; set; }
        public string? MileageText { get; set; }
        public string? DurationText { get; set; }
        public double Price { get; set; }

    }

    public class RankBookingDto
    {
        public string Pickup { get; set; }
        public string PickupPostcode { get; set; }
        public string Destination { get; set; }
        public string DestinationPostcode { get; set; }
        public string Name { get; set; }
        public int Userid { get; set; }

        public int DurationMinutes { get; set; }
        public decimal? Mileage { get; set; }
        public string? MileageText { get; set; }
        public string? DurationText { get; set; }
        public double Price { get; set; }
    }

    public class AccountPassengerDto : ModelValidator
    {
        public int Id { get; set; }

        [Required]
        public int AccNo { get; set; }

        [Required]
        public string Description { get; set; }
        [Required]
        public string Passenger { get; set; }
        [Required]
        public string Address { get; set; }
        [Required]
        public string Postcode { get; set; }
        
        public string? Phone { get; set; }
        public string? Email { get; set; }
    }

    /// <summary>
    /// Core class which inherits ModelValidator
    /// </summary>
    public class BookingModel : ModelValidator, IBookingModel
    {
        public BookingModel()
        {
            BookedByName = string.Empty;
            PassengerName = string.Empty;
            BookedByName = string.Empty;
            Email = string.Empty;
            PhoneNumber = string.Empty;
        }

        public DateTime DateCreated { get; set; }

        // interface members
        [JsonProperty]
        [Display(Prompt = "Booked By", Name = "BookdBy")]
        [DefaultValue("")]
        public string BookedByName { get; set; } = string.Empty;

        [Display(Prompt = "Cancelled", Name = "Cancelled")]
        public bool Cancelled { get; set; }

        [Display(Prompt = "Enter full details of this booking", Name = "Details")]
        [DataType(DataType.MultilineText)]
        [MaxLength(2000)]
        [DefaultValue("")]
        public string Details { get; set; } = string.Empty;

        [Display(Prompt = "Customer email", Name = "Email")]
        [DefaultValue("")]
        public string Email { get; set; } = string.Empty;

        [Display(Prompt = "Duration in minutes", Name = "Duration")]
        [DefaultValue(0)]
        public int DurationMinutes { get; set; }

        [Display(Prompt = "Is All Day", Name = "AllDay")]
        public bool IsAllDay { get; set; }

        [Display(Prompt = "Passenger Name", Name = "Passenger Name")]
        [DefaultValue("")]
        public string? PassengerName { get; set; } = string.Empty;

        [Display(Prompt = "Number of Passengers", Name = "Passengers")]
        [DefaultValue(1)]
        public int Passengers { get; set; } = 1;

        [Display(Prompt = "Select payment status", Name = "£ Status", GroupName = "Options")]
        [AllowNull]
        public PaymentStatus? PaymentStatus { get; set; }

        [Display(Prompt = "Is booking confirmed?", Name = "Confirmed", GroupName = "Options")]
        [AllowNull]
        public ConfirmationStatus? ConfirmationStatus { get; set; }

        [Display(Prompt = "Booking scope", Name = "Scope", GroupName = "Options")]
        [AllowNull]
        public BookingScope? Scope { get; set; }

        [Display(Prompt = "Customer telephone", Name = "Phone")]
        [MaxLength(20)]
        [DefaultValue("")]
        public string PhoneNumber { get; set; } = string.Empty;

        [Display(Prompt = "Enter pickup address", Name = "Pickup Address", GroupName = "Pickup Details")]
        [MaxLength(250)]
        [DefaultValue("")]
        public string PickupAddress { get; set; } = string.Empty;

        [Required]
        [Display(Name = "Date", GroupName = "Pickup Details")]
        public DateTime PickupDateTime { get; set; }

        public DateTime? ArriveBy { get; set; }

        [Display(Prompt = "Enter pickup postcode", Name = "Pickup Postcode", GroupName = "Pickup Details")]
        [StringLength(9, ErrorMessage = "Pickup postcode should not exceed 9 characters")]
        [MaxLength(9)]
        [DefaultValue("")]
        public string PickupPostCode { get; set; } = string.Empty;

        [Display(Prompt = "Enter destination address", Name = "Destination Address", GroupName = "Destination Details")]
        [MaxLength(250)]
        [DefaultValue("")]
        public string DestinationAddress { get; set; } = string.Empty;

        [Display(Prompt = "Enter destination postcode", Name = "Destination Postcode", GroupName = "Destination Details")]
        [StringLength(9, ErrorMessage = "Destination postcode should not exceed 9 characters")]
        [MaxLength(9)]
        [DefaultValue("")]
        public string DestinationPostCode { get; set; } = string.Empty;

        public List<BookingVia> Vias { get; set; } = new List<BookingVia>();


        public string? RecurrenceException { get; set; }
        public int? RecurrenceID { get; set; }
        public string? RecurrenceRule { get; set; }
        public string UpdatedByName { get; set; } = string.Empty;
        public string CancelledByName { get; set; } = string.Empty;
        
        public decimal Price { get; set; }
        public bool ManuallyPriced { get; set; }
        public decimal PriceDiscount { get; set; }
        public decimal PriceAccount { get; set; }
        public decimal? Mileage { get; set; }
        public string? MileageText { get; set; }
        public string? DurationText { get; set; }

        public bool ChargeFromBase { get; set; }
        public int ActionByUserId { get; set; }

        public int? AccountNumber { get; set; }
        public decimal ParkingCharge { get; set; }
        public int WaitingTimeMinutes { get; set; }

        public DateTime? PaymentLinkSentOn { get; set; }
        public string? PaymentLinkSentBy { get; set; }
        public bool IsASAP { get; set; } = false;
    }


    public class ActiveBookingDataDto
    {
        public int Id { get; set; }
        public int BookingId { get; set; }
        public DateTime DateTime { get; set; }
        public string PassengerName { get; set; }
        public string PickupAddress { get; set; }
        public string DestinationAddress { get; set; }
        public int? RecurranceId { get; set; }
        public bool ApplyToBlock { get; set; }
        public bool ChangesPending { get; set; }
    }

    public class ActiveBookingAmendDto : ActiveBookingDataDto
    {
        public string? Amendments { get; set; }
        public bool CancelBooking { get; set; } = false;
        public DateTime RequestedOn { get; set; }
    }


    /// <summary>
    /// Inherits BookingModel and ModelValidator
    /// </summary>
    public class PersistedBookingModel : BookingModel, IBookingModel, IPersistedBookingModel
    {
        // returned fields from user
        public string? RegNo { get; set; } = string.Empty;
        public string? BackgroundColorRGB { get; set; }
        public string? Fullname { get; set; }

        public int BookingId { get; set; }
        public int? UserId { get; set; }
        public int? SuggestedUserId { get; set; }

        public bool CancelledOnArrival { get; set; }

        public string CellText 
        { 
            get 
            {
                var mpv = Passengers > 4 ? "(MPV): " : "";
                var status = string.Empty;

                if (Status != null)
                {
                    if (Status == BookingStatus.RejectedJob)
                    {
                        status = "[R]";
                    }
                    else if (Status == BookingStatus.RejectedJobTimeout)
                    {
                        status = "[RT]";
                    }
                    else if (Status == BookingStatus.Complete)
                    {
                        if (Scope != BookingScope.Account)
                            status = "[C]";
                    }
                }

                if (CancelledOnArrival)
                {
                    if (Scope == BookingScope.Account)
                        return "COA - " + mpv + PassengerName;
                    else
                        return "COA - " + mpv + PickupAddress + " -- " + DestinationAddress;
                }
                else
                {
                    if (Scope == BookingScope.Account)
                        return status + " " + mpv + PassengerName;
                    else
                        return status + " " + mpv + PickupAddress + " -- " + DestinationAddress;
                }
            } 
        }

        [JsonIgnore]
        public string HasDetails
        {
            get 
            {
                return !string.IsNullOrEmpty(Details) ? "*" : "";
            }
        }

        [JsonIgnore]
        public BookingStatus? Status {  get; set; } 

        //[JsonIgnore]
        //public string? BookedOn
        //{
        //    get
        //    {
        //        return "todo";
        //    }
        //}

        //[JsonIgnore]
        //public string? ManuallyPriced
        //{
        //    get
        //    {
        //        return "todo";
        //    }
        //}

        //[JsonIgnore]

        //public string? ChargeFromBase
        //{
        //    get
        //    {
        //        return "todo";
        //    }
        //}

        public DateTime? EndTime
        {
            get
            {
                if (DurationMinutes < 20)
                {
                    return PickupDateTime.AddMinutes(20);
                }
                else
                {
                    return PickupDateTime.AddMinutes(DurationMinutes);
                }
            }
        }
    }

    public class GetPickupHistoryResponseDto
    {
        public string Address { get; set; }
        public string Postcode { get; set; }
        public string PhoneNo { get; set; }
        public string Name { get; set; }
        public string EmailAddress { get; set; }
    }

    public class JourneyDetails
    {
        public double Miles { get; set; }
        public int Minutes { get; set; }
        public string MileageText { get; set; }
        public string DurationText { get; set; }

        public string StartPostcode { get; set; }
        public string EndPostcode { get; set; }
    }

    public class DriverEarnings
    {
        public int Id { get; set; }
        public string Fullname { get; set; }

        public double CommsRate { get; set; }

        public string Identifier { get { return $"{Id} - {Fullname}"; } }

        public double Earnings { get { return AccEarned + CashEarned + RankEarned; } }

        /// <summary>
        /// Admin property
        /// </summary>
        public double CommissionCash 
        {
            get
            {
                double total = 0;
                if (CashEarned > 0)
                    total = ((double)CashEarned / 100) * CommsRate;

                return total;
            }
        }

        /// <summary>
        /// Admin property
        /// </summary>
        public double CommissionRank 
        {
            get
            {
                double total = 0;
                if (RankEarned > 0)
                    total = ((double)RankEarned / 100) * CommsRate;

                return total;
            }
        }

        public double Commission 
        { 
            get 
            {
                double total = 0;
                if(CashEarned > 0)
                    total = ((double)CashEarned / 100) * CommsRate; 
                if(RankEarned > 0)
                    total += ((double)RankEarned / 100) * 7.5;

                return total;
            } 
        }

        public int JobsCount { get; set; }
        public string DateRange { get; set; }
        public string ColourCode { get; set; }
        public double RankEarned { get; set; }
        public double CashEarned { get; set; }
        public double AccEarned { get; set; }

        /// <summary>
        /// Driver property
        /// </summary>
        public double TakeHome 
        {
            get
            {
                return (Earnings - Commission);
            }
        }
    }

    public class JobsBookedToday
    {
        public string BookedBy { get; set; }
        public int AccountJobs { get; set; }
        public int CashJobs { get; set; }
        public int RankJobs { get; set; }
        public int Total { get { return AccountJobs + CashJobs + RankJobs; } }
    }

    public class DashCounts
    {
        public int UnallocatedTodayCount { get; set; }
        public int BookingsCount { get; set; }
        public int POIsCount { get; set; }
        public int DriversCount { get; set; }
    }

    public class AllocationReply
    {
        public string Time { get; set; }
        public int JobNo { get; set; }
        public string ColourCode { get; set; }
        public string Driver { get; set; }
        public string Pickup { get; set; }
        public string Passenger{ get; set; }
        public string Response { get; set; }
    }

    public class AllocationStatus : AllocationReply
    {
        
    }

    public class CustomerCounts
    {
        public int New { get; set; }
        public int Returning { get; set; }
        public Period PeriodWhen { get; set; }

        public enum Period
        {
            Day,
            Week,
            Month
        }
    }

    public class JobCompletedDetail
    {
        public int BookingId { get; set; }
        public double CommsRate { get; set; }
        public string Pickup { get; set; }
        public string Passenger { get; set; }
        public double Price { get; set; }
        public BookingScope Scope { get; set; }
        public double Commission 
        { 
            get 
            {
                if (Price > 0 && (Scope == BookingScope.Cash || Scope == BookingScope.Card))
                {
                    return ((double)Price / 100) * CommsRate;
                }
                else if (Price > 0 && Scope == BookingScope.Rank)
                {
                    return ((double)Price / 100) * 7.5;
                }

                return 0;
            }
        }
    }

    public class EarningsBreakdown 
    {
        public EarningsBreakdown()
        {
            JobDetails = new List<JobCompletedDetail>();
        }

        public string Date { get; set; }
        public double CommsRate { get; set; }
        public int JobsCount { get; set; }
        public double CashTotal { get; set; }
        public double AccountTotal { get; set; }
        public double RankTotal { get; set; }

        public double EarnedTotal { 
            get 
            {
                return CashTotal + AccountTotal + RankTotal;
            } 
        }

        public double CommisionTotal 
        {
            get
            {
                double total = 0;
                if (CashTotal > 0)
                    total = ((double)CashTotal / 100) * CommsRate;
                if (RankTotal > 0)
                    total += ((double)RankTotal / 100) * 7.5;

                return total;
            }
        }

        public double TakeHome
        {
            get
            {
                return (EarnedTotal - CommisionTotal);
            }
        }

        public List<JobCompletedDetail> JobDetails { get; set; }
    }

    public class DriverTotalsForDateRange
    {
        public DriverTotalsForDateRange()
        {
            Earnings = new List<EarningsBreakdown>();
        }
        public List<EarningsBreakdown> Earnings { get; set; }

        public int CashJobs { get; set; }
        public int AccountJobs { get; set; }
        public int RankJobs { get; set; }
    }

    public class UpdateChargesDataDto : ModelValidator
    {
        [Required]
        public int BookingId { get; set; }
        public int WaitingMinutes { get; set; }
        public double ParkingCharge { get; set; }
        public double PriceAccount{ get; set; }
        public double Price { get; set; }
    }

    public class DriverTotalsToday
    {
        public DriverTotalsToday()
        {
            Jobs = new List<JobCompletedDetail>();
        }

        public int TotalJobCount { get { return JourneyJobCount + SchoolRunJobCount; } }
        public int JourneyJobCount { get; set; }
        public int SchoolRunJobCount { get; set; }

        public double EarnedTodayTotal { get; set; }

        public List<JobCompletedDetail> Jobs { get; set; }
    }

    public class ChargeableJob 
    {
        public ChargeableJob()
        {
            Vias = new List<BookingVia>();
        }

        public int? AccNo { get; set; }
        public int BookingId { get; set; }
        public int UserId { get; set; }
        public DateTime Date { get; set; }
        public int Passengers { get; set; }
        public string Pickup { get; set; }
        public string PickupPostcode { get; set; }
        public string Destination { get; set; }
        public string DestinationPostcode { get; set; }
        public List<BookingVia>? Vias { get; set; }
        public bool HasVias { 
            get 
            { 
                if(Vias == null)
                    return false;
                else
                    return Vias.Any(); 
            }
        }
        public string? Passenger { get; set; }
        public double Price { get; set; }
        public BookingScope? Scope { get; set; } 
        public bool Cancelled { get; set;}
        public bool COA { get; set; }
        public VehicleType VehicleType { get; set; }
        public double PriceAccount { get; set; }
        public string Details { get; set; }
        public bool HasDetails { get { return !string.IsNullOrEmpty(Details); } }
        public int WaitingMinutes { get; set; }
        public PaymentStatus? PaymentStatus { get; set; }

        public string WaitingTime 
        { 
            get 
            {
                var str = string.Empty;

                if (WaitingMinutes > 0)
                {
                    str = TimeSpan.FromMinutes(WaitingMinutes).ToString(@"hh\:mm");
                }

                return str;
            } 
        }

        public double WaitingPriceDriver
        {
            get
            {
                var permin = 0.32;
                var sum = WaitingMinutes * permin;
                return sum;
            }
        }

        public double WaitingPriceAccount
        {
            get 
            {
                var permin = 0.42;
                var sum = WaitingMinutes * permin;
                return sum;
            }
        }

        public double ParkingCharge { get; set; }

        public double TotalCharge { get { return PriceAccount + WaitingPriceAccount + ParkingCharge; } }

        public double TotalCost { get { return Price + WaitingPriceDriver + ParkingCharge; } }

        public bool PostedForInvoicing { get; set; }

        public bool PostedForStatement { get; set; }

        public double Miles { get; set; }
    }

    public class ChargableHvsGroup
    {
        // single journeys
        public List<ChargeableJobGroup> Singles { get; set; }

        // shared journeys
        public List<ChargeableGroup> Shared { get; set; }
    }

    public class ChargeableGroup
    {
        public string GroupName { get; set; }
        public List<ChargeableJob> Jobs { get; set; } = new();
    }

    //
    public class ChargeableJobGroup
    {
        public string? Passenger { get; set; }
        public List<PickupGroup> PickupGroups { get; set; } = new();
    }

    public class PickupGroup
    {
        public string Pickup { get; set; }
        public List<DestinationGroup> DestinationGroups { get; set; } = new();
    }

    public class DestinationGroup
    {
        public string Destination { get; set; }
        public List<ChargeableJob> Jobs { get; set; } = new();
    }
    //

    public class DriverInvoiceStatementDto : IDriverInvoiceStatement
    {
        public int AccountJobsTotalCount { get; set; }
        public int CashJobsTotalCount { get; set; }
        public double CommissionDue { get; set; }
        public DateTime DateCreated { get; set; }
        public DateTime? DateUpdated { get; set; }
        public double EarningsAccount { get; set; }
        public double EarningsCash { get; set; }
        public double EarningsCard { get; set; }
        public double EarningsRank { get; set; }
        public double CardFees { get; set; }
        public DateTime EndDate { get; set; }
        public bool PaidInFull { get; set; }
        public double PaymentDue { get { return (EarningsAccount + EarningsCard) - CommissionDue; } }
        public int RankJobsTotalCount { get; set; }
        public DateTime StartDate { get; set; }
        public int StatementId { get; set; }
        public double SubTotal { get; set; }
        public double TotalEarned { get { return (EarningsAccount + EarningsCash + EarningsCard + EarningsRank); } }
        public int TotalJobCount { get { return AccountJobsTotalCount + CashJobsTotalCount; } }
        public int UserId { get; set; }
        public string Identifier { get; set; }
        public string ColorCode { get; set; }
        public List<ChargeableJob> Jobs { get; set; } = new List<ChargeableJob>();


    }

    public class DriverIdentifer
    {
        public int UserId { get; set; }
        public string ColorCode { get; set; }
        public string FullName { get; set; }
    }

    public class EarningsModelTotalsDto
    {
        public DateTime Date { get; set; }
        public int UserId { get; set; }
        public double CashTotal { get; set; }
        public double AccTotal { get; set; }
        public double RankTotal { get; set; }
        public double CommsTotal { get; set; }
        public double GrossTotal { get; set; }
        public double NetTotal { get; set; }

        public int CashJobsCount { get; set; }
        public int AccJobsCount { get; set; }
        public int RankJobsCount { get; set; }

        
        public decimal? CashMilesCount { get; set; }
        public decimal? AccMilesCount { get; set; }
        public decimal? RankMilesCount { get; set; }

    }

    public class JobsCountModelDto
    {
        public int CashJobsCount { get; set; }
        public int AccJobsCount { get; set; }
        public int RankJobsCount { get; set; }

        public int Total { get { return CashJobsCount + AccJobsCount + RankJobsCount; } }
    }

    public class MileageCountModelDto
    {
        public decimal? CashMilesCount { get; set; }
        public decimal? AccMilesCount { get; set; }
        public decimal? RankMilesCount { get; set; }

        public decimal? Total { get { return CashMilesCount + AccMilesCount + RankMilesCount; } }
    }

    public class EarningsModelDto
    {
        public DateTime Date { get; set; }
        public int? UserId { get; set; }
        public decimal? Price { get; set; }
        public BookingScope? Scope { get; set; }
        public decimal? WaitingPrice { get; set; }
        public decimal? Mileage { get; set; }
    }

    public class AccountInvoiceDto
    {
        public AccountInvoiceDto()
        {
            Items = new();
        }

        public string CompanyNo { get; set; }
        public string VatNo { get; set; }


        public int InvoiceNumber { get; set; }
        public string OrderNo { get; set; }
        public string Reference { get; set; }
        public string AccNo { get; set; }

        public decimal Net { get; set; }
        public decimal Vat { get; set; }
        public decimal Total { get; set; }

        public bool Paid { get; set; }

        public DateTime InvoiceDate { get; set; }
        
        public Address CustomerAddress { get; set; }

        public List<JourneyItem> Items { get; set; }

        public string Comments { get; set; }

        public class Address
        {
            public string ContactName { get; set; }
            public string BusinessName { get; set; }
            public string Address1 { get; set; }
            public string Address2 { get; set; }
            public string Address3 { get; set; }
            public string Address4 { get; set; }
            public string Postcode { get; set; }
        }
    }

    public class JourneyItem
    {
        public string JobNo { get; set; }

        public DateTime Date { get; set; }
        public string Passenger { get; set; }
        public string Pickup { get; set; }
        public string Destination { get; set; }
        public string WaitingTime { get; set; }

        public double Waiting { get; set; }
        public double Parking { get; set; }
        public double Journey { get; set; }

        public double Total { get { return Waiting + Parking + Journey; } }
        public double TotalInc { get { return Total + (Waiting + Parking + Journey) * 0.2; } }

        public bool COA { get; set; }
    }


    public class AccountModel
    {
        public int AccNo { get; set; }
        public string AccountName { get; set; }
    }

    public class AirportSearchModel
    {
        public AirportSearchModel()
        {
            LastAirports = new();
        }
        public List<LastTripModel> LastAirports { get; set; }

        public class LastTripModel
        {
            public int UserId { get; set; }
            public string Fullname { get; set; }
            public string Identifier { get { return $"{UserId} - {Fullname}"; } }
            public string Color { get; set; }
            public string Pickup { get; set; }
            public string Destin { get; set; }
            public DateTime Date { get; set; }
            public double Price { get; set; }
        }
    }

    public class CallNotificationDto
    {
        public string caller_id { get; set; }
        public string recipient_id { get; set; }
    }

    public class CompleteJobRequestDto : ModelValidator
    {
        [Required]
        public int BookingId { get; set; }
        
        [Required]
        public int WaitingTime { get; set; }
        public double ParkingCharge { get; set; }
        [Required]
        public double DriverPrice { get; set; }
        public double AccountPrice { get; set; }
        public double Tip { get; set; }
    }

    public class RabbitMessagePacket
    {
        public string Telephone { get; set; }
        public string Message { get; set; }
    }

    public class GetAvailabilityReportDto : ModelValidator
    {
        public int UserId { get; set; }

        [Required]
        public DateTime StartDate { get; set; }
        [Required]
        public DateTime EndDate { get; set; }
    }

    public class AvailabilityReportDto
    {
        public int UserId { get; set; }
        public List<AvailableHours> AvailableHoursByDay { get; set; } = new();
        public List<UserWeekdayHours> WeekDay { get; set; } = new();
        public List<UserWeekendHours> WeekEnd { get; set; } = new();
        public List<UserWeekHours> Week { get; set; } = new();
        public List<UserMonthHours> Month { get; set; } = new();
        public List<UnAvailableDatesDto> Unavailable { get; set; } = new();
    }

    public class UnAvailableDatesDto
    {
        public int UserId { get; set; }
        public List<DateTime> UnAvailableDates { get; set; } = new();
        public int TotalUnAvailableDays { get { return UnAvailableDates.Count; } }
    }

    public class AvailableHours
    {
        public int UserId { get; set; }
        public DateTime Date { get; set; }
        public double HoursAvailable { get; set; }

        #region week
        // Record to represent the total hours for a user in a specific week
        public record UserWeekHours(int UserId, int Week, double TotalHours);

        // Main method to calculate total hours per week
        /// <summary>
        /// 
        /// </summary>
        /// <param name="availableHours"></param>
        /// <returns>Key as UserId</returns>
        public List<UserWeekHours> CalculateTotalHoursByWeek(List<AvailableHours> availableHours)
        {
            var groupedByUserAndWeek = GroupByUserAndWeek(availableHours);
            return CalculateTotalHoursForEachUserWeek(groupedByUserAndWeek);
        }

        // Step 1: Group records by UserId and Week of the year using the record
        private IEnumerable<IGrouping<(int UserId, int Week), AvailableHours>> GroupByUserAndWeek(List<AvailableHours> availableHours)
        {
            return availableHours
                .GroupBy(ah => (ah.UserId, GetWeekOfYear(ah.Date)));
        }

        // Step 2: Calculate total hours for each user and week, and return a list of UserWeekHours records
        private List<UserWeekHours> CalculateTotalHoursForEachUserWeek(IEnumerable<IGrouping<(int UserId, int Week), AvailableHours>> groupedByUserAndWeek)
        {
             return groupedByUserAndWeek
               .Select(group => new UserWeekHours(
                group.Key.UserId,                   // UserId from the grouping key
                group.Key.Week,                     // Week number from the grouping key
              group.Sum(ah => ah.HoursAvailable)  // Total hours for this user and week
              ))
             .ToList(); // Create a flat list
        }

        #endregion

        #region month

        // Record to represent the total hours for a user in a specific month
        public record UserMonthHours(int UserId, int Month, double TotalHours);

        // Main method to calculate total hours per month
        /// <summary>
        /// 
        /// </summary>
        /// <param name="availableHours"></param>
        /// <returns>Key as UserId</returns>
        public List<UserMonthHours> CalculateTotalHoursByMonth(List<AvailableHours> availableHours)
        {
            var groupedByUserAndMonth = GroupByUserAndMonth(availableHours);
            return CalculateTotalHoursForEachUserMonth(groupedByUserAndMonth);
        }

        // Step 1: Group records by UserId and Month
        private IEnumerable<IGrouping<(int UserId, int Month), AvailableHours>> GroupByUserAndMonth(List<AvailableHours> availableHours)
        {
            return availableHours
                .GroupBy(ah => (ah.UserId, ah.Date.Month)); // Group by UserId and Month
        }

        // Step 2: Calculate total hours for each user and month, and return a list of UserMonthHours records
        private List<UserMonthHours> CalculateTotalHoursForEachUserMonth(IEnumerable<IGrouping<(int UserId, int Month), AvailableHours>> groupedByUserAndMonth)
        {
               return groupedByUserAndMonth
               .Select(group => new UserMonthHours(
                   group.Key.UserId,                   // UserId from the grouping key
                   group.Key.Month,                    // Month from the grouping key
                   group.Sum(ah => ah.HoursAvailable)  // Total hours for this user and month
               ))
               .ToList(); // Create a flat list
        }

        #endregion month

        #region week day
        // Record to represent the total hours for a user on a specific weekday
        public record UserWeekdayHours(int UserId, DayOfWeek Day, double TotalHours);

        // Main method to calculate total hours per weekday
        public List<UserWeekdayHours> CalculateTotalHoursByWeekday(List<AvailableHours> availableHours)
        {
            var groupedByUserAndDay = GroupByUserAndDay(availableHours);
            return CalculateTotalHoursForEachUserWeekDay(groupedByUserAndDay);
        }

        // Step 1: Group records by UserId and DayOfWeek
        private IEnumerable<IGrouping<(int UserId, DayOfWeek Day), AvailableHours>> GroupByUserAndDay(List<AvailableHours> availableHours)
        {
            return availableHours
                .GroupBy(ah => (ah.UserId, ah.Date.DayOfWeek)); // Group by UserId and DayOfWeek (e.g., Monday)
        }

        // Step 2: Calculate total hours for each user and day and return a list of UserWeekdayHours records
        private List<UserWeekdayHours> CalculateTotalHoursForEachUserWeekDay(IEnumerable<IGrouping<(int UserId, DayOfWeek Day), AvailableHours>> groupedByUserAndDay)
        {
            return groupedByUserAndDay
                .Select(group => new UserWeekdayHours(
                group.Key.UserId,                   // UserId from the grouping key
                group.Key.Day,                      // Day from the grouping key
                group.Sum(ah => ah.HoursAvailable)  // Total hours for this user and day
                ))
                .ToList(); // Create a flat list
        }

        #endregion week day

        #region weekend
        // Record to represent the total hours for a user on a specific weekend day
        public record UserWeekendHours(int UserId, DayOfWeek WeekendDay, double TotalHours);

        // Main method to calculate total hours for weekends
        /// <summary>
        /// 
        /// </summary>
        /// <param name="availableHours"></param>
        /// <returns>Key is UserId</returns>
        public List<UserWeekendHours> CalculateTotalHoursByWeekend(List<AvailableHours> availableHours)
        {
            var groupedByUserAndWeekendDay = GroupByUserAndWeekendDay(availableHours);
            return CalculateTotalHoursForEachUser(groupedByUserAndWeekendDay);
        }

        // Step 1: Group records by UserId and DayOfWeek (for weekends: Saturday and Sunday)
        private IEnumerable<IGrouping<(int UserId, DayOfWeek WeekendDay), AvailableHours>> GroupByUserAndWeekendDay(List<AvailableHours> availableHours)
        {
            return availableHours
                .Where(ah => ah.Date.DayOfWeek == DayOfWeek.Saturday || ah.Date.DayOfWeek == DayOfWeek.Sunday) // Filter weekends
                .GroupBy(ah => (ah.UserId, ah.Date.DayOfWeek)); // Group by UserId and WeekendDay (Saturday/Sunday)
        }

        // Step 2: Calculate total hours for each user and weekend day, and return a list of UserWeekendHours records
        private List<UserWeekendHours> CalculateTotalHoursForEachUser(IEnumerable<IGrouping<(int UserId, DayOfWeek WeekendDay), AvailableHours>> groupedByUserAndWeekendDay)
        {
            return groupedByUserAndWeekendDay
                .Select(group => new UserWeekendHours(
                group.Key.UserId,                   // UserId from the grouping key
                group.Key.WeekendDay,               // WeekendDay (Saturday or Sunday) from the grouping key
                group.Sum(ah => ah.HoursAvailable)  // Total hours for this user and weekend day
            ))
            .ToList(); // Create a flat list
        }
        #endregion

        private int GetWeekOfYear(DateTime date)
        {
            var day = (int)date.DayOfWeek;
            var startOfWeek = date.AddDays(-day + (day == 0 ? -6 : 1)); // Adjust for Sunday to belong to the previous week
            return CultureInfo.InvariantCulture.Calendar.GetWeekOfYear(startOfWeek, CalendarWeekRule.FirstFourDayWeek, DayOfWeek.Monday);
        }

    }



}
