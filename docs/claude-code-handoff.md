# Claude Code Handoff — Red Taxi V2

> **V2 = Wrap & extend the proven RedTaxi codebase. Don't rewrite.**
> Updated: 2026-03-19

## Repository
```
git clone https://github.com/onesoftuk/red-taxi.git
```

## Read These First
1. **docs/codebase-analysis.md** — current codebase state (services, controllers, what works)
2. **docs/feature-tracker.md** — 200 features with status from operator review
3. **docs/v2-implementation-plan.md** — 8 phases with bullet lists
4. **docs/smoke-tests.md** — regression test suite (run after every change)
5. **docs/PRD.md** — 144 sections, full product spec (§144 = feature review decisions)
6. **docs/changelog.md** — what's been done, what was removed/deferred

## Current Repo Structure
```
src/
├── RedTaxi.API/           16 controllers, 237 endpoints
├── RedTaxi.Lib/           17 services, 36 entities, ~147K lines
└── RedTaxi.sln            .NET 7 (upgrade to 8 planned)

frontend/
├── ace-dispatcher/        React dispatch console (localhost:5173)
├── ace-admin-panel/       React admin panel
├── ace-account-web-booker/ React web booker
└── ace-local-sms/         MAUI SMS gateway (Android only → move to mobile/)

mobile/
├── driver/                Flutter driver app (production)
├── customer/              Flutter customer app (scaffold from V1)
├── operator/              Flutter operator app (scaffold from V1)
└── shared/                Shared Flutter package

archive/                   V1 new build (reference only)
docs/                      70+ docs, PRD, strategy, tracker
```

## Running Locally
| Service | Command | URL |
|---------|---------|-----|
| API | `cd src/RedTaxi.API && dotnet run` | http://localhost:5092/swagger |
| Dispatcher | `cd frontend/ace-dispatcher && npm run dev` | http://localhost:5173 |
| Admin | `cd frontend/ace-admin-panel && npm install && npm run dev` | Check Vite output |

## Database
- Local: `Server=localhost\SQLEXPRESS;Database=AceTaxis_Dev;Trusted_Connection=True;TrustServerCertificate=True;`
- 127,321 bookings, 29 drivers, 51 accounts (copied from production, PII sanitised)

## Login
- Username: Peter, Password: Test1234 (Admin role)
- Endpoint: POST /api/UserProfile/Login (NOT /api/Auth/login)
- Token field: `token` (NOT `accessToken`)

## Key Decisions (from §144)
- ❌ REMOVED: Command palette, Ctrl+N/S/Escape shortcuts
- ⏳ DEFERRED: Multi-monitor, Material theme, map marker popups, Pusher→SignalR
- ✅ KEEP: Pusher (for now), current dark theme, existing keyboard (Tab + number keys only)
- Mobile dispatch = Operator Mobile App (Flutter), NOT responsive CSS on desktop console

## API Keys
- Google Maps/Places/Distance Matrix: AIzaSyDtmccRciM2vDtBik-cH9tyFMBCjhjqukI
- Stripe PK: pk_test_2Bev2SetXUmgnJMqgIOXDLPm
- Stripe SK: sk_test_yXkGfVZbzDtHTA8W9lKwXYzR

## Rules
- DO NOT rewrite working code — wrap and extend
- Build ONE feature → run smoke tests → commit → next
- DO NOT change any API routes, method signatures, or JSON properties
- DO NOT add [AllowAnonymous] to bypass auth — fix auth properly
- Merge to main after each feature
- Update docs/feature-tracker.md after each feature
- Reference PRD section numbers in commits
