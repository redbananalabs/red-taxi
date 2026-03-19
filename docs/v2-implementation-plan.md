# Red Taxi V2 — Feature Implementation Plan

> **V2 = Wrap & extend the proven codebase, don't rewrite.**
> 125 features already working. Focus on what's NEW and what needs IMPROVING.
> Last Updated: 2026-03-19

---

## Phase 1: Foundation & Cleanup (Week 1)

### 1.1 Repo Cleanup
- [ ] Delete pre-rename duplicates (AceTaxis.Lib, AceTaxisAPI, TaxiDispatch.API)
- [ ] Move RedTaxi.API + RedTaxi.Lib to src/
- [ ] Move frontends to frontend/
- [ ] Move mobile apps to mobile/
- [ ] Archive v1 reusable code
- [ ] Delete HTMLPage1.html, empty folders
- [ ] Update all docs to reflect new structure

### 1.2 .NET 7 → .NET 8 Upgrade
- [ ] Update TargetFramework in all .csproj files
- [ ] Update EF Core 7 → EF Core 8
- [ ] Update ASP.NET Core packages
- [ ] Fix any breaking changes
- [ ] Smoke test: all 14 sections pass

### 1.3 Config Extraction (PRD §104 — 18 items)
- [ ] C01: Base postcode "SP8 4PZ" → CompanyConfig.BasePostcode
- [ ] C02: Bank holidays hardcoded → CompanyConfig.BankHolidays (JSON)
- [ ] C03: HVS account numbers (9014, 10026) → AccountTariff FK
- [ ] C04: HVS per-mile rates → AccountTariff fields
- [ ] C05: HVS via surcharge → AccountTariff.ViaSurcharge
- [ ] C06: Rank commission 7.5% → CompanyConfig.RankCommissionRate
- [ ] C07: Waiting rates £0.33/£0.42 → CompanyConfig.WaitingRate*
- [ ] C08: Distance Matrix key (TariffService:466) → config
- [ ] C09: SendGrid template IDs → MessagingNotifyConfig
- [ ] C10: WhatsApp SIDs → CompanyConfig
- [ ] C11: Airport strings (26) → LocalPOI type=Airport
- [ ] C12: Webhook URLs → auto per tenant subdomain
- [ ] C13: Map centre → CompanyConfig.MapCenter* (done in v1)
- [ ] C14: Min journey minutes → CompanyConfig
- [ ] C15: Block booking duration → CompanyConfig
- [ ] C16: Address centre bias → CompanyConfig
- [ ] Smoke test after each extraction

### 1.4 Controller → Service Extraction (Remaining)
- [ ] AdminUIController (56 endpoints, 36 inline DB calls) → AdminUIService
- [ ] WeBookingController (19 endpoints, 41 inline DB calls) → WebBookingService
- [ ] DriverAppController (30 endpoints) → DriverAppService
- [ ] CallEventsController (6 endpoints) → existing services
- [ ] Smoke test after each controller

---

## Phase 2: Multi-Tenancy (Week 2)

### 2.1 Tenant Infrastructure
- [ ] Master DB schema (RedTaxi_Platform): Tenants, TenantSubscriptions
- [ ] Tenant middleware (X-Tenant-Slug header → DB connection)
- [ ] ITenantConnectionResolver (reuse from archive)
- [ ] Tenant provisioning service (create DB, run migrations, seed defaults)
- [ ] Tenant subdomain routing
- [ ] Per-tenant Redis key isolation

### 2.2 Tenant Onboarding
- [ ] Signup API endpoint
- [ ] Provision new tenant DB automatically
- [ ] Seed default data (tariffs, config, admin user)
- [ ] Generate tenant subdomain
- [ ] Welcome email with login credentials

---

## Phase 3: SaaS Billing (Week 2-3)

### 3.1 Stripe Integration
- [ ] Stripe product/price seeding (14 products, 24 prices) — reuse StripeSeedService
- [ ] Stripe Checkout for signup
- [ ] Stripe Customer Portal for self-service
- [ ] Stripe webhook processing (7 events) — reuse StripeWebhookController

### 3.2 Tenant Lifecycle
- [ ] Trial: 14 days, no card required
- [ ] Active: after payment
- [ ] Grace: 3 days after payment failure
- [ ] Soft lock: read-only after grace
- [ ] Hard lock: no access after 7 days
- [ ] Data deletion: 30 days after cancellation
- [ ] Trial reminder emails (day 10, day 13)

