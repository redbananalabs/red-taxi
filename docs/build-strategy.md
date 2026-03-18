# Red Taxi Platform — Build Strategy & Parallel Agent Playbook

> **Version:** 1.0
> **Created:** 18 March 2026
> **Purpose:** Maximise build velocity using parallel AI agents. This doc tells every agent what to build, in what order, what dependencies to respect, and how to log their work so successors can continue without context loss.

---

## 1. Architecture Dependency Graph

```
                    ┌───────────────────────┐
                    │   RedTaxi.Domain      │  ← BUILD FIRST (zero dependencies)
                    │   Entities, Enums,     │
                    │   Interfaces, Events   │
                    └──────────┬────────────┘
                               │
                    ┌──────────▼────────────┐
                    │   RedTaxi.Application  │  ← MediatR handlers, DTOs, validators
                    │   (depends on Domain)  │
                    └──────────┬────────────┘
                               │
          ┌────────────────────┼────────────────────┐
          │                    │                    │
┌─────────▼──────┐  ┌─────────▼──────┐  ┌─────────▼──────┐
│ RedTaxi.Infra  │  │  RedTaxi.API   │  │ RedTaxi.Shared │
│ EF Core, Redis │  │  Controllers,  │  │  DTOs, Client  │
│ External APIs  │  │  SignalR Hubs  │  │  (for Blazor)  │
└────────────────┘  └───────┬────────┘  └───────┬────────┘
                            │                    │
         ┌──────────────────┼────────────────────┤
         │                  │                    │
┌────────▼───┐  ┌───────────▼───┐  ┌────────────▼────────┐
│ Blazor     │  │ Blazor        │  │ Blazor              │
│ Dispatch   │  │ TenantAdmin   │  │ WebPortal           │
│ (Server)   │  │ (WASM)        │  │ (WASM)              │
└────────────┘  └───────────────┘  └─────────────────────┘

         ┌────────────────────────────────┐
         │  red_taxi_shared (Flutter)     │  ← BUILD FIRST for mobile
         │  API client, models, auth,     │
         │  design tokens                 │
         └──────────┬─────────┬──────────┘
                    │         │          │
         ┌──────────▼──┐ ┌───▼────┐ ┌───▼──────┐
         │ Driver App  │ │Customer│ │ Operator │
         │ (Flutter)   │ │App     │ │ Mobile   │
         └─────────────┘ └────────┘ └──────────┘
```

---

## 2. Build Phases (Strict Order)

### Phase 0: Foundation (1 agent, 1 day)
**No parallelism — this must complete before anything else starts.**

| Task | Agent | Output |
|------|-------|--------|
| Scaffold .NET solution (all 5 projects) | Agent 0 | Solution compiles with empty projects |
| Domain entities (all 40+) | Agent 0 | `RedTaxi.Domain/Entities/` |
| Domain enums (all from §103) | Agent 0 | `RedTaxi.Domain/Enums/` |
| Domain interfaces | Agent 0 | `IBookingRepository`, `ITenantResolver`, etc. |
| Shared DTOs | Agent 0 | `RedTaxi.Shared/DTOs/` |
| EF Core DbContext + migrations | Agent 0 | `TenantDbContext`, master DB context |
| Per-tenant DB resolver | Agent 0 | `ITenantConnectionResolver` |
| Scaffold Flutter workspace (3 apps + shared) | Agent 0 | `mobile/` folder, shared package |
| Design tokens loaded into all projects | Agent 0 | Colours, typography, spacing |

**Commit checkpoint: `v0.1-foundation`**

### Phase 1A: Core Backend (2 agents, 3 days)

Two agents split the API by bounded context:

| Agent | Bounded Contexts | Key Deliverables |
|-------|-----------------|-------------------|
| **Agent 1: Booking+Dispatch** | Booking, Dispatch, Pricing, Fleet | Create/Update/Cancel/Complete booking, Tariff engine (5-level priority), Allocation, Job offers, Scheduler queries, SignalR hub for real-time |
| **Agent 2: Identity+Accounts+Billing** | Identity, Tenancy, Accounts, Billing, Messaging, Config | Auth (JWT + refresh), User/driver profiles, Account CRUD, Invoice processing, Statement processing, Commission calculation, SMS/email sending, Company config |

