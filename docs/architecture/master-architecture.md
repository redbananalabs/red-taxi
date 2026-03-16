# Red Taxi Platform — Architecture

**Version:** 2.0  
**Last Updated:** 2026-03-16

---

## 1. Architecture Style

**Modular Monolith with Vertical Slice Architecture**

Single deployable .NET 8 API with features organised by bounded context. Each feature contains its own commands, queries, handlers, DTOs, and endpoints. No microservices for v1 — complexity is not justified at this scale.

MediatR handles command/query dispatch. One handler per use case. Domain events drive cross-cutting concerns (messaging, notifications, audit logging) so features don't call each other directly.

---

## 2. Technology Stack

| Layer | Technology | Rationale |
|-------|-----------|-----------|
| **Backend API** | .NET 8, ASP.NET Core | Team expertise, legacy compatibility |
| **CQRS / Handlers** | MediatR | Breaks god services into single-purpose handlers |
| **ORM** | EF Core 8 | Existing migration history, `IDbContextFactory` for scoped contexts |
| **Database** | SQL Server | Legacy compatibility, import wizard needs schema parity |
| **Cache / Real-time state** | Redis | GPS positions, driver status, dispatch notifications |
| **Real-time** | SignalR | Blazor Server built-in; diary/dispatch live updates |
| **Push notifications** | FCM (Firebase) | Existing driver app integration |
| **SMS** | Twilio | Existing integration |
| **WhatsApp** | Twilio / WhatsApp Business API | Existing integration |
| **Payments** | Revolut API | Existing integration; Stripe planned for Phase 4+ |
| **Address lookup** | Ideal Postcodes + Google Places | Existing integration |
| **Distance/duration** | Google Distance Matrix API | Existing pricing dependency |
| **PDF generation** | QuestPDF | Existing; invoices, statements, credit notes |
| **Dispatch console** | Blazor Server + Syncfusion | C# full-stack, real-time via SignalR built-in, Syncfusion Scheduler/Grid/Charts |
| **Driver app** | Flutter | Reliable background GPS + push; Dart syntax close to C# |
| **Customer portal** | Blazor WASM or lightweight SPA | Small surface area; decision deferred |
| **Hosting** | Self-hosted VPS + Docker Compose | v1 target |
| **Reverse proxy** | Nginx | SSL termination, static files, load balancing |

---

## 3. Project Structure

