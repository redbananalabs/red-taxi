using AceTaxis.Domain;
using System.ComponentModel.DataAnnotations;

namespace AceTaxis.DTOs
{

    public class AccountTariffDetailDto
    {
        public int Id { get; set; }
        public string Name { get; set; }
    }

    public class CreditJourneysRequestDto
    {
        public int InvoiceNumber { get; set; }
        public string Reason { get; set; }
        public int[] BookingIds { get; set; }
    }

    public class DriverProcessingRowTotalDto
    {
        public int WaitMinutes { get; set; }
        public double WaitCharge { get; set; }
        public double Parking { get; set; }
        public double Price { get; set; }
        public double Total { get { return WaitCharge + Parking + Price; } }
    }

    public class AccountProcessingRowTotalsDto
    {
        public int WaitMinutes { get; set; }
        public double WaitCharge { get; set; }
        public double Parking { get; set; }
        public double DriverPrice { get; set; }
        public double AccountPrice { get; set; }
        public double Total { get { return WaitCharge + Parking + AccountPrice; } }
    }

    public class SendCardPaymentReminderDto : ModelValidator
    {
        [Required]
        public int BookingId { get; set; }
        [Required]
        public string Phone { get; set; }
    }


    public class RequestVATOutputDto : ModelValidator
    {
        [Required]
        public DateTime Start { get; set; }
        [Required]
        public DateTime End { get; set; }
    }

    public class RegisterAccountWebBookerDto : ModelValidator
    {
        [Required]
        public int Accno { get; set; }
        [Required]
        public string BookerName { get; set; }
        [Required]
        public string BookerEmail { get; set; }
        [Required]
        public string BookerPhone { get; set; }
    }

    public class AccountDto : ModelValidator
    {
        public int AccNo { get; set; }

        [Required]
        public string ContactName { get; set; }

        [Required]
        public string BusinessName { get; set; }
        [Required]
        public string Address1 { get; set; }
        [Required]
        public string Address2 { get; set; }

        public string Address3 { get; set; } = string.Empty;
        public string Address4 { get; set; } = string.Empty;

        [Required]
        public string Postcode { get; set; }

        [Required]
        public string Telephone { get; set; }

        public string? PurchaseOrderNo { get; set; }
        public string? Reference { get; set; }

        [Required]
        public string Email { get; set; }

        public string BookerEmail { get; set; } = string.Empty;
        public string BookerName { get; set; } = string.Empty;

        public int? AccountTariffId { get; set; }
    }
}
