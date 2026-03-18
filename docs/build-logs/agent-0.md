# Agent 0 Build Log — Foundation
Started: 2026-03-18
Last Updated: 2026-03-18
Status: Complete

## Context
- Working on: Phase 0 — Foundation scaffold (solution, entities, migrations, Flutter workspace)
- PRD sections: §36, §103, §107-108, §134, §137, §139, §140
- Dependencies: None (first phase)
- Branch: main (initial commit)

## Completed Work

### 2026-03-18 — Full Foundation Scaffold

**What was built:**

1. **.NET Solution** (8 projects, all compiling with 0 warnings/0 errors)
   - RedTaxi.Domain — 29 enums, 47 entities, 8 interfaces, 12 domain events
   - RedTaxi.Application — MediatR + FluentValidation, assembly marker
   - RedTaxi.Infrastructure — EF Core DbContexts, Stripe seed service, tenant resolver
   - RedTaxi.Shared — 20 DTO files covering all API contracts
   - RedTaxi.API — Full Program.cs with JWT auth, SignalR, Hangfire, Redis, Swagger
   - RedTaxi.Blazor — Blazor Server (dispatch console shell)
   - RedTaxi.TenantAdmin — Blazor WASM (tenant admin shell)
   - RedTaxi.WebPortal — Blazor WASM (customer portal shell)

2. **Domain Layer**
   - 29 enums from §103 (BookingScope, BookingStatus, VehicleType, AppJobStatus, etc.)
   - 47 entities from §107-108 (Booking with 60+ fields, UserProfile, Account, Tariff, etc.)
   - 6 platform entities (Tenant, TenantExitSurvey, PlatformConfig, PartnerRelationship, CoverRequest, SettlementRecord)
   - 8 domain interfaces (ITenantConnectionResolver, IStripeService, IPricingService, etc.)
   - 12 domain events (BookingCreated, BookingAllocated, BookingCompleted, etc.)

3. **Infrastructure Layer**
   - TenantDbContext — 50+ DbSets with full Fluent API config (decimal precision, string lengths, indexes, FK relationships)
   - PlatformDbContext — Tenant, TenantExitSurvey, PlatformConfig
   - TenantConnectionResolver — resolves tenant from JWT claim / header / default
   - TenantDbContextFactory — creates per-tenant DbContext instances
   - Design-time factories for EF migrations
   - StripeSeedService — creates 4 plans + 10 bolt-ons with idempotent upsert

4. **Database Migrations Applied**
   - RedTaxi_Platform database created (master DB)
   - RedTaxi_ace database created (first tenant — Ace Taxis)
   - Both on localhost SQL Server (default instance)

5. **API Configuration**
   - JWT Bearer auth with SignalR query string support
   - CORS for localhost development
   - Redis with abortConnect=false (graceful when Redis is down)
   - Hangfire with SQL Server storage
   - Swagger UI with Bearer token support
   - Health checks (SQL Server + Redis)
   - Stripe seed on startup (skips gracefully if keys missing)
   - Tenant middleware logging

6. **Flutter Workspace** (4 packages)
   - red_taxi_shared — models, API client, auth service, design tokens
   - red_taxi_driver — driver app scaffold
   - red_taxi_customer — customer app scaffold
   - red_taxi_operator — operator mobile app scaffold

**Decisions made:**
- ADR-0-1: SQL Server default instance (localhost) not SQLEXPRESS — machine has MSSQLSERVER service
- ADR-0-2: StripeSeedService registered as Scoped (not Singleton) — depends on scoped PlatformDbContext
- ADR-0-3: Redis abortConnect=false so app starts even if Redis is temporarily down
- ADR-0-4: Design-time DbContext factories separate from runtime DI for EF migrations
- ADR-0-5: Flutter workspace scaffolded without SDK — pubspec.yaml and Dart files ready for `flutter pub get`

## Current State
- What works: Solution compiles, databases exist with full schema, all project references correct
- What's left: Flutter SDK installation, Tailwind CSS setup for Blazor projects
- Blockers: None
- Known bugs: None
- Tech debt: Flutter SDK not installed; Blazor projects are empty shells

## Handoff Notes
- Key patterns: MediatR handler per use case, domain events via INotification, per-tenant DB via ITenantConnectionResolver
- All DTOs in RedTaxi.Shared are the API contracts — frontend agents should code against these
- Stripe test keys are in appsettings.Development.json (gitignored)
- Connection strings use `Server=localhost` (default instance), not `localhost\SQLEXPRESS`
- Next: Agent 1 = Booking/Dispatch/Pricing handlers, Agent 2 = Identity/Accounts/Billing handlers