```
src/
├── RedTaxi.API/                    # ASP.NET Core host, controllers (thin), middleware, Program.cs
│   ├── Controllers/                # Thin REST controllers — delegate to MediatR
│   ├── Middleware/                  # Tenant resolution, JWT, error handling
│   ├── Hubs/                       # SignalR hubs (dispatch, GPS)
│   └── Configuration/              # DI registration, options
│
├── RedTaxi.Application/            # Use cases organised by feature
│   ├── Bookings/
│   │   ├── Commands/               # CreateBooking, UpdateBooking, CancelBooking, AllocateDriver, CompleteBooking, MergeSchoolRuns
│   │   ├── Queries/                # GetBookingsToday, GetBookingById, FindBookings, GetBookingsByDriver
│   │   ├── Events/                 # BookingCreated, BookingAllocated, BookingCompleted, BookingCancelled
│   │   └── DTOs/
│   ├── Dispatch/
│   │   ├── Commands/               # AllocateBooking, SoftAllocate, ConfirmSoftAllocates, RecordTurnDown
│   │   ├── Queries/                # GetDriverList, GetDiaryView
│   │   └── Events/                 # DriverAllocated, DriverUnallocated
│   ├── Pricing/
│   │   ├── Commands/               # RecalculatePrice, ManualPriceUpdate, ResetPrice
│   │   ├── Queries/                # GetPrice, GetTariffs, GetAccountTariffs, GetZonePrices
│   │   └── Services/               # TariffCalculator, DistanceMatrixClient
│   ├── Fleet/
│   │   ├── Commands/               # SetAvailability, UpdateGPS, DriverShift, UploadDocument
│   │   ├── Queries/                # GetAvailability, GetDriverStatus, GetAllGPS, GetDriverExpirys
│   │   └── Events/                 # DriverWentAvailable, DriverWentOffline, GPSUpdated
│   ├── Accounts/
│   │   ├── Commands/               # CreateInvoice, CreditInvoice, MarkPaid, PostJobs, PriceBulk
│   │   ├── Queries/                # GetAccounts, GetInvoices, GetStatements, GetChargableJobs, VATOutputs
│   │   └── Events/                 # InvoiceCreated, StatementCreated
│   ├── Messaging/
│   │   ├── Commands/               # SendSMS, SendWhatsApp, SendPush, SendPaymentLink, ScheduleMessage
│   │   ├── Queries/                # GetMessageConfig, GetMessageHistory
│   │   └── Handlers/               # Event handlers that react to domain events (BookingAllocated → send driver notification)
│   ├── Reporting/
│   │   ├── Queries/                # RevenueByMonth, DriverEarnings, Profitability, BookingScopeBreakdown, TopCustomers
│   │   └── DTOs/
│   ├── WebBooking/
│   │   ├── Commands/               # CreateWebBooking, AcceptWebBooking, RejectWebBooking, RequestAmendment
│   │   ├── Queries/                # GetWebBookings, GetAccountActiveBookings
│   │   └── Events/                 # WebBookingSubmitted, WebBookingAccepted
│   ├── Partners/
│   │   ├── Commands/               # RegisterPartner, CreateCoverRequest, AcceptCover, DeclineCover, CreateSettlement
│   │   ├── Queries/                # GetPartners, GetCoverRequests, GetPartnerJobs, GetSettlements
│   │   └── Events/                 # CoverRequested, CoverAccepted, CoverDeclined, SettlementCreated
│   ├── Customers/
│   │   ├── Commands/               # CreateCustomer, UpdateCustomer, SaveAddress
│   │   ├── Queries/                # LookupByPhone, GetCustomer, GetSavedAddresses
│   │   └── DTOs/
│   ├── WhatsAppBot/
│   │   ├── Commands/               # ProcessInboundMessage, CreateBotBooking, HandoffToOperator
│   │   ├── Queries/                # GetConversationState
│   │   └── Services/               # ConversationManager, AddressExtractor, BotResponseGenerator
│   ├── Identity/
│   │   ├── Commands/               # Register, Login, RefreshToken, ResetPassword
│   │   └── Queries/                # GetUser, ListUsers
│   └── Tenancy/
│       ├── Commands/               # ProvisionTenant, ImportTenantData, UpdateTenantConfig
│       └── Queries/                # GetTenantConfig, GetCompanyConfig
│
├── RedTaxi.Domain/                 # Entities, enums, value objects, domain events, interfaces
│   ├── Entities/                   # Booking, Driver, Account, Tariff, etc.
│   ├── Enums/                      # BookingStatus, BookingScope, VehicleType, DriverStatus, etc.
│   ├── Events/                     # Domain event definitions
│   └── Interfaces/                 # Repository interfaces, service interfaces
│
├── RedTaxi.Infrastructure/         # EF Core, Redis, external APIs, file storage
│   ├── Persistence/
│   │   ├── RedTaxiDbContext.cs
│   │   ├── Configurations/         # EF entity configurations (fluent API)
│   │   └── Migrations/
│   ├── Redis/                      # GPS cache, driver state, SignalR backplane
│   ├── ExternalServices/           # Google Maps, Ideal Postcodes, Revolut, Twilio, FCM
│   └── Tenancy/                    # Tenant connection resolver, tenant middleware
│
├── RedTaxi.Blazor/                 # Dispatch console (Blazor Server)
│   ├── Pages/                      # Booking, Diary, Availability, DriverStatus, Accounts, Reports
│   ├── Components/                 # BookingForm, BookingDetailPopup, DriverList, ViaManager, etc.
│   ├── Shared/                     # Layout, NavMenu
│   └── wwwroot/
│
├── RedTaxi.WebPortal/              # Customer booking portal
│
└── tests/
    ├── RedTaxi.UnitTests/
    ├── RedTaxi.IntegrationTests/
    └── RedTaxi.ArchTests/          # Architecture guardrails (handler isolation, no cross-feature refs)
```

