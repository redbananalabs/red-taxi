using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using RedTaxi.Domain.Enums;
using RedTaxi.Infrastructure.Persistence;
using RedTaxi.Shared.DTOs;

namespace RedTaxi.API.Controllers;

[ApiController]
[Route("api/[controller]")]
public class DashboardController : ControllerBase
{
    private readonly TenantDbContext _db;

    public DashboardController(TenantDbContext db) => _db = db;

    [HttpGet("kpis")]
    public async Task<ActionResult<DashboardKpiDto>> GetKpis(CancellationToken ct)
    {
        var today = DateTime.Today;
        var tomorrow = today.AddDays(1);

        var bookings = await _db.Bookings
            .Where(b => !b.Cancelled && b.PickupDateTime >= today && b.PickupDateTime < tomorrow)
            .ToListAsync(ct);

        var todayCount = bookings.Count;
        var unallocated = bookings.Count(b => b.UserId == null);
        var driversOnline = await _db.DriversOnShift.CountAsync(d => d.IsOnline, ct);
        var active = bookings.Count(b => b.UserId != null && b.Status != BookingStatus.Complete);
        var completed = bookings.Count(b => b.Status == BookingStatus.Complete);
        var revenue = bookings.Where(b => b.Status == BookingStatus.Complete).Sum(b => b.Price);

        return Ok(new DashboardKpiDto(todayCount, unallocated, driversOnline, revenue, active, completed));
    }
}
