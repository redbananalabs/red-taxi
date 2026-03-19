# Red Taxi V2 — Changelog

## [2026-03-19] Feature Review & Scope Lock

### Removed from Scope
- KB01: Command palette (Ctrl+K)
- KB02: New booking shortcut (Ctrl+N)
- KB03: Save booking shortcut (Ctrl+S)
- KB05: Close dialog shortcut (Escape)

### Deferred Post-Launch
- DC09: Multi-monitor pop-out
- DC10: Material Dark theme (strict spec)
- MP05: Map marker → booking detail popup
- NT08: Pusher → SignalR migration

### Confirmed Done (from recent work)
- DC01: Split layout (form left, scheduler/map right)
- DC02: Draggable splitter
- DC04: Permanent booking form
- BF12: Auto time update on ASAP
- CA04: Caller queue stacking
- All 16 booking form features (BF01-BF16)
- All 14 scheduler features (SC01-SC14)
- All 7 caller/allocation features (CA01-CA07)

### Created
- V2 smoke tests (docs/smoke-tests.md) — 14 sections, 80+ test cases
- V2 implementation plan (docs/v2-implementation-plan.md) — 8 phases
- Feature review spreadsheet (Google Sheets)

## [2026-03-18] Strategic Pivot & Codebase Refactoring

### Architecture Decision
- PIVOTED from rewrite to wrap-and-extend approach
- Legacy AceTaxis codebase (142K lines) becomes the foundation
- V1 new build (47K lines) archived for reference

### Codebase Changes
- Merged OSS project into AceTaxis.Lib (19 files, 0 errors)
- Renamed AceTaxis → RedTaxi (namespaces, projects, DbContext)
- Extracted controller logic: RedirectController + QRCodeClickCounter → UrlTrackingService
- Added structured logging (Serilog) to all services
- Deleted old TaxiDispatch projects (322 files, 40K lines removed)
- Deleted OSS project (merged into RedTaxi.Lib)

### Database
- Copied live production data to local SQL Server (AceTaxis_Dev)
- PII sanitised: all phones → 07572382366, all emails → peter@abacusonline.net
- 127,321 bookings, 29 drivers, 51 accounts, 450 POIs

### Verification
- API running on localhost:5092 (Swagger: 237 endpoints)
- Dispatcher running on localhost:5173
- Login: Peter / Test1234 (admin)
- Pricing: SP8→DT9 = £50 (Tariff 1: Day Rate, 31.7mi)
- All regression tests passing

## [2026-03-18] V1 Build Attempt (Archived)

### Built (archived in archive/new-build-v1/)
- 47K lines across 400+ files
- 8 .NET projects (Domain, Application, Infrastructure, API, Shared, Blazor ×3)
- 3 Flutter apps + shared package
- Stripe integration (14 products, 24 prices)
- Per-tenant DB resolver
- Google Distance Matrix + Places services

### Issues Found
- ~40% of features actually working
- Pricing returned £0 (stub distance service)
- Allocation returned 500 (DTO mapping bug)
- Blazor dispatch circuit crashed on startup
- Auth bypassed with [AllowAnonymous] hacks

### Decision
- Archived for reference, not deployed
- Reusable pieces extracted: Stripe, tenancy, Google services, Flutter scaffolds
