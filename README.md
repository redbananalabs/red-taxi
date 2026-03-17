# Red Taxi Platform

Multi-tenant taxi dispatch SaaS platform. Replaces the legacy Ace Taxis dispatch system with a modern, scalable platform for any taxi company.

## Repo Structure

```
├── docs/                           ← All documentation (source of truth)
│   ├── PRD.md                      ← Master product requirements (45 sections)
│   ├── business-rules.md           ← Operational logic (42 sections)
│   ├── saas-platform.md            ← SaaS signup, billing, trial/expiry lifecycle
│   ├── claude-code-handoff.md      ← Build plan, machine allocation, definition of done
│   ├── module-map.md               ← 72 modules for parallel dev
│   ├── saas-packaging.md           ← Subscription tier definitions
│   ├── design/                     ← Design language, tokens, visual identity
│   ├── architecture/               ← System architecture, per-tenant DB, IIS staging
│   ├── api/                        ← API contract (232 endpoints), endpoint matrix
│   ├── data-model/                 ← Entity definitions, per-tenant DB pattern
│   ├── features/                   ← Feature specs (booking, dispatch, etc.)
│   ├── prd/                        ← Product vision, scope, roadmap
│   └── chatgpt-source/             ← Archived discovery files (18 docs)
├── legacy/                          ← Ace Taxis complete legacy system (read-only reference)
│   ├── TaxiDispatch.API/           ← .NET 8 backend API (20 controllers, 232 endpoints)
│   ├── TaxiDispatch.Lib/           ← Services, models, migrations (18 services, 36 entities)
│   ├── TaxiDispatch.Tests/         ← Guardrail tests
│   ├── ace-dispatcher/             ← React dispatch console (booking form, diary, drag-drop)
│   ├── ace-admin-panel/            ← React admin panel (689 JSX — billing, reports, settings)
│   ├── ace-account-web-booker/     ← React account booking portal
│   ├── ace-local-sms/              ← .NET MAUI Android SMS gateway
│   └── ace-driver-app/             ← Flutter driver app (92 Dart files — GPS, jobs, FCM)
├── src/                             ← New Red Taxi solution
│   ├── RedTaxi.API/                ← .NET 8 Web API
│   ├── RedTaxi.Application/        ← MediatR handlers by feature
│   ├── RedTaxi.Domain/             ← Entities, enums, domain events
│   ├── RedTaxi.Infrastructure/     ← EF Core, Redis, Stripe, external APIs
│   ├── RedTaxi.Shared/             ← DTOs, validation, API client (shared by all Blazor projects)
│   ├── RedTaxi.Blazor/             ← Dispatch console (Blazor Server + Syncfusion + Tailwind)
│   ├── RedTaxi.WebPortal/          ← Customer portal (Blazor WASM + Tailwind)
│   └── RedTaxi.TenantAdmin/        ← Tenant admin portal (Blazor WASM + Tailwind)
├── tests/                           ← Test projects
├── design-tokens.json               ← Machine-readable design tokens (colours, spacing, typography)
├── docker-compose.yml               ← Production stack (nginx, .NET, SQL Server, Redis)
├── .github/workflows/deploy.yml     ← CI/CD pipeline
└── .env.example                     ← Environment template
```

## Getting Started

1. Read `docs/claude-code-handoff.md` — build plan, machine allocation, definition of done
2. Read `docs/PRD.md` — what we're building (45 sections)
3. Read `docs/architecture/master-architecture.md` — how we're building it
4. Read `docs/design/design-language.md` — visual identity and component tokens
5. Read `docs/saas-platform.md` — SaaS signup, Stripe billing, tenant lifecycle

## Tech Stack

| Layer | Choice |
|-------|--------|
| Backend API | .NET 8, ASP.NET Core, MediatR |
| Database | SQL Server 2022 — **per-tenant databases** (complete data isolation) |
| Cache | Redis 7 (GPS cache, SignalR backplane) |
| Background Jobs | Hangfire (SQL Server-backed) |
| Real-time | SignalR (built into Blazor Server) |
| Dispatch Console | Blazor Server + Syncfusion + Tailwind CSS |
| Customer Portal | Blazor WASM + Tailwind CSS |
| Tenant Admin | Blazor WASM + Tailwind CSS |
| Driver App | Flutter (iOS + Android) |
| Design System | Dark-first, Inter typeface, design-tokens.json, Lucide Icons |
| Billing | Stripe (subscriptions, checkout, billing portal, webhooks) |
| PDF Generation | QuestPDF (invoices, statements, credit notes, receipts) |
| Staging | IIS on Windows (alongside existing Ace system) |
| Production | Hetzner CX32, Docker Compose, GitHub Actions CI/CD |