### 3.3 Usage & Limits
- [ ] Track booking count per billing cycle
- [ ] Track driver count per tenant
- [ ] Track SMS count per month
- [ ] Enforce plan limits (Solo=1500, Team=5000, Fleet=15000 bookings/mo)
- [ ] Bolt-on management (add drivers, SMS packs, web portal)

---

## Phase 4: Booking & Dispatch UI Improvements (Week 3-4)

### 4.1 Dispatch Console — Layout (PRD §142)
- [ ] Split layout: booking form LEFT, scheduler/map RIGHT
- [ ] Draggable splitter (default 35%/65%)
- [ ] Tabbed right panel: Scheduler (default) | Map
- [ ] Booking form always visible (no sliding/hiding)
- [ ] Day view as default scheduler view
- [ ] Current time red line indicator

### 4.2 Dispatch Console — Booking Form
- [ ] All fields from PRD §96 present and working
- [ ] Google Places autocomplete in address fields
- [ ] Auto-price calculation when postcodes entered
- [ ] ASAP toggle (current time + 5 min)
- [ ] Return booking button
- [ ] Repeat/block booking UI
- [ ] Scope selector (Cash/Account/Card/Rank)
- [ ] Via stops (add/remove)
- [ ] Price override with ManuallyPriced flag
- [ ] Phone number auto-format

