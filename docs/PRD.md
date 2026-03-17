# Red Taxi Platform — Product Requirements Document

**Version:** 2.0  
**Status:** Active  
**Last Updated:** 2026-03-16  
**Initial Tenant:** Ace Taxis (Dorset)

---

## 1. Product Vision

Red Taxi is a cloud-based taxi dispatch platform that replaces legacy dispatch systems and operates as a multi-tenant SaaS product. The first deployment must fully replicate the current Ace Taxis operational workflow before enabling SaaS onboarding for additional operators.

The platform provides: booking management, intelligent dispatch, driver mobile applications, real-time GPS tracking, automated customer communication, account billing, reporting/analytics, a customer web booking portal, and a foundation for future AI automation.

---

## 2. Objectives

| Priority | Objective |
|----------|-----------|
| P0 | Replicate Ace Taxis operational behaviour exactly |
| P0 | Three frontends at launch: dispatch console, driver app, customer booking portal |
| P1 | Eliminate technical debt (god services, logic in controllers, single-tenant design) |
| P1 | Tenant import wizard so Ace migrates seamlessly |
| P2 | Multi-tenant SaaS onboarding for new operators |
| P3 | AI automation features (voice booking, auto-dispatch, demand forecasting) |

---

## 3. Problems With Current System

The existing Ace system (repo: `taxis_ace_refactor`) suffers from:

- **God services**: `BookingService` (2,142 lines), `AccountsService` (2,247 lines) mix booking, pricing, messaging, dispatch, and COA logic
- **Business logic in controllers**: thin controllers call fat services but routing/validation bleeds across boundaries
- **Hard-coded Ace rules**: pricing, messaging templates, and company config are not tenant-configurable
- **Inconsistent DTOs**: 175KB of DTOs with naming inconsistencies and unused types
- **Single-tenant design**: tenancy scaffolding exists (header-based `X-Tenant-Id`, per-tenant DB mode) but no data isolation, no provisioning workflow
- **Minimal testing**: only structural/guardrail tests exist, no business logic coverage
- **No CI/CD pipeline**: manual deployment via IIS

---

## 4. Core Modules

### 4.1 Booking Management
Create, edit, duplicate, cancel, and complete bookings. Supports single bookings, return bookings, repeat bookings (daily/weekly/fortnightly with day selection and end date), and ASAP bookings.

### 4.2 Dispatch & Driver Allocation
Manual allocation (operator selects driver from list), soft allocation (tentative assignment), drag-and-drop diary allocation. School run merge: operators can drag school bookings onto each other when they share the same destination + account — the merged booking's pickup becomes a via stop.

### 4.3 Pricing & Tariff Engine
Auto-calculates price on any booking field change. Supports standard tariffs, night tariffs, airport tariffs, and per-account custom tariffs. Uses Google Distance Matrix for mileage/duration (averages A→B and B→A).

### 4.4 Driver Availability
Drivers declare availability via: app login, pre-declared shift schedules, calling dispatch, or operator manual override. States: Offline, Available, Busy, On Job, Break, Unavailable. Availability grid shows all drivers with time blocks.

### 4.5 Corporate Accounts
Business accounts with custom tariffs, monthly invoicing, passenger lists, and web booking access. Account jobs track two prices: `PriceAccount` (invoice amount) and `Price` (driver payout).

### 4.6 Messaging & Notifications
SMS (Twilio), WhatsApp, push notifications (FCM). Automated messages on: booking confirmation, driver allocation, driver arrival, journey completion, payment links. Operator can send custom/scheduled messages.

### 4.7 Payment Links
Revolut integration for sending payment links to customers. Track payment status, resend requests, send receipts. Future: Stripe, GoCardless.

### 4.8 Reporting & Settlement
Driver earnings, account invoicing, driver statements, profitability reports, booking breakdowns by scope/period, VAT outputs, credit notes. Driver commission is calculated at settlement, not booking level.

### 4.9 Driver Mobile Application
Receive job notifications, accept/reject, navigate, update status, upload compliance documents, GPS tracking in background. Must support reliable background GPS and push notifications.

### 4.10 Customer Web Booking Portal
Public-facing booking interface for cash customers and authenticated account customers. Address autocomplete, price quote, booking submission, amendment requests, cancellation requests.

### 4.11 Multi-Tenant SaaS
Each operator is a tenant with isolated data, custom tariffs, drivers, branding, and integrations. Tenant import wizard for migrating from existing systems. Pricing tiers based on drivers, volume, and enabled modules.

---

## 5. Operator Dispatch Interface

The dispatch console has four primary tabs (bottom navigation):

### Availability
- Grid view: hours on Y-axis, drivers on X-axis
- Colour-coded blocks showing declared availability per driver
- Shows driver name, number, vehicle type (Saloon/Estate/SUV/MPV)
- "Use Old Driver Availability" toggle for copying previous day's pattern
- Click driver to set/edit availability

### Driver Status
- Same grid layout as availability but shows allocated bookings overlaid on availability
- Colour-coded per driver (each driver has a unique RGB colour)
- Hatched pattern = completed jobs
- Booking cards show pickup → destination text

### Booking
- Full booking form: date/time, ASAP toggle, return toggle, repeat booking config
- Pickup address + postcode with autocomplete (Ideal Postcodes + address lookup)
- Destination address + postcode with autocomplete
- Swap addresses button
- Booking details (free text)
- Arrive By toggle + Calculate Pickup button
- Add VIA stops (modal: address + postcode per via, orderable)
- Driver Price (£) — auto-calculated, manually overridable
- Manually Priced checkbox
- Passengers count
- All Day checkbox
- Reset Price button
- Name, Hours, Minutes (journey duration)
- Email, Phone + Lookup button (finds customer by phone)
- Confirmation status dropdown
- Scope dropdown: Cash, Account, Rank, Card
- Account number (shown when scope = Account)
- Allocate Driver button
- Action buttons: Cancel On Arrival, Send Quote, Cancel, Create

### Diary
- Calendar timeline view (day view)
- Columns per driver showing their bookings as blocks
- Click booking to open detail popup
- Show Allocated / Show Completed toggles
- Month navigation

### Booking Detail Popup
Shows: booking number, scope badge (CASH/ACCOUNT), pickup details, destination, passenger info, journey details (type, allocated driver, price, time, distance with dead miles vs trip miles breakdown), payment status with Send Payment Link / Resend buttons, confirmation status, booked by + date.

Action buttons: Soft Allocate, Allocate Booking, Edit Booking, Duplicate Booking, Driver Arrived, Complete Booking, Cancel Booking.

### Menu
Booking, Diary, Merge Mode toggle, Logs, COA Entries, Search, No (turn-downs), Text Message, Ticket Raise, Logout.

---

## 6. Booking Lifecycle

```
Created → Allocated → Accepted → Driver En Route → Driver Arrived → Passenger Onboard → Completed
                                                                                      ↘ Cancelled
                                                                                      ↘ No Show / COA
```

Each transition triggers: booking status update, driver availability update, optional messaging (configurable per event), UI notification to dispatch console.

---

## 7. Pricing Model

### Cash / Rank / Card Jobs
- Single price calculated = driver price
- Company earns via **commission** charged to driver at settlement time
- Commission rate is a driver-level or company-level config

### Account Jobs
- Two prices on every booking:
  - `PriceAccount` — what the account is invoiced
  - `Price` — what the driver is paid
- Account may have custom tariffs overriding default rates
- Changing account number triggers price recalculation

### Price Calculation
- Uses Google Distance Matrix API
- Averages A→B and B→A distances for fairness
- Tariff applied: base fare + (miles × per-mile rate) + (minutes × per-minute rate)
- Recalculates on any change to: pickup, destination, vias, passengers, vehicle type, account number
- Manual override available (sets `ManuallyPriced = true`, locks auto-recalc)

### Tariff Components
- Base fare
- Per mile rate
- Per minute rate  
- Minimum fare
- Waiting time charge
- Passenger surcharge
- Airport surcharge
- Dead miles tracking (total miles = dead miles + trip miles)

---

## 8. COA (Cancel on Arrival) Rules

COA is triggered when a passenger doesn't show up after the driver has arrived.