## Multi-Tenancy

Per-tenant database architecture. Each taxi company gets their own SQL Server database — complete physical isolation, no TenantId columns, no query filters to forget.

- **Master DB** (`RedTaxi_Platform`): tenant registry, Stripe data, platform config
- **Tenant DBs** (`RedTaxi_{slug}`): all business data — bookings, drivers, accounts, tariffs

## SaaS Model

- **Self-service signup** — no card required, 14-day free trial
- **Tiers:** Starter (≤15 drivers) → Growth (≤40) → Professional (≤100) → Enterprise (custom)
- **Billing:** Stripe subscriptions with self-service billing portal
- **Tenant access:** Subdomain by default (`ace-taxis.{platform-domain}`), custom domain on Professional+
- **Expiry flow:** Trial → 3-day grace → soft lock (read-only + exit survey) → 7-day data warning → hard lock → 30-day deletion

## Build Plan

API-first, then parallel frontend agents across 3 machines + VMs:

| Phase | Duration | Deliverable |
|-------|----------|-------------|
| 1A | ~5 days | Complete backend API (per-tenant DB, Stripe, all 232 endpoints) |
| 1B | ~7 days | 4 parallel agents: Blazor dispatch, Blazor admin, customer portal, Flutter app |
| 2 | ~5 days | Integration: SignalR, drag-drop, school run merge, payments, polish |
| **Total** | **~3-4 weeks** | |

## Documentation (6,900+ lines)

| Document | Lines | Description |
|----------|-------|-------------|
| [PRD](docs/PRD.md) | 980 | Product requirements (45 sections) |
| [Business Rules](docs/business-rules.md) | 1,061 | Operational logic (42 sections — tariffs, pricing, dispatch, COA, school runs, commission, settlement, card payments, repeat bookings) |
| [Architecture](docs/architecture/master-architecture.md) | 465 | Stack decisions, per-tenant DB, ADRs, IIS staging, Hetzner deployment, CI/CD |
| [SaaS Platform](docs/saas-platform.md) | 306 | Signup, Stripe billing, provisioning, onboarding wizard, trial/expiry lifecycle |
| [Design Language](docs/design/design-language.md) | 336 | Dark-first design system, colour palette, typography, component tokens, layout |
| [Data Model](docs/data-model/master-data-model.md) | 372 | Entity definitions, per-tenant DB pattern |
| [API Contract](docs/api/api-contract.md) | 251 | 232 legacy endpoints mapped to v2 REST routes |
| [Build Handoff](docs/claude-code-handoff.md) | 266 | Step-by-step build plan, machine allocation, definition of done |
| [Module Map](docs/module-map.md) | 154 | 72 modules across 10 parallelisation groups |
| [Decision Log](docs/decision-log.md) | 215 | All architecture decision records |

## Legacy Reference

The `legacy/` folder contains the complete Ace Taxis system (6 projects). Claude Code reads this to extract business logic — never modifies it.

**Backend (key services):**
- `TaxiDispatch.Lib/Services/BookingService.cs` — 2,142 lines
- `TaxiDispatch.Lib/Services/AccountsService.cs` — 2,247 lines
- `TaxiDispatch.Lib/Services/DispatchService.cs` — 1,002 lines
- `TaxiDispatch.Lib/Services/TariffService.cs` — 709 lines

**Frontends (key UI reference files):**
- `ace-dispatcher/src/components/Dragger.jsx` — drag-and-drop dispatch logic
- `ace-dispatcher/src/components/CallerIdPopUp.jsx` — phone lookup popup
- `ace-dispatcher/src/context/bookingSlice.js` — booking state management
- `ace-admin-panel/src/pages/billing&Payments/` — invoice processor UI
- `ace-driver-app/lib/helpers/location_service_helper.dart` — background GPS
- `ace-driver-app/lib/helpers/fcm_helper.dart` — push notifications

## License

Proprietary — Red Banana Labs
