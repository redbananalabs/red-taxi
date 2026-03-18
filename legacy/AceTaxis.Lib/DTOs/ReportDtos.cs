using AceTaxis.Domain;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace AceTaxis.DTOs
{
    public class DuplicateBookingReportDto
    {
        public string PickupAddress { get; set; }
        public DateTime PickupDateTime { get; set; }
        public string DestinationAddress { get; set; }
        public string? PassengerName { get; set; }
        public int DuplicateCount { get; set; }
    }

    public class ScopeBreakdownEntry
    {
        public string PeriodLabel { get; set; } = string.Empty; // e.g., "2025-04-01", "Week 14", "2025-Q1"
        public BookingScope Scope { get; set; }
        public string ScopeText { get; set; } = string.Empty;
        public int Count { get; set; }
        public bool IsComparison { get; set; } = false;
    }

    public class TopCustomerDto
    {
        public string PhoneNumber { get; set; } = string.Empty;
        public string? PassengerName { get; set; } = string.Empty;
        public int BookingCount { get; set; }
        public DateTime? LastBookingDate { get; set; }
    }


    public class PickupPostcodeDto
    {
        public string PickupPostCode { get; set; } = string.Empty;
        public int Count { get; set; }
    }

    public class VehicleTypeCountDto
    {
        public VehicleType VehicleType { get; set; }
        public string VehicleTypeText { get; set; } = string.Empty;
        public int Count { get; set; }
    }

    public class PeriodAverageDurationDto
    {
        public string PeriodLabel { get; set; } = string.Empty;
        public double AverageDurationMinutes { get; set; }
        public int TotalBookings { get; set; }
    }

    public class ScopeTimeGrowthDto
    {
        public string PeriodLabel { get; set; } = string.Empty;
        public BookingScope Scope { get; set; }
        public string ScopeText { get; set; } = string.Empty;
        public int CurrentYearCount { get; set; }
        public int PreviousYearCount { get; set; }
        public double PercentageGrowth { get; set; }
    }


    public class RevenueByMonthDto
    {
        public string Month { get; set; }
        public decimal NetTotal { get; set; }
    }

    public class PayoutByMonthDto
    {
        public string Month { get; set; }
        public decimal TotalPaymentDue { get; set; }
    }

    public class ProfitabilityDto
    {
        public int InvoiceNumber { get; set; }
        public int AccountNo { get; set; }
        public DateTime Date { get; set; }
        public decimal NetTotal { get; set; }
        public decimal Cost { get; set; }
        public double Profit { get; set; }
        public double Margin { get; set; }
    }

}
