# Red Taxi Driver App — Design Specification

## Platform
Flutter (iOS + Android). Single codebase.

## Design Principles

- **Dark-first** (matches dispatch console brand, works well in-vehicle at night). Light mode toggle available for daytime.
- **One-thumb operation.** Everything reachable with one hand. Primary actions at bottom of screen.
- **Glanceable.** Driver should understand current state in <1 second. Large text, bold status colours, minimal clutter.
- **Zero-distraction during driving.** Active job screen shows only what's needed. No unnecessary taps while moving.
- **Same design tokens** as dispatch console: brand red, status colours, Inter typeface, Lucide icons. The driver app should feel like part of the same product family.

---

## Navigation: Bottom Tab Bar (5 Tabs)

```
┌─────────────────────────────────────────────────┐
│                                                 │
│              [Screen Content]                   │
│                                                 │
├─────────┬─────────┬─────────┬─────────┬─────────┤
│  📋     │  🔔     │  🚗     │  📅     │  💰     │
│Schedule │ Offers  │ Active  │ Avail.  │Earnings │
└─────────┴─────────┴─────────┴─────────┴─────────┘
```

| Tab | Icon | Badge | Description |
|-----|------|-------|-------------|
| Schedule | Calendar list | Count of today's jobs | Today's upcoming jobs — the home screen |
| Offers | Bell / alert | Count of pending offers | Incoming job offers + notifications |
| Active | Car | Status indicator dot | Current active job (navigation + status progression) |
| Availability | Calendar | — | Set today's / week's availability |
| Earnings | Wallet | — | Today's earnings, weekly summary, statements |

**Active tab highlight:** `brand-500` (`#FF2D2D`) icon + label. Inactive: `text-secondary`.

**Badge:** Red circle with white count number, top-right of icon.

---

## Tab 1: Schedule (Home Screen)

The default screen when the driver opens the app. Shows today's allocated jobs in chronological order.

```
┌─────────────────────────────────────────┐
│  Good morning, Andrew          [⚙️] [🌙] │
│  Today: 6 jobs · £0.00 earned so far    │
├─────────────────────────────────────────┤
│                                         │
│  ┌─ 07:30 ─────────────────────────┐    │
│  │ 📍 6 Cobham Road, Blandford     │    │
│  │ → Harbour Vale School, Sherborne │    │
│  │ 👤 Ethan Collins, Kaitlin Dyer   │    │
│  │ 🏢 Harbour Vale School (Acc)     │    │
│  │ [Navigate]              [Status] │    │
│  └──────────────────────────────────┘    │
│                                         │
│  ┌─ 08:10 ─────────────────────────┐    │
│  │ 📍 Harbour Vale School           │    │
│  │ → 10 Waverland Terrace, Gilli... │    │
│  │ 👤 Jessie Perry, Liam Dyke       │    │
│  │ 🏢 Harbour Vale School (Acc)     │    │
│  │ [Navigate]              [Status] │    │
│  └──────────────────────────────────┘    │
│                                         │
│  ┌─ 14:30 ─────────────────────────┐    │
│  │ 📍 Stratton Village Hall         │    │
│  │ → Flat 1, 7 Roman Avenue, Bl... │    │
│  │ 👤 Oscar Wedge                   │    │
│  │ 💵 Cash                          │    │
│  │ [Navigate]              [Status] │    │
│  └──────────────────────────────────┘    │
│                                         │
│  No more jobs today                     │
└─────────────────────────────────────────┘
```

### Header
- Driver's first name + greeting (time-based: morning/afternoon/evening)
- Settings gear icon (top right)
- Dark/light mode toggle
- Today's summary: job count + earnings so far

### Job Cards
- Time prominently displayed (left edge, large text)
- Pickup address (📍 icon)
- Destination address (→ arrow)
- Passenger name(s) (👤 icon)
- Account name or "Cash" / "Card" payment type
- Pax count if > 1
- Via stops shown if present
- Booking details/notes if present

### Job Card Actions
- **Navigate** button → opens Google Maps / Apple Maps / Waze with pickup address
- **Status** button → begins the status flow (Accept → Arrived → etc.)
- Tap card body → expands to show full details (vias, notes, booking ID, driver price)

### Card Colours
- Left border colour matches booking status:
  - Allocated (not yet accepted): `dispatched` purple (`#A78BFA`)
  - Accepted: `available` green (`#34D399`)
  - Active (in progress): `onJob` amber (`#FBBF24`)
  - Completed: `info` blue (`#38BDF8`) at 50% opacity
