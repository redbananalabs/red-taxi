using AceTaxis.Domain;
using AceTaxis.Interfaces;
using System.ComponentModel;
using System.ComponentModel.DataAnnotations;

namespace AceTaxis.DTOs.Booking
{
    public class CreateAvailabilityRequestDto : ModelValidator
    {
        [Required]
        public int UserId { get; set; }
        [Required]
        public DateTime Date { get; set; }
        [Required]
        public string From { get; set; }
        [Required]
        public string To { get; set; }
        public bool? GiveOrTake { get; set; } = false;
        [Required]
        public DriverAvailabilityType Type { get; set; }
        public string? Note { get; set; }
    }

    public class DeleteByRangeRequestDto : GetBookingsRequestDto
    {
        public int AccountNo { get; set; }

    }
    public class GetBookingsRequestDto : ModelValidator, IGetBookingsRequestDto
    {
        [Required]
        [DisplayName("From Date")]
        public DateTime From { get; set; }

        [DisplayName("To Date")]
        public DateTime? To { get; set; }
    }

    public class CreateBookingRequestDto : BookingModel, IBookingModel
    {
        public int? UserId { get; set; }

        public DateTime? ReturnDateTime { get; set; }

        public bool Allocate { get; set; } = true;

        public bool IsDuplicate { get; set; }
    }

    public class UpdateBookingRequestDto : CreateBookingRequestDto, IBookingModel
    {
        [Required]
        public int BookingId { get; set; }
        public int? UserId { get; set; }

        public string UpdatedByName { get; set; }
        public bool EditBlock { get; set; }
    }

    public class AllocateBookingDto : ModelValidator
    {
        [Required]
        public int BookingId { get; set; }
        [Required]
        public int? UserId { get; set; }
        [Required]
        public int ActionByUserId { get; set; }
    }

    public class UpdateBookingDateRequest
    {
        [Required]
        public int BookingId { get; set; }
        [Required]
        public DateTime NewDate { get; set; }
        [Required]
        public string UpdatedByName { get; set; }
        [Required]
        public int ActionByUserId { get; set; }
    }

    public class CancelBookingRequest
    {
        [Required]
        [Range(1, 999999)]
        public int BookingId { get; set; }

        public string CancelledByName { get; set; }

        public bool CancelBlock { get; set; }

        public bool CancelledOnArrival { get; set; }

        [Required]
        public int ActionByUserId { get; set; }

        public bool? SendEmail { get; set; }
    }

    public class GetPriceRequestDto : ModelValidator
    {
        [Required]
        public string PickupPostcode { get; set; }
        
        public List<string>? ViaPostcodes { get; set; }

        [Required]
        public string DestinationPostcode { get; set; }

        [Required]
        public DateTime PickupDateTime { get; set; }

        [Required]
        public int Passengers { get; set; }

        [Required]
        public bool PriceFromBase { get; set; }

        public int AccountNo { get; set; }
    }

    /// <summary>
    /// Used from back end admin panel
    /// </summary>
    public class UpdateBookingQuoteRequestDto : GetPriceRequestDto
    {
        [Required]
        [Range(1, 999999)]
        public int BookingId { get; set; }

        [Required]
        public int ActionByUserId { get; set; }

        [Required]
        public string UpdatedByName { get; set; }

        [Required]
        public decimal Price { get; set; }

        public decimal? PriceAccount { get; set; }

        [Required]
        public decimal Mileage { get; set; }

        public string MileageText { get; set; }

        public string DurationText { get; set; }
    }

    public class UpdateBookingQuoteBulkRequestDto : UpdateBookingQuoteRequestDto
    {
        public int[] BookingIds { get; set; }
    }

    public class ManualPriceUpdateRequestDto : ModelValidator
    {
        [Required]
        [Range(1, 999999)]
        public int BookingId { get; set; }

        [Required]
        public decimal Price { get; set; }

        public decimal? PriceAccount { get; set; }

        [Required]
        public int ActionByUserId { get; set; }

        [Required]
        public string UpdatedByName { get; set; }
    }


    public class BookingSearchRequestDto
    {
        public string PickupAddress { get; set; }
        public string PickupPostcode { get; set; }
        public string DestinationAddress { get; set; }
        public string DestinationPostcode { get; set; }
        public string Passenger { get; set; }
        public string PhoneNumber { get; set; }
        public string Details { get; set; }
    }
}