---

## 4. Key Architecture Decisions

### ADR-001: MediatR over direct service injection
God services exist because services call each other. MediatR handlers are isolated by design — one handler per use case. Cross-cutting concerns (messaging after allocation, audit logging) are handled by domain event handlers, not direct calls.

### ADR-002: Blazor Server over Blazor WASM for dispatch console
Dispatch operators need instant load time and real-time updates. Blazor Server gives us: zero WASM download, built-in SignalR for live diary/dispatch, full server-side rendering, and Syncfusion Blazor components (Scheduler, DataGrid, Charts) which are most mature on Blazor Server.

### ADR-003: Flutter for driver app
Background GPS and push notifications must be reliable on both iOS and Android. Flutter's `geolocator` and `firebase_messaging` packages are production-proven. .NET MAUI was considered (C# consistency) but background services on iOS are still unreliable. React Native background location is notoriously flaky. Dart is syntactically similar to C#.

### ADR-004: Per-tenant database from day one
Each tenant gets their own SQL Server database (`RedTaxi_{slug}`). A master database (`RedTaxi_Platform`) holds the tenant registry, Stripe subscription data, and platform config. Connection strings are resolved per-request via middleware. This eliminates cross-tenant data leak risk entirely — no query filters to forget, no TenantId columns to maintain. Tenant deletion is a simple `DROP DATABASE`. Migrations run across all tenant DBs via a Hangfire job.

### ADR-005: Redis for real-time state
GPS positions, driver on-shift status, and dispatch notifications change frequently and must be fast. Redis stores ephemeral state; SQL Server stores durable records. SignalR uses Redis as backplane for horizontal scaling.

### ADR-006: Domain events for messaging
When a booking is allocated, the `AllocateBookingHandler` publishes a `BookingAllocated` domain event. A separate `SendDriverNotificationHandler` reacts to that event and sends SMS/WhatsApp/Push. This decouples dispatch from messaging — the exact problem the legacy BookingService has.

---

## 5. Deployment Architecture (v1 — Hetzner VPS)

### Server Spec
- **Provider:** Hetzner Cloud
- **Plan:** CX32 (4 vCPU, 8GB RAM, 80GB SSD) — ~€7/month
- **OS:** Ubuntu 24.04 LTS
- **Location:** Falkenstein (EU) or Ashburn (US) — EU preferred for UK data residency
- **Extras:** Hetzner Firewall (free), automated backups (€1.20/month)

### Docker Compose Stack
```yaml
# docker-compose.yml
services:
  nginx:
    image: nginx:alpine
    ports: ["80:80", "443:443"]
    volumes: [./nginx.conf:/etc/nginx/nginx.conf, ./certs:/etc/ssl]
    depends_on: [redtaxi-api]

  redtaxi-api:
    image: ghcr.io/redbananalabs/redtaxi:latest
    environment:
      - ConnectionStrings__PlatformConnection=Server=sqlserver;Database=RedTaxi_Platform;...
      - ConnectionStrings__TenantTemplate=Server=sqlserver;Database=RedTaxi_{slug};...
      - Redis__ConnectionString=redis:6379
    depends_on: [sqlserver, redis]

  sqlserver:
    image: mcr.microsoft.com/mssql/server:2022-latest
    environment:
      - ACCEPT_EULA=Y
      - MSSQL_SA_PASSWORD=${SQL_PASSWORD}
    volumes: [sqldata:/var/opt/mssql]

  redis:
    image: redis:7-alpine
    volumes: [redisdata:/data]

volumes:
  sqldata:
  redisdata:
```

### Domains
- `dispatch.redtaxi.io` → nginx → redtaxi-api (Blazor Server dispatch console)
- `api.redtaxi.io` → nginx → redtaxi-api (REST API)
- `book.acetaxisdorset.co.uk` → nginx → redtaxi-api (customer portal, tenant-branded)

SSL via Let's Encrypt (certbot auto-renewal).

