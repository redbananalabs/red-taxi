# Claude Code Handoff — Red Taxi Platform

> **Read this first. Then read the files it references. Then start building.**

---

## What You're Building

Red Taxi is a multi-tenant SaaS taxi dispatch platform. 7 apps, 1 API, per-tenant databases. First tenant: Ace Taxis (Dorset, UK).

## Repository

```
git clone https://github.com/onesoftuk/red-taxi.git
```

GitHub token: provided separately (do not commit tokens to repo)

## Context Files — Read in This Order

1. **`docs/build-strategy.md`** — build phases, agent assignment, parallel execution plan, dependency graph
2. **`docs/PRD.md`** — 140 sections, 4,600+ lines. The COMPLETE product spec. Every business rule, formula, entity, screen, workflow.
3. **`docs/business-rules.md`** — 42 business rule sections (extracted from legacy code)
4. **`docs/architecture/master-architecture.md`** — system architecture
5. **`docs/data-model/master-data-model.md`** — entity relationships
6. **`docs/design/design-language.md`** — design system (Material Dark, Syncfusion, Tailwind)
7. **`docs/design/dispatch-layout.md`** — dispatch console map-centric layout
8. **`docs/design/driver-app.md`** — driver app 5-tab design
9. **`docs/saas-pricing.md`** — SaaS pricing model (Solo/Team/Fleet + bolt-ons)
10. **`design-tokens.json`** — colours, typography, spacing tokens

There are 70+ docs in the repo. Search them when you need detail on any topic.

## Legacy Code (Reference Only — Do NOT Port)

The `legacy/` folder contains the old system code for reference:
- `legacy/TaxiDispatch.API/` — .NET 8 backend (20 controllers, 232 endpoints)
- `legacy/TaxiDispatch.Lib/` — 18 services (13,758 lines), 36 entities
- `legacy/ace-dispatcher/` — React dispatch console
- `legacy/ace-admin-panel/` — React admin panel
- `legacy/ace-driver-app/` — Flutter driver app
- `legacy/ace-account-web-booker/` — React account portal
- `legacy/ace-local-sms/` — .NET MAUI Android SMS gateway

Use these to verify business logic, NOT to copy code. The rebuild is clean architecture, not a port.

## Tech Stack (LOCKED — Do Not Change)

