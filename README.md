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
│   ├── architecture/               ← System architecture, multi-tenant design
│   ├── api/                        ← API contract, endpoint matrix
│   ├── data-model/                 ← Entity definitions, relationships
│   ├── features/                   ← Feature specs (booking, dispatch, etc.)
│   ├── prd/                        ← Product vision, scope, roadmap
│   └── chatgpt-source/             ← Archived ChatGPT discovery files
├── legacy/                          ← Ace Taxis legacy codebase (read-only reference)
│   ├── TaxiDispatch.API/
│   ├── TaxiDispatch.Lib/
│   ├── TaxiDispatch.Tests/
│   └── TaxiDispatch.sln
├── src/                             ← New Red Taxi solution (Phase 1 build)
├── tests/                           ← Test projects
├── docker-compose.yml               ← Hetzner production stack
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
- **Driver App:** Flutter
- **Customer Portal:** TBD (Blazor WASM or lightweight SPA)
- **Hosting:** Hetzner CX32, Docker Compose, GitHub Actions CI/CD

## Master Documents

These are the authoritative source of truth, produced from legacy code analysis + 40+ UI screenshots + ChatGPT discovery sessions:

| Document | Lines | Description |
|----------|-------|-------------|
| [PRD](docs/PRD.md) | 771 | Product requirements (34 sections) |
| [Business Rules](docs/business-rules.md) | 800 | Operational logic (28 sections, includes actual Ace tariff values) |
| [Architecture](docs/architecture/master-architecture.md) | 299 | Stack, ADRs, Hetzner deployment, CI/CD |
| [Data Model](docs/data-model/master-data-model.md) | 344 | Entity definitions with TenantId |
| [API Contract](docs/api/api-contract.md) | 251 | 232 legacy endpoints mapped to v2 |
| [Module Map](docs/module-map.md) | 154 | 72 modules across 10 parallelisation groups |
| [SaaS Packaging](docs/saas-packaging.md) | 165 | Starter/Growth/Professional/Enterprise tiers |
| [Build Handoff](docs/claude-code-handoff.md) | 140 | Step-by-step instructions for Claude Code |

## Legacy Reference

The `legacy/` folder contains the existing Ace Taxis .NET codebase. Claude Code reads this to extract business logic for the new system. Key files:

- `legacy/TaxiDispatch.Lib/Services/BookingService.cs` (2,142 lines)
- `legacy/TaxiDispatch.Lib/Services/AccountsService.cs` (2,247 lines)
- `legacy/TaxiDispatch.Lib/Services/DispatchService.cs` (1,002 lines)
- `legacy/TaxiDispatch.Lib/Services/TariffService.cs` (709 lines)
- `legacy/TaxiDispatch.Lib/Data/Models/` (36 entity models)

## License

Proprietary — Red Banana Labs
