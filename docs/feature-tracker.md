# Red Taxi — Feature Implementation Tracker

> **This file is the source of truth for what's done and what's not.**
> Claude Code MUST update this file after completing each feature.
> Status: ✅ Done | 🟡 Partial | 🔴 Not Started | ⬜ N/A

Last Updated: 2026-03-18

---

## BACKEND — Core Infrastructure

| # | Feature | PRD § | Status | Notes |
|---|---------|-------|--------|-------|
| B01 | .NET 8 solution scaffold (8 projects) | §44 | ✅ | All 8 projects compile, 0 errors 0 warnings |
| B02 | Per-tenant database (ITenantConnectionResolver) | §36 | ✅ | Resolver works — login + bookings tested end-to-end |
| B03 | Master DB (RedTaxi_Platform) — tenants, Stripe | §36 | ✅ | 4 tables, Stripe products seeded |
| B04 | Tenant DB (RedTaxi_ace) — all business entities | §36 | ✅ | 45 tables, 10 seed bookings confirmed |
| B05 | JWT authentication + refresh tokens | §63 | ✅ | Login returns JWT, bookings/today works with token |
| B06 | Role-based access (Admin/Dispatcher/Viewer/Accountant/Restricted) | §63, §103 | 🔴 | Roles defined in enum, RBAC middleware not verified |
| B07 | EF Core global query filters (soft deletes) | §36 | 🔴 | Not verified |
| B08 | MediatR pipeline (validation, logging) | §44 | 🟡 | Handlers exist, pipeline behaviours not verified |
| B09 | Domain events infrastructure | §137 | 🟡 | Event handlers exist, verify publishing works |
| B10 | Redis cache integration | §35 | 🔴 | Not verified — is Redis actually used? |
| B11 | Hangfire job scheduler | §35 | 🔴 | Not verified — auto-complete, recurring jobs |
| B12 | SignalR hub infrastructure | §137 | 🟡 | Hub exists, end-to-end not tested |
| B13 | Sentry error monitoring | §65 | 🔴 | Not implemented |
| B14 | Seq structured logging | §65 | 🔴 | Not implemented |
| B15 | Health check endpoint (/health) | §137 | 🔴 | Not implemented |
| B16 | API rate limiting | §72 | 🔴 | Not implemented |
| B17 | CORS configuration | — | 🔴 | Not verified |

---

## BACKEND — Booking Module

| # | Feature | PRD § | Status | Notes |
|---|---------|-------|--------|-------|
| BK01 | Create booking (single) | §76, §102 | 🟡 | Handler exists (197 lines), verify all fields mapped |
| BK02 | Create booking — phone standardisation | §102 | 🔴 | Trim spaces, format +44/044 |
| BK03 | Create booking — postcode standardisation | §102 | 🔴 | Uppercase, format |
| BK04 | Create booking — address normalisation | §102 | 🔴 | Remove extra spaces |
| BK05 | Create booking — auto-price on create | §102 | ✅ | Pricing calls real Google Distance Matrix API |
| BK06 | Create booking — mileage calculated | §102 | ✅ | Real Distance Matrix, via segments, dead mileage |
| BK07 | Create return booking (reversed addresses) | §102, §84 | 🟡 | Handler exists, verify reverse logic |
| BK08 | Create block booking (recurrence rules) | §84, §103 | 🟡 | Handler exists, verify iCal parsing |
| BK09 | Update booking | §76 | 🟡 | Handler exists |
| BK10 | Cancel booking (single) | §76 | 🟡 | Handler exists |
| BK11 | Cancel booking (block — all future) | §84 | 🟡 | Handler exists |
| BK12 | Cancel on Arrival (COA toggle) | §8, §102 | 🔴 | Toggle behaviour: same call creates/removes |
| BK13 | Complete booking | §102, §137 | 🟡 | Handler exists, verify business rules |
| BK14 | Complete — block before pickup time | §102 | 🔴 | Not verified |
| BK15 | Complete — Cash auto-sets PaymentStatus=Paid | §102 | 🔴 | Not verified |
| BK16 | Complete — Account price only by Admin | §102 | 🔴 | Not verified |
| BK17 | Complete — customer SMS (Cash/Card only) | §102 | 🔴 | Not verified |
| BK18 | Auto-complete forgotten jobs (Hangfire) | §91 | 🔴 | Configurable threshold, default 2hrs |
| BK19 | Duplicate booking | §84 | 🟡 | Handler exists |
| BK20 | Merge school run bookings | §9, §102 | 🟡 | Handler exists, verify merge rules |
| BK21 | Merge — validation (same account, pickup OR dest match) | §102 | 🔴 | Not verified |
| BK22 | Merge — append becomes via, passenger names concat | §102 | 🔴 | Not verified |
| BK23 | Merge — append cancelled not deleted | §102 | 🔴 | Not verified |
| BK24 | Booking search (keyword) | §76 | 🟡 | Handler exists |
| BK25 | Booking search (advanced — multi-field) | §76 | 🔴 | FindBookings with all filters |
| BK26 | Scheduler query (date range, by driver) | §95 | 🟡 | Handler exists |
| BK27 | Phone number history lookup | §98, §110 | 🔴 | Caller popup: previous + current + cancelled |
| BK28 | ASAP = current time + 5 minutes | §101 | 🔴 | Not verified |
| BK29 | Default duration = 20 minutes | §101 | 🔴 | Not verified (legacy uses 15 in some places, 20 in others) |
| BK30 | ManuallyPriced auto-set when operator edits price | §101 | 🔴 | Frontend behaviour |
| BK31 | Arrive By calculation (arriveByTime - Google duration) | §101 | 🔴 | Not implemented |
| BK32 | Booking change audit log | §62, §136 | 🔴 | BookingChangeAudit entity exists, verify logging |

