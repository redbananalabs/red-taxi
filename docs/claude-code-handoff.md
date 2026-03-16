# Red Taxi — Claude Code Build Handoff

**Date:** 2026-03-16  
**Status:** Ready to build Phase 1

---

## 1. What Claude Code Should Do First

### Step 1: Analyse Legacy Service Files
Extract exact business logic from these god services before writing any new code:

| File | Lines | Extract |
|------|-------|---------|
| `TaxiDispatch.Lib/Services/BookingService.cs` | 2,142 | Every booking operation: create, update, cancel, complete, duplicate, merge, price calc triggers, recurrence handling |
| `TaxiDispatch.Lib/Services/DispatchService.cs` | 1,002 | Allocation flow, soft allocate, confirm, unallocate, job offer sending, turn-down recording |
| `TaxiDispatch.Lib/Services/AccountsService.cs` | 2,247 | Invoice generation, statement generation, batch pricing, credit notes, posting/unposting, HVS pricing |
| `TaxiDispatch.Lib/Services/TariffService.cs` | 709 | Price calculation (Google Distance Matrix call, tariff application, dead miles) |
| `TaxiDispatch.Lib/Services/AceMessagingService.cs` | 891 | Message template rendering, channel selection (SMS/WhatsApp/Push), send logic |
| `TaxiDispatch.Lib/Services/WebBookingService.cs` | 878 | Web portal booking creation, acceptance, rejection, amendment requests |
| `TaxiDispatch.Lib/Services/AvailabilityService.cs` | 491 | Availability CRUD, preset logic, availability grid queries |

For each service: produce a document listing every public method, what it does, which entities it touches, and which MediatR handler it should become.

### Step 2: Create the Solution Structure

The repo should be organised as follows (legacy code copied in for reference):

```
redtaxi/
├── legacy/                         ← existing Ace projects (READ-ONLY reference)
│   ├── TaxiDispatch.API/
│   ├── TaxiDispatch.Lib/
│   ├── TaxiDispatch.Tests/
│   ├── ace-admin-ui/               ← React dispatch console (if available)
│   ├── ace-sms-gateway/            ← Android SMS gateway (if available)
│   └── ace-driver-app/             ← Driver app (if available)
├── src/
│   ├── RedTaxi.sln
│   ├── RedTaxi.API/                (.NET 8 Web API + Blazor Server host)
│   ├── RedTaxi.Application/        (MediatR handlers by feature)
│   ├── RedTaxi.Domain/             (Entities, enums, events, interfaces)
│   ├── RedTaxi.Infrastructure/     (EF Core, Redis, external APIs)
│   ├── RedTaxi.Blazor/             (Dispatch console - Blazor Server + Syncfusion)
│   └── RedTaxi.WebPortal/          (Customer booking portal)
├── tests/
│   ├── RedTaxi.UnitTests/
│   ├── RedTaxi.IntegrationTests/
│   └── RedTaxi.ArchTests/
├── docs/                            ← already populated (8 docs + chatgpt-source)
├── docker-compose.yml
├── .github/workflows/deploy.yml
└── .gitignore
```

Claude Code should reference `legacy/` when extracting business logic but NEVER modify files in that folder.

### Step 3: Build Strategy — API First, Then Parallel Frontends

The backend API is built first as the single source of truth. Once the API is stable, parallel agents build each frontend project against it.

#### Phase 1A: Backend API (Days 1-5)

Build in this order:

1. **Solution scaffold** — RedTaxi.sln, project references, NuGet packages
2. **Domain entities** — port from legacy `Data/Models/`, remove TenantId columns (per-tenant DB means no TenantId needed), add new entities (Customer, SavedAddress)
3. **DbContext** — RedTaxiDbContext with per-tenant database connection resolution (master DB holds tenant registry, each tenant gets own database)
4. **Auth** — ASP.NET Core Identity + JWT + roles (SuperAdmin, TenantAdmin, Dispatcher, Driver, AccountUser, WebBooker)
5. **Booking CRUD** — CreateBooking, UpdateBooking, CancelBooking, CompleteBooking, GetBookingsToday, GetBookingById, FindBookings, DuplicateBooking
6. **Pricing engine** — TariffService port: Google Distance Matrix, tariff selection by time/day, price calculation (InitialCharge + FirstMile + AdditionalMiles × Rate), account tariff overrides (dual pricing)
7. **Customer directory** — CreateCustomer, LookupByPhone, GetCustomer
8. **Driver availability** — SetAvailability, GetAvailability (with presets: Custom, SR AM Only, SR PM Only, SR Only, UNAVAILABLE ALL DAY), availability logs
9. **Dispatch** — AllocateBooking, SoftAllocate, ConfirmSoftAllocates, RecordTurnDown, COA
10. **Driver fleet** — DriverList, DriverAdd, DriverUpdate, GPS ingestion, shift tracking
11. **Messaging** — SendSMS, SendWhatsApp, SendPush (event-driven via domain events)
12. **Accounts** — AccountCRUD, InvoiceProcessor, StatementProcessing, CreditNotes
13. **Reporting** — all 18 report endpoints (driver earnings, booking stats, financials)
14. **Web booking** — CreateWebBooking, Accept, Reject, AmendRequest
15. **Admin/Config** — CompanySettings, MessageSettings, TariffConfig, AccountTariffs, LocalPOIs