**Interface contract:** Both agents work from the same DTOs in `RedTaxi.Shared`. Agent 1 owns `/api/Bookings/*`, `/api/Dispatch/*`, `/api/Pricing/*`. Agent 2 owns `/api/Auth/*`, `/api/Accounts/*`, `/api/Billing/*`, `/api/Users/*`, `/api/Messaging/*`, `/api/Config/*`.

**Commit checkpoint: `v0.2-api-core`**

### Phase 1B: All Frontends (5 agents, 5 days)

All 5 agents start simultaneously once the API contracts (DTOs) are stable from Phase 1A.

| Agent | App | Tech | Key Deliverables |
|-------|-----|------|-------------------|
| **Agent 3: Dispatch Console** | RedTaxi.Blazor | Blazor Server + Syncfusion | Map view, scheduler/Gantt, booking form, caller popup, context panel, command palette, keyboard shortcuts, SignalR integration |
| **Agent 4: Tenant Admin** | RedTaxi.TenantAdmin | Blazor WASM | Invoice processor (normal + Grp), statement processing, driver management, account management, tariff config, zone pricing editor, reports, company settings |
| **Agent 5: Customer Portal** | RedTaxi.WebPortal | Blazor WASM | Account booker login, create booking, active bookings, history, passenger management, amendment requests |
| **Agent 6: Driver App** | Flutter (red_taxi_driver) | Flutter | 25 screens: schedule, job offers, active job, availability, earnings, documents, expenses, profile, messages, statements |
| **Agent 7: Customer + Operator Apps** | Flutter (red_taxi_customer + red_taxi_operator) | Flutter | Customer: 15 screens. Operator: 4-tab mobile dispatch. Both share `red_taxi_shared`. |

**Commit checkpoint: `v0.3-frontends`**

### Phase 2: Integration & Polish (2 agents, 3 days)

| Agent | Focus | Deliverables |
|-------|-------|-------------|
| **Agent 8: Real-time + Payments** | SignalR wiring, Revolut webhook, Stripe SaaS billing, push notifications (FCM), SMS gateway | All real-time events working end-to-end, payment flow complete, SMS sending |
| **Agent 9: Polish + Testing** | E2E testing, school run merge UX, drag-and-drop allocation, edge cases from §84-85, responsive fixes, deployment pipeline | CI/CD via GitHub Actions, Docker Compose, staging deploy to Hetzner |

**Commit checkpoint: `v1.0-release`**

---

## 3. Agent Assignment by Tool

### Claude Code (Primary — Backend + Blazor)
Best for: .NET, C#, Blazor, EF Core, SQL, complex business logic.
**Assign to:** Agents 0, 1, 2, 3, 4, 5.

### Codex / Claude Code (Flutter)
Best for: Dart, Flutter, mobile UI, multi-platform.
**Assign to:** Agents 6, 7.

### Antigravity / Claude Code (Integration + Infra)
Best for: Docker, CI/CD, deployment, multi-service orchestration.
**Assign to:** Agents 8, 9.

### Recommended Setup

| Agent | Tool | Instance | Working Directory |
|-------|------|----------|-------------------|
| 0 | Claude Code | Terminal 1 | `src/` (full solution) |
| 1 | Claude Code | Terminal 2 | `src/RedTaxi.API/` + `src/RedTaxi.Application/` (Booking contexts) |
| 2 | Claude Code | Terminal 3 | `src/RedTaxi.API/` + `src/RedTaxi.Infrastructure/` (Accounts contexts) |
| 3 | Claude Code | Terminal 4 | `src/RedTaxi.Blazor/` |
| 4 | Claude Code | Terminal 5 | `src/RedTaxi.TenantAdmin/` |
| 5 | Claude Code | Terminal 6 | `src/RedTaxi.WebPortal/` |
| 6 | Claude Code | Terminal 7 | `mobile/red_taxi_driver/` |
| 7 | Claude Code | Terminal 8 | `mobile/red_taxi_customer/` + `mobile/red_taxi_operator/` |
| 8 | Claude Code | Terminal 9 | `src/` (cross-cutting) |
| 9 | Claude Code | Terminal 10 | `src/` + `.github/` + `docker/` |

