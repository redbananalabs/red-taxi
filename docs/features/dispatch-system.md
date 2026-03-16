# Dispatch System

## Overview

The dispatch system allocates drivers to bookings. It supports manual, assisted, and automatic dispatch modes.

## Business Logic

### Dispatch Modes

| Mode | Description | Use Case |
|------|-------------|----------|
| Manual | Operator selects driver | Small fleet, complex jobs |
| Assisted | System suggests, operator confirms | Medium fleet |
| Auto | System allocates automatically | Large fleet, ASAP jobs |

### Manual Dispatch

1. Operator views unallocated bookings
2. Operator views available drivers (map/list)
3. Operator drags booking to driver OR selects from list
4. System validates driver suitability
5. Booking status → Allocated
6. Driver receives notification

### Assisted Dispatch

1. System identifies best driver candidates
2. System suggests top 3 with reasoning
3. Operator reviews suggestions
4. Operator confirms or overrides
5. Same allocation flow as manual

### Auto Dispatch

1. Booking created/confirmed
2. System runs allocation algorithm
3. Job offered to best driver
4. Driver has X seconds to accept
5. If rejected/timeout, offer to next driver
6. If no driver accepts, escalate to operator

## Workflow

### Auto Dispatch Flow

```
┌──────────────────────────────────────────────────────────────┐
│                    BOOKING CONFIRMED                          │
└────────────────────────────┬─────────────────────────────────┘
                             │
                             ▼
┌──────────────────────────────────────────────────────────────┐
│              FIND ELIGIBLE DRIVERS                            │
│  • Online and available                                       │
│  • Correct vehicle type                                       │
│  • In coverage zone                                           │
│  • Cleared for account type                                   │
└────────────────────────────┬─────────────────────────────────┘
                             │
                             ▼
┌──────────────────────────────────────────────────────────────┐
│              RANK DRIVERS                                     │
│  1. ETA to pickup (not straight line)                        │
│  2. Fairness score (spread work)                             │
│  3. Driver rating                                            │
│  4. Account preference                                       │
└────────────────────────────┬─────────────────────────────────┘
                             │
                             ▼
┌──────────────────────────────────────────────────────────────┐
│              OFFER TO DRIVER #1                               │
│  • Push notification                                         │
│  • 60 second timeout                                         │
└─────────────────────────┬────────────────────────────────────┘
                          │
          ┌───────────────┼───────────────┐
          │               │               │
          ▼               ▼               ▼
    ┌──────────┐   ┌──────────┐   ┌──────────┐
    │ ACCEPTED │   │ REJECTED │   │ TIMEOUT  │
    └────┬─────┘   └────┬─────┘   └────┬─────┘
         │              │              │
         │              └──────┬───────┘
         │                     │
         │                     ▼
         │         ┌───────────────────┐
         │         │ MORE DRIVERS?     │
         │         └─────────┬─────────┘
         │               YES │ NO
         │              ┌────┴────┐
         │              │         │
         │              ▼         ▼
         │    ┌──────────────┐ ┌──────────────┐
         │    │ OFFER NEXT   │ │ ESCALATE TO  │
         │    └──────────────┘ │ OPERATOR     │
         │                     └──────────────┘
         ▼
┌─────────────────┐
│    ALLOCATED    │
└─────────────────┘
```

## Driver Selection Algorithm

### Eligibility Filters (must pass all)

```python
def is_eligible(driver, booking):
    return (
        driver.is_online and
        driver.status == 'available' and
        driver.vehicle_type >= booking.vehicle_type and
        driver.capacity >= booking.passenger_count and
        driver.is_in_zone(booking.pickup_zone) and
        driver.is_cleared_for_account(booking.account_type) and
        driver.shift_covers(booking.pickup_time)
    )
```

### Ranking Score

```python
def calculate_score(driver, booking):
    eta_score = 100 - min(driver.eta_to_pickup, 60)  # Lower ETA = higher score
    fairness_score = 50 - driver.jobs_today          # Fewer jobs = higher score
    rating_score = driver.rating * 10                # 1-5 → 10-50
    
    return eta_score + fairness_score + rating_score
```

### Priority Rules

| Priority | Condition |
|----------|-----------|
| 1 | ASAP bookings (dispatch immediately) |
| 2 | Airport runs (time critical) |
| 3 | Account bookings (contractual) |
| 4 | Standard bookings |

## Soft Allocation

Pre-allocation without driver confirmation:

1. System suggests driver (SuggestedDriverId)
2. Booking shows on scheduler with dotted pattern
3. Driver sees job in "upcoming" list
4. Operator can confirm or reassign
5. On confirm: SuggestedDriverId → DriverId

Use cases:
- Pre-booked jobs
- School runs (regular patterns)
- Account contracts

## Edge Cases

### No Available Drivers

1. Alert operator
2. Show on "unallocated" dashboard
3. Option to broadcast to all drivers
4. Option to subcontract

### Driver En Route Cancellation

1. Driver notifies via app
2. Job returns to unallocated
3. Re-run auto dispatch
4. Log reason for reporting

### Overlapping Jobs

System prevents allocation if:
- Driver has job at same time
- Buffer time insufficient between jobs

### Zone Restrictions

Some drivers restricted to zones:
- Town centre only
- Airport cleared
- School runs only

## Future Enhancements

- [ ] AI dispatch suggestions with explanations
- [ ] Predictive positioning (pre-position drivers)
- [ ] Dynamic pricing based on availability
- [ ] Driver bidding for jobs
- [ ] Cross-operator job sharing

## API Reference

See [Dispatch API](../api/dispatch-api.md)

## Related Documents

- [Dispatch Modes](../dispatch/dispatch-modes.md)
- [Auto Dispatch](../dispatch/auto-dispatch.md)
- [Driver Selection](../dispatch/driver-selection.md)
- [Booking System](booking-system.md)
