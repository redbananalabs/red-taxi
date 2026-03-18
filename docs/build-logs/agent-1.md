# Agent 1 Build Log — Booking + Dispatch + Pricing API
Started: 2026-03-18
Last Updated: 2026-03-18
Status: Complete

## Context
- Working on: Phase 1A — Booking CRUD, 5-level pricing engine, dispatch allocation, SignalR hub
- PRD sections: §76, §77, §102, §111, §132, §134, §137
- Dependencies: Phase 0 foundation (complete)
- Branch: main

## Completed Work

### 2026-03-18 — Full Booking+Dispatch+Pricing Implementation

**Booking Handlers (11 files):**
- CreateBooking: auto-pricing, return journey, via stops, publishes BookingCreatedEvent
- UpdateBooking: detects pricing-sensitive changes, auto-recalculates unless ManuallyPriced
- CancelBooking: COA support (CancelledOnArrival flag)
- CompleteBooking: status transition, publishes BookingCompletedEvent
- DuplicateBooking: clones booking for new date/time
- Queries: GetById, GetToday, GetSchedulerView (date range), FindBookings (full search with pagination), GetByDriver

**Pricing Engine (4 files):**
- PricingService: 5-level priority (Manual → Zone → Fixed Route → Account Tariff → Standard)
- Tariff selection: T1 Day (Mon-Sat 07:00-21:59), T2 Night (22:00-06:59, Sunday, bank holidays), T3 Holiday (Dec 24 18:00+, Dec 25-26, Dec 31 18:00+, Jan 1)
- Bank holidays configurable via CompanyConfig
- Cash formula: totalMiles = (journeyMiles + deadMiles) / 2; price = Initial + FirstMile + (miles-1) × Additional
- Account dual pricing: separate driver/account rates per tariff component
- Commands: RecalculatePrice, ManualPriceUpdate
- Query: GetPrice (preview/quote)

**Dispatch Handlers (7 files):**
- AllocateBooking: firm allocation, creates DriverAllocation + JobOffer, publishes BookingAllocatedEvent
- SoftAllocate: sets SuggestedUserId only, no notifications
- ConfirmSoftAllocates: batch converts soft→firm for a date
- Unallocate: clears driver, publishes BookingUnallocatedEvent
- RecordTurnDown: creates TurnDown record
- GetDriverList: all drivers with optional active filter

**SignalR & Events (3 files):**
- DispatchHub: tenant group management, driver-specific groups
- BookingCreatedEventHandler: broadcasts to dispatch board
- BookingAllocatedEventHandler: broadcasts to board + driver group

**API Controllers (3 files):**
- BookingsController: CRUD, search, cancel, complete, duplicate
- DispatchController: allocate, soft-allocate, confirm, unallocate, turn-down, driver list
- PricingController: quote, recalculate, manual price

**Infrastructure (1 file):**
- StubDistanceMatrixService: development stub returning estimates

**Total: 31 files, 1,932 lines**

## Handoff Notes
- PricingService uses IDistanceMatrixService (currently stubbed) — needs Google Distance Matrix integration in Phase 2
- Zone-to-Zone pricing uses point-in-polygon check — GeoFence.PolygonData must be JSON array of {lat,lng}
- BookingMapper.ToDto() is a shared static mapper in CreateBookingCommand.cs — could be extracted
- Booking state machine enforced in handlers, not a formal state machine class
