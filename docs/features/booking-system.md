# Booking System

## Overview

The booking system handles creation, modification, and lifecycle management of taxi journey requests. It is the core operational feature of Red Taxi.

## Business Logic

### Booking Creation Flow

1. Operator enters pickup address
2. System autocompletes via Google Places / Ideal Postcodes
3. Operator enters destination
4. System calculates route, distance, duration
5. System calculates price based on tariffs
6. Operator adds passenger details
7. Booking is created in "Confirmed" status
8. Confirmation sent to passenger (SMS/email)

### Scope

| Scope | Value | Description |
|-------|-------|-------------|
| Quote | 0 | Price enquiry only |
| Confirmed | 1 | Real booking |

### ASAP Bookings

When `IsASAP = true`:
- Pickup time set to current time + 5 minutes
- Priority flag for dispatch
- Immediate driver notification

### Return Bookings

- Create linked booking with IsReturn = true
- Swap pickup ↔ destination addresses
- Link via LinkedBookingId
- Can be edited independently

### Repeat Bookings

Generate multiple bookings from a template:
- Daily / Weekly / Monthly frequency
- End by date or occurrence count
- Each generated booking is independent

## Workflow

```
┌─────────────┐
│   START     │
└──────┬──────┘
       │
       ▼
┌─────────────┐     ┌─────────────┐
│   DRAFT     │────▶│  CONFIRMED  │
│  (Quote)    │     │             │
└─────────────┘     └──────┬──────┘
                           │
       ┌───────────────────┼───────────────────┐
       │                   │                   │
       ▼                   ▼                   ▼
┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│  CANCELLED  │     │  ALLOCATED  │     │   NO SHOW   │
└─────────────┘     └──────┬──────┘     └─────────────┘
                           │
                           ▼
                    ┌─────────────┐
                    │DRIVER_ENROUTE│
                    └──────┬──────┘
                           │
                           ▼
                    ┌─────────────┐
                    │   ARRIVED   │
                    └──────┬──────┘
                           │
       ┌───────────────────┴───────────────────┐
       │                                       │
       ▼                                       ▼
┌─────────────┐                         ┌─────────────┐
│ IN_PROGRESS │                         │     COA     │
└──────┬──────┘                         │(Cancel On   │
       │                                │  Arrival)   │
       ▼                                └─────────────┘
┌─────────────┐
│  COMPLETED  │
└─────────────┘
```

## Edge Cases

### Price Recalculation

Price must recalculate when:
- Pickup address changes
- Destination address changes
- Via points modified
- Date/time changes (affects peak rates)
- Passenger count changes (affects vehicle)
- Vehicle type changes
- Account changes

### Account 9999

Special "cash" account. Bookings can have price = 0 during creation.

### Duplicate Detection

Warn operator if booking exists with:
- Same phone number
- Same pickup time (±30 mins)
- Same pickup address

### Cancellation Rules

- Before allocation: No charge
- After allocation: May incur cancellation fee
- Cancel on arrival (COA): Driver receives fee

## Future Enhancements

- [ ] AI-assisted address entry
- [ ] Predicted journey duration based on traffic
- [ ] Automatic return booking suggestion
- [ ] Passenger app self-booking
- [ ] Flight number integration for delays
- [ ] Recurring booking templates

## API Reference

See [Booking API](../api/booking-api.md)

## Related Documents

- [Data Model: Booking](../data-model/booking.md)
- [Dispatch System](dispatch-system.md)
- [Pricing Engine](pricing-engine.md)
- [Notifications](notifications.md)
