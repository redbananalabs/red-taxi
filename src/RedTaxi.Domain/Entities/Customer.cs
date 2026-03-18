using System;
using System.Collections.Generic;
using RedTaxi.Domain.Enums;

namespace RedTaxi.Domain.Entities;

public class Customer
{
    public int Id { get; set; }
    public string Name { get; set; } = string.Empty;
    public string Phone { get; set; } = string.Empty;
    public string? Email { get; set; }
    public CustomerAccountType AccountType { get; set; }
    public int? DefaultAccountId { get; set; }
    public string? DefaultPickupNotes { get; set; }
    public string? MarketingSource { get; set; }
    public string? Notes { get; set; }
    public bool IsActive { get; set; }
    public DateTime CreatedAt { get; set; }

    // Navigation properties
    public ICollection<Booking> Bookings { get; set; } = [];
}