---

## 4. Conflict Prevention Rules

### Git Strategy
- **Main branch:** protected, requires PR
- **Agent branches:** `agent/{N}-{feature}` (e.g. `agent/1-booking-api`, `agent/3-dispatch-console`)
- **Merge order:** Agent 0 first → Agent 1+2 → Agents 3-7 → Agents 8-9
- **Conflict zones:** `RedTaxi.Shared/` is the hot zone. Agent 0 defines all DTOs upfront. Later agents ADD new DTOs but don't modify existing ones without PR.

### File Ownership (No Two Agents Touch the Same File)
```
Agent 0 OWNS: RedTaxi.Domain/*, RedTaxi.Shared/*, RedTaxi.Infrastructure/Data/*
Agent 1 OWNS: RedTaxi.Application/Booking/*, RedTaxi.Application/Dispatch/*, RedTaxi.Application/Pricing/*
Agent 2 OWNS: RedTaxi.Application/Identity/*, RedTaxi.Application/Accounts/*, RedTaxi.Application/Billing/*
Agent 3 OWNS: RedTaxi.Blazor/*
Agent 4 OWNS: RedTaxi.TenantAdmin/*
Agent 5 OWNS: RedTaxi.WebPortal/*
Agent 6 OWNS: mobile/red_taxi_driver/*
Agent 7 OWNS: mobile/red_taxi_customer/*, mobile/red_taxi_operator/*, mobile/red_taxi_shared/*
Agent 8 OWNS: RedTaxi.Infrastructure/SignalR/*, RedTaxi.Infrastructure/Payments/*
Agent 9 OWNS: .github/*, docker/*, tests/*
```

### Shared Contract: API Endpoints
All agents reference `docs/api-contracts.md` (generated by Agent 0 in Phase 0). This file defines every endpoint's URL, method, request DTO, and response DTO. Frontend agents code against these contracts even before the backend is complete (mock responses).

---

## 5. Build Logs — Mandatory for Every Agent

Every agent MUST maintain a build log at `docs/build-logs/agent-{N}.md`. This is the single most important artifact for continuity.

### Build Log Format

```markdown
# Agent {N} Build Log — {Description}
Started: {date}
Last Updated: {date}
Status: In Progress / Complete / Blocked

## Context
- Working on: {what this agent is building}
- PRD sections: {which sections are relevant}
- Dependencies: {what must exist before this agent can work}
- Branch: agent/{N}-{feature}

## Completed Work
### {date} — {summary}
- What was built: {description}
- Files created/modified: {list}
- Decisions made: {any design decisions with rationale}
- Tests: {what was tested, pass/fail}
- Commit: {hash}

### {date} — {summary}
...

## Current State
- What works: {list of working features}
- What's left: {remaining tasks}
- Blockers: {anything blocking progress}
- Known bugs: {list}
- Tech debt: {shortcuts taken that need revisiting}

## Architecture Decisions
### ADR-{N}-{num}: {title}
- Decision: {what was decided}
- Rationale: {why}
- Alternatives considered: {what else was evaluated}
- PRD reference: §{section}

## Handoff Notes
{Notes for the next agent/developer who picks this up}
- Key patterns used: {e.g. "MediatR handler per use case", "Syncfusion SfSchedule for Gantt"}
- Gotchas: {things that weren't obvious}
- What I'd do differently: {retrospective}
```

### Why This Matters
- A new Claude Code session can read `docs/build-logs/agent-*.md` and have full context
- No work is lost between sessions
- Decisions are traceable
- Tech debt is visible
- Handoff is seamless

---

## 6. Agent Prompts (Copy-Paste Ready)

### Agent 0 — Foundation
```
You are building the Red Taxi Platform. Read docs/PRD.md (135 sections, 4300+ lines) and docs/build-strategy.md for full context.

Your job: scaffold the .NET solution and Flutter workspace. Create ALL domain entities (§107-108), ALL enums (§103), ALL shared DTOs, the EF Core DbContext with per-tenant DB support (§36), and the Flutter shared package.

Output: a compiling solution with all projects, all entities, all migrations, all DTOs. Nothing else — no business logic, no UI.

Log everything to docs/build-logs/agent-0.md.
Branch: agent/0-foundation
```