---

## BACKEND — Pricing Engine

| # | Feature | PRD § | Status | Notes |
|---|---------|-------|--------|-------|
| PR01 | 5-level pricing priority chain | §102, §132 | 🟡 | Code exists in PricingService, logic looks correct |
| PR02 | Google Distance Matrix integration | §102 | ✅ | GoogleDistanceMatrixService with real API, fallback on error |
| PR03 | Dead mileage calculation (base → pickup + dest → base) | §102 | ✅ | Reads BasePostcode, calculates legA+legC, totalMiles=(journey+dead)/2 |
| PR04 | Total miles averaging: (journey + dead) / 2 | §102 | ✅ | Formula correct, deadMiles now calculated from real API |
| PR05 | Via segment calculation (multi-stop) | §102 | ✅ | Sums all segments pickup→via1→...→dest |
| PR06 | Standard tariff: Day (T1) / Night (T2) / Holiday (T3) | §102 | 🟡 | DetermineTariffTypeAsync exists, logic looks correct |
| PR07 | Tariff: InitialCharge + FirstMileCharge + (miles-1) × AdditionalMileCharge | §102 | 🟡 | Formula in code |
| PR08 | Bank holiday detection (configurable list) | §102, §104 | ✅ | Configurable JSON in CompanyConfig, seeded 2025-2027 UK dates |
| PR09 | Account tariff (dual pricing: driver + account rates) | §102, §107 | 🟡 | TryAccountTariffPriceAsync exists |
| PR10 | Zone-to-zone pricing (polygon matching) | §111, §126 | 🟡 | Name-matching only, no real point-in-polygon |
| PR11 | Fixed route pricing (postcode prefix) | §132 | 🟡 | TryFixedPriceAsync exists |
| PR12 | Auto-quote trigger (postcode ≥ 7 chars, scope=Cash, not manual) | §101 | 🔴 | Frontend behaviour |
| PR13 | Account dual pricing (separate driver + account price) | §102 | 🟡 | In pricing service |
| PR14 | Waiting time pricing (driver £0.33/min, account £0.42/min) | §105, §106 | 🔴 | Not found — must be configurable |
| PR15 | Charge From Base toggle | §137 | ✅ | Field exists, pricing uses real dead mileage when true |

---

## BACKEND — Dispatch Module