Deploy to IIS after each sprint for immediate testing.

#### Phase 1B: Parallel Frontend Agents (Days 6-12)

Once the API is stable, spin up parallel agents:

| Agent | Project | Key screens |
|-------|---------|-------------|
| Agent 1 | RedTaxi.Blazor (dispatch console) | Booking form, diary/scheduler, availability grid, driver status, map, dashboard, all admin pages |
| Agent 2 | RedTaxi.WebPortal (customer portal) | Account login, booking form, active bookings, passenger management, booking history |
| Agent 3 | Flutter driver app (Phase 3) | Login, jobs, accept/reject, navigation, GPS, documents, earnings |

All agents consume the same API. No blocking dependencies between them.

#### Phase 2: Integration & Polish (Days 13-18)
- SignalR real-time updates (diary, dispatch, GPS)
- Drag-and-drop booking reallocation
- School run merge
- Payment links (Revolut)
- Phone lookup / caller ID
- Dark mode
- Keyboard shortcuts

### Staging: IIS on Windows

During development, deploy to IIS on your Windows machine alongside the existing Ace system.

**IIS Setup:**
- Create a new IIS site: `RedTaxi` on a different port (e.g. 5100) or subdomain
- Application Pool: .NET CLR version = No Managed Code (runs via ASP.NET Core module)
- Install ASP.NET Core Hosting Bundle on the server
- Publish command: `dotnet publish src/RedTaxi.API -c Release -o C:\inetpub\redtaxi`
- SQL Server: create `RedTaxi` database alongside existing `TaxiDispatch` database
- Redis: install Redis for Windows or use Docker Desktop for Redis only
- Connection strings in `appsettings.Production.json`

**Deployment during dev:**
```
dotnet publish src/RedTaxi.API -c Release -o C:\inetpub\redtaxi
```
Or configure a simple PowerShell script that builds + publishes + restarts the IIS app pool.

**Later:** Hetzner Docker deployment for production (docker-compose.yml already in repo).

---

## 2. Reference Documents (all in `docs/`)

| Doc | Purpose |
|-----|---------|
| `PRD.md` | What to build (34 sections) |
| `business-rules.md` | How it works (28 sections) |
| `data-model.md` | Entity definitions and relationships |
| `api-contract.md` | 232 legacy endpoints → v2 REST routes |
| `architecture.md` | Stack decisions, project structure, ADRs |
| `module-map.md` | 72 modules for parallel development |
| `saas-packaging.md` | SaaS tiers (not needed for Phase 1) |

---

## 3. Key Technical Decisions (Do Not Override)

- **Blazor Server** for dispatch console (not WASM)
- **Syncfusion Blazor** components: SfSchedule (diary), SfDataGrid (lists/reports), SfChart (dashboard), SfTextBox/SfDropDown (forms)
- **MediatR** — one handler per use case, no service-to-service calls
- **Domain events** — messaging triggered by events (BookingAllocated → send notification), not by direct calls
- **Hangfire** for background jobs (not RabbitMQ)
- **QuestPDF** for invoice/statement PDFs
- **SignalR** for real-time dispatch updates (built into Blazor Server)
- **EF Core** with `IDbContextFactory` (same pattern as legacy)
- **Redis** for GPS cache and SignalR backplane
- **Per-tenant database** — master DB (`RedTaxi_Platform`) holds tenant registry, each tenant gets own DB (`RedTaxi_{slug}`). Connection resolved per-request via `ITenantConnectionResolver`. No TenantId columns, no global query filters — complete physical isolation.

---

## 4. Legacy Code to Port vs Rewrite

### Port (copy logic, clean up structure)
- Tariff calculation (TariffService.GetPriceHVS — the core algorithm works)
- Booking entity model (Booking.cs — field definitions are correct)
- Enum definitions (BookingEnums.cs — all values must match for import compatibility)
- AutoMapper profiles (field mappings between entities and DTOs)

