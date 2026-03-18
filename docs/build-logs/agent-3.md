# ⚠️ ARCHIVED — These are from the v1 rewrite approach (now deprecated)

# Agent 3 Build Log — Dispatch Console (Blazor Server)
Started: 2026-03-18
Last Updated: 2026-03-18
Status: In Progress (Steps 0-3 PASS, Steps 4-10 pending)

## Context
- Working on: Dispatch Console — Blazor Server + Syncfusion + Tailwind
- PRD sections: §42 (original), §142 (revised layout), §95-99, §137
- Branch: main

## Verified Steps (QA tested in browser)

### Step 0: Circuit crash fix ✅
- Syncfusion JS interop script added (syncfusion-blazor.min.js)
- SignalR start is fire-and-forget (doesn't crash circuit)
- DetailedErrors enabled

### Step 1: KPIs showing real data ✅
- DashboardController created at /api/dashboard/kpis
- Returns: todayBookings, unallocatedBookings, driversOnline, activeJobs, completedToday, todayRevenue
- BearerTokenHandler auto-authenticates with service credentials

### Step 2: Google Maps renders ✅
- Maps API loaded with key, centred on Gillingham (dark scheme)
- Map centre reads from CompanyConfig (operator-configurable)
- CSS fixed: .map-area flex:1, .map-container/.map-element position:absolute

### Step 3: §142 revised layout ✅
- Split layout: BookingForm always visible left (~30%), tabbed right (~70%)
- Tab bar: Scheduler (default) | Map with KPI badges
- Draggable splitter (JS interop)
- Syncfusion SfSchedule with Day + Timeline views
- DAY view: vertical time axis, driver columns (like legacy Ace)
- TIMELINE view: horizontal Gantt, driver rows on Y-axis
- Filter toggles: Show Allocated, Show Completed
- CONF SA button, Merge Mode toggle
- Driver rows colored with ColorCodeRGB, booking tiles colored by driver
- Unallocated bookings in amber (#F59E0B)
- Right-click context menu on booking tiles

## Architecture Decisions
- §142 replaces §42: operators want legacy split-panel layout, not floating panels
- BookingForm has AlwaysVisible param (hides close btn, resets on submit)
- Timeline has FullHeight param for panel mode
- Splitter uses pure JS (splitter.js) with 20-50% width clamp

## Remaining Steps
- Step 4: Create booking form works end-to-end
- Step 5: Driver allocation via UI
- Step 6: Booking detail panel
- Step 7: Complete a booking
- Step 8: Cancel a booking
- Step 9: Caller popup
- Step 10: Soft allocate + CONF SA
