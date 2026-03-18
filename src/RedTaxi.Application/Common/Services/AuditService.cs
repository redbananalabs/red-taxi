using RedTaxi.Domain.Entities;
using RedTaxi.Infrastructure.Persistence;

namespace RedTaxi.Application.Common.Services;

/// <summary>
/// BK32: Booking Change Audit — compares old vs new values and persists change records.
/// </summary>
public class AuditService
{
    private readonly TenantDbContext _db;

    public AuditService(TenantDbContext db) => _db = db;

    /// <summary>
    /// Compares a snapshot of old values against new values and writes BookingChangeAudit rows.
    /// Call this BEFORE mutating the entity.
    /// </summary>
    public void RecordChanges(
        int bookingId,
        string? userName,
        IReadOnlyList<(string PropertyName, string? OldValue, string? NewValue)> changes)
    {
        var now = DateTime.UtcNow;
        var entityId = bookingId.ToString();

        foreach (var (prop, oldVal, newVal) in changes)
        {
            if (oldVal == newVal) continue;

            _db.BookingChangeAudits.Add(new BookingChangeAudit
            {
                EntityIdentifier = entityId,
                EntityName = "Booking",
                PropertyName = prop,
                OldValue = oldVal,
                NewValue = newVal,
                UserFullName = userName,
                TimeStamp = now,
                Action = "Update",
            });
        }
    }
}