| # | Feature | PRD § | Status | Notes |
|---|---------|-------|--------|-------|
| DS01 | Hard allocate driver | §77, §102 | 🟡 | Handler exists |
| DS02 | Allocate — un-allocate previous driver first | §102 | 🔴 | Not verified |
| DS03 | Allocate — send notification to driver | §102 | 🔴 | Not verified end-to-end |
| DS04 | Allocate — audit log entry | §102 | 🔴 | Not verified |
| DS05 | Soft allocate driver | §77 | 🟡 | Handler exists |
| DS06 | Confirm all soft allocates (CONF SA) | §77 | 🟡 | Handler exists |
| DS07 | Unallocate driver | §77 | 🟡 | Handler exists |
| DS08 | Job offer with timeout (configurable, default 120s) | §137 | 🔴 | Not verified |
| DS09 | Job offer accept/reject/timeout status | §137 | 🔴 | Not verified |
| DS10 | Driver on-shift tracking (Start/Finish/OnBreak/FinishBreak) | §137 | 🟡 | Handler exists |
| DS11 | GPS position update + storage | §59, §136 | 🟡 | Handler exists |
| DS12 | GPS location history (breadcrumb) | §136 | 🔴 | DriverLocationHistory entity exists, verify storage |
| DS13 | Driver shift logging (DriverShiftLog) | §136 | 🔴 | Entity exists, verify logging |
| DS14 | Turn-down recording | §110 | 🟡 | Handler exists |
| DS15 | Auto-dispatch suggestion (Phase 2+) | §137 | 🔴 | Not implemented (future) |

---

## BACKEND — Accounts & Billing

| # | Feature | PRD § | Status | Notes |
|---|---------|-------|--------|-------|
| AB01 | Account CRUD | §79 | 🟡 | Handlers exist |
| AB02 | Account with AccountTariff linking | §107 | 🔴 | Not verified |
| AB03 | Account passenger management | §110, §113 | 🟡 | Handlers exist |
| AB04 | Invoice processing — get chargeable jobs by account | §118 | 🟡 | Handler exists |
| AB05 | Invoice processing — Singles grouping (passenger → route → booking) | §118 | 🔴 | Critical UI logic |
| AB06 | Invoice processing — Shared grouping (route → merged booking) | §118 | 🔴 | Critical UI logic |
| AB07 | Invoice processing — Price All (bulk price per route) | §118 | 🔴 | Not verified |
| AB08 | Invoice processing — Post All Priced | §118 | 🟡 | Handler exists |
| AB09 | Invoice PDF generation (QuestPDF) | §55, §80 | 🔴 | Not implemented |
| AB10 | Invoice email to account | §80 | 🔴 | Not verified |
| AB11 | Statement processing — get chargeable jobs by driver | §120 | 🟡 | Handler exists |
| AB12 | Statement processing — commission calculation (exact §105 formula) | §105 | 🔴 | Not verified against exact formula |
| AB13 | Statement — Cash commission = price × CashCommRate% | §105 | 🔴 | Not verified |
| AB14 | Statement — Card commission = price × (CashCommRate + CardRate)% | §105 | 🔴 | Not verified |
| AB15 | Statement — Rank commission = configurable % (legacy 7.5%) | §105, §106 | 🔴 | Not verified |
| AB16 | Statement — Card earnings exclude VAT when AddVatOnCardPayments | §105 | 🔴 | Not verified |
| AB17 | Statement — Account parking + waiting added to driver payout | §105 | 🔴 | Not verified |
| AB18 | Statement PDF generation (QuestPDF) | §55, §80 | 🔴 | Not implemented |
| AB19 | Statement email to driver with PDF attachment | §80, §105 | 🔴 | Not verified |
| AB20 | Credit note generation | §119 | 🟡 | Handler exists |
| AB21 | Credit note PDF | §80 | 🔴 | Not implemented |
| AB22 | VAT outputs calculation | §105, §119 | 🟡 | Handler exists |
| AB23 | PostedForInvoicing / PostedForStatement flags | §137 | 🔴 | Not verified |

---

## BACKEND — Messaging & Notifications

