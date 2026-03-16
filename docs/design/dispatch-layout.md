# Red Taxi Dispatch Console — Layout Concept

## Design Philosophy

The dispatch console is a **command centre**, not a form-filling application. The operator's primary view is the live situation — where drivers are, what bookings are coming up, what needs attention. The booking form is a tool they invoke when needed, not a permanent fixture.

**Inspiration:** Air traffic control interfaces, Figma's floating panels, Linear's command palette, Bloomberg Terminal's information density.

---

## Layout: Map-Centric with Floating Panels

```
┌─────────────────────────────────────────────────────────────────────┐
│ ◄ Sidebar   [🔍 Cmd+K Search]    [⚡ 4 Unallocated]  [🔔 3]  [SA]  [👤] │
│ (64px)  ────────────────────────────────────────────────────────────│
│ │       ┌─────────────────────────────────────────────────────────┐ │
│ │ 🏠    │                                                         │ │
│ │       │              LIVE MAP (FULL WIDTH)                      │ │
│ │ 📋    │                                                         │ │
│ │       │     Driver pins (status coloured)                       │ │
│ │ 👥    │     Active booking routes                               │ │
│ │       │     Click pin → driver card flyout                      │ │
│ │ 🚗    │                                                         │ │
│ │       │  ┌──────────────┐                                       │ │
│ │ 💰    │  │ BOOKING FORM │ ← Floating panel, slides in from     │ │
│ │       │  │ (appears on  │   left on Cmd+N or "New Booking"     │ │
│ │ 📊    │  │  demand)     │   click. Dismissable. Draggable.     │ │
│ │       │  │              │                                       │ │
│ │ ⚙️    │  └──────────────┘                                       │ │
│ │       │                                                         │ │
│ │       ├─────────────────────────────────────────────────────────┤ │
│ │       │  TIMELINE BAR (bottom dock, ~200px height)              │ │
│ │       │  ┌─────┬─────┬─────┬─────┬─────┬─────┬─────┬─────┐    │ │
│ │       │  │07:00│08:00│09:00│10:00│11:00│12:00│13:00│14:00 │    │ │
│ │       │  │ ██  │████ │ ██  │     │ █   │████ │     │ ██   │    │ │
│ │       │  │     │ ██  │████ │ ██  │     │ █   │ ██  │████  │    │ │
│ │       │  └─────┴─────┴─────┴─────┴─────┴─────┴─────┴─────┘    │ │
│ │       │  [Driver rows: coloured blocks per booking]             │ │
│ │       └─────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────────┘
```

---

## Core Concepts

### 1. The Map is the Primary View
The map fills the entire content area. Everything else floats on top of it or docks to edges. The operator always has spatial awareness of their fleet.

- Driver pins show real-time GPS positions with status colours
- Active booking routes drawn on the map
- Click a driver pin → flyout card showing their current job, next job, availability
- Click a booking route → flyout card showing booking details, allocate/cancel actions
- Unallocated bookings pulse on the map at their pickup location

### 2. The Timeline (Bottom Dock)
A horizontal timeline/Gantt bar docked to the bottom of the screen. Shows the next 8-12 hours:

- Each row = one driver
- Each block = one booking (coloured by status)
- Drag bookings between driver rows to reallocate
- Drag to resize (change pickup time)
- Click a block → booking detail flyout
- Current time = vertical red line
- Collapsible — double-click bottom edge to expand/collapse
- Can be expanded to full-height "Diary Mode" (traditional scheduler view)

### 3. The Booking Form (Floating Panel)
Not permanently visible. Invoked by:
- `Cmd+N` / `Ctrl+N` keyboard shortcut
- "New Booking" button in top bar
- Phone lookup trigger (incoming call auto-opens form with caller data)

The form slides in from the left as a floating panel (480px wide):
- Semi-transparent backdrop (map still visible)
- All fields visible without scrolling
- Real-time price calculation as addresses are entered
- Mini route preview on the map behind the form
- Confirm creates the booking and dismisses the form
- Escape dismisses without saving

### 4. Command Palette (Cmd+K)
A spotlight-style search that can do everything:
- Search bookings: "booking 134567" or "pickup gillingham"
- Search drivers: "driver andrew" or "driver 14"
- Search customers: "07700900123" or "smith"
- Quick actions: "new booking", "send global message", "confirm soft allocates"
- Navigation: "go to reports", "go to accounts"

This replaces the legacy search modal with something faster and more flexible.

### 5. Right-Side Panel (Context Panel)
When you click anything (driver pin, booking block, customer), a detail panel slides in from the right (400px):
- Booking detail: full info, action buttons (allocate, cancel, complete, duplicate, amend)
- Driver detail: current job, next jobs, today's earnings, availability, send message
- Customer detail: phone, address, booking history, repeat bookings

The panel is dismissable (Escape or click outside). Only one panel open at a time.

---

## Sidebar (64px — Icon Only by Default)

Slim icon sidebar, always visible:

