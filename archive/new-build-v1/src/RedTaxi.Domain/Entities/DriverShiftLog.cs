using System;
using RedTaxi.Domain.Enums;

namespace RedTaxi.Domain.Entities;

public class DriverShiftLog
{
    public int Id { get; set; }
    public int UserId { get; set; }
    public DateTime TimeStamp { get; set; }
    public AppDriverShift EntryType { get; set; }
}
