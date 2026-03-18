namespace RedTaxi.Domain.Enums;

public enum SentMessageType
{
    DriverOnAllocate = 0,
    DriverOnUnAllocate = 1,
    DriverOnAmend = 2,
    DriverOnCancel = 3,
    CustomerOnAllocate = 4,
    CustomerOnUnAllocate = 5,
    CustomerOnAmend = 6,
    CustomerOnCancel = 7,
    CustomerOnComplete = 8,
    DriverDirectMessage = 9,
    DriverGlobalMessage = 10
}