### Rewrite (logic is correct but structure is wrong)
- BookingService → split into ~15 MediatR handlers
- DispatchService → split into ~8 MediatR handlers
- AccountsService → split into ~12 MediatR handlers
- AceMessagingService → domain event handlers (not direct calls)

### Discard
- WeatherForecast.cs (template leftover)
- ATestController (test endpoint)
- Legacy migration files (new baseline migration for Red Taxi)

---

## 5. Phase 1A Definition of Done (API)

The API is complete when all these endpoints work via Swagger/Postman:

1. Auth: login, register, refresh token, role-based access
2. Create a booking with all fields (pickup, destination, vias, passenger, date/time, scope)
3. Price auto-calculates using tariff rules (T1/T2/T3 + account tariffs)
4. Get bookings today, by date range, by ID, by search term
5. Allocate a driver to a booking (+ soft allocate + confirm)
6. Complete and cancel bookings (+ COA)
7. Look up customer by phone number, create customer
8. Set and get driver availability (with presets)
9. Driver list with profiles, GPS position update
10. Account CRUD, invoice processor, statement processing
11. All 18 report endpoints returning correct data
12. Web booking submit, accept, reject
13. Send SMS/WhatsApp/Push via domain events on allocation/completion
14. Company settings, message settings, tariff config, POIs

## 6. Phase 1B Definition of Done (Blazor Dispatch Console)

The dispatch console is complete when an operator can:

1. Log in and see the dashboard with KPI cards and driver earnings
2. Create a booking and see the price auto-calculate with map route
3. See bookings on the diary/scheduler with driver columns
4. Allocate a driver (booking changes to driver's colour)
5. Soft allocate and bulk confirm
6. Drag bookings between drivers on the diary
7. Search bookings by multiple fields
8. Look up customer by phone (caller ID popup with history)
9. Set driver availability using presets
10. View all admin pages: accounts, drivers, tariffs, billing, reports
11. Receive real-time SignalR updates on diary changes
12. Toggle dark mode

---

## 7. Machine Allocation & Parallel Agent Plan

### Hardware

| Machine | OS | Assigned Work |
|---------|-----|--------------|
| PC 1 | Windows + IIS | Backend API (Phase 1A) → then Blazor dispatch console (Phase 1B) |
| PC 2 | Windows | Customer web portal + admin features |
| Mac | macOS | Flutter driver app (iOS build requires Xcode on Mac) |

### Phase 1A: API Build (Days 1-5) — PC 1 Only

Single agent on PC 1 builds the entire API. Deploy to IIS on same machine for immediate testing. This is sequential — the API contract must be solid before frontends start.

### Phase 1B: Parallel Frontend Build (Days 6-12) — All 3 Machines

| Machine | Agent | Project | Key deliverable |
|---------|-------|---------|----------------|
| PC 1 | Agent 1 | `src/RedTaxi.Blazor/` | Dispatch console (Syncfusion SfSchedule, booking form, all admin pages) |
| PC 2 | Agent 2 | `src/RedTaxi.WebPortal/` | Account web booker portal (login, booking, passengers, history) |
| Mac | Agent 3 | `src/RedTaxi.DriverApp/` (Flutter) | Driver app for iOS + Android (login, jobs, GPS, documents) |

All three agents point at the same API running on PC 1 (IIS). Set API base URL as an environment variable so each frontend can reach it.

### Optional: Extra Parallelism with VMs

If you want to push harder, split the Blazor work across two agents:

| Machine | Agent | Focus |
|---------|-------|-------|
| PC 1 | Agent 1A | Blazor dispatch: booking form, diary, availability, driver status, map |
| PC 1 VM | Agent 1B | Blazor admin: dashboard, accounts, billing, reports, drivers, settings |
| PC 2 | Agent 2 | Customer web portal |
| Mac | Agent 3 | Flutter driver app |

This gets you 4 parallel agents. The Blazor split works cleanly because dispatch pages and admin pages share the API but have no UI dependencies on each other.

### Git Workflow for Parallel Agents

Each agent works on its own branch:

```
main
├── feature/api-phase1          ← PC 1 (days 1-5)
├── feature/blazor-dispatch     ← PC 1 / Agent 1A (days 6-12)
├── feature/blazor-admin        ← PC 1 VM / Agent 1B (days 6-12)
├── feature/web-portal          ← PC 2 / Agent 2 (days 6-12)
└── feature/driver-app          ← Mac / Agent 3 (days 6-12)
```

Merge to main via PR when each feature set is testable. API merges first, then frontends merge against it.