### CI/CD Pipeline (GitHub Actions)
```
Push to main
  → Build .NET 8
  → Run tests
  → Build Docker image
  → Push to GitHub Container Registry (ghcr.io)
  → SSH to Hetzner VPS
  → docker compose pull && docker compose up -d
```

Single YAML file: `.github/workflows/deploy.yml`. No Kubernetes, no Terraform. Blue-green deployment via nginx upstream port switching.

### Backup Strategy
- Hetzner automated server snapshots (daily, €1.20/month)
- SQL Server backup job via Hangfire (nightly, to Hetzner Object Storage)
- Redis AOF persistence (survives container restart)

---

## 6. Authentication & Authorisation

- ASP.NET Core Identity with JWT bearer tokens
- Roles: SuperAdmin, TenantAdmin, Dispatcher, Driver, AccountUser, WebBooker
- Tenant resolution via `X-Tenant-Id` header (API) or subdomain (Blazor/portal)
- Refresh token rotation with Redis-backed revocation
- Driver app: JWT + FCM device registration
- Web portal: JWT for account users, anonymous with rate limiting for cash bookings

---

## 7. Real-Time Communication

| Channel | Technology | Use |
|---------|-----------|-----|
| Dispatch console live updates | SignalR (built-in Blazor Server) | Diary changes, new bookings, driver status |
| Driver app job offers | FCM push + SignalR fallback | New job notification, status updates |
| GPS tracking | SignalR → Redis | Driver location updates every 5-10s |
| Customer tracking | SignalR or polling | "Driver is X minutes away" |

---

## 8. API Versioning

```
/api/v1/*    — Legacy Ace endpoints (compatibility during migration)
/api/v2/*    — New Red Taxi endpoints (clean contract)
```

The v1 surface exists only for the transition period while the Ace frontend migrates to Blazor. Once migration is complete, v1 is deprecated.

---

## 9. Background Job Processing

### Decision: Hangfire over RabbitMQ for v1

The legacy system uses RabbitMQ for message queuing (e.g. SMS gateway polling). For Red Taxi v1, **Hangfire** is recommended instead:

- Simpler to operate (no separate message broker to manage)
- Built-in dashboard for monitoring jobs
- SQL Server backed (no additional infrastructure)
- Supports delayed/scheduled jobs natively
- Good enough for v1 scale (100+ drivers, 1000+ daily bookings per tenant)

RabbitMQ or Azure Service Bus can be introduced later if throughput demands exceed what Hangfire handles.

### Job Types
- Scheduled SMS/WhatsApp sending
- Job offer retry logic (configurable delay between attempts)
- Invoice batch generation
- Driver document expiry alerts
- GPS history cleanup
- Reporting pre-computation

---

## 10. OpenAPI Contract

The API contract should be committed to the repo as the source of truth:

- `docs/openapi/v2.json` — generated from ASP.NET Core Swagger
- Auto-generated on build via CI
- Used for: client code generation (Flutter, customer portal), regression testing, documentation
- Smoke/parity tests can compare v1 and v2 endpoint responses using HAR recordings from the legacy system

---

## 11. Reporting Strategy

### Decision: Syncfusion Blazor Components over Bold Reports for v1

Bold Reports is overkill for v1. Every report on the list is a filtered data grid or chart — not a pixel-perfect paginated report. Use what's already in the Blazor Syncfusion stack:

| Need | Tool | Notes |
|------|------|-------|
| Tabular reports | `SfDataGrid` | Sorting, filtering, grouping, column templates, export to Excel/CSV |
| Charts (revenue, profitability, growth) | `SfChart` | Bar, line, pie, area charts with drill-down |
| Dashboard KPI cards | Blazor components | Simple card components with real-time SignalR updates |
| Invoice/Statement PDFs | QuestPDF | Already used in legacy, proven |
| Credit note PDFs | QuestPDF | Same template engine |
| CSV export | Simple API endpoint | Streaming CSV from EF query |

Bold Reports (Community License) can be added in Phase 4+ if tenants want a custom report designer for their own reports. For v1, all 18 reports (3 driver, 9 booking, 6 financial) are built as Blazor pages with `SfDataGrid` + `SfChart`.

