# Red Taxi Documentation

## Master Documents (Source of Truth)

These documents were produced from legacy code analysis, 40+ UI screenshots, and ChatGPT discovery sessions. They are the authoritative reference for the entire platform.

| Document | Description |
|----------|-------------|
| [PRD.md](PRD.md) | Master product requirements (34 sections) |
| [business-rules.md](business-rules.md) | Operational logic, tariff values, COA, school runs (28 sections) |
| [claude-code-handoff.md](claude-code-handoff.md) | Build instructions for Claude Code |
| [module-map.md](module-map.md) | 72 modules across 10 parallelisation groups |
| [saas-packaging.md](saas-packaging.md) | SaaS tier definitions |

## Architecture & Technical

| Document | Description |
|----------|-------------|
| [architecture/master-architecture.md](architecture/master-architecture.md) | Stack decisions, Hetzner deployment, CI/CD, ADRs |
| [architecture/system-overview.md](architecture/system-overview.md) | System overview |
| [architecture/multi-tenant-design.md](architecture/multi-tenant-design.md) | Multi-tenant design |
| [architecture/tenancy-modes.md](architecture/tenancy-modes.md) | Tenancy mode config |

## Data Model & API

| Document | Description |
|----------|-------------|
| [data-model/master-data-model.md](data-model/master-data-model.md) | All entities, per-tenant DB architecture |
| [data-model/booking.md](data-model/booking.md) | Booking entity detail |
| [api/api-contract.md](api/api-contract.md) | 232 endpoints mapped to v2 REST routes |
| [api/auth-endpoint-matrix.md](api/auth-endpoint-matrix.md) | Legacy endpoint auth matrix |

## Features & Workflows

| Folder | Description |
|--------|-------------|
| [features/](features/) | Booking system, dispatch system specs |
| [workflows/](workflows/) | Operator and dispatch workflow details |
| [dispatch/](dispatch/) | Dispatch modes, auto-dispatch logic |
| [integrations/](integrations/) | Twilio, Revolut, Google Places, Ideal Postcodes |

## Reference

| Folder | Description |
|--------|-------------|
| [prd/](prd/) | Product vision, scope, roadmap, user types |
| [dev/](dev/) | Coding standards, git workflow, migrations policy |
| [security/](security/) | Audit logs, GDPR |
| [chatgpt-source/](chatgpt-source/) | Archived ChatGPT discovery files (18 source docs) |