### Agent 1 — Booking + Dispatch API
```
You are building the Red Taxi Platform. Read docs/PRD.md and docs/build-strategy.md.

Your job: implement all Booking, Dispatch, and Pricing API endpoints. Key PRD sections: §6, §7, §76-77, §84-85, §95-102, §111, §126, §130, §132, §134, §137.

Business rules are CRITICAL — the PRD has exact formulas for tariff calculation (§102), commission (§105), merge logic (§102), COA toggle (§102), block bookings (§103), and the complete booking state machine (§134).

Build MediatR handlers: one handler per use case. Domain events for side-effects. No fat services.

Log everything to docs/build-logs/agent-1.md.
Branch: agent/1-booking-dispatch
```

### Agent 2 — Identity + Accounts + Billing API
```
You are building the Red Taxi Platform. Read docs/PRD.md and docs/build-strategy.md.

Your job: implement Auth, User management, Account management, Invoice processing, Statement processing, Commission calculation, Messaging, and Company Config.

Key PRD sections: §36-40 (tenancy), §63 (RBAC), §79-80 (accounts/billing), §81 (messaging), §83 (settings), §105 (settlement formula), §118-120 (invoice/statement UI specs), §124 (messaging config).

Settlement formula is EXACT — follow §105 precisely. Invoice grouping logic from §118 (Singles vs Shared tabs, 3-level hierarchy).

Log everything to docs/build-logs/agent-2.md.
Branch: agent/2-identity-accounts
```

### Agent 3 — Dispatch Console (Blazor)
```
You are building the Red Taxi Platform dispatch console. Read docs/PRD.md, docs/build-strategy.md, docs/design/dispatch-layout.md, docs/design/design-language.md.

Your job: build the Blazor Server dispatch console. Map-centric layout (§42), floating booking form, scheduler/Gantt (§95), context panel (§96), caller popup (§98), keyboard shortcuts (§23), driver selection (§97), drag-and-drop allocation (§137).

Use Syncfusion components (Material Dark theme), Tailwind CSS, Google Maps JS API, SignalR for real-time updates.

Log everything to docs/build-logs/agent-3.md.
Branch: agent/3-dispatch-console
```

### Agent 4 — Tenant Admin (Blazor)
```
You are building the Red Taxi Platform admin panel. Read docs/PRD.md and docs/build-strategy.md.

Your job: build the Blazor WASM tenant admin portal. Full sidebar navigation (§121), invoice processor with Singles+Shared tabs (§118), statement processing (§120), availability with presets (§123), zone pricing editor (§126), driver management, account management, tariff config, reports, company settings (§83).

Log everything to docs/build-logs/agent-4.md.
Branch: agent/4-tenant-admin
```

### Agent 5 — Customer Web Portal (Blazor)
```
You are building the Red Taxi Platform customer web portal. Read docs/PRD.md §79, §113.

Your job: build the Blazor WASM account booker portal. Login, booking dashboard, create booking form, repeat bookings, active/history bookings, passenger management, amendment requests (§130).

Log everything to docs/build-logs/agent-5.md.
Branch: agent/5-web-portal
```

### Agent 6 — Driver App (Flutter)
```
You are building the Red Taxi Platform driver app. Read docs/PRD.md §78, §109, §115, §137, and docs/design/driver-app.md.

Your job: build the Flutter driver app (iOS + Android). 25 screens (§109): schedule, job offers (full-screen takeover §137), active job with status progression, availability with presets, earnings, documents, expenses, profile, messages, statements.

Use red_taxi_shared package for API client, models, auth. Follow design-tokens.json for theming.

Log everything to docs/build-logs/agent-6.md.
Branch: agent/6-driver-app
```

### Agent 7 — Customer App + Operator Mobile App (Flutter)
```
You are building the Red Taxi Platform customer app and operator mobile app. Read docs/PRD.md §46, §128, §129.

Customer app (15 screens §129): tenant selection, OTP login, home/map, booking confirmation, driver tracking, trip complete + rating, booking history, saved places, payments, profile.

Operator mobile app (4 tabs §128): bookings (create/view/allocate), alerts (web booking accept/reject), live map (driver pins), more (drivers, accounts, messaging).

Both use red_taxi_shared package. Build shared package first, then both apps in parallel.

Log everything to docs/build-logs/agent-7.md.
Branch: agent/7-mobile-apps
```

