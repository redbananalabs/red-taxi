using AceTaxis.DTOs.Booking;

namespace AceTaxis.DTOs
{
    public class DriverExpensesResponseDto
    {
        public JobsCountModelDto JobsCount { get; set; }
        public double[] JobCountDateRangeValues { get; set; }
        public string[] JobCountDateRangeLabels { get; set; }
        public List<EarningsModelTotalsDto> Earnings { get; set; }
    }
}