| Icon | Page | Shortcut |
|------|------|----------|
| 🏠 | Dashboard | `Cmd+1` |
| 📋 | Dispatch (map + timeline) | `Cmd+2` |
| 👥 | Accounts | `Cmd+3` |
| 🚗 | Drivers | `Cmd+4` |
| 💰 | Billing & Payments | `Cmd+5` |
| 📊 | Reports | `Cmd+6` |
| ⚙️ | Settings | `Cmd+7` |

Hover on icon → tooltip with page name.
Click → navigates to full page.
Dispatch page is the default/home view.

The sidebar expands to 240px on hover (showing labels) — slides back to 64px when mouse leaves. This maximises map space.

---

## Top Bar (48px)

Slim, information-dense:

```
[≡ Logo]  [🔍 Search... Cmd+K]  [⚡ 4 Unallocated] [📱 SMS ✓] [🔔 3] [CONF SA] [👤 Peter ▾]
```

| Element | Purpose |
|---------|---------|
| Logo | "redtaxi" wordmark, clicking returns to dispatch |
| Search | Command palette trigger, always accessible |
| Unallocated badge | Live count of unallocated bookings — click to list them |
| SMS heartbeat | Green tick = healthy, red X = gateway down |
| Notifications bell | Count badge, dropdown with driver/system/booking alerts |
| CONF SA | Confirm Soft Allocates button (only visible when soft allocates exist) |
| User avatar | Dropdown: dark mode toggle, notifications toggle, ticket raise, logout |

---

## Keyboard-First Design

Dispatch operators are fast typists. Every primary action has a keyboard shortcut:

| Shortcut | Action |
|----------|--------|
| `Cmd+K` | Command palette (search everything) |
| `Cmd+N` | New booking form |
| `Cmd+Enter` | Confirm/save current form |
| `Escape` | Close any floating panel |
| `Cmd+S` | Confirm all soft allocates |
| `Cmd+M` | Global message |
| `F1` | Toggle timeline expand/collapse |
| `F2` | Toggle map fullscreen |
| `1-9` | (When booking selected) Allocate to driver by number |
| `Tab` | Cycle through unallocated bookings |

---

## View Modes

The dispatch page supports three modes, toggleable:

### 1. Map Mode (Default)
Full map + bottom timeline + floating panels. Best for monitoring fleet and ad-hoc dispatch.

### 2. Diary Mode
Full-screen traditional scheduler (expanded timeline). Rows = drivers, columns = time blocks. Best for planning school runs and pre-allocated days. Map becomes a small mini-map in corner.

### 3. Split Mode
50/50 vertical split — map on top, diary on bottom. Compromise for operators who want both. 

Toggle via buttons in top bar or keyboard shortcuts.

---

## Responsive / Multi-Monitor

Dispatch operators often have 2+ monitors:
- **Pop-out support:** Map, timeline, and booking form can each be popped out to separate browser windows
- **Persistent state:** Pop-out windows maintain real-time SignalR connection
- This means: Map on monitor 1, diary on monitor 2, both live-updating

---

## Dashboard Page

When navigating to Dashboard (not dispatch), show:
- KPI cards (today's bookings, unallocated, revenue, drivers active, new/returning customers)
- Driver earnings table (today + week)
- Booking stats by operator
- Earnings chart (7-day trend)
- Quick links: New Booking, View Unallocated, Process Invoices

The dashboard is an overview. The dispatch page is where work happens.

---

## Notification System

### Toast Notifications (Bottom Right)
- New web booking submitted → toast with "Accept / Reject" actions
- Driver accepted job → toast with driver name + booking ID
- Driver rejected → toast with "[R]" warning
- Auto-dismiss after 5 seconds unless actionable

### Audio Alerts
- New web booking: `new_web_booking.mp3`
- Driver event: `driver_audio.mp3`  
- System alert: `system_audio.mp3`
- General: `notification_ping.mp3`

### Notification Centre (Bell Dropdown)
Tabs: All | Drivers | Bookings | System
Scrollable list, mark as read, click to navigate to relevant item.

---

## Implementation Notes for Claude Code

1. The map is the base layer. Use Google Maps JavaScript API with custom dark styling from design tokens.
2. Floating panels use absolute positioning over the map. NOT a CSS grid/flexbox split — the map must be truly full-width behind everything.
3. The timeline/Gantt uses Syncfusion SfSchedule in TimelineDay view, docked to bottom with configurable height.
4. Command palette: custom Blazor component, not a Syncfusion control. Modal overlay with fuzzy search (Fuse.js pattern).
5. All panels animate: slide-in from left (booking form), slide-in from right (detail panel), slide-up from bottom (timeline expand). Use CSS transitions, 200ms ease-out. These are the ONLY animations in the app.
6. SignalR pushes all updates — driver GPS, booking status changes, new bookings. No polling.
7. Pop-out windows via `window.open()` with SharedWorker or BroadcastChannel for state sync.