| # | Feature | PRD § | Status | Notes |
|---|---------|-------|--------|-------|
| MS01 | 11 message event types defined | §103 | 🟡 | Events defined |
| MS02 | Per-event channel config (None/WhatsApp/SMS/Push) | §103, §124 | 🔴 | Not verified |
| MS03 | Per-driver channel preference (CommsPlatform) | §124 | 🔴 | Field exists, sending logic not verified |
| MS04 | TextLocal SMS sending (actual API) | §81 | 🟡 | Service exists, API integration not verified |
| MS05 | SendGrid email sending (actual API) | §81 | 🟡 | Service exists, API integration not verified |
| MS06 | FCM push notifications (actual API) | §137 | 🟡 | Service exists, API integration not verified |
| MS07 | WhatsApp via WATI/Twilio | §81 | 🔴 | Not implemented |
| MS08 | Message templates with placeholders | §81, §103 | 🔴 | Not implemented |
| MS09 | Operator → driver direct message | §103 | 🔴 | DriverMessage entity exists |
| MS10 | Operator → all drivers broadcast | §103 | 🔴 | Not verified |
| MS11 | Review request (post-journey, configurable delay) | §131 | 🔴 | Not implemented |
| MS12 | Booking confirmation SMS | §81 | 🔴 | Not verified |
| MS13 | Payment link SMS | §81 | 🔴 | Not verified |
| MS14 | Driver arrived SMS (with vehicle details) | §110, §137 | 🔴 | Not verified |

---

## BACKEND — Payments

