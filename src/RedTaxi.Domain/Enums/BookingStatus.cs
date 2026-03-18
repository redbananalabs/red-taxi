namespace RedTaxi.Domain.Enums;

public enum BookingStatus
{
    None = 0,
    AcceptedJob = 1,
    RejectedJob = 2,
    Complete = 3,
    RejectedJobTimeout = 4
}