- Account jobs: account may be billed the **full fare** (they booked, their passenger no-showed)
- Driver: paid a **reduced amount** (didn't complete the full journey)
- COA records are tracked separately (`COARecord` table)
- COA pricing is per-booking: operator can adjust the account charge and driver payout independently

---

## 9. School Run Behaviour

School bookings are regular bookings with a school-run tag/flag.

**Special dispatch behaviour:** When multiple school bookings share the same destination AND the same account, operators can drag one booking onto another in the diary view to **merge** them. The merged booking's pickup address becomes a via stop on the target booking. This is a dispatch UI feature, not a backend auto-merge.

Drivers may have availability patterns like "AM School Only" or "PM School Run" indicating they only work school run slots.

---

## 10. Substitute Drivers

Drivers from other taxi companies who take Ace jobs. Same as normal drivers in the system but flagged as substitutes. Same payment rules, same dispatch workflow. The flag enables separate reporting and filtering.

**Important distinction:** Substitute drivers are NOT the same as partner-company coverage. A substitute is a person temporarily operating under the tenant's dispatch control. Partner coverage is a booking fulfilled by another company entirely. These need different records, permissions, and settlement logic.

---

## 11. Partner Network / Cross-Tenant Job Sharing

Taxi companies frequently need to share work — own fleet at capacity, geographic convenience, out-of-area pickups, night/weekend coverage, or reciprocal agreements.

### Partner Model
- Each tenant can register partner relationships with other tenants on the platform
- Partners have defined coverage rules and commercial terms
- Partner data is isolated — no accidental cross-tenant data leakage

### Cover Request Flow
1. Source tenant's dispatcher (or auto-escalation rule) creates a cover request
2. Target tenant receives the request with booking details and offered price
3. Target tenant accepts or declines
4. If accepted, target tenant dispatches from their own fleet
5. Source tenant retains visibility into job progress (appropriate to relationship level)
6. Settlement record generated per agreed rules

### Settlement Models
- Fixed referral fee (e.g. £5 per job)
- Percentage split (e.g. source keeps 15%, partner gets 85%)
- Net fulfilment price (partner quotes their price, source marks up to customer)
- Account customer pass-through (account rate applies, split agreed separately)

### No-Driver Escalation Path
1. Internal driver pool exhausted
2. Substitute driver pool checked (if configured)
3. Partner companies offered the job (priority order or broadcast)
4. If no partner accepts within timeout, booking flagged as unallocated exception

---

## 12. Dispatch Scoring Engine

Beyond manual dispatch, the system supports assisted and (future) automatic dispatch using a weighted scoring model.

### Candidate Scoring Inputs
- Driver availability state (gate: must be eligible)
- Vehicle compatibility (gate: must match requirements)
- Estimated distance to pickup
- Estimated time to pickup (ETA)
- Driver shift status and remaining hours
- Recent workload / fairness balancing
- Customer-driver affinity (if repeat customer has preferred driver)
- Job priority level
- Penalty for recently declined jobs
- Partner option only after internal scores fall below threshold or timeout

### Dispatch Flow
1. Booking becomes dispatchable
2. System validates booking completeness
3. Internal driver candidate pool generated
4. Scores calculated per above inputs
5. Dispatcher sees ranked recommendations (or system auto-assigns if policy permits)
6. If no viable internal driver → escalate (substitute → partner → unallocated exception)
7. Assigned driver notified
8. Booking state updated through lifecycle

For v1: manual dispatch with scored suggestions displayed. Auto-dispatch is Phase 3+.

---

## 13. White-Label Booking Websites

Each tenant can have one or more branded booking websites that feed directly into the dispatch system.

### Website → Dispatch Pipeline
1. Customer lands on tenant's branded website (SEO-optimised route/area pages)
2. Customer requests a quote or books directly
3. Booking data posts into the dispatch platform via API
4. Operator confirms (or future: automated acceptance rules)
5. Booking enters dispatch queue

### SEO Strategy
- Auto-generated landing pages per route (e.g. "Taxi from Shaftesbury to Bristol Airport")
- Local area pages for organic search
- Structured data for Google search visibility
- Each page has an embedded booking form that feeds into the platform

### Commercial Value
Combining lead generation websites + booking conversion + dispatch fulfilment + reporting creates a stronger SaaS than dispatch alone. This is a key differentiator.

For v1: API endpoint for website booking ingestion. White-label website builder is Phase 4+.

---

## 14. Customer Directory

Unlike the legacy system (which stores passenger details directly on bookings), Red Taxi introduces a proper Customer entity.

### Customer Record
- Name, phone, email
- Account type (casual, regular, business account)
- Default pickup notes / preferences
- Saved addresses
- Marketing source (how they found us)
- Booking history (derived)
- Notes

### Benefits
- Phone lookup instantly populates booking form (existing "Lookup" feature, but backed by a real customer record)
- Repeat customer recognition
- Account customer linking
- Marketing source tracking for website-generated leads
- Future: customer self-service portal, loyalty

---

## 15. WhatsApp Chatbot Booking Channel (Phase 2+)

Customers can book taxis via WhatsApp conversation with an AI-powered chatbot.

### Flow
1. Customer messages the tenant's WhatsApp Business number
2. Chatbot greets customer, asks for pickup and destination
3. Bot extracts addresses, validates, calls pricing engine for quote
4. Customer confirms booking
5. Booking created in dispatch system as a WebBooking (pending or auto-accepted based on config)
6. Customer receives confirmation message with booking details
7. On dispatch: driver allocated notification sent via same WhatsApp thread
8. Driver arrival / journey updates sent conversationally

### Chatbot Capabilities
- Natural language address extraction
- Price quoting
- Booking creation and confirmation
- Booking status enquiry ("Where's my taxi?")
- Cancellation requests
- Handoff to human operator for complex queries

### Technical Approach
- WhatsApp Business API (existing Twilio integration)
- AI layer (Claude or similar) for conversation management
- Structured tool calls to booking/pricing APIs
- Conversation state managed per customer phone number
- Falls back to operator notification if bot confidence is low

For v1: WhatsApp remains one-way notifications only. Chatbot booking is Phase 2/3.

---

## 16. Implementation Phases

### Phase 1 — Core Dispatch (Weeks 1-4)
- Backend: Booking CRUD, pricing engine, driver availability, dispatch/allocation
- Customer directory with phone lookup
- Blazor dispatch console: booking form, diary view, availability grid, driver status
- Auth: JWT + Identity with role-based access
- Database: EF Core migrations, tenant database created on provisioning

### Phase 2 — Accounts, Messaging & Web Portal (Weeks 5-6)
- Account management, invoicing, statements, credit notes
- SMS/WhatsApp/Push notification system (one-way)
- Payment link integration (Revolut)
- Customer web booking portal
- Substitute driver flagging and reporting

### Phase 3 — Driver App & Reporting (Weeks 7-8)
- Flutter driver app: login, jobs, accept/reject, navigation, GPS tracking, document upload
- Reporting module: earnings, profitability, booking breakdowns, VAT
- Dispatch scoring engine (assisted suggestions for operators)

### Phase 4 — SaaS & Migration (Weeks 9-12)
- Tenant import wizard (Ace SQL Server → Red Taxi)
- Tenant provisioning workflow
- Tenant-level config: branding, tariffs, messaging templates
- Subscription billing integration
- SaaS packaging: Solo / Team / Fleet / Enterprise plans with bolt-on marketplace

### Phase 5 — Partner Network & Job Sharing (Weeks 13-16)
- Partner company registry and relationship management
- Cover request workflow (create, accept, decline)
- Cross-tenant job assignment with visibility controls
- Settlement engine: referral fee, percentage split, net fulfilment
- Partner job audit trail and reporting
- No-driver escalation path (internal → substitute → partner)

### Phase 6 — White-Label Websites & Booking Channels (Weeks 17-20)
- Public booking API for website ingestion
- WhatsApp chatbot booking channel (AI-powered conversational booking)
- White-label website builder (SEO route pages, area pages, embedded booking forms)
- Booking source tracking and attribution reporting

### Phase 7+ — AI & Growth (Future)
- AI voice booking agent (phone intake)
- Auto-dispatch (fully automated assignment based on scoring engine)
- Dynamic pricing engine
- Demand forecasting
- Driver monitoring/scoring
- AI operator copilot (natural language queries, anomaly detection)
- Proactive partner coverage recommendations

---

## 12. Performance Requirements

- Support 100+ drivers per tenant
- 1,000+ daily bookings per tenant
- Real-time diary updates < 500ms latency
- GPS tracking updates every 5-10 seconds
- System uptime target: 99.9%

---

## 13. Open Questions

| # | Question | Status |
|---|----------|--------|
| 1 | Exact tariff rate values for Ace (base fare, per-mile, etc.) | Pending — can extract from legacy `Tariff` table |
| 2 | Commission rate structure (flat % or tiered?) | Pending |
| 3 | Web booking portal auth flow for account customers | Pending |
| 4 | Revolut API version and webhook setup details | Can extract from legacy code |
| 5 | Flight tracking integration for airport pickups | Pending — future phase? |
| 6 | Live driver map timing — Phase 1 or later? | Pending |

---

## 17. Master Tenant / Network Dispatch (Phase 5+)

The system will support a Master Tenant concept — a central marketplace that receives bookings from shared booking channels and distributes them to participating operators.

### Flow
1. Customer books through the marketplace (e.g. "First Taxis" brand)
2. Master tenant receives the booking
3. Job broadcast to participating operators based on rules (geographic radius, fastest acceptance, operator preference)
4. Operators accept or reject
5. Accepted operator dispatches from their fleet

First real-world use case: **First Taxis** — a network brand that distributes jobs to member taxi companies.

This extends the Partner Network model — the master tenant is essentially a specialised tenant that only distributes, never fulfils directly.

---

## 18. Telephony / Caller ID Integration

### Caller ID Booking Pop
When an inbound call is answered, the system:
1. Detects the caller's phone number
2. Looks up customer in the Customer Directory
3. If found: displays customer details + current bookings + previous bookings
4. Operator can select a previous booking and click "Confirm" to repeat it instantly
5. If not found: opens a new booking form pre-populated with the phone number

### VoIP Integration
The platform integrates with external VoIP providers (not hosting its own):
- 3CX
- V4Voip
- Other SIP-based providers

Requirements: detect inbound caller number, trigger booking pop, identify which operator answered.

Must work on both desktop and mobile dispatch interfaces.

---

## 19. Multi-Mode Dispatch

The platform supports three dispatch modes to suit different operator types:

### Grid Dispatch
Traditional dispatch board showing open jobs, driver status, and assignments. Used by busy dispatch offices with multiple operators.

### Diary / Scheduler Dispatch
Calendar-based dispatch (the current Ace system's primary mode). Used for airport bookings, pre-bookings, school contracts, account journeys. Split-screen: booking form left, scheduler/map right.

### Mobile Dispatch
Designed for rural operators and owner-drivers who answer calls while driving. Features: fast booking creation, minimal typing, caller ID pop, repeat booking shortcuts, view active bookings. This is a simplified mobile-first interface, not the full dispatch console.

---

## 20. AI Website Builder & Marketing Automation (Phase 6+)

### AI Website Builder
Each tenant can generate a branded booking website automatically, powered by AI tools (e.g. Lovable). Capabilities: automatic design using tenant branding, embedded booking engine, SEO-optimised structure. This is a paid module.

### SEO Content Automation
The system generates ongoing SEO content: service pages, location pages, airport transfer route pages (e.g. "Taxi Bath to Heathrow", "Taxi Gillingham to Bristol Airport"). Content generation runs on configurable schedule (weekly/monthly).

### Social Media Automation
AI-generated social media posts for Facebook, Instagram, and X. Configurable posting frequency (weekly/bi-weekly/monthly). Content based on routes served, testimonials, seasonal messaging.

---

## 21. External Booking Channel Integrations (Phase 6+)

The platform integrates with third-party booking sources:
- Booking.com
- Hotel booking systems
- Travel platforms
- Airport transfer aggregators

Bookings flow directly into dispatch. Can be used by master tenant or individual tenants.

---

## 22. Provider Configuration System

Tenants can either use their own provider accounts or platform-bundled services:

| Service | Own Provider | Platform Bundled |
|---------|-------------|-----------------|
| SMS | TextLocal, own Twilio | Platform SMS bundle |
| Address lookups | Own Google Maps key, own postcode API | Platform address service |
| Email | Own SendGrid | Platform email service |
| Payments | Own Stripe/Revolut | Platform payment processing |
| Maps | Own Google Maps | Platform maps |

This enables the SaaS to offer bundled services at margin while letting larger operators use their own accounts.

---

## 23. Keyboard Shortcuts (Dispatch Console)

The desktop dispatch console supports keyboard shortcuts for speed:

| Key | Action |
|-----|--------|
| F1 | Switch to Map view |
| F2 | Switch to Scheduler view |
| F3 | Open Messages |

Additional shortcuts TBD based on operator feedback.

---

## 24. Dispatch Console Desktop Layout

Split-screen layout:
- **Left panel**: Booking form (new booking / edit booking)
- **Right panel**: Tabbed view with MAP, SCHEDULER, LOGS, COA ENTRIES

### Map Tab
Shows Google Maps route A→B with journey cost panel displaying:
- Charge From Base (Yes/No)
- Journey Time
- Journey Mileage with dead miles vs trip miles breakdown
- Applied tariff name

### Scheduler Tab
Day view calendar with driver columns, booking blocks, COA banners at top. Toggles: Show Allocated, Show Completed, Merge Mode. Views: Day / Agenda.

### Logs Tab
Two sub-tabs: Booking Logs (action history) and Action Logs. Paginated table: DateTime, Booking#, User, Action. Actions tracked: Booking Created, Allocated, Updated, Marked as Completed, Driver Arrived (Sent).

### COA Entries Tab
Table of cancel-on-arrival records: COA Date/Time, Journey Date/Time, Pickup Address, Passenger, Account number.

### Top Bar
Ticket Raise, NO (turn-down), Text Message, Search, notification bell, Logout. Confirm SA (Confirm Soft Allocates) button.

---

## 25. Complete Booking Sources

All channels through which bookings can enter the system:

| # | Source | Phase | Description |
|---|--------|-------|-------------|
| 1 | Operator phone entry | 1 | Dispatcher creates booking during/after phone call |
| 2 | Dispatch console direct | 1 | Operator creates booking proactively |
| 3 | Customer web portal | 2 | Account customers submit via branded portal |
| 4 | Cash web booking | 2 | Public customers via website booking form |
| 5 | Repeat from phone lookup | 1 | Operator selects previous booking from caller ID popup |
| 6 | Rank pickup (driver-created) | 1 | Driver records rank job after pickup |
| 7 | Recurring booking engine | 1 | System auto-generates from repeat booking rules |
| 8 | White-label website | 6 | SEO landing page booking forms |
| 9 | External API integration | 6 | Booking.com, hotel systems, travel platforms |
| 10 | WhatsApp AI chatbot | 6 | Customer messages WhatsApp, AI creates booking |
| 11 | AI voice agent (phone) | 7+ | AI answers phone call, captures booking details |
| 12 | CMAC integration | Future | Corporate taxi network partner bookings |
| 13 | Mobile app (customer) | Future | Customer mobile app direct booking |
| 14 | Driver-entered booking | 3 | Driver creates booking via driver app |

---

## 26. Address Geolocation

All addresses in the system should store latitude and longitude alongside the text address and postcode.

### Uses
- Dispatch accuracy (distance-to-pickup calculation)
- Demand heatmaps and analytics
- Route visualisation on map
- ETA calculation
- Geofence matching (airport zones, coverage areas)

### Implementation
- Geocode on address entry (via Google Places / Ideal Postcodes)
- Store lat/lng on Booking (pickup + destination), BookingVia, LocalPOI, SavedAddress
- Legacy `DriverLocationHistory` already stores lat/lng for GPS tracking

---

## 27. Naming Convention: "Scope" → "Work Type"

The legacy system uses "Scope" for the booking payment type (Cash/Account/Rank/Card). This is unclear terminology.

**Recommendation for Red Taxi:** Rename to **Work Type** or **Booking Type** in all new UI and API contracts. The underlying enum values remain the same for backward compatibility with the import wizard. The Blazor dispatch console should display "Work Type" in the UI dropdown (currently shows "scope:").

---

## 28. AI Route Intelligence (Phase 7+)

AI analyses booking data and demand patterns to suggest:
- High-demand routes that should have landing pages
- Profitable destinations for targeted marketing
- New SEO pages to auto-generate
- Pricing optimisation opportunities (routes where competitors charge more)
- Time-of-day demand patterns for driver shift planning

---

## 29. Admin Navigation Structure (from desktop screenshots)

The full left sidebar navigation of the legacy dispatch console:

```
Dashboards
Booking & Dispatch          ← main dispatch screen (split-screen layout)
Tracking                    ← live GPS map + driver list
Availability                ← driver availability grid with presets
Availability Logs           ← audit trail of availability changes
Local POIs                  ← points of interest (451 in Ace)
Bookings ▸
  ├── Web Bookings          ← pending web portal bookings
  ├── Global Search         ← advanced multi-field booking search
  ├── Audit View            ← booking action history
  ├── Card Bookings         ← bookings paid by card
  ├── Cancel Range          ← bulk cancel bookings in date range
  └── Cancel Range Report   ← report on cancelled bookings
Accounts                    ← corporate account list (49 in Ace)
Driver ▸
  ├── Driver List           ← all drivers with details
  └── Expiry's              ← document expiry tracking
Tariffs                     ← tariff configuration (3 tariffs in Ace)
Account Tariffs             ← per-account tariff overrides
Billing & Payments ▸        ← invoices, statements, payment tracking
Reports ▸                   ← all reporting modules
Company Settings            ← tenant configuration
Message Settings            ← messaging template and channel config
Utilities                   ← miscellaneous tools
```

---

## 30. Dashboard KPIs

The dashboard shows real-time operational metrics:

### Driver Earnings Tables
- **Today's Totals**: per-driver table with Jobs, Cash, Acc, Rank, Cash Comms, Rank Comms, Total, Total Comms. Searchable. Shows Total Earnings and Total Commissions at bottom.
- **Week's Totals**: same structure for current week

### Booking Stats
- Table: Booked By (operator name), Cash Jobs Booked, Account Jobs Booked, Rank Jobs Booked, Total Booked. Searchable.

### KPI Cards (real-time counts)
| Card | Description | Example |
|------|-------------|---------|
| Today Bookings | Total bookings for today | 69 |
| Jobs Booked Today | New jobs created today | 30 |
| Drivers | Active driver count | 22 |
| POIs | Total points of interest | 451 |
| Today Unallocated | Bookings without driver | 4 |
| Day New Customer | New customers today | 29 |
| Week New Customer | New customers this week | 136 |
| Month New Customer | New customers this month | 455 |
| Day Returning Customer | Returning customers today | 11 |
| Week Returning Customer | Returning customers this week | 47 |
| Month Returning Customer | Returning customers this month | 176 |

### Top Bar Actions
- Direct Message button → send to selected drivers
- Global Message button → broadcast to all drivers
- SMS Heartbeat indicator (shows last SMS gateway ping time — monitors Android SMS device health)

---

## 31. Live Tracking Page

Full-page view with:
- Google Map showing live driver positions (each driver has unique icon/colour marker)
- Map/Satellite toggle
- F12 for fullscreen mode
- Driver List table below map: #, Name, Reg No, Last Updated (timestamp), Speed (mph)
- Drivers update position every 5-10 seconds
- Speed calculated from GPS data

---

## 32. Reports Navigation (from screenshots)

Complete reports menu structure:

```
Reports
├── Driver Reports
│   ├── Availability Report
│   ├── Expenses Report
│   └── Earning Report
├── Bookings
│   ├── Turndown History
│   ├── Airport Runs
│   ├── Duplicate Bookings
│   ├── Count By Scope
│   ├── Top Customer
│   ├── Pickups By Postcode
│   ├── By Vehicle Type
│   ├── Average Duration
│   └── Growth By Period
└── Financial
    ├── Payouts By Month
    ├── Revenue By Month
    ├── Profitability On Invoice
    ├── Total Profitability By Period
    ├── Profitability By DateRange
    └── QR Code Adverts
```

### Airport Runs Report
Shows airport journeys with period filter (Last 1/3/6/12 Months). Table: Driver, Date, Pickup, Destination, Price. Below the summary table: "Airport Journeys - 1 Month" detail grouped by driver (expandable), showing Date, Journey, Price.

Example prices visible: Heathrow Terminal 3 = £255, Heathrow Terminal 5 = £235, Bristol Airport = £128-£156, Bournemouth Airport = £110. These are clearly fixed/zone prices for airport routes.

---

## 33. User Settings Menu

Profile dropdown (top-right, click avatar) shows:
- User name + "Pro" badge (role indicator)
- **Dark Mode** toggle
- **Dark Sidebar** toggle
- **Notifications** toggle
- **Mute Notifications** toggle
- **Ticket Raise** link
- **Logout**

The dispatch console supports dark mode — the Blazor rebuild must also support light/dark theme switching.

---

## 34. Import Wizard — Ace Data to Migrate

Based on all screenshots, the import wizard must migrate:

| Data | Count (Ace) | Priority |
|------|-------------|----------|
| Accounts | 49 | P0 |
| Account Tariffs | 3 | P0 |
| Standard Tariffs | 3 | P0 |
| Drivers + Profiles | ~22 active | P0 |
| Local POIs | 451 | P0 |
| Bookings (historical) | 135,000+ (based on booking IDs) | P1 |
| Booking Vias | Unknown | P1 |
| Account Passengers | Unknown | P0 |
| Invoices + Statements | Unknown | P1 |
| Credit Notes | Unknown | P1 |
| Message Settings | 1 config set | P0 |
| Company Settings | 1 config set | P0 |
| Driver Availability templates | Recurring patterns | P1 |
| Users (operator logins) | ~5-10 | P0 |

---

## 35. Technology Stack (Locked)

| Layer | Choice | Rationale |
|-------|--------|-----------|
| Backend API | .NET 8, ASP.NET Core, MediatR | One handler per use case, clean vertical slices |
| ORM | EF Core 8 | IDbContextFactory, per-tenant DB connection |
| Database | SQL Server 2022 | Per-tenant database (see §36) |
| Cache | Redis 7 | GPS location cache, SignalR backplane |
| Background Jobs | Hangfire | SQL Server-backed, no extra infra |
| Real-time | SignalR | Built into Blazor Server, Redis backplane |
| Dispatch Console | Blazor Server + Syncfusion | SfSchedule, SfDataGrid, SfChart — real-time via SignalR |
| Customer Portal | Blazor WASM | Public-facing, offline-capable, shares DTOs with Server |
| Tenant Admin Portal | Blazor WASM | Self-service tenant management |
| Driver App | Flutter | iOS + Android, background GPS, FCM push |
| CSS | Tailwind CSS + Syncfusion Material Dark | Tailwind for custom UI, Syncfusion for components |
| Icons | Lucide Icons | 24px grid, 1.5px stroke, open-source |
| PDF Generation | QuestPDF | Invoices, statements, credit notes, receipts |
| Billing | Stripe | Subscriptions, checkout, billing portal, webhooks |
| Hosting (Production) | Hetzner CX32, Docker Compose | €7/mo, nginx + .NET + SQL Server + Redis |
| Hosting (Staging) | IIS on Windows | Alongside existing Ace system during dev |
| CI/CD | GitHub Actions | Build → test → Docker → ghcr.io → deploy |

---

## 36. Multi-Tenancy: Per-Tenant Database

Each tenant gets their own SQL Server database. This provides:

- **Complete data isolation** — no risk of cross-tenant data leaks
- **Independent backup/restore** — can restore a single tenant without affecting others
- **Per-tenant scaling** — heavy tenants can be moved to their own server
- **Simpler queries** — no TenantId filters needed, no global query filters
- **Regulatory compliance** — tenant data physically separated

### How It Works

1. **Master database** (`RedTaxi_Platform`): stores Tenant records, Stripe info, subscription status, platform admin data. Tiny — just the tenant registry.
2. **Tenant databases** (`RedTaxi_{TenantSlug}`): each tenant gets their own database with the full schema — bookings, drivers, accounts, tariffs, everything.
3. **Connection resolution**: on every request, middleware reads the tenant from the JWT/subdomain/custom domain, looks up the connection string in the master DB, and sets the DbContext to use that tenant's database.
4. **Provisioning**: on signup, a Hangfire job creates the new database and runs EF migrations.
5. **Deletion**: on data deletion (expiry flow), the database is dropped entirely.

### Connection Resolution Flow

```
Request arrives
  → Resolve tenant (subdomain / custom domain / JWT claim)
  → Lookup tenant in master DB → get TenantId
  → Lookup connection string: "Server=localhost;Database=RedTaxi_{slug};..."
  → Set DbContext connection string for this request
  → Continue to controller/handler
```

### EF Core Implementation

```csharp
// ITenantConnectionResolver resolves the connection string per-request
public class TenantDbContextFactory : IDbContextFactory<RedTaxiDbContext>
{
    private readonly ITenantConnectionResolver _resolver;

    public RedTaxiDbContext CreateDbContext()
    {
        var connectionString = _resolver.GetConnectionString();
        var options = new DbContextOptionsBuilder<RedTaxiDbContext>()
            .UseSqlServer(connectionString)
            .Options;
        return new RedTaxiDbContext(options);
    }
}
```

### Migration Strategy

- All tenant databases share the same schema version
- New migrations applied to ALL tenant databases via a Hangfire job
- Migration status tracked per-tenant in the master DB
- Failed migrations alert the platform admin, do not block other tenants

---

## 37. SaaS Signup & Onboarding

### Self-Service Signup
1. Landing page → "Start Free Trial" → registration form (company name, subdomain, owner name, email, password, phone)
2. No card required. 14-day free trial with full access.
3. Email verification (48h to verify, soft reminder banner until verified)
4. Auto-provisioning: Stripe Customer created, tenant database created, default data seeded (tariffs, message templates, company settings)
5. Redirect to dispatch console with onboarding wizard

### Onboarding Wizard (6 Steps)
1. Company profile (logo, name, address, phone)
2. Tariff setup (review/edit 3 default tariffs)
3. Add drivers (at least 1)
4. Messaging setup (configure SMS/WhatsApp/None per event)
5. Import data (optional — CSV or legacy system connection)
6. Create first booking (guided walkthrough)

Skippable, progress tracked, shows completion % on dashboard.

---

## 38. SaaS Pricing Model (Stripe)

**Base plan + bolt-on marketplace.** Full spec in `docs/saas-pricing.md`.

### Base Plans
| Plan | Price | Drivers | Bookings/mo |
|------|-------|---------|-------------|
| Solo | £199/mo | 5 | 1,500 |
| Team | £389/mo | 20 | 5,000 |
| Fleet | £799/mo | 50 | 15,000 |
| Enterprise | Custom | Unlimited | Unlimited |

All plans include: dispatch console, driver app, booking/pricing/dispatch, accounts, invoicing, all reports, partner network, support. 14-day free trial, no card required. 20% annual discount.

### Bolt-Ons
- Extra drivers: £89/mo per 5-pack
- Extra bookings: £60 (500) / £200 (2,000) / £400 (5,000) per month
- SMS packs: £25 (500) / £75 (2,000) / £150 (5,000)
- WhatsApp: 1p per message (metered)
- Customer web portal: £109/mo
- Custom domain / white-label: £65/mo
- API access: £109/mo

Bolt-on pricing set 20% higher than upgrading to next tier — incentivises natural plan upgrades. Stripe Subscription with multiple line items (base + bolt-ons). Metered billing for WhatsApp.

---

## 39. Trial Expiry & Account Lifecycle

```
Day 0:  Signup → 14-day trial (full access)
Day 10: Email: "4 days left"
Day 12: In-app banner: "2 days left"
Day 14: Trial expires → 3-day grace period
Day 17: SOFT LOCK (read-only, exit survey, "data safe for 7 days" message)
Day 24: HARD LOCK (no access, "reactivate within 30 days")
Day 54: DATA DELETION (tenant DB dropped, Stripe Customer archived)
```

Payment at any point before deletion instantly restores full access.

---

## 40. Tenant Access Model

- **Default:** Subdomain routing — `{slug}.{platform-domain}`
- **Upgrade:** Custom domain — `dispatch.yourtaxicompany.co.uk` (Professional + Enterprise)
- **Resolution order:** Custom domain → Subdomain → JWT claim
- **Customer portal:** `book.{slug}.{platform-domain}` or custom domain
- **SSL:** Auto-provisioned via Let's Encrypt for both subdomains and custom domains

---

## 41. Design Language

Dark-first, card-based, status-colour-driven dispatch UI. Full spec in `docs/design/design-language.md`.

- **Design reference:** CoinTax by Phenomenon Studio (Dribbble)
- **Default theme:** Dark mode (operators work extended shifts in low-light)
- **Brand colour:** `#FF2D2D` (Red Taxi red)
- **Logo:** "red" bold red + "taxi" regular white — text wordmark, no icon
- **Typography:** Inter (variable weight, tabular numerals for fares)
- **Tokens:** `design-tokens.json` at repo root — generates CSS variables, Tailwind config, Syncfusion overrides
- **Components:** Cards (no shadows, 0.5px borders), status pills (coloured dot + tinted bg), 8px radius buttons
- **Map:** Google Maps dark style, vehicle status colour pins, brand red route overlay

---

## 42. Dispatch Console Layout

**Map-centric with floating panels.** The map is the primary view — everything else floats on top or docks to edges. Full spec in `docs/design/dispatch-layout.md`.

- **Map:** Full-width live map as the base layer. Driver pins (status-coloured), active routes, unallocated booking pulses.
- **Timeline:** Horizontal Gantt bar docked to bottom (~200px). Driver rows, booking blocks, drag to reallocate. Expandable to full diary mode.
- **Booking Form:** Floating panel (480px), slides in from left on `Cmd+N`. Not permanently visible — invoked on demand.
- **Context Panel:** Slides in from right (400px) when clicking any entity (booking, driver, customer). Shows detail + actions.
- **Command Palette:** `Cmd+K` spotlight search — bookings, drivers, customers, quick actions, navigation.
- **Sidebar:** 64px icon-only (expands to 240px on hover). Dashboard, Dispatch, Accounts, Drivers, Billing, Reports, Settings.
- **Top Bar:** 48px. Search trigger, unallocated badge, SMS heartbeat, notifications, CONF SA, user menu.
- **View Modes:** Map Mode (default), Diary Mode (full scheduler), Split Mode (50/50 map+diary).
- **Multi-Monitor:** Map, timeline, and forms can pop out to separate browser windows with live SignalR.
- **Keyboard-first:** Every primary action has a shortcut. Cmd+N (new), Cmd+K (search), Escape (close), Cmd+S (confirm SA).

---

## 43. Scheduler Colour System

| State | Visual |
|-------|--------|
| Unallocated | Tenant-configurable colour (default amber `#D97706`) |
| Allocated | Driver's profile colour |
| Soft Allocated | Driver's colour at 50% opacity |
| Accepted | Driver's colour + crosshatch overlay |
| COA | Strikethrough diagonal lines + red border + `[COA]` prefix |
| ASAP | Booking colour + pulsing red border |
| Completed | Info blue at 30% opacity |
| Rejected | Driver's colour + `[R]` prefix, greyed |
| Timeout | Driver's colour + `[RT]` prefix, greyed |

---

## 44. Solution Structure

```
src/
├── RedTaxi.sln
├── RedTaxi.API/                    (.NET 8 Web API)
├── RedTaxi.Application/            (MediatR handlers by feature)
├── RedTaxi.Domain/                 (Entities, enums, domain events, interfaces)
├── RedTaxi.Infrastructure/         (EF Core, Redis, Stripe, external APIs)
├── RedTaxi.Shared/                 (DTOs, validation, API client — shared by all Blazor projects)
├── RedTaxi.Blazor/                 (Dispatch console — Blazor Server + Syncfusion + Tailwind)
├── RedTaxi.WebPortal/              (Customer portal — Blazor WASM + Tailwind)
├── RedTaxi.TenantAdmin/            (Tenant admin — Blazor WASM + Tailwind)
└── RedTaxi.DriverApp/              (Flutter — separate, not in .NET solution)
```

---

## 45. Build Timeline

| Phase | Duration | Deliverable |
|-------|----------|-------------|
| 1A | ~5 days | Complete backend API (all endpoints, per-tenant DB, Stripe integration) |
| 1B | ~7 days | 4 parallel agents: Blazor dispatch, Blazor admin, web portal, Flutter app |
| 2 | ~5 days | Integration: SignalR, drag-drop, school run merge, payments, polish |
| **Total** | **~3-4 weeks** | |

---

## 46. Customer App (Flutter — Phase 1)

Public-facing Uber-style passenger app. Any member of the public can download, register, and book a taxi.

**Phase 1:** One Red Taxi branded app in App Store / Play Store. Passenger selects taxi company inside the app. Tenant branding (logo, colours, company name) applied to the UI once a company is selected.

**Phase 2:** White-label per-tenant store listings. One Flutter codebase, separate builds per tenant with injected config (tenant ID, assets, colours). Published under Red Taxi's developer account.

### Registration & Auth
- Phone number + OTP verification (like Uber)
- No email/password registration — phone-first
- OTP sent via SMS (TextLocal) or WhatsApp

### Booking Flow
1. Passenger enters pickup address (Google Places autocomplete)
2. Enters destination address
3. Optional: add via stops
4. System shows **upfront fixed quote** based on tariff (distance × rate)
5. Passenger selects vehicle type (Saloon, Estate, SUV, MPV, WAV) — price adjusts per type
6. Selects payment method (card, Revolut, Apple Pay, Google Pay, cash)
7. Selects booking type: Scheduled (date/time picker) or ASAP (if tenant enables ASAP)
8. Confirms booking
9. Booking appears in dispatch console as **pending web booking** — operator must manually accept
10. Passenger receives confirmation push + optional SMS

### Payment Methods
- Card via Stripe (Visa, Mastercard, Amex)
- Revolut Pay
- Apple Pay (iOS)
- Google Pay (Android)
- Cash (driver collects, system records)
- Pre-payment link (advance bookings — pay before journey via Revolut link)

### Payment Timing
- **Advance bookings:** pre-pay at time of booking. Refund on cancellation (minus cancellation fee if applicable).
- **ASAP bookings:** post-pay after journey completes. Charge runs automatically on saved card.

### Live Tracking
After booking is accepted and driver allocated:
- Live map showing driver position (GPS updated every 10 seconds)
- Status updates: Driver Allocated → On Route → Arriving → Passenger Onboard → Completing
- ETA calculated from driver GPS position to pickup (live, recalculated as driver moves)
- Push notifications at each status change
- SMS/WhatsApp notifications configurable per tenant (on/off)

### Passenger Profile
- Saved addresses (home, work, favourites)
- Booking history with re-book option
- Saved payment methods (Stripe tokenised)
- Phone number (primary identifier)
- Name

### Ratings
- After journey completes, passenger prompted to rate driver (1-5 stars)
- Rating stored on booking record
- Driver average rating visible to operator in dispatch console
- No driver-rates-passenger in v1

### Cancellation Policy
Configurable per tenant. Both time and distance factor in:

| Condition | Fee |
|-----------|-----|
| Cancelled > 1 hour before pickup | Free |
| Cancelled 30min - 1hr before pickup | 50% of quoted fare |
| Cancelled < 30min before pickup | Full quoted fare |
| Cancelled after driver en route (distance-based) | Full fare + dead miles charge |

Exact thresholds and percentages configurable per tenant in Company Settings.

### Notifications
- Push notifications via FCM (always on)
- In-app real-time updates via SignalR WebSocket
- SMS fallback: configurable per tenant (on/off in v1)
- WhatsApp fallback: configurable per tenant (on/off in v1)

---

## 47. Vehicle Types

Five standard vehicle types. Affect pricing — each type can have its own tariff multiplier.

| Type | Description | Tariff Impact |
|------|-------------|---------------|
| Saloon | Standard 4-passenger car | Base tariff (1.0x) |
| Estate | Larger boot, 4 passengers | Configurable multiplier |
| SUV | Premium, 4-6 passengers | Configurable multiplier |
| MPV | Multi-passenger vehicle, 6-8 passengers | Configurable multiplier |
| Wheelchair Accessible (WAV) | Wheelchair accessible vehicle | Configurable multiplier |

Tenants can configure a price multiplier per vehicle type in Tariff Settings. For example: SUV = 1.3x base tariff. If no multiplier is set, defaults to 1.0x (same as Saloon).

The customer app shows available vehicle types with prices so the passenger can choose.

---

## 48. Email Notifications

Transactional emails for documents, not real-time alerts.

### Platform Emails (SendGrid)
- Trial reminder emails
- Subscription confirmations
- Payment failed alerts
- Welcome / onboarding emails

### Tenant Emails (Configurable Provider)
Each tenant configures their own email sending:
- **Option 1:** SMTP credentials (any email provider)
- **Option 2:** SendGrid API key
- **Option 3:** Other API (Mailgun, Amazon SES)

Configured in Company Settings. Tenant's sending domain used for `From` address (e.g. `bookings@acetaxisdorset.co.uk`).

### Email Use Cases
| Email | Trigger | Recipient |
|-------|---------|-----------|
| Account invoice PDF | Invoice posted | Account email |
| Driver statement PDF | Statement generated | Driver email |
| Payment receipt PDF | Card payment completed (Revolut webhook) | Customer phone/email |
| Credit note PDF | Credit note created | Account email |
| Booking confirmation | Booking accepted (if email configured) | Customer email |
| Document expiry warning | 30/14/7/1 days before expiry | Driver + operator |

---

## 49. Address Entry

Dual provider system for maximum coverage:

- **Google Places Autocomplete:** Primary address entry. As-you-type suggestions. Used for general address lookup, pickup/destination fields in booking form and customer app.
- **Ideal Postcodes:** UK postcode precision. Operator types postcode → sees list of addresses at that postcode → selects exact address. Used alongside Google for UK-specific accuracy.

Both providers available simultaneously. Operator can type a postcode (triggers Ideal) or start typing an address (triggers Google). The system detects which to use based on input pattern.

---

## 50. Driver Allocation UX

On the dispatch console, operator allocates a driver by:

1. Right-click on a booking block in the scheduler/timeline
2. Context menu shows "Allocate Driver"
3. Opens a driver list panel:
   - Each row: `ID | Name` with row background in **driver's assigned colour**
   - Filtered to show only available drivers near that time slot
   - Operator types driver number directly for fast keyboard entry
   - Or clicks a driver row
4. On selection, booking block colour changes to the selected driver's colour
5. Notification sent (or queued for soft allocate confirm)

Alternative: operator types driver number directly into a quick-allocate input on the booking context panel (right slide-in).

---

## 51. Live ETA & Customer Tracking

### Tracking URL
Auto-generated for every booking where tracking is enabled (configurable per tenant in Company Settings). Format: `track.{platform-domain}/{short-code}`

### Tracking Page
- Lightweight responsive web page (no app required)
- Live map showing driver position (GPS pin moves in real-time)
- ETA calculated from current driver position to pickup/destination
- Status bar: Driver Allocated → On Route → Arriving → In Journey → Complete
- Driver details: name, vehicle type, registration, colour
- Branded with tenant logo and colours

### ETA Calculation
- Uses Google Distance Matrix from driver's current GPS position to pickup (pre-pickup) or destination (in-journey)
- Recalculated every 30 seconds as driver moves
- Pushed to tracking page via SignalR WebSocket
- Pushed to customer app via SignalR

---

## 52. Driver Documents & Expiry

### Required Documents (default set, configurable per tenant)
| Document | Expiry Tracked | Default |
|----------|---------------|---------|
| Driving Licence | Yes | Required |
| Private Hire Badge / Hackney Licence | Yes | Required |
| Vehicle Insurance | Yes | Required |
| MOT Certificate | Yes | Required |
| DBS Check | Yes | Required |

Tenants can add custom document types in Settings (e.g. "First Aid Certificate", "Safeguarding Training").

### Expiry Warnings
Warning thresholds configurable per tenant (default: 30, 14, 7, 1 days before expiry).

Notifications: email to driver + in-app alert + operator dashboard flag.

### Expiry Blocking
Configurable per tenant:
- **Block mode:** driver cannot receive job offers when any required document is expired
- **Warn mode:** driver can still work, operator sees red flag on driver profile and dashboard

---

## 53. Driver Expenses

- Configurable expense categories per tenant (e.g. Fuel, Car Wash, Tolls, Parking, Maintenance, Other)
- Driver submits expenses via the driver app (amount, category, date, optional receipt photo)
- Expenses visible to operator in driver profile and expense reports
- **Tracked for reporting only** — expenses are NOT deducted from the driver's weekly settlement
- Expense reports available in the reporting module (total by driver, by category, by period)

---

## 54. VAT Configuration

Configurable per tenant in Company Settings:
- **VAT Registered:** Yes/No toggle
- **VAT Number:** stored on tenant profile, printed on invoices
- **VAT Rate:** configurable (default 20% UK)
- If VAT registered: all account invoices include VAT line (Net + VAT + Gross)
- VAT Outputs report available for HMRC MTD preparation
- If not VAT registered: invoices show total only, no VAT line

---

## 55. Invoice & Statement Configuration

### Invoice Numbering
Auto-increment per tenant: `INV-001`, `INV-002`, etc. Counter stored per tenant, never resets.

### Payment Terms
Configurable **per account** (not global). Each account can have different terms:
- Net 7 / Net 14 / Net 30 / Net 60 / Custom days
- Stored on the Account entity
- Shown on invoice PDF

### QR Code Adverts
Tenants can generate QR codes that link to their customer booking portal. QR codes trackable — each scan logged with timestamp and source. Available in the QR Code Adverts report. Used for marketing materials (business cards, flyers, vehicle stickers).

---

## 56. Ratings System

- Passengers rate drivers 1-5 stars after journey completion (via customer app)
- Rating stored on the booking record (`CustomerRating` field)
- Driver's average rating calculated and displayed on driver profile in dispatch console
- Operator can view rating trends in driver reports
- Low rating alerts: configurable threshold (e.g. below 3.5 triggers operator notification)
- No driver-rates-passenger in v1

---

## 57. Service Area (Customer App)

Tenants define their operating area in Company Settings. The customer app only shows the tenant to passengers whose pickup falls within the service area.

Three definition methods available (tenant picks one or combines):

1. **Postcode prefixes:** e.g. SP, DT, BA — any pickup in those postcode areas is within service
2. **Polygon on map:** tenant draws a boundary on Google Maps in settings. Pickup must fall inside the polygon.
3. **Radius:** centre point (lat/lng, typically the office) + radius in miles. Pickup must be within radius.

Tenants can combine methods (e.g. radius for general area + specific postcodes for extended coverage).

Bookings from outside the service area are rejected in the customer app with a message: "Sorry, [Company Name] doesn't cover this area."

Service area does NOT affect dispatch console — operators can create bookings for any address regardless.

---

## 58. In-App Chat (Customer ↔ Driver)

Real-time messaging scoped to the active booking.

### Availability
- Chat opens when driver is allocated to the booking
- Chat closes when journey is marked complete
- Messages are NOT deleted — retained on the booking record

### Implementation
- SignalR WebSocket connection (same hub as dispatch real-time updates)
- Messages stored in `BookingChatMessage` table: BookingId, SenderType (Customer/Driver), Message, Timestamp
- Both customer app and driver app show a chat icon when chat is available
- Push notification on new message if app is backgrounded

### Operator Visibility
- Operator can view full chat history on any booking via the booking context panel
- Chat history visible in booking audit view
- Operator CANNOT send messages in the chat — it's customer ↔ driver only
- Operator uses Direct Message (SMS/WhatsApp) for operator → driver communication

---

## 59. Actual Miles Tracking (GPS)

The system tracks actual miles driven from GPS data, separate from estimated miles from Google Distance Matrix.

### How It Works
1. When driver accepts job, GPS tracking begins logging positions every 10 seconds
2. Actual miles calculated by summing distance between consecutive GPS points
3. Two segments tracked separately:
   - **Dead miles:** driver's position at acceptance → pickup address
   - **Trip miles:** pickup address → destination address (via any stops)
4. Stored on the booking: `ActualDeadMiles`, `ActualTripMiles`, `ActualTotalMiles`
5. `EstimatedMiles` from Google Distance Matrix stored separately for comparison

### Usage
- Invoice processor shows both Actual Miles and estimated Journey Charge
- Cancellation fees can reference actual dead miles driven
- Operator can override actual miles if GPS data is unreliable
- Reporting: comparison of estimated vs actual miles for tariff accuracy analysis

---

## 60. Surge / Dynamic Pricing

**Phase 2+ feature.** Not in v1.

Architecture supports it: pricing engine can accept a multiplier. When implemented:
- Demand/supply ratio calculated per service area
- Multiplier applied to tariff (e.g. 1.5x during peak)
- Customer app shows surge indicator + adjusted price before confirmation
- Configurable per tenant (opt-in, not forced)

---

## 61. Vehicle Capacity & Passenger Count

Customer app enforces vehicle capacity:

| Vehicle Type | Max Passengers |
|-------------|---------------|
| Saloon | 4 |
| Estate | 4 |
| SUV | 6 |
| MPV | 8 |
| WAV | 4 (+ wheelchair) |

Passenger selects number of passengers in booking flow. App filters available vehicle types to those that can accommodate the count. If passenger selects 6 pax, only SUV and MPV shown.

Capacity configurable per tenant in Vehicle Type settings (some operators have larger/smaller vehicles).

---

## 62. Audit Trail

Full audit log on every booking. Every change recorded.

### Audit Record Fields
| Field | Description |
|-------|-------------|
| BookingId | Which booking |
| Timestamp | When the change happened |
| UserId | Who made the change |
| UserRole | Role (Dispatcher, Driver, Customer, System) |
| Action | What happened (Created, Updated, Allocated, Cancelled, StatusChanged, PriceChanged, etc.) |
| FieldChanged | Which field changed (if update) |
| OldValue | Previous value |
| NewValue | New value |

### What's Logged
- Booking creation (all initial values)
- Every field update (address, time, passenger, price, status)
- Allocation / unallocation (which driver, by whom)
- Status changes (with timestamp of each transition)
- Price changes (manual override, recalculation)
- Cancellation (reason, by whom, cancellation fee applied)
- COA (who reported, timestamp)
- Chat messages (as audit entries)

Audit log viewable in dispatch console via booking context panel → "Audit" tab. Also available in the Audit View page (Bookings submenu) for cross-booking search.

---

## 63. Operator Roles (Tenant RBAC)

Within a tenant, operators have role-based access control:

| Role | Description | Permissions |
|------|-------------|-------------|
| Tenant Admin | Owner / manager | Full access: settings, billing, drivers, accounts, reports, dispatch, user management |
| Dispatcher | Booking operator | Dispatch: create/amend/cancel bookings, allocate drivers, view schedule, send messages. No access to: billing, settings, driver management, reports |
| Viewer | Read-only | View dispatch console (read-only), view reports. Cannot create or modify anything. |
| Accountant | Billing focus | Billing & payments: invoice processing, statements, credit notes, financial reports. No dispatch access. |

Tenant Admin can create operator accounts and assign roles. Roles are additive — a user can have multiple roles if needed (e.g. Dispatcher + Accountant).

Permissions enforced at API level (role claims in JWT) and UI level (menu items/buttons hidden for unauthorised roles).

---

## 64. GDPR Compliance

- All personal data stored with purpose and legal basis documented
- **Right to erasure:** customer or driver can request data deletion. System anonymises booking records (replaces name/phone/address with "REDACTED") but retains financial records for accounting compliance (7 years UK requirement)
- **Data export:** tenant can export all their data as JSON/CSV from settings (GDPR Article 20 portability)
- **Consent management:** customer app collects explicit consent for data processing, marketing, and location tracking. Stored with timestamp.
- **Data retention:** configurable per tenant. Default: active data kept indefinitely, deleted customer data purged after 30 days, booking records retained 7 years for financial compliance
- **Cookie consent:** tracking page and web portal show cookie banner where required
- **Privacy policy:** platform provides a template, tenants can customise

---

## 65. Error Monitoring & Logging

### Sentry (Error Tracking)
- All unhandled exceptions captured with stack trace, user context, tenant context
- Performance monitoring (API response times, slow queries)
- Release tracking (errors tagged to deployment version)
- Alert rules: notify platform admin on error spike or new error type

### Seq (Structured Logging)
- All application logs sent to Seq via Serilog
- Structured log events with tenant ID, user ID, booking ID, request ID
- Queryable dashboard for debugging
- Log retention: 30 days rolling

### Per-Tenant Context
Every log entry and error includes: `TenantId`, `TenantSlug`, `UserId`, `UserRole`, `RequestId`. This enables filtering logs by tenant for support.

---

## 66. System Health (Tenant Dashboard)

Tenant dashboard shows operational health:

| Metric | Source |
|--------|--------|
| Platform uptime (last 30 days) | Health check endpoint monitoring |
| API response time (avg last hour) | Sentry performance |
| Active operators online | SignalR connection count |
| Active drivers online | GPS last-updated within 5 min |
| SMS gateway status | Heartbeat check (green/red) |
| Bookings today | Real-time count |
| Unallocated bookings | Real-time count |

Health metrics update in real-time via SignalR on the dashboard page.

---

## 67. Backup & Data Export

### Automated Backups
- Daily automated backup of ALL tenant databases to Hetzner Object Storage
- Retention: 30 days rolling (configurable)
- Master database (`RedTaxi_Platform`) backed up separately
- Hangfire job runs at 02:00 UTC daily

### Tenant Data Export (GDPR)
- Tenant Admin can download a full export of their data from Settings → Data Export
- Export format: ZIP containing JSON files (one per entity type) + CSV summary
- Includes: bookings, drivers, accounts, customers, invoices, statements, settings
- Generated as a background job, download link emailed when ready
- Also available via API for programmatic access (API bolt-on required)

---

## 68. Timezones

- All timestamps stored in UTC in the database
- Tenant timezone configured in Company Settings (default: `Europe/London`)
- All UI displays convert UTC → tenant's local timezone
- Booking pickup times entered in local timezone, converted to UTC on save
- API accepts and returns UTC timestamps (ISO 8601 format)
- Driver app uses device timezone for display

---

## 69. Currency

- **GBP only for v1**
- Currency symbol and formatting stored on tenant record (`Currency = "GBP"`)
- Architecture supports multi-currency (stored as string, formatting via CultureInfo)
- Multi-currency can be enabled in v2 by allowing tenant to set currency in Company Settings
- All monetary values stored as `decimal` with 2 decimal places

---

## 70. Help & Support (v1)

- **v1:** In-app ticket system (Ticket Raise button in user menu). Tickets stored in master DB, visible to platform admin.
- **Phase 2:** Searchable knowledge base, in-app contextual help tooltips, video tutorials

---

## 71. Platform Updates & Changelog

- In-app release notes: "What's New" modal shown on first login after an update
- Changelog accessible from user menu → "What's New"
- Platform admin publishes release notes via admin panel
- Major updates: in-app banner + email notification to all tenant admins
- Minor updates: changelog entry only, no notification
- Release notes stored in master DB, rendered as markdown

---

## 72. API Rate Limiting

No rate limiting in v1. Tenants trusted. Rate limiting can be added later via ASP.NET Core rate limiting middleware if needed.

---

## 73. Go-Live Strategy

Ace Taxis stays on the legacy system until Red Taxi is fully tested and stable. No parallel run — clean cutover when ready.

1. Build and test Red Taxi with synthetic data
2. Import Ace data into a staging tenant database
3. Operator acceptance testing on staging
4. Clean cutover: switch Ace operations to Red Taxi on a quiet day (Sunday)
5. Legacy system kept read-only for 30 days as fallback

---

## 74. Marketing Website

**Tech:** Next.js (SEO-optimised, static generation, React ecosystem)

**URL:** `redtaxi.io` (or chosen platform domain)

**Pages:**
- Home (hero, value proposition, feature highlights)
- Features (detailed feature breakdown with screenshots)
- Pricing (interactive plan comparison with cost calculator)
- About (company info, team)
- Blog (SEO content, industry news)
- Contact / Demo request
- Sign Up → redirects to platform registration flow

**Phase 1:** simple landing page with pricing and signup CTA. Full marketing site built out over time.

---

## 75. Data Import (Phase 2)

Phase 2 feature. Generic CSV import wizard for new tenants migrating from other systems:

- Upload CSV files: drivers, accounts, bookings, passengers, tariffs
- Column mapping UI (map CSV columns to Red Taxi fields)
- Validation report before import (missing fields, data issues)
- Import preview with record counts
- Background job processes the import
- Completion report with success/failure counts

---

## 76. Booking Module — Deep Detail

### Phone Lookup / Caller ID
When operator receives a call (or enters a phone number manually):
1. System searches customer records by phone number
2. If found: popup shows two tabs — **Active Bookings** | **History**
3. History tab shows **distinct** journeys (deduplicated — same route shown once, ordered by most recent)
4. Operator clicks a history entry to pre-fill the booking form with that journey's details
5. If no match: phone number auto-fills in the form, cursor focuses on Pickup Address field

### Via Stops
- Maximum 5 via stops per booking
- Each via has: address, postcode, optional passenger name
- Vias affect price calculation (distance includes all via segments)
- Vias visible on map route overlay

### Booking Notes
Two note fields:
- **Driver Notes:** visible to driver in their app and on allocation message. Used for directions, passenger description, gate codes, etc.
- **Internal Notes:** visible to operators only. Used for account instructions, special handling, internal flags. Never sent to driver.

### Price Recalculation
- Auto-recalculates whenever pickup, destination, vias, or pickup time changes
- Recalculation calls Google Distance Matrix → applies tariff → updates price
- If `ManuallyPriced = true`: price is locked. Address/time changes do NOT trigger recalculation.
- Operator can unlock by unchecking "Manually Priced" → triggers immediate recalculation
- Account tariff overrides standard tariff when booking is for an account

### Duplicate Booking
- Creates a new booking pre-filled with all details from the original
- Driver allocation is **stripped** — duplicate is always unallocated
- New date/time defaults to now (operator adjusts)
- Operator reviews all fields before confirming
- Useful for repeat customers calling for the "same as last time"

### School Run Split/Merge
- **Merge:** in Diary Mode, drag booking A onto booking B. Preconditions: both school-run tagged, same destination, same account. Booking A's pickup becomes a via on booking B.
- **Split:** operator can split a merged school run booking back into individual bookings. Each split booking gets its original pickup as the primary address.
- Split/merge is only available for school-run bookings — not general bookings.

---

## 77. Dispatch Module — Deep Detail

### v1: Manual Dispatch Only
- No automated job offers in v1
- Operator manually allocates drivers via right-click on scheduler → driver list
- Soft allocate (no notification) and hard allocate (notification sent) both available
- CONF SA button batch-confirms all soft allocates

### Job Offer Framework (v2 — architecture ready)
Schema and entities ready for v2 implementation:
- `JobOffer` entity: BookingId, DriverId, OfferedAt, ExpiresAt, Status (Pending/Accepted/Rejected/TimedOut)
- Offer timeout: configurable per tenant + per job urgency (ASAP = shorter timeout)
- Rejection penalty: configurable per tenant (X rejections in Y hours = Z minute temporary ban from offers)
- Sequential offering: offer to one driver at a time, move to next on reject/timeout
- Offer channel: FCM push notification (full-screen takeover in driver app)

### Turn-Down Recording
When an operator attempts to allocate but no driver is available:
- "Turn Down" (NO button in top bar) records the booking as a turn-down
- Turn-down report tracks: date, time, pickup, destination, reason
- Used for demand analysis (which areas/times have insufficient coverage)

---

## 78. Driver Module — Deep Detail

### Online/Offline Toggle
- Driver opens app → toggles "Online" switch at top of Schedule screen
- Going online: starts GPS tracking (every 10s), logs shift start time, driver appears on dispatch map
- Going offline: stops GPS tracking, logs shift end time, driver disappears from dispatch map
- Auto-offline after configurable idle period (e.g. 4 hours with no job activity)

### Driver Types
| Type | Can Rank | Metered Jobs | Pre-Booked Jobs |
|------|----------|-------------|-----------------|
| Private Hire | No | No | Yes |
| Hackney | Yes | Yes | Yes |

Stored on driver profile as `DriverType` enum. Affects:
- Whether driver can create rank jobs from the app
- Whether "Enter Final Price" appears on job completion (Hackney runs meter)
- Reporting: rank jobs tracked separately from pre-booked

### Rank Job Flow (Hackney Only)
1. Hackney driver at taxi rank picks up passenger
2. Opens app → "Create Rank Job"
3. Enters destination address → system calculates tariff-based price
4. Drives to destination with meter running
5. On completion: enters final metered price (overrides tariff calculation)
6. Enters payment type (cash/card)
7. Job recorded — operator takes commission at settlement

### Rank Job Flow (Private Hire)
Private hire drivers cannot create rank jobs. If a private hire driver picks up from a rank, it must be pre-booked through the dispatch system.

### Financial Transparency
Driver app Earnings tab shows:
- Today's earnings breakdown: each job with price
- Commission deductions (per-job and total)
- Card fee deductions (where applicable)
- Net payout (what they'll actually receive)
- Weekly running total
- Statement preview (before official statement is generated)
- Historical statements with PDF download

---

## 79. Accounts Module — Deep Detail

### Account Creation
- Operator creates account in dispatch console: company name, address, postcode, email, phone
- System auto-generates account number (auto-increment from tenant's last account number)
- System emails login credentials to the account's email address
- Credentials: account number + auto-generated password (account can change on first login)

### Multiple Bookers
- Each account can have multiple authorised bookers
- Each booker has their own login (email + password) linked to the account
- Booker permissions are equal — all can create, view, and (if permitted) cancel bookings
- Operator manages bookers from the account edit screen
- Booker activity tracked: "Booked By" field on each booking shows which booker created it

### Account Web Portal Features
- **Create booking:** pickup, destination, vias, date/time, passenger selection, repeat booking
- **Active bookings:** list of current bookings with live map (configurable per tenant — some tenants enable map, some don't)
- **Booking history:** past bookings with status, filterable by date range
- **Amend booking:** submit amendment request → operator approves or rejects. Account sees "Amendment Pending" status.
- **Cancel booking:** configurable per account. Some accounts can cancel freely, others require operator approval. Cancel request shows "Cancellation Pending" until approved.
- **Passenger management:** add, edit, delete passengers. Passengers linked to account, selectable when creating bookings.
- **Duplicate booking:** one-click re-book from history

### Account Payment Methods
Configurable per account:
- **Invoice:** monthly invoice generated by operator, emailed as PDF. Payment terms per account (Net 7/14/30/60).
- **Card:** individual bookings payable by card via Revolut payment link
- **Direct Debit:** GoCardless integration for automated monthly collection (Phase 2)

### Account Invoicing
- Invoice Processor: operator selects account + date range → sees all uninvoiced completed bookings
- Individual pricing: each job priced using account tariff (account price + driver price)
- Grouped pricing (school runs): jobs grouped by route, batch-priced
- "Post All Priced" → generates invoice PDF → auto-emails to account
- Auto Email Invoices toggle: when ON, posted invoices auto-send; when OFF, operator manually triggers email

---

## 80. Billing Module — Deep Detail

### Account Invoice Delivery
Configurable per account — operator sets preferred delivery method:
- **PDF email only:** invoice PDF attached to email
- **PDF email + Revolut payment link:** email contains PDF attachment + payment link for instant card payment
- **PDF email + online portal:** account views and pays invoices via the web portal

### Credit Notes
- Formal document issued against a specific invoice (not ad-hoc balance adjustments)
- Credit note has its own number sequence: `CN-001`, `CN-002` (auto-increment per tenant)
- References the original invoice number
- Can be partial (credit specific line items) or full (credit entire invoice)
- Credit note PDF generated via QuestPDF, emailed to account
- Credit notes appear in financial reports as negative revenue

### Driver Weekly Statement
Full detail with running balance:
- **Gross earnings:** total of all completed jobs (cash + account + rank + card)
- **Commission deductions:** per-job commission based on driver's rate
- **Card fee deductions:** processing fees on card payments
- **Expenses note:** summary of submitted expenses (informational, not deducted)
- **Balance brought forward:** outstanding balance from previous weeks (positive = owed to driver, negative = driver owes company)
- **Net payout:** gross - commission - card fees +/- balance forward
- Statement PDF generated via QuestPDF

### Statement Generation
Configurable per tenant:
- **Manual:** operator clicks "Process Statement" for a selected date range + driver(s)
- **Auto:** Hangfire job generates statements every Monday at 06:00 for the previous week (Mon-Sun)
- Setting in Company Settings: `StatementGeneration = Manual | Auto`

### Driver Payment
- Operator pays driver outside the system (bank transfer, typically weekly)
- Operator marks statement as "Paid" in the system with payment date
- Payment status visible to driver in the app (Paid / Unpaid / Partial)
- No integrated payout via Stripe/Revolut in v1 — record-keeping only

---

## 81. Messaging Module — Deep Detail

### Message Template Builder
Tenants customise their notification templates via an intuitive drag-and-drop builder in Message Settings:

**Editor layout:**
- Left panel: text editor (WYSIWYG for the message body)
- Right panel: available placeholders as draggable chips/pills
- Drag a placeholder from the right panel → drop into the text → inserts `{VariableName}`
- Preview pane below shows the message with sample data

**Available placeholders (draggable):**
`{BookingId}`, `{PickupTime}`, `{PickupAddress}`, `{DestinationAddress}`, `{PassengerName}`, `{PassengerPhone}`, `{Passengers}`, `{BookingDetails}`, `{DriverName}`, `{DriverPhone}`, `{VehicleReg}`, `{VehicleType}`, `{VehicleColour}`, `{Price}`, `{CompanyName}`, `{TrackingUrl}`, `{PaymentUrl}`, `{ETA}`

**Per-event templates:**
Each of the 8 messaging events has its own template:
- DRIVER - ON ALLOCATE
- DRIVER - UN-ALLOCATE
- DRIVER - ON AMEND BOOKING
- DRIVER - ON CANCEL BOOKING
- CUSTOMER - ON ALLOCATE
- CUSTOMER - UN-ALLOCATE
- CUSTOMER - ON AMEND BOOKING
- CUSTOMER - ON CANCEL BOOKING

**Channel selection:** each event also has a channel toggle (None / WhatsApp / SMS) — same as current legacy system but with the improved template editor.

**Default templates:** system provides sensible defaults on tenant creation (as documented in business-rules.md §42). Tenant can customise from day one.

### SMS Sending
- Provider: TextLocal (existing) or tenant-configurable (Twilio, etc.)
- Branded sender ID: tenant's company name (e.g. "Ace Taxis") — configurable in Company Settings
- SMS uses tenant's purchased SMS pack (bolt-on). When pack depleted: messages queued, operator warned.

### WhatsApp Sending
- Provider: Twilio WhatsApp Business API (or Meta Cloud API)
- Per-message cost: 1p charged to tenant (metered via Stripe)
- WhatsApp messages use approved template formats (Meta requirement)
- Fallback: if WhatsApp delivery fails, system can auto-fallback to SMS (configurable)

### Local SMS Gateway (Legacy Support)
- For tenants with Android SMS gateway devices (like Ace's current setup)
- API endpoint: driver app / gateway device polls for queued messages
- Gateway sends via device's native SMS (cheaper than provider SMS)
- SMS Heartbeat monitor: dispatch console shows last gateway ping time
- If heartbeat stale > 5 minutes: alert in dispatch console
