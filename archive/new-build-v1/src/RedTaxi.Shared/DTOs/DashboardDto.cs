namespace RedTaxi.Shared.DTOs;

public record DashboardKpiDto(int TodayBookings, int UnallocatedBookings, int DriversOnline,
    decimal TodayRevenue, int ActiveJobs, int CompletedToday);