| # | Feature | PRD § | Status | Notes |
|---|---------|-------|--------|-------|
| PM01 | Stripe SaaS subscription (platform billing) | §139 | 🟡 | StripeSeedService exists, products created |
| PM02 | Stripe webhook processing (7 events) | §139 | 🟡 | Controller exists |
| PM03 | Stripe Customer Portal link | §139 | 🔴 | Not verified |
| PM04 | Tenant ride payments — Stripe (tenant's keys) | §139 | 🟡 | PaymentService exists with Stripe path |
| PM05 | Tenant ride payments — Revolut (tenant's keys) | §102, §139 | 🟡 | PaymentService exists with Revolut path |
| PM06 | Payment link generation | §102 | 🟡 | Handler exists |
| PM07 | Payment webhook → update booking status | §102 | 🔴 | Not verified end-to-end |
| PM08 | Refund flow (Stripe + Revolut) | §102 | 🟡 | Code exists |
| PM09 | Payment receipt generation + email | §102 | 🔴 | Not implemented |
| PM10 | VAT on card payments (configurable toggle) | §105, §106 | 🔴 | Not verified |

---

## BACKEND — Other Services

| # | Feature | PRD § | Status | Notes |
|---|---------|-------|--------|-------|
| OT01 | Google Places autocomplete | §49 | ✅ | GooglePlacesService + /api/address/autocomplete + /api/address/details |
| OT02 | Ideal Postcodes integration | §49 | 🔴 | Not implemented |
| OT03 | Address lookup API endpoint | §49 | 🔴 | Not implemented |
| OT04 | Local POI CRUD | §87 | 🔴 | Entity exists, verify controller/handler |
| OT05 | Document upload (driver documents) | §52 | 🟡 | Handler exists |
| OT06 | Document storage (configurable: Dropbox/S3) | §110, §124 | 🔴 | Not implemented |
| OT07 | Document expiry tracking + warnings | §52 | 🔴 | Not implemented |
| OT08 | Driver expense CRUD | §53 | 🔴 | Entity exists |
| OT09 | Availability CRUD with overlap validation | §110 | 🟡 | Handler exists |
| OT10 | Availability presets (SR AM, SR PM, SR Only, Custom, Unavailable) | §123 | 🔴 | Not implemented |
| OT11 | Availability audit log | §110 | 🔴 | Not verified |
| OT12 | Company config CRUD | §83 | 🟡 | Handler exists |
| OT13 | Web booking accept/reject workflow | §130 | 🔴 | Not implemented |
| OT14 | Web amendment request approval | §130 | 🔴 | Not implemented |
| OT15 | URL shortening / tracking | §110 | 🔴 | Entity exists |
| OT16 | QR code click tracking | §110 | 🔴 | Entity exists |
| OT17 | Google Calendar sync | §124 | 🔴 | Not implemented |
| OT18 | Reporting — all 18 report queries | §82, §112 | 🔴 | Not verified |
| OT19 | Data seed — Ace Taxis | §73 | 🟡 | Seed service exists |

---

## DISPATCH CONSOLE (Blazor Server)

| # | Feature | PRD § | Status | Notes |
|---|---------|-------|--------|-------|
| DC01 | Map view (Google Maps JS API) | §42 | 🟡 | MapView.razor exists, needs Google API key wired |
| DC02 | Map — driver position pins (live GPS) | §42, §31 | 🔴 | Not verified |
| DC03 | Map — unallocated booking pins | §42 | 🔴 | Not implemented |
| DC04 | Scheduler/timeline (Syncfusion SfSchedule) | §95 | ✅ | SfSchedule TimelineDay, driver resources, drag-drop, Material Dark |
| DC05 | Scheduler — driver rows on Y-axis | §95 | ✅ | SfSchedule ScheduleResource with driver resources |
| DC06 | Scheduler — booking tiles with driver colours | §43, §95 | ✅ | Color from DriverDto.ColorCodeRGB |
| DC07 | Scheduler — unallocated amber | §43 | ✅ | Default color #F59E0B for unallocated |
| DC08 | Scheduler — accepted diagonal stripes | §43 | 🔴 | CSS pattern needed for accepted status |
| DC09 | Scheduler — drag-and-drop allocation | §137 | 🟡 | HTML5 Drag API, not Syncfusion |
| DC10 | Floating booking form (slides from left) | §42 | 🟡 | BookingForm.razor exists |
| DC11 | Booking form — Google Places autocomplete | §49 | ✅ | Wired to /api/address/autocomplete endpoint |
| DC12 | Booking form — all fields from §96 | §96 | 🔴 | Not verified against full field spec |
| DC13 | Booking form — auto-time-update (ticks every second) | §101 | 🔴 | Not implemented |
| DC14 | Booking form — ASAP toggle (current + 5 min) | §101 | 🔴 | Not verified |
| DC15 | Booking form — return booking creation | §84 | 🔴 | Not verified |
| DC16 | Booking form — repeat booking (recurrence UI) | §84 | 🔴 | Not implemented |
| DC17 | Context panel (slides from right on click) | §42 | 🟡 | BookingDetailPanel.razor exists |
| DC18 | Caller popup (phone number → history) | §98, §110 | 🔴 | Not implemented |
| DC19 | Caller queue stacking (multiple callers) | §101 | 🔴 | Not implemented |
| DC20 | Driver selection screen | §97 | 🟡 | DriverSelector.razor exists |
| DC21 | Driver selection — colour-coded, type number to allocate | §97 | 🔴 | Not verified |
| DC22 | Command palette (Cmd+K) | §42 | 🟡 | CommandPalette.razor exists |
| DC23 | Keyboard shortcuts (all from §23) | §23 | 🔴 | Not verified |
| DC24 | Sidebar navigation (64px icons, expands on hover) | §42 | 🟡 | Sidebar.razor exists |
| DC25 | Top bar (48px) | §42 | 🟡 | TopBar.razor exists |
| DC26 | SMS Heartbeat indicator | §119 | 🔴 | Not implemented |
| DC27 | Direct Message button | §119 | 🔴 | Not implemented |
| DC28 | Global Message button | §119 | 🔴 | Not implemented |
| DC29 | Notification bell with badge count | §119 | 🔴 | Not implemented |
| DC30 | 3 view modes: Map, Diary, Split | §42 | 🔴 | Not implemented |
| DC31 | Multi-monitor pop-out support | §42 | 🔴 | Not implemented (future) |
| DC32 | SignalR real-time updates (booking/driver events) | §137 | 🟡 | Hub wired, verify events update UI |
| DC33 | Notification sounds (4 audio events) | §133 | 🔴 | Not implemented |
| DC34 | Right-click context menu on bookings | §137 | 🔴 | Not implemented |
| DC35 | Material Dark theme (Syncfusion) | §41 | ✅ | material-dark.css loaded, Tailwind + Syncfusion coexist |

---

## TENANT ADMIN (Blazor WASM)

| # | Feature | PRD § | Status | Notes |
|---|---------|-------|--------|-------|
| TA01 | Full sidebar navigation (§121) | §121 | 🟡 | AdminSidebar.razor exists |
| TA02 | Dashboard with KPIs | §30 | 🟡 | Dashboard.razor exists |
| TA03 | Booking list with search/filter | §76 | 🟡 | BookingList.razor exists |
| TA04 | Booking detail/edit | §76 | 🟡 | BookingDetail.razor exists |
| TA05 | Invoice Processor (normal — single journey) | §118 | 🟡 | InvoiceProcessor.razor exists |
| TA06 | Invoice Processor (Grp) — Singles tab (3-level hierarchy) | §118 | 🔴 | Not implemented |
| TA07 | Invoice Processor (Grp) — Shared tab | §118 | 🔴 | Not implemented |
| TA08 | Invoice Processor — inline editable fields (orange highlight) | §118 | 🔴 | Not implemented |
| TA09 | Invoice Processor — Price All / Post All Priced buttons | §118 | 🔴 | Not verified |
| TA10 | Statement Processing (flat list, 17 columns) | §120 | 🟡 | StatementProcessing.razor exists |
| TA11 | Statement Processing — filter by Driver/Scope | §120 | 🔴 | Not verified |
| TA12 | Statement History | §121 | 🟡 | StatementHistory.razor exists |
| TA13 | Invoice History | §121 | 🟡 | InvoiceHistory.razor exists |
| TA14 | Credit Notes page | §121 | 🟡 | CreditNotes.razor exists |
| TA15 | VAT Outputs page | §121 | 🟡 | VatOutputs.razor exists |
| TA16 | Driver list | §78 | 🟡 | DriverList.razor exists |
| TA17 | Driver detail/edit (profile, vehicle, commission, colour) | §78, §107 | 🟡 | DriverDetail.razor exists |
| TA18 | Driver document management (upload, expiry) | §52 | 🔴 | Not implemented |
| TA19 | Driver expense management | §53 | 🔴 | Not implemented |
| TA20 | Account list | §79 | 🟡 | AccountList.razor exists |
| TA21 | Account detail/edit (tariff linking) | §79 | 🟡 | AccountDetail.razor exists |
| TA22 | Availability page (presets, driver colours) | §123 | 🟡 | AvailabilityPage.razor exists |
| TA23 | Availability — 5 preset buttons | §123 | 🔴 | Not verified |
| TA24 | Availability Logs page | §121 | 🔴 | Not implemented |
| TA25 | Tariff configuration (T1/T2/T3) | §83 | 🟡 | TariffList.razor exists |
| TA26 | Account Tariff configuration | §83 | 🟡 | AccountTariffList.razor exists |
| TA27 | Zone Pricing (polygon editor + pricing matrix) | §126 | 🟡 | ZonePricing.razor exists |
| TA28 | Zone Pricing — draw polygons on Google Maps | §126 | 🔴 | Not verified |
| TA29 | Zone Pricing — pricing matrix (Cost + Charge per zone pair) | §126 | 🔴 | Not verified |
| TA30 | Fixed Route Pricing CRUD | §132 | 🔴 | Not implemented |
| TA31 | Local POIs management | §87 | 🟡 | LocalPois.razor exists |
| TA32 | Reports — Booking Breakdown | §112 | 🟡 | BookingBreakdown.razor exists |
| TA33 | Reports — Driver Earnings | §112 | 🟡 | DriverEarnings.razor exists |
| TA34 | Reports — Revenue | §112 | 🟡 | RevenuePage.razor exists |
| TA35 | Reports — Top Customers | §112 | 🟡 | TopCustomers.razor exists |
| TA36 | Reports — all 18 from §112 | §112 | 🔴 | Only 4 report pages exist |
| TA37 | Company Settings (all fields from §83) | §83 | 🟡 | CompanySettings.razor exists |
| TA38 | Message Settings (11 events, channel config) | §83 | 🟡 | MessageSettings.razor exists |
| TA39 | Tracking page (live driver map) | §31 | 🔴 | Not implemented |
| TA40 | Utilities menu | §121 | 🔴 | Not implemented |
| TA41 | Credit Invoice page | §121 | 🔴 | Not implemented |
| TA42 | Credit Journeys page | §121 | 🔴 | Not implemented |

---

## CUSTOMER WEB PORTAL (Blazor WASM)

| # | Feature | PRD § | Status | Notes |
|---|---------|-------|--------|-------|
| WP01 | Account booker login | §113 | 🟡 | Page exists |
| WP02 | Booking dashboard | §113 | 🟡 | Page exists |
| WP03 | Create booking form | §113 | 🟡 | Page exists |
| WP04 | Repeat booking | §113 | 🔴 | Not verified |
| WP05 | Active bookings list | §113 | 🟡 | Page exists |
| WP06 | Booking history | §113 | 🟡 | Page exists |
| WP07 | Passenger list management | §113 | 🔴 | Not verified |
| WP08 | Add passenger | §113 | 🔴 | Not verified |
| WP09 | Amendment request submission | §130 | 🔴 | Not implemented |
| WP10 | Cancellation request | §130 | 🔴 | Not implemented |

---

## DRIVER APP (Flutter — iOS + Android)

| # | Feature | PRD § | Status | Notes |
|---|---------|-------|--------|-------|
| DA01 | 5-tab bottom navigation | §78 | 🟡 | Scaffold exists (29 dart files) |
| DA02 | Schedule tab (today's jobs chronologically) | §78, §109 | 🟡 | Screen exists |
| DA03 | Calendar view | §94 | 🔴 | Not verified |
| DA04 | Job offer screen (full-screen takeover) | §137 | 🟡 | Screen exists |
| DA05 | Job offer — countdown timer | §137 | 🔴 | Not verified |
| DA06 | Job offer — accept/reject buttons (56px) | §137 | 🔴 | Not verified |
| DA07 | Job offer — sound alert + vibration | §137 | 🔴 | Not implemented |
| DA08 | Active job — status progression (OnRoute→Arrived→POB→Clear) | §137 | 🟡 | Screen exists |
| DA09 | Active job — navigation to pickup (Google Maps intent) | §78 | 🔴 | Not verified |
| DA10 | Completion form (waiting, parking, price, tip) | §137 | 🟡 | Screen exists |
| DA11 | Hackney mode (rank job creation, meter) | §78 | 🔴 | Not implemented |
| DA12 | Online/offline toggle with GPS tracking | §137 | 🟡 | Exists |
| DA13 | On Break / Finish Break | §137 | 🔴 | Not verified |
| DA14 | Availability management | §123 | 🟡 | Screen exists |
| DA15 | Earnings report | §109 | 🟡 | Screen exists |
| DA16 | Statement viewing with PDF | §109 | 🔴 | Not verified |
| DA17 | Expense submission | §109 | 🟡 | Screen exists |
| DA18 | Document upload (camera + gallery) | §52, §109 | 🔴 | Not verified |
| DA19 | Profile (vehicle details, colour) | §109 | 🟡 | Screen exists |
| DA20 | Messages screen (direct + global) | §109 | 🔴 | Not verified |
| DA21 | Booking log screen | §109 | 🔴 | Not implemented |
| DA22 | Report screen | §109 | 🔴 | Not verified |
| DA23 | GPS background service | §59, §109 | 🔴 | Not implemented |
| DA24 | FCM push notification handling | §137 | 🔴 | Not verified |
| DA25 | Login screen | §109 | 🟡 | Screen exists |

---

## CUSTOMER APP (Flutter — iOS + Android)

| # | Feature | PRD § | Status | Notes |
|---|---------|-------|--------|-------|
| CA01 | Tenant selection (nearby companies by GPS) | §129 | 🔴 | Not verified |
| CA02 | Phone + OTP login | §129 | 🟡 | Screen exists |
| CA03 | Home screen (map + "Where to?" search) | §129 | 🟡 | Screen exists |
| CA04 | Google Places autocomplete in search | §129 | 🟡 | Backend endpoint exists, Flutter wiring needed |
| CA05 | Booking confirmation (vehicle type, price, payment) | §129 | 🟡 | Screen exists |
| CA06 | Upfront fixed price quote | §46, §129 | 🔴 | Not verified |
| CA07 | Via stops (Add Stop, max 5) | §129 | 🔴 | Not verified |
| CA08 | Payment method selection (card, Apple Pay, Google Pay, cash) | §129 | 🔴 | Not implemented |
| CA09 | Booking submitted → waiting for confirmation | §129 | 🟡 | Screen exists |
| CA10 | Driver allocated → live map tracking | §129 | 🟡 | Screen exists |
| CA11 | Live ETA countdown (recalculated every 30s) | §51, §129 | 🔴 | Not implemented |
| CA12 | In-app chat (customer ↔ driver) | §58 | 🔴 | Not implemented |
| CA13 | Trip complete — rating (1-5 stars) | §56, §129 | 🟡 | Screen exists |
| CA14 | Trip complete — review request link | §131 | 🔴 | Not implemented |
| CA15 | Booking history | §129 | 🟡 | Screen exists |
| CA16 | Saved places (home, work, favourites) | §129 | 🔴 | Not verified |
| CA17 | Payment methods management | §129 | 🔴 | Not implemented |
| CA18 | Profile + GDPR delete account | §64, §129 | 🔴 | Not verified |
| CA19 | Share trip tracking link | §129 | 🔴 | Not implemented |
| CA20 | Push notifications (booking confirmed, driver arriving, etc.) | §129 | 🔴 | Not verified |

---

## OPERATOR MOBILE APP (Flutter — iOS + Android)

| # | Feature | PRD § | Status | Notes |
|---|---------|-------|--------|-------|
| OM01 | 4-tab bottom navigation | §128 | 🟡 | Scaffold exists (13 dart files) |
| OM02 | Bookings tab — today's bookings list | §128 | 🟡 | Screen exists |
| OM03 | Bookings tab — filter (all/unallocated/allocated/completed) | §128 | 🔴 | Not verified |
| OM04 | Bookings tab — new booking FAB | §128 | 🔴 | Not verified |
| OM05 | Bookings tab — simplified booking form | §128 | 🔴 | Not verified |
| OM06 | Alerts tab — pending web bookings (accept/reject) | §128, §130 | 🔴 | Not implemented |
| OM07 | Alerts tab — driver events | §128 | 🔴 | Not implemented |
| OM08 | Live Map tab — driver pins (GPS) | §128 | 🔴 | Not implemented |
| OM09 | Live Map tab — tap pin → allocate | §128 | 🔴 | Not implemented |
| OM10 | More tab — drivers, accounts, messages, stats | §128 | 🔴 | Not verified |
| OM11 | CONF SA (confirm all soft allocates) | §128 | 🔴 | Not implemented |
| OM12 | Push notifications | §128 | 🔴 | Not verified |

---

## DEPLOYMENT & DEVOPS

| # | Feature | PRD § | Status | Notes |
|---|---------|-------|--------|-------|
| DV01 | GitHub Actions CI/CD pipeline | §73 | 🟡 | deploy.yml exists |
| DV02 | Docker multi-stage builds | §73 | 🟡 | Dockerfile exists |
| DV03 | docker-compose.yml (API + Redis + Hangfire) | §35 | 🟡 | File exists |
| DV04 | Hetzner CX32 deployment | §35 | 🔴 | Not tested |
| DV05 | IIS local hosting scripts | §140 | 🟡 | Mentioned |
| DV06 | appsettings.Development.json (gitignored) | §140 | 🟡 | Exists |
| DV07 | SSL/HTTPS configuration | — | 🔴 | Not configured |

---

## SUMMARY COUNTS

| Status | Count | Percentage |
|--------|-------|-----------|
| ✅ Done (verified working) | 0 | 0% |
| 🟡 Partial (code exists, not verified) | ~95 | ~40% |
| 🔴 Not Started / Not Implemented | ~140 | ~60% |
| **Total features** | **~235** | |

### Critical Blockers (must fix first)
1. ✅ PR02 — Google Distance Matrix — FIXED: GoogleDistanceMatrixService with real API calls
2. ✅ PR03 — Dead mileage — FIXED: reads BasePostcode, calculates legA+legC
3. ✅ PR05 — Via segment — FIXED: sums all segments pickup→via1→...→dest
4. ✅ OT01 — Google Places autocomplete — FIXED: GooglePlacesService + /api/address/*
5. ✅ DC04 — Syncfusion scheduler — FIXED: SfSchedule TimelineDay with driver resources
6. ✅ DC11 — Booking form address search — FIXED: wired to Places autocomplete
7. ✅ PR08 — Bank holidays — FIXED: configurable JSON list, seeded 2025-2027
