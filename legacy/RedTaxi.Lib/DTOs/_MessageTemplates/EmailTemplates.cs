
namespace RedTaxi.DTOs.MessageTemplates
{
    public enum EmailTemplates
    {
        Register,
        DriverStatement,
        AccountInvoice,
        PaymentLink,
        PaymentReceipt,
        AccountRegistration,
        AccountBookingAccepted,
        AccountBookingRejected,
        AccountBookingCancelled,
        DriverStatementResend,
        AccountCreditNote,
        Quotation,
        CashBookingAccepted,
        CashBookingRejected
    }


    public class BookingCancelledEmail
    {
        public int accno { get; set; }
        public string passengername { get; set; }
        public string pickupaddress { get; set; }
        public string destinationaddress { get; set; }
        public string subject { get; set; }
    }

    public class BookingAcceptedEmail
    {
        public int accno { get; set; }
        public string passengername { get; set; }
        public string pickupaddress { get; set; }
        public string destinationaddress { get; set; }
        public string subject { get; set; }
        public string datetime { get; set; }
        public int bookingId { get; set; }
        public double price { get; set; }
    }

    public class BookingRejectedEmail
    {
        public int accno { get; set; }
        public string passengername { get; set; }
        public string pickupaddress { get; set; }
        public string destinationaddress { get; set; }
        public string reason { get; set; }
        public string subject { get; set; }
        public string datetime { get; set; }
    }

    public class NewUserRegisteredDto
    {
        public int userid { get; set; }
        public int accno { get; set; }
        public string fullname { get; set; }
        public string reg { get; set; }
        public string username { get; set; }
        public string password { get; set; }
        public string subject { get; set; }
    }

    public class DriverStatementDto 
    {
        public int userid { get; set; }
        public string fullname { get; set; }
        public string reg { get; set; }
        public int statementid { get; set; }
        public string period { get; set; }

        public List<transaction> transactions {  get; set; } 

        public string commstotal { get; set; }
        public string nettotal { get; set; }

        public string subject { get; set; }
        public class transaction
        {
            public string date { get; set; }
            public int bookingid { get; set; }
            public string comms { get; set; }
            public string net { get; set; }
        }

    }

    public class AccountInvoiceTemplateDto
    {
        public string customer { get; set; }
        public string invno { get; set; }
        public string subject { get; set; }
    }

    public class CreditNoteTemplateDto
    {
        public string customer { get; set; }
        public string creditnoteId { get; set; }
        public string subject { get; set; }
    }

    public class PaymentLinkTemplateDto
    {
        public string customer { get; set; }
        public string link { get; set; }
        public string subject { get; set; }
    }

    public class PaymentReceiptDto
    {
        public string customer { get; set; }
    }
}