- Upcoming jobs: full colour. Past/completed jobs: muted.

### Pull to Refresh
Pull down to refresh schedule from API.

---

## Tab 2: Offers

Shows incoming job offers and notifications.

### Job Offer (Full-Screen Takeover)

When a job offer arrives via FCM push, regardless of which screen the driver is on:

```
┌─────────────────────────────────────────┐
│                                         │
│            🚕 NEW JOB OFFER             │
│                                         │
│         ⏱️ 00:45 remaining              │
│                                         │
│  ┌──────────────────────────────────┐   │
│  │                                  │   │
│  │  📅 Today, 14:30                 │   │
│  │                                  │   │
│  │  📍 PICKUP                       │   │
│  │  Stratton Village Hall,          │   │
│  │  The Square, Dorchester Road     │   │
│  │  DT2 9WG                         │   │
│  │                                  │   │
│  │  → DESTINATION                   │   │
│  │  Flat 1, 7 Roman Avenue,         │   │
│  │  Blandford St. Mary              │   │
│  │  DT11 9FU                        │   │
│  │                                  │   │
│  │  👤 Oscar Wedge · 1 pax          │   │
│  │  💵 Cash · Est. £85.77           │   │
│  │  📏 66.4 miles                   │   │
│  │                                  │   │
│  └──────────────────────────────────┘   │
│                                         │
│                                         │
│  ┌─────────────────────────────────┐    │
│  │        ✓  ACCEPT                │    │
│  │        (56px, full-width,       │    │
│  │         brand-500 red)          │    │
│  └─────────────────────────────────┘    │
│                                         │
│  ┌─────────────────────────────────┐    │
│  │        ✗  REJECT                │    │
│  │        (56px, full-width,       │    │
│  │         bg-elevated grey)       │    │
│  └─────────────────────────────────┘    │
│                                         │
└─────────────────────────────────────────┘
```

- **Full-screen modal** — cannot be dismissed except by Accept or Reject
- **Countdown timer** — configurable per tenant (default 60 seconds). Visible ring/bar animation.
- **On timeout:** auto-reject, screen dismisses, operator notified
- **Accept/Reject buttons:** 56px height, full width, bottom of screen. One-thumb reachable.
- **Vibration + sound** on offer arrival (device haptics + `driver_audio.mp3` equivalent)
- **Works from lock screen** via high-priority FCM notification with action buttons

### Offers List (When No Active Offer)

Shows recent offer history:
- Accepted offers (green left border)
- Rejected offers (red left border)
- Timed out offers (grey, "(Timed Out)" label)
- Tap to view job details

### Notifications Sub-Tab
- Messages from operator (direct messages)
- Global messages (broadcast)
- System notifications (booking amendments, cancellations)
- Read/unread indicator

---

## Tab 3: Active Job

Only active when a job is in progress. Shows the current job with status progression.

```
┌─────────────────────────────────────────┐
│                                         │
│  ┌──────────────────────────────────┐   │
│  │         MINI MAP                 │   │
│  │   (pickup pin + current          │   │
│  │    location, route line)         │   │
│  │                        [Expand]  │   │
│  └──────────────────────────────────┘   │
│                                         │
│  📍 PICKUP                              │
│  6 Cobham Road, Blandford Forum         │
│  DT11 7YB                               │
│                                         │
│  → DESTINATION                          │
│  Harbour Vale School, Sherborne         │
│  DT9 4DN                                │
│                                         │
│  VIA: 1 Union Court, Peel Close,        │
│       Blandford                          │
│                                         │
│  👤 Ethan Collins, Kaitlin Dyer · 2 pax │
│  🏢 Harbour Vale School (Account)       │
│                                         │
│  ── Status Progress ──────────────────  │
│  ✅ Accepted                             │
│  ● On Route        ← current            │
│  ○ Arrived                               │
│  ○ Passenger Onboard                     │
│  ○ Completed                             │
│                                         │
│  ┌─────────────────────────────────┐    │
│  │     📍 NAVIGATE TO PICKUP       │    │
│  │     (56px, brand-500 red)       │    │
│  └─────────────────────────────────┘    │
│                                         │
│  ┌─────────────────────────────────┐    │
│  │     ► ADVANCE STATUS             │    │
│  │     (56px, success green)        │    │
│  └─────────────────────────────────┘    │
│                                         │
└─────────────────────────────────────────┘
```