---

## 7. Productivity Maximisation

### Parallel Agent Limits
- **Phase 0:** 1 agent only (foundation must be serial)
- **Phase 1A:** 2 agents (backend split by bounded context)
- **Phase 1B:** 5 agents (all frontends simultaneously)
- **Phase 2:** 2 agents (integration + polish)
- **Max concurrent:** 7 agents (Phase 1A agents finish → become 1B agents)

### Speed Multipliers

| Technique | Impact | How |
|-----------|--------|-----|
| **DTO-first design** | 3x | Agent 0 creates ALL DTOs upfront. Frontend agents mock against contracts. No waiting for backend. |
| **Feature flags** | 2x | Ship incomplete features behind flags. Deploy early, enable later. |
| **Shared Flutter package** | 2x | Agent 7 builds shared package FIRST. Agents 6+7 both consume it. API client written once. |
| **Syncfusion components** | 3x | Don't hand-roll scheduler, grids, charts. Syncfusion gives 90% for free. |
| **Copy patterns from PRD** | 2x | The PRD has exact field lists, column specs, formulas. Agents copy verbatim instead of guessing. |
| **Build log continuity** | 5x over lifecycle | New agents read build logs → instant context. No re-discovery. |

### Anti-Patterns to Avoid
- **Don't let agents refactor each other's code** — leads to merge hell
- **Don't skip build logs** — the 10 minutes spent logging saves hours later
- **Don't deviate from PRD without logging an ADR** — decisions must be traceable
- **Don't build features not in the PRD** — scope creep kills velocity
- **Don't share DbContext files** — one agent owns data access per bounded context

---

## 8. Definition of Done (Per Agent)

An agent's work is "done" when:

1. ✅ All assigned features from PRD implemented
2. ✅ Code compiles with zero warnings
3. ✅ Build log updated with final state
4. ✅ All files committed to agent branch
5. ✅ PR created against main with description
6. ✅ No hardcoded values (use config/design tokens)
7. ✅ Error handling in place (try/catch, Result pattern)
8. ✅ Logging added (Serilog, structured)
9. ✅ Works on both desktop and mobile (Blazor = responsive, Flutter = both platforms)
10. ✅ Handoff notes written in build log

---

## 9. Estimated Timeline

| Phase | Days | Agents | Cumulative |
|-------|------|--------|-----------|
| Phase 0: Foundation | 1 | 1 | Day 1 |
| Phase 1A: Core API | 3 | 2 | Day 4 |
| Phase 1B: All Frontends | 5 | 5 | Day 9 |
| Phase 2: Integration | 3 | 2 | Day 12 |
| Buffer + Testing | 3 | 1-2 | Day 15 |
| **Total** | **~3 weeks** | **Max 7 concurrent** | |

### Critical Path
```
Foundation (1d) → Booking API (3d) → Dispatch Console (5d) → Integration (3d) = 12 days
```
Everything else runs in parallel off the critical path.

---

## 10. Context Loading for New Agents

When a new Claude Code / Codex / Antigravity session starts, it should read files in this order:

1. `docs/build-strategy.md` ← YOU ARE HERE (this file)
2. `docs/PRD.md` ← full product spec (search for relevant sections)
3. `docs/build-logs/agent-{N}.md` ← previous agent's work on this area
4. `docs/claude-code-handoff.md` ← repo structure and conventions
5. `docs/architecture/master-architecture.md` ← system architecture
6. `docs/data-model/master-data-model.md` ← entity relationships
7. `docs/business-rules.md` ← 42 business rule sections
8. `design-tokens.json` ← colours, fonts, spacing

### Minimal Context (for small tasks)
```
Read: docs/build-strategy.md + docs/build-logs/agent-{N}.md + relevant PRD section
```

### Full Context (for new feature work)
```
Read: All 8 files above + docs/design/dispatch-layout.md + docs/design/driver-app.md
```