### 4.3 Dispatch Console — Scheduler
- [ ] Driver rows on Y-axis with driver colours
- [ ] Booking tiles at pickup times with duration width
- [ ] Unallocated row (amber #F59E0B)
- [ ] Accepted bookings with diagonal stripe pattern
- [ ] Drag-and-drop allocation between rows
- [ ] Right-click context menu (allocate, edit, complete, cancel)
- [ ] Merge mode for school runs
- [ ] Date navigation (prev/next day, today button)

### 4.4 Dispatch Console — Map
- [ ] Google Maps (dark theme) centred from CompanyConfig
- [ ] Driver position pins (live GPS, coloured by driver)
- [ ] Booking pickup markers (amber=unallocated, driver colour=allocated)
- [ ] Click marker → show booking detail
- [ ] Driver info popup on pin hover

### 4.5 Dispatch Console — Caller Popup
- [ ] Phone number → history lookup
- [ ] Show previous + current + cancelled bookings
- [ ] Click previous address → auto-fill form
- [ ] Caller queue stacking (multiple simultaneous calls)

### 4.6 Dispatch Console — Notifications
- [ ] Notification bell with badge count
- [ ] Web booking alerts (accept/reject)
- [ ] Driver event alerts
- [ ] 4 notification sounds (configurable)
- [ ] SMS heartbeat indicator

### 4.7 Dispatch Console — Keyboard Shortcuts (PRD §23)
- [ ] Ctrl+K → command palette
- [ ] Ctrl+N → new booking
- [ ] Ctrl+S → save booking
- [ ] Tab → cycle focus
- [ ] Escape → close panel/dialog
- [ ] Number keys → allocate to driver

### 4.8 Dispatch Console — Responsive / Mobile
- [ ] Breakpoints: desktop (>1280px), tablet (768-1280px), mobile (<768px)
- [ ] Desktop: full split layout
- [ ] Tablet: collapsible sidebar, stacked form/scheduler
- [ ] Mobile: separate operator mobile app (not responsive dispatch)
- [ ] OR: simplified mobile web view (booking list + quick actions only)

---

## Phase 5: Admin Panel Improvements (Week 4)

### 5.1 Invoice Processor
- [ ] Singles tab: 3-level hierarchy (Passenger → Route → Booking)
- [ ] Shared/Grp tab: 2-level (Route → Merged Booking)
- [ ] Inline editable fields (Waiting, Driver Charge, Journey Charge, Parking)
- [ ] Orange highlight on editing
- [ ] Price All button per route
- [ ] Post All Priced button
- [ ] PDF generation (QuestPDF)

### 5.2 Statement Processor
- [ ] Flat list with 17 columns
- [ ] Filter by Driver, Scope
- [ ] Post All Priced → group by driver
- [ ] PDF generation
- [ ] Email to driver with attachment

### 5.3 Zone Pricing (PRD §126)
- [ ] Polygon editor (Google Maps Drawing Manager)
- [ ] Zone pricing matrix (bidirectional grid)
- [ ] Cost (driver) + Price (customer) per zone pair
- [ ] Diagonal disabled
- [ ] Point-in-polygon matching in pricing engine

### 5.4 Availability (PRD §123)
- [ ] 5 presets: Custom, SR AM, SR PM, SR Only, Unavailable
- [ ] Colour-coded rows (driver colour)
- [ ] GiveOrTake displayed as (+/-)
- [ ] Multiple blocks per driver

### 5.5 Reports
- [ ] Verify all 18 reports work
- [ ] Add export to CSV/PDF
- [ ] Date range picker on all reports
- [ ] Filters (by driver, account, scope)

### 5.6 Company Settings
- [ ] All current fields working
- [ ] Add: map centre configuration
- [ ] Add: payment processor choice (Stripe/Revolut)
- [ ] Add: bank holiday management
- [ ] Add: configurable rates (waiting, rank commission)

---

## Phase 6: New Mobile Apps (Week 5-6)

### 6.1 Customer App — Flutter (15 screens)
- [ ] Tenant selection by GPS proximity
- [ ] Phone + OTP login
- [ ] Home map with "Where to?" search (Google Places)
- [ ] Booking confirmation with upfront price + vehicle type
- [ ] Live driver tracking with ETA countdown
- [ ] Rating (1-5 stars) + review request link
- [ ] Payment methods (Stripe card, Apple Pay, Google Pay, cash)
- [ ] Booking history + re-book
- [ ] Saved places (home, work, favourites)
- [ ] In-app chat (customer ↔ driver)
- [ ] Share trip tracking link
- [ ] Profile + GDPR delete account
- [ ] Push notifications (FCM)

### 6.2 Operator Mobile App — Flutter (4 tabs)
- [ ] Bookings tab: today's list, filter pills, new booking FAB
- [ ] Alerts tab: pending web bookings (accept/reject), driver events
- [ ] Live Map tab: Google Maps with driver pins, tap → allocate
- [ ] More tab: drivers, accounts, messages, stats, CONF SA
- [ ] Push notifications

### 6.3 Driver App Improvements
- [ ] Review existing 25 screens for bugs
- [ ] Improve job offer screen (countdown timer UX)
- [ ] Add hackney/rank job creation if missing
- [ ] Improve offline handling
- [ ] Update API URL config for multi-tenancy

### 6.4 Local SMS Gateway (Android only)
- [ ] Move to mobile/local-sms/
- [ ] Verify MAUI build for Android
- [ ] Test SMS sending flow

---

## Phase 7: Marketing & Onboarding (Week 6-7)

### 7.1 Marketing Website (Next.js)
- [ ] Landing page with value proposition
- [ ] Features page
- [ ] Pricing page (Solo/Team/Fleet/Enterprise)
- [ ] Signup flow → Stripe Checkout
- [ ] FAQ page
- [ ] Contact/demo request form

### 7.2 Tenant Onboarding Wizard
- [ ] Company details (name, postcode, phone)
- [ ] Choose plan
- [ ] Payment (Stripe)
- [ ] Auto-provision tenant DB
- [ ] Configure basics (tariffs, first driver, first account)
- [ ] "Go live" checklist

---

## Phase 8: Polish & Go Live (Week 7-8)

### 8.1 Security
- [ ] RBAC enforcement on all endpoints (Admin/Dispatcher/Driver/Viewer/Accountant)
- [ ] Rate limiting on public endpoints
- [ ] CORS configuration per tenant subdomain
- [ ] Audit logging on all write operations
- [ ] GDPR: data export, right to delete

### 8.2 Infrastructure
- [ ] Docker multi-stage builds
- [ ] GitHub Actions CI/CD
- [ ] Hetzner CX32 deployment
- [ ] SSL/HTTPS with Let's Encrypt
- [ ] Health check endpoint (/health)
- [ ] Sentry error monitoring
- [ ] Seq structured logging (already started)

### 8.3 Testing with Ace Taxis
- [ ] Point Ace Taxis to new multi-tenant instance
- [ ] Verify all operator workflows
- [ ] Verify driver app connects
- [ ] Verify web booker works
- [ ] Verify invoicing and statements
- [ ] Run full smoke test suite
- [ ] 1 week parallel running (old + new)

---

## Future (Post-Launch)

### AI Features (PRD Phase 5+)
- [ ] Voice booking agent
- [ ] AI dispatch suggestions
- [ ] Dynamic pricing
- [ ] Route optimisation
- [ ] No-show/fraud detection
- [ ] Operator copilot (NL queries)

### Platform Enhancements
- [ ] Replace Pusher with SignalR
- [ ] Separate account booker logins
- [ ] CMAC integration
- [ ] School transport module
- [ ] Airport feed integration
- [ ] Accounting integration (Xero, QuickBooks)
- [ ] DVLA driver verification