### Mini Map
- Shows pickup location, destination, current driver position
- Route drawn between points
- Tap "Expand" to open full-screen map
- "Navigate" button opens external maps app (Google Maps / Apple Maps / Waze — driver's choice, saved in preferences)

### Status Progression
Visual stepper showing the configurable flow. Per tenant either:
- **Minimal:** Accept → Complete
- **Extended:** Accept → On Route → Arrived → Passenger Onboard → Complete

"Advance Status" button moves to next step. Button label changes to match next status:
- "On Route" (after accepting)
- "I've Arrived" (when on route)
- "Passenger Onboard" (when arrived)
- "Complete Job" (when passenger onboard)

### On Complete
When driver taps "Complete Job", a completion form appears:

```
┌─────────────────────────────────────────┐
│         JOB COMPLETE                    │
│                                         │
│  Waiting Time (minutes)                 │
│  ┌────────────────────────────────┐     │
│  │ 0                              │     │
│  └────────────────────────────────┘     │
│                                         │
│  Parking (£)                            │
│  ┌────────────────────────────────┐     │
│  │ 0.00                           │     │
│  └────────────────────────────────┘     │
│                                         │
│  Final Price (£)     (for rank/cash)    │
│  ┌────────────────────────────────┐     │
│  │ 85.77                          │     │
│  └────────────────────────────────┘     │
│                                         │
│  ┌─────────────────────────────────┐    │
│  │      ✓  CONFIRM COMPLETE        │    │
│  │      (56px, success green)      │    │
│  └─────────────────────────────────┘    │
└─────────────────────────────────────────┘
```

- Waiting time: numeric input (minutes)
- Parking: currency input
- Final price: pre-filled from tariff calculation, editable for rank/cash jobs
- Confirm → sends completion to API → returns to Schedule tab

### COA (Cancel on Arrival)
If driver arrives and passenger is a no-show:
- Long-press on "Advance Status" reveals "Report No-Show (COA)" option
- Or accessible via ⋮ menu on the active job screen
- Confirmation dialog → sends COA to API

---

## Tab 4: Availability

Simple screen to set availability for today and upcoming days.

```
┌─────────────────────────────────────────┐
│  My Availability                        │
│                                         │
│  ┌─ Today (Mon 16 Mar) ───────────┐    │
│  │  ✅ Available                    │    │
│  │  07:00 — 18:00                  │    │
│  │  [Edit]                         │    │
│  └──────────────────────────────────┘    │
│                                         │
│  ┌─ Tomorrow (Tue 17 Mar) ────────┐    │
│  │  ❌ Not Set                      │    │
│  │  [Set Availability]             │    │
│  └──────────────────────────────────┘    │
│                                         │
│  ┌─ Wed 18 Mar ───────────────────┐    │
│  │  ✅ Available                    │    │
│  │  07:30 — 09:30 (AM School)     │    │
│  │  14:30 — 16:30 (PM School)     │    │
│  │  [Edit]                         │    │
│  └──────────────────────────────────┘    │
│                                         │
│  [+ Add Availability]                   │
│                                         │
│  ── Quick Set ────────────────────────  │
│  [Full Day] [AM Only] [PM Only]         │
│  [School AM+PM] [Unavailable]           │
└─────────────────────────────────────────┘
```

### Features
- Shows 7 days ahead (scrollable)
- Each day shows current availability blocks (or "Not Set")
- Quick Set buttons match the dispatch console presets (Custom, SR AM Only, SR PM Only, SR Only, Unavailable)
- Edit opens a time picker for custom start/end times
- Multiple blocks per day supported (morning + afternoon school runs)
- Changes sync immediately to API → operator sees in dispatch console

---

## Tab 5: Earnings

```
┌─────────────────────────────────────────┐
│  Earnings                               │
│                                         │
│  ┌──────────────────────────────────┐   │
│  │  Today              This Week    │   │
│  │  £142.50            £687.30      │   │
│  │  6 jobs             24 jobs      │   │
│  └──────────────────────────────────┘   │
│                                         │
│  ── Today's Jobs ──────────────────────  │
│                                         │
│  07:30  Cobham Rd → HVS          £47.51 │
│  08:10  HVS → Waverland Terr.   £60.31 │
│  09:15  Gillingham Stn → Mere   £34.68 │
│  14:30  Stratton VH → Blandford  —      │
│  15:15  HVS → Stalbridge         —      │
│  16:00  HVS → Cobham Rd          —      │
│                                         │
│  ── This Week ─────────────────────────  │
│  [Mon £142]  [Tue £0]  [Wed £0]        │
│  [Thu £0]    [Fri £0]  [Sat £0] [Sun]  │
│                                         │
│  ── Statements ────────────────────────  │
│  📄 Week 10 (4-10 Mar)    £543.20 [PDF] │
│  📄 Week 9 (25 Feb-3 Mar) £612.80 [PDF] │
│  📄 Week 8 (18-24 Feb)    £498.50 [PDF] │
└─────────────────────────────────────────┘
```

### Features
- Today's earnings + this week's earnings (hero numbers, large font, `2xl`)
- Today's completed jobs with prices (tabular numerals)
- Weekly mini bar chart (tap a day to see that day's jobs)
- Statement history: tap to view PDF, download, or share
- Commission shown separately if applicable

---

## Additional Screens (Behind Menu / Profile)

Accessible from the Settings gear icon on Schedule tab header:

| Screen | Content |
|--------|---------|
| Profile | Name, phone, vehicle details, licence, colour |
| Documents | Upload/view: licence, insurance, MOT, badge. Expiry dates with warnings. |
| Vehicle | Vehicle type, reg number, colour, passengers capacity |
| Expenses | Add expense (fuel, wash, etc.), view expense history |
| Messages | View all operator messages (direct + global) |
| Preferences | Default maps app (Google/Apple/Waze), notification sounds on/off, dark/light mode |
| Shift Log | Clock in/out history |
| About | App version, support contact |

---

## Push Notifications

| Event | Notification Type | Sound | Behaviour |
|-------|-------------------|-------|-----------|
| Job Offer | High priority (heads-up) | Custom alert tone | Full-screen takeover |
| Booking Amended | Normal | Notification ping | Badge on Offers tab |
| Booking Cancelled | Normal | Notification ping | Badge on Offers tab, remove from Schedule |
| Booking Unallocated | Normal | Notification ping | Badge on Offers tab, remove from Schedule |
| Operator Message | Normal | Notification ping | Badge on Offers tab |
| Global Message | Normal | Notification ping | Badge on Offers tab |
| Document Expiry Warning | Normal | None | Badge on Settings |

---

## Background Services

### GPS Tracking
- Reports driver position to API every 10 seconds when on shift
- Uses `geolocator` plugin with background location permission
- Battery-efficient: reduces frequency when stationary (every 30s if speed = 0)
- GPS data: lat, lng, speed (mph), heading, timestamp

### FCM Push
- Firebase Cloud Messaging for all push notifications
- High-priority channel for job offers (bypasses Do Not Disturb)
- Normal channel for everything else
- Token registered on login, refreshed on app launch

### Shift Tracking
- Driver clocks in (top of Schedule screen or auto on first job acceptance)
- Clocks out manually or auto after configurable idle period
- Shift status visible to dispatch console

---

## Offline Behaviour

- Schedule cached locally — viewable without connection
- Job status updates queued locally if offline, synced when reconnected
- GPS data buffered locally, batch-uploaded on reconnection
- Job offers require connectivity (if offline, offer times out)
- Clear "No Connection" banner at top of screen when offline

---

## Implementation Notes for Claude Code

1. **Flutter with Provider pattern** (matching the existing app architecture — providers + repositories)
2. **Same design-tokens.json** as dispatch console. Generate a Dart `AppColors` / `AppTheme` class from the tokens.
3. **Navigation:** `BottomNavigationBar` with 5 items. Use `go_router` for nested navigation within each tab.
4. **Job offer takeover:** Use a `OverlayEntry` or dedicated route that blocks back navigation until Accept/Reject.
5. **Maps:** `google_maps_flutter` for mini-maps. External navigation via `url_launcher` to Google Maps / Apple Maps / Waze.
6. **Push:** `firebase_messaging` + `flutter_local_notifications`. High-priority channel for job offers.
7. **GPS:** `geolocator` with `LocationSettings(distanceFilter: 10)` for battery efficiency.
8. **API client:** Use the same endpoint contract as dispatch console. Auth via JWT stored in `flutter_secure_storage`.
9. **Offline:** `hive` or `sqflite` for local cache. Queue pattern for pending status updates.
10. **All number displays** use tabular numerals (`fontFeatures: [FontFeature.tabularFigures()]`).
