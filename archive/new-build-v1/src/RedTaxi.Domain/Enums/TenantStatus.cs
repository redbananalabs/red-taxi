namespace RedTaxi.Domain.Enums;

public enum TenantStatus
{
    Trial = 0,
    Active = 1,
    PastDue = 2,
    GracePeriod = 3,
    SoftLocked = 4,
    HardLocked = 5,
    Cancelled = 6
}
