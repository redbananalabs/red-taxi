# Red Taxi Platform

Modern taxi dispatch SaaS platform. Replaces the legacy Ace Taxis dispatch system and scales to multi-tenant.

## Repo Structure

```
├── docs/                           ← All documentation (source of truth)
│   ├── PRD.md                      ← Master product requirements (34 sections)
│   ├── business-rules.md           ← Operational logic (28 sections)
│   ├── claude-code-handoff.md      ← Build instructions for Claude Code
│   ├── module-map.md               ← 72 modules for parallel dev
│   ├── saas-packaging.md           ← SaaS tier definitions
│   ├── architecture/               ← System architecture, multi-tenant, IIS staging
│   ├── api/                        ← API contract, endpoint matrix
│   ├── data-model/                 ← Entity definitions, relationships
│   ├── features/                   ← Feature specs (booking, dispatch, etc.)
│   ├── prd/                        ← Product vision, scope, roadmap
│   └── chatgpt-source/             ← Archived ChatGPT discovery files (18 docs)
├── legacy/                          ← Ace Taxis legacy codebase (read-only reference)
│   ├── TaxiDispatch.API/           ← .NET 8 backend API (20 controllers, 232 endpoints)
│   ├── TaxiDispatch.Lib/           ← Services, models, migrations (18 services, 36 entities)
│   ├── TaxiDispatch.Tests/         ← Guardrail tests
│   ├── TaxiDispatch.sln
│   ├── ace-dispatcher/             ← React dispatch console (booking form, diary, drag-drop)
│   ├── ace-admin-panel/            ← React admin panel (689 JSX — billing, reports, settings)
│   ├── ace-account-web-booker/     ← React account booking portal (login, passengers, history)
│   ├── ace-local-sms/              ← .NET MAUI Android SMS gateway
│   └── ace-driver-app/             ← Flutter driver app (92 Dart files — GPS, jobs, FCM)
├── src/                             ← New Red Taxi solution
├── tests/                           ← Test projects
├── docker-compose.yml               ← Production stack (nginx, .NET, SQL Server, Redis)
├── .github/workflows/deploy.yml     ← CI/CD pipeline
└── .env.example                     ← Environment template
```

## Getting Started

1. Read `docs/claude-code-handoff.md` for the build plan
2. Read `docs/PRD.md` for what we're building
3. Read `docs/architecture/master-architecture.md` for how we're building it

## Stack

- **Backend:** .NET 8, EF Core, MediatR, SQL Server, Redis, Hangfire
- **Dispatch Console:** Blazor Server + Syncfusion
- **Driver App:** Flutter (iOS + Android)
- **Customer Portal:** Blazor WASM or lightweight SPA
- **Staging:** IIS on Windows (alongside existing Ace system)
- **Production:** Hetzner CX32, Docker Compose, GitHub Actions CI/CD

## Build Plan

API-first, then parallel frontend agents across 3 machines:

| Phase | Duration | What |
|-------|----------|------|
| 1A | ~5 days | Complete backend API (all 232 endpoints via MediatR) |
| 1B | ~7 days | 4 parallel agents: Blazor dispatch, Blazor admin, web portal, Flutter app |
| 2 | ~5 days | Integration: SignalR, drag-drop, school run merge, payments, polish |

## Master Documents

Source of truth — produced from legacy code analysis + 40+ UI screenshots + ChatGPT discovery:

| Document | Description |
|----------|-------------|
| [PRD](docs/PRD.md) | Product requirements (34 sections) |
| [Business Rules](docs/business-rules.md) | Operational logic (28 sections, actual Ace tariff values) |
| [Architecture](docs/architecture/master-architecture.md) | Stack, ADRs, IIS staging, Hetzner production |
| [Data Model](docs/data-model/master-data-model.md) | Entity definitions, per-tenant DB architecture |
| [API Contract](docs/api/api-contract.md) | 232 legacy endpoints mapped to v2 REST routes |
| [Module Map](docs/module-map.md) | 72 modules across 10 parallelisation groups |
| [SaaS Packaging](docs/saas-packaging.md) | Starter / Growth / Professional / Enterprise tiers |
| [Build Handoff](docs/claude-code-handoff.md) | Step-by-step build plan, machine allocation, definition of done |

## Legacy Reference

The `legacy/` folder contains the complete Ace Taxis system. Claude Code reads this to extract business logic — never modifies it.

**Backend (key services):**
- `TaxiDispatch.Lib/Services/BookingService.cs` — 2,142 lines
- `TaxiDispatch.Lib/Services/AccountsService.cs` — 2,247 lines
- `TaxiDispatch.Lib/Services/DispatchService.cs` — 1,002 lines
- `TaxiDispatch.Lib/Services/TariffService.cs` — 709 lines

**Frontends (key files for UI reference):**
- `ace-dispatcher/src/components/Dragger.jsx` — drag-and-drop dispatch logic
- `ace-dispatcher/src/components/CallerIdPopUp.jsx` — phone lookup popup
- `ace-dispatcher/src/context/bookingSlice.js` — booking state management
- `ace-admin-panel/src/pages/billing&Payments/` — invoice processor UI
- `ace-driver-app/lib/helpers/location_service_helper.dart` — background GPS
- `ace-driver-app/lib/helpers/fcm_helper.dart` — push notifications

## License

Proprietary — Red Banana Labs