---

## 12. Custom Dispatch UI Components (Blazor)

Full layout spec in `docs/design/dispatch-layout.md`. These require custom Blazor component development:

### Map Base Layer
- Google Maps JavaScript API with custom dark styling from design tokens
- Driver pins with status colours (5 vehicle statuses), white border for legibility
- Active booking routes drawn as overlays (brand red, 3px, 40% opacity fill)
- Unallocated bookings pulse at pickup location
- Click pin → driver context panel slides in from right
- Click booking route → booking context panel slides in from right
- Selected vehicle: 1.3x scale with pulsing brand red ring

### Timeline / Gantt Bar (Bottom Dock)
- Syncfusion `SfSchedule` in TimelineDay view, docked to bottom (~200px)
- Each row = one driver, each block = one booking (coloured by scheduler colour system)
- Drag bookings between driver rows → triggers `AllocateBooking` MediatR command
- Drag to resize → updates booking pickup time
- Double-click bottom edge to expand to full diary mode
- Current time = vertical red line
- Expandable to full-height "Diary Mode" (traditional scheduler)

### Booking Form (Floating Panel)
- Slides in from left (480px) on `Cmd+N` or "New Booking" action
- Absolutely positioned over the map, not a CSS grid split
- Entering pickup + destination triggers: Google Distance Matrix → price calculation → route preview drawn on map behind the form
- Price displayed inline on form (Journey Cost, Miles, Tariff applied)
- Semi-transparent backdrop — map remains visible
- `Cmd+Enter` to confirm, `Escape` to dismiss

### Context Panel (Right Slide-In)
- 400px panel slides in from right when clicking any entity
- Booking detail: full info + actions (allocate, cancel, complete, duplicate, amend, send payment link)
- Driver detail: current job, next jobs, today's earnings, availability, message
- Customer detail: phone, address, booking history, repeat bookings
- Only one context panel open at a time, `Escape` to dismiss

### Command Palette (Cmd+K)
- Custom Blazor component — centre modal overlay with fuzzy search
- Searches: bookings (by ID, address, passenger), drivers (by name, number), customers (by phone, name)
- Quick actions: "new booking", "global message", "confirm soft allocates"
- Navigation: "go to reports", "go to accounts"

### School Run Merge (Drag to Combine)
- In Diary Mode, when Merge Mode is enabled (toggle), dragging booking A onto booking B triggers merge
- Preconditions: both school-run tagged, same destination, same account
- Booking A's pickup becomes a via on booking B, price recalculates
- Custom drag handler detects overlap → shows merge confirmation dialog

### Real-Time SignalR Updates
- All dispatch console users see live updates without page refresh
- Events: BookingCreated, BookingAllocated, BookingCancelled, BookingCompleted, DriverStatusChanged, DriverGPSUpdated
- Blazor Server has built-in SignalR — no extra wiring
- Map pins move in real-time (driver GPS every 5-10 seconds)
- Timeline blocks update on booking status changes
- Dashboard KPI cards update in real-time
- Toast notifications for actionable events (bottom right)

### Multi-Monitor Pop-Out
- Map, timeline, and booking form can each pop out to separate browser windows via `window.open()`
- State sync via BroadcastChannel API — all windows share the same SignalR connection
- Enables: map on monitor 1, diary on monitor 2, both live-updating

---

## 13. IIS Staging Deployment (Development)

During development, Red Taxi runs on IIS alongside the existing Ace system on the same Windows server.

### Setup

```
C:\inetpub\
├── acetaxisdorset\          ← existing Ace React apps (Vercel, but API here)
└── redtaxi\                 ← new Red Taxi API + Blazor Server
```

### IIS Configuration
- **Site name:** RedTaxi
- **Port:** 5100 (or subdomain: `redtaxi.yourdomain.com`)
- **Application Pool:** No Managed Code (.NET 8 runs out-of-process via ASP.NET Core Module)
- **Install:** ASP.NET Core Hosting Bundle (.NET 8) on the server