| Layer | Choice |
|-------|--------|
| Backend | .NET 8, EF Core 8, MediatR, SQL Server, Redis, Hangfire, SignalR |
| Dispatch Console | Blazor Server + Syncfusion (Material Dark) + Tailwind CSS |
| Customer Portal | Blazor WASM + Tailwind CSS |
| Tenant Admin | Blazor WASM + Tailwind CSS |
| Driver App | Flutter (iOS + Android) |
| Customer App | Flutter (iOS + Android) |
| Operator Mobile App | Flutter (iOS + Android) |
| Platform Billing | Stripe Billing (subscriptions) |
| Tenant Payments | Stripe or Revolut (tenant's own keys, tenant chooses) |
| SMS | TextLocal (branded) |
| Maps | Google Maps + Distance Matrix |
| Address | Google Places + Ideal Postcodes (dual) |
| PDF | QuestPDF |
| Icons | Lucide Icons |
| Email | SendGrid (platform); tenant-configurable (SMTP/SendGrid/Mailgun/SES) |
| Error Monitoring | Sentry + Seq |

## Local Development Setup

**Install these tools first:**
- .NET 8 SDK
- SQL Server 2022 Express (connection: `Server=localhost\SQLEXPRESS;Trusted_Connection=True;TrustServerCertificate=True`)
- Redis for Windows (or Memurai) on `localhost:6379`
- Node.js 20 LTS (for Tailwind CSS build)
- Flutter SDK (for mobile apps)
- Stripe CLI (`winget install Stripe.StripeCLI` then `stripe login`)
- IIS (enable Windows feature, for realistic local hosting)

**Database setup:**
- Master DB: `RedTaxi_Platform` (tenant registry, Stripe config)
- First tenant DB: `RedTaxi_ace` (Ace Taxis business data)
- EF Core migrations handle schema creation

**Stripe setup:**
- Use TEST mode keys (`sk_test_*`, `pk_test_*`) for development
- Install Stripe CLI: `winget install Stripe.StripeCLI` then `stripe login`
- Forward webhooks locally: `stripe listen --forward-to https://localhost:5001/api/stripe/webhook`
  (this auto-generates the webhook signing secret `whsec_*`)
- Products/prices created via `StripeSeedService` at startup (idempotent — uses Stripe API)
- See PRD §139 for full Stripe product list and webhook events

**Local URLs:**
- API: `https://localhost:5001`
- Dispatch Console: `https://localhost:5002`
- Tenant Admin: `https://localhost:5003`
- Customer Portal: `https://localhost:5004`

## Solution Structure

```
src/
├── RedTaxi.sln
├── RedTaxi.Domain/              Entities, enums, domain events, interfaces
├── RedTaxi.Application/         MediatR handlers (one per use case), DTOs, validators
├── RedTaxi.Infrastructure/      EF Core, Redis, Stripe, Revolut, Google Maps, SendGrid, Hangfire
├── RedTaxi.API/                 Controllers, SignalR hubs, middleware, auth
├── RedTaxi.Shared/              DTOs, validation, API client (shared by Blazor projects)
├── RedTaxi.Blazor/              Dispatch console (Blazor Server + Syncfusion + Tailwind)
├── RedTaxi.TenantAdmin/         Tenant admin portal (Blazor WASM + Tailwind)
├── RedTaxi.WebPortal/           Customer/account portal (Blazor WASM + Tailwind)
└── mobile/
    ├── red_taxi_shared/          Shared Flutter package (API client, models, auth, design tokens)
    ├── red_taxi_driver/          Driver app (Flutter)
    ├── red_taxi_customer/        Customer app (Flutter)
    └── red_taxi_operator/        Operator mobile app (Flutter)
```

## Architecture Rules

1. **One MediatR handler per use case** — no fat service classes. Each handler does ONE thing.
2. **Domain events for side-effects** — messaging, notifications, audit trails triggered by events, not direct calls.
3. **Per-tenant database** — no TenantId columns. Connection resolved per-request via `ITenantConnectionResolver`. Master DB only has tenant registry + Stripe data.
4. **Global query filters** — EF Core 8 global filters for soft deletes.
5. **Outbox pattern** — for reliable multi-channel message delivery.
6. **No God Classes** — the legacy `BookingService` was 2,142 lines mixing everything. We fix this with clean separation.

## Git Workflow

- **Always work on feature branches** then merge back to main
- Branch naming: `feature/{description}` or `agent/{N}-{description}`
- **Merge to main after each feature completes** — no long-lived branches
- Commit messages reference PRD sections: `"feat: booking creation (§76, §102, §134)"`

## Build Logs

**Mandatory.** Maintain build logs at `docs/build-logs/agent-{N}.md`. Log:
- What was built
- Files created/modified
- Decisions made (with rationale)
- What's left
- Known bugs or tech debt
- Handoff notes for the next session

This is how future Claude Code sessions get context. Skip this and context is lost.

## Build Order (Critical Path)

```
1. Foundation: Domain entities (40+), enums, DTOs, DbContext, migrations, solution scaffold
2. Core API: Booking CRUD, pricing engine (5-level priority), dispatch/allocation, auth (JWT + refresh)
3. Core API: Accounts, billing, invoicing, statements, messaging, company config
4. Dispatch Console: Map, scheduler, booking form, caller popup, allocation, real-time (SignalR)
5. Tenant Admin: Invoice processor, statement processor, availability, zone pricing, reports, settings
6. Customer Portal: Account booker login, booking, history, passengers, amendments
7. Driver App: 25 screens — schedule, offers, active job, availability, earnings, documents
8. Customer App: 15 screens — tenant select, OTP, booking, tracking, rating, history
9. Operator Mobile: 4 tabs — bookings, alerts, live map, more
10. Integration: SignalR wiring, Stripe webhooks, Revolut, push notifications, SMS
11. Polish: Edge cases (§84-85), drag-and-drop, school run merge, deployment
```

Steps 4-9 can run in parallel once step 3 is complete.

## Key Business Logic (Don't Miss These)

### Pricing Priority (5 levels)
```
1. Manual override (ManuallyPriced = true)
2. Zone-to-Zone (pickup in polygon A, destination in polygon B)
3. Fixed route (postcode prefix match)
4. Account tariff (dual pricing: driver rate + account rate)
5. Standard tariff (Day=T1 / Night=T2 / Holiday=T3)
```

### Cash Price Formula (§102)
```
totalMiles = (journeyMiles + deadMiles) / 2  ← AVERAGED, not added
price = tariff.InitialCharge + tariff.FirstMileCharge
if totalMiles > 1: price += (totalMiles - 1) × tariff.AdditionalMileCharge
```

### Settlement Formula (§105)
```
Commission = ((CashEarnings + CardEarnings) × CashCommRate%)
           + (RankEarnings × RankCommRate%)
           + CardFees
Net = (Cash + Card + Rank) - Commission + AccountEarnings
```

### Tariff Selection (§102)
- Tariff 1 (Day): Mon-Fri 07:00-21:59, Sat 07:00-21:59
- Tariff 2 (Night): Any day 22:00-06:59, all Sunday, bank holidays
- Tariff 3 (Holiday): Dec 24 after 18:00, Dec 25-26, Dec 31 after 18:00, Jan 1

### Booking State Machine (§134)
```
Created → Allocated → Accepted → OnRoute → Arrived → PassengerOnBoard → Completed
                   → Rejected/Timeout → back to Unallocated
At any point → Cancelled, COA (Cancel on Arrival), Reallocated
```

## What Success Looks Like

When you're done, an operator should be able to:
1. Log into the dispatch console, see today's bookings on a map + scheduler
2. Receive a phone call, see caller popup with history, create a booking in 3 clicks
3. Allocate a driver (drag-and-drop or driver list), driver gets push notification
4. Driver accepts on their app, drives to pickup, completes the job
5. Customer gets live tracking link, rates the driver after
6. At end of week: process driver statements, generate account invoices, send PDFs
7. Tenant admin manages drivers, accounts, tariffs, zones, availability, reports

And a taxi company should be able to:
1. Sign up at redtaxi.co.uk, pick a plan, start 14-day trial
2. Configure their company, add drivers, set tariffs
3. Go live taking bookings within 30 minutes of signup
