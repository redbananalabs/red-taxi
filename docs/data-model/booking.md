> **⚠️ NOTE:** The `TenantId` column and related indexes shown in this document are from an earlier shared-database design. Red Taxi now uses **per-tenant databases** — the `TenantId` column is NOT present on the Booking entity. See `docs/PRD.md §36`.

# Booking Entity

## Overview

The Booking entity is the central domain object representing a customer journey request. It captures all information from initial quote through to completion.

## Entity Definition

```csharp
public class Booking : BaseEntity, ITenantScoped
{
    public Guid Id { get; set; }
    public Guid TenantId { get; set; }
    
    // Reference
    public string BookingRef { get; set; }  // RT-240316-001
    
    // Status
    public BookingStatus Status { get; set; }
    public int Scope { get; set; }  // 0=Quote, 1=Confirmed
    public BookingSource Source { get; set; }
    
    // Timing
    public DateTimeOffset PickupDateTime { get; set; }
    public bool IsASAP { get; set; }
    public DateTimeOffset? ArriveBy { get; set; }
    public bool IsAllDay { get; set; }
    public int DurationMinutes { get; set; }
    
    // Pickup Location (snapshot at booking time)
    public string PickupAddress { get; set; }
    public string PickupPostCode { get; set; }
    public decimal PickupLat { get; set; }
    public decimal PickupLng { get; set; }
    
    // Destination Location (snapshot)
    public string DestinationAddress { get; set; }
    public string DestinationPostCode { get; set; }
    public decimal DestinationLat { get; set; }
    public decimal DestinationLng { get; set; }
    
    // Passenger Details
    public string PassengerName { get; set; }
    public int PassengerCount { get; set; }  // 1-9
    public string PhoneNumber { get; set; }
    public string? Email { get; set; }
    
    // Account (null = cash customer)
    public Guid? AccountId { get; set; }
    public Account? Account { get; set; }
    public string? PurchaseOrderNumber { get; set; }
    public string? Reference { get; set; }
    
    // Pricing (snapshots)
    public decimal QuotedPrice { get; set; }
    public decimal QuotedDriverPay { get; set; }
    public decimal FinalPrice { get; set; }
    public decimal FinalDriverPay { get; set; }
    public bool ManuallyPriced { get; set; }
    
    // Distance & Duration (snapshots)
    public decimal QuotedDistanceMiles { get; set; }
    public int QuotedDurationMinutes { get; set; }
    public decimal? ActualDistanceMiles { get; set; }
    public int? ActualDurationMinutes { get; set; }
    public string? RoutePolyline { get; set; }
    
    // Payment
    public PaymentStatus PaymentStatus { get; set; }
    public PaymentMethod? PaymentMethod { get; set; }
    
    // Allocation
    public Guid? DriverId { get; set; }
    public User? Driver { get; set; }
    public Guid? SuggestedDriverId { get; set; }  // Soft allocation
    public VehicleType VehicleType { get; set; }
    
    // Linked Bookings
    public bool IsReturn { get; set; }
    public Guid? LinkedBookingId { get; set; }
    public Booking? LinkedBooking { get; set; }
    
    // Notes
    public string? SpecialRequirements { get; set; }
    public string? DriverNotes { get; set; }
    public string? InternalNotes { get; set; }
    
    // Audit
    public Guid BookedByUserId { get; set; }
    public string BookedByName { get; set; }
    public Guid? UpdatedByUserId { get; set; }
    public string? UpdatedByName { get; set; }
    public DateTimeOffset CreatedAt { get; set; }
    public DateTimeOffset UpdatedAt { get; set; }
    
    // Navigation
    public ICollection<BookingVia> Vias { get; set; }
    public ICollection<BookingStatusHistory> StatusHistory { get; set; }
}
```

## Fields Reference

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| Id | Guid | Yes | Primary key |
| TenantId | Guid | Yes | Tenant isolation |
| BookingRef | string | Yes | Human-readable reference |
| Status | enum | Yes | Current status |
| Scope | int | Yes | 0=Quote, 1=Confirmed |
| Source | enum | Yes | Origin of booking |
| PickupDateTime | DateTimeOffset | Yes | When to collect |
| IsASAP | bool | Yes | ASAP flag |
| PickupAddress | string | Yes | Full address text |
| PickupPostCode | string | Yes | Postcode |
| PickupLat | decimal | Yes | Latitude |
| PickupLng | decimal | Yes | Longitude |
| DestinationAddress | string | Yes | Full address text |
| PassengerName | string | Yes | Name(s) |
| PassengerCount | int | Yes | 1-9 |
| PhoneNumber | string | Yes | Contact number |
| QuotedPrice | decimal | Yes | Price at quote time |
| FinalPrice | decimal | Yes | Final charged price |

## Relationships

```
Booking
  ├── Tenant (many-to-one)
  ├── Account (many-to-one, optional)
  ├── Driver (many-to-one, optional)
  ├── LinkedBooking (self-reference, optional)
  ├── Vias (one-to-many)
  └── StatusHistory (one-to-many)
```

## Lifecycle States

```
Draft → Confirmed → Allocated → DriverEnRoute → Arrived → InProgress → Completed
                 ↘                                                    ↗
                   Cancelled ←────────────────────────────────────────
                             ←── NoShow
```

### Status Definitions

| Status | Description |
|--------|-------------|
| Draft | Quote only, not confirmed |
| Confirmed | Customer confirmed, awaiting allocation |
| Allocated | Driver assigned |
| DriverEnRoute | Driver heading to pickup |
| Arrived | Driver at pickup location |
| InProgress | Passenger on board |
| Completed | Journey finished |
| Cancelled | Cancelled by customer/operator |
| NoShow | Passenger didn't show |

## Business Rules

### Validation

- PickupDateTime must be in the future (unless editing)
- PassengerCount must be 1-9
- DestinationAddress required for Scope=1
- Price must be > 0 for Scope=1 (unless account 9999)
- Return booking: ReturnDateTime > PickupDateTime

### Price Recalculation Triggers

Price must be recalculated when:
- Pickup address changes
- Destination address changes
- Via points added/removed
- Date/time changes (peak hours)
- Passenger count changes
- Vehicle type changes
- Account number changes

### Snapshots

These fields are snapshots captured at booking time and preserved for audit:
- PickupAddress, PickupLat, PickupLng
- DestinationAddress, DestinationLat, DestinationLng
- QuotedPrice, QuotedDriverPay
- QuotedDistanceMiles, QuotedDurationMinutes

## Indexes

```sql
CREATE INDEX IX_Bookings_TenantId ON Bookings(TenantId);
CREATE INDEX IX_Bookings_PickupDateTime ON Bookings(TenantId, PickupDateTime);
CREATE INDEX IX_Bookings_Status ON Bookings(TenantId, Status);
CREATE INDEX IX_Bookings_DriverId ON Bookings(TenantId, DriverId);
CREATE INDEX IX_Bookings_AccountId ON Bookings(TenantId, AccountId);
```

## Related Entities

- [BookingVia](booking-via.md)
- [BookingStatusHistory](booking-status-history.md)
- [Driver](driver.md)
- [Account](account.md)

## Domain Events

| Event | When |
|-------|------|
| BookingCreated | New booking saved |
| BookingUpdated | Booking modified |
| BookingCancelled | Status → Cancelled |
| BookingAllocated | Driver assigned |
| BookingCompleted | Status → Completed |