### Publish & Deploy

```powershell
# Build and publish
dotnet publish src/RedTaxi.API -c Release -o C:\inetpub\redtaxi

# Or with a deploy script:
# scripts/deploy-iis.ps1
```

### Configuration Files

`appsettings.Production.json` (on server, not in repo):
```json
{
  "ConnectionStrings": {
    "PlatformConnection": "Server=localhost;Database=RedTaxi_Platform;Trusted_Connection=true;TrustServerCertificate=true",
    "TenantTemplate": "Server=localhost;Database=RedTaxi_{slug};Trusted_Connection=true;TrustServerCertificate=true"
  },
  "Redis": {
    "ConnectionString": "localhost:6379"
  },
  "Tenancy": {
    "Mode": "PerTenantDatabase"
  }
}
```

### Database
- Create `RedTaxi_Platform` database (master — tenant registry, Stripe data, platform config)
- Tenant databases created automatically on signup: `RedTaxi_{slug}` (e.g. `RedTaxi_ace-taxis`)
- For dev/staging with Ace: manually create `RedTaxi_ace-taxis` and run migrations
- Existing `TaxiDispatch` database untouched — no interference

### Redis
- Option A: Install Redis for Windows (Memurai or MSOpenTech fork)
- Option B: Docker Desktop running just Redis: `docker run -d -p 6379:6379 redis:7-alpine`

### Transition to Production
When ready for production: Hetzner Docker deployment using the `docker-compose.yml` already in the repo. IIS staging continues as a dev/test environment.

---

## 14. CSS Framework Decision

**Tailwind CSS** for all non-Syncfusion UI elements.

- Tailwind config extends from `design-tokens.json` (colours, spacing, radius, typography)
- Syncfusion components use Material Dark/Light theme with brand red overrides
- Custom components (cards, pills, layout shells, nav) use Tailwind utility classes
- No Bootstrap anywhere in the stack
- Tailwind and Syncfusion coexist — Syncfusion handles grids/charts/scheduler, Tailwind handles everything else

### Tailwind Config Extension
```js
// tailwind.config.js (generated from design-tokens.json)
module.exports = {
  theme: {
    extend: {
      colors: {
        'bg-base': 'var(--color-bg-base)',
        'bg-surface': 'var(--color-bg-surface)',
        'bg-card': 'var(--color-bg-card)',
        'brand': { 300: '#FF6B6B', 500: '#FF2D2D', 600: '#E62626', 900: '#331010' },
        // ... all tokens
      }
    }
  }
}
```

---

## 15. Portal Technology Decisions

| Project | Tech | Reason |
|---------|------|--------|
| RedTaxi.Blazor (dispatch console) | Blazor Server | Real-time SignalR built-in, no WASM download, stable office connections |
| RedTaxi.WebPortal (customer portal) | Blazor WASM | Public-facing, works offline, shared C# code with dispatch |
| RedTaxi.TenantAdmin (tenant admin portal) | Blazor WASM | Tenant self-service, code sharing, independent deployment |
| RedTaxi.DriverApp | Flutter | iOS + Android, background GPS, push notifications |

Blazor WASM projects share a `RedTaxi.Shared` class library with the Server project for DTOs, validation, and API client code. This eliminates duplication between dispatch console and portals.

### Updated Solution Structure
```
src/
├── RedTaxi.sln
├── RedTaxi.API/                    (.NET 8 Web API)
├── RedTaxi.Application/            (MediatR handlers)
├── RedTaxi.Domain/                 (Entities, enums, events)
├── RedTaxi.Infrastructure/         (EF Core, Redis, external APIs)
├── RedTaxi.Shared/                 (DTOs, validation, API client — shared by all Blazor projects)
├── RedTaxi.Blazor/                 (Dispatch console — Blazor Server + Syncfusion)
├── RedTaxi.WebPortal/              (Customer portal — Blazor WASM)
├── RedTaxi.TenantAdmin/            (Tenant admin — Blazor WASM)
└── RedTaxi.DriverApp/              (Flutter — separate, not in .NET solution)
```
