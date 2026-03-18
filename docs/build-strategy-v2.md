# Red Taxi — REVISED Build Strategy v2

> **Principle: Wrap the working system, don't rewrite it.**
> The legacy system has 142K lines of battle-tested code. Rewriting it from scratch
> is slower, riskier, and produces worse results than extending what already works.

---

## What Changed (and Why)

v1 strategy: Rewrite everything from clean architecture (MediatR handlers, domain events, etc.)
Result: 47K lines of scaffolded code, ~40% working, weeks from feature parity.

v2 strategy: Take the working legacy backend + frontends, add multi-tenancy + SaaS layer on top.
Expected result: Working system in days, not weeks. Ace Taxis can test immediately.

---

## Architecture: Layered Wrap

```
┌─────────────────────────────────────────────────────────────┐
│  NEW: SaaS Platform Layer                                    │
│  - Stripe billing, tenant signup, onboarding wizard          │
│  - Marketing website (Next.js)                               │
│  - Master DB (RedTaxi_Platform)                              │
└──────────────────────┬──────────────────────────────────────┘
                       │ provisions tenant DB
┌──────────────────────▼──────────────────────────────────────┐
│  NEW: Multi-Tenancy Wrapper                                  │
│  - ITenantConnectionResolver (per-request DB routing)        │
│  - Tenant middleware (X-Tenant-Slug header → DB connection)  │
│  - Config overrides (make hardcoded values configurable)     │
└──────────────────────┬──────────────────────────────────────┘
                       │ wraps
┌──────────────────────▼──────────────────────────────────────┐
│  EXISTING: Legacy Backend (TaxiDispatch.API + Lib)           │
│  - BookingService (2,142 lines) — KEEP AS-IS                 │
│  - TariffService (709 lines) — KEEP, extract hardcoded vals  │
│  - DispatchService (1,002 lines) — KEEP AS-IS                │
│  - AccountsService (2,247 lines) — KEEP AS-IS                │
│  - AceMessagingService (891 lines) — KEEP, make configurable │
│  - All 20 controllers (5,396 lines) — KEEP AS-IS             │
│  - All 36 entities (1,320 lines) — KEEP, add new fields      │
└──────────────────────┬──────────────────────────────────────┘
                       │ serves
┌──────────────────────▼──────────────────────────────────────┐
│  EXISTING: Frontends (KEEP ALL, enhance incrementally)       │
│  - ace-dispatcher (React) — KEEP, operators trained on it    │
│  - ace-admin-panel (React) — KEEP, fully functional          │
│  - ace-driver-app (Flutter) — KEEP, drivers use it daily     │
│  - ace-account-web-booker (React) — KEEP                     │
│  - ace-local-sms (MAUI) — KEEP                               │
├──────────────────────────────────────────────────────────────┤
│  NEW: Apps That Don't Exist Yet                              │
│  - Customer App (Flutter) — BUILD NEW                        │
│  - Operator Mobile App (Flutter) — BUILD NEW                 │
│  - Marketing Website + Signup (Next.js) — BUILD NEW          │
└──────────────────────────────────────────────────────────────┘
```

---

## What We KEEP (Don't Touch Unless Fixing a Bug)

| Component | Lines | Status | Action |
|-----------|-------|--------|--------|
| BookingService.cs | 2,142 | Working | Keep. Extract hardcoded account numbers to config. |
| TariffService.cs | 709 | Working | Keep. Move bank holidays to DB. Move base postcode to config. |
| DispatchService.cs | 1,002 | Working | Keep as-is. |
| AccountsService.cs | 2,247 | Working | Keep. Extract hardcoded waiting rates to config. |
| AceMessagingService.cs | 891 | Working | Keep. Replace hardcoded template IDs with config. |
| WebBookingService.cs | 878 | Working | Keep as-is. |
| AvailabilityService.cs | 491 | Working | Keep as-is. |
| All other services | ~5,398 | Working | Keep as-is. |
| All 20 controllers | 5,396 | Working | Keep. Add tenant middleware. |
| All 36 entities | 1,320 | Working | Keep. Add new fields where needed. |
| ace-dispatcher (React) | 14,359 | Working | Keep. Operators use it. |
| ace-admin-panel (React) | 89,016 | Working | Keep as-is. |
| ace-driver-app (Flutter) | 18,541 | Working | Keep. Point to new API URL. |
| ace-account-web-booker | ~2,000 | Working | Keep as-is. |
| ace-local-sms (MAUI) | ~500 | Working | Keep as-is. |

**Total kept: ~142,000 lines of working code.**

---

## What We ADD (New Code Only)

### Layer 1: Multi-Tenancy (2-3 days)

| Task | Description |
|------|-------------|
| TenantConnectionResolver | Middleware that reads X-Tenant-Slug header, resolves to tenant DB connection string |
| Master DB (RedTaxi_Platform) | New DB with: Tenants, TenantSubscriptions, StripePrices tables |
| Tenant provisioning | Hangfire job: creates new DB, runs existing EF migrations, seeds defaults |
| Config extraction | Move 18 hardcoded items (§104) from code to CompanyConfig table |
| Per-tenant app settings | Each tenant's API URL, subdomain, branding |

### Layer 2: SaaS Billing (2-3 days)

| Task | Description |
|------|-------------|
| Stripe subscription management | Products, prices, checkout, customer portal |
| Tenant lifecycle | Signup → trial → active → grace → locked → deleted |
| Usage tracking | Booking count, driver count, SMS count per month |
| Bolt-on management | Add/remove bolt-ons via Stripe |

### Layer 3: New Apps (5-7 days)

| App | What | Effort |
|-----|------|--------|
| Customer App (Flutter) | 15 screens from §129 — tenant select, OTP, booking, tracking, rating | 3 days |
| Operator Mobile App (Flutter) | 4 tabs from §128 — bookings, alerts, live map, more | 2 days |
| Marketing Website (Next.js) | Landing page, pricing, signup flow | 2 days |

### Layer 4: Config Extraction (1-2 days)

Make these hardcoded items configurable via CompanyConfig (admin panel already has settings pages):

| Item | Current | Target |
|------|---------|--------|
| Base postcode | "SP8 4PZ" hardcoded | CompanyConfig.BasePostcode |
| Bank holidays | Hardcoded list | CompanyConfig.BankHolidays (JSON) |
| HVS account numbers | 9014, 10026 hardcoded | Account.AccountTariffId (already exists) |
| Waiting rates | £0.33/£0.42 hardcoded | CompanyConfig.DriverWaitingRate, AccountWaitingRate |
| Rank commission | 7.5% hardcoded | CompanyConfig.RankCommissionRate |
| Airport strings | 26 hardcoded strings | LocalPOI with type=Airport |
| SendGrid templates | 14 hardcoded IDs | MessagingNotifyConfig |
| Revolut API key | Hardcoded | CompanyConfig.RevoluttSecretKey (already exists) |
| Map centre | Hardcoded lat/lng | CompanyConfig.MapCenter* (from new build) |

---

## What We REUSE from the New Build

The new build isn't wasted. These parts are good and should be kept:

| Component | From New Build | Reuse How |
|-----------|---------------|-----------|
| Per-tenant DB resolver | RedTaxi.Infrastructure/Tenancy/ | Apply to legacy DbContext |
| Stripe seed service | StripeSeedService.cs | Keep for SaaS billing |
| Stripe webhook handler | StripeWebhookController.cs | Keep for subscription lifecycle |
| Payment service (dual Stripe/Revolut) | PaymentService.cs | Keep, wire into legacy |
| Google Distance Matrix client | GoogleDistanceMatrixService.cs | Replace legacy's inline HTTP calls |
| Google Places service | GooglePlacesService.cs | Add to legacy as new endpoint |
| Flutter shared package | red_taxi_shared/ | Base for customer + operator apps |
| Domain entities (extended) | 47 entities with new fields | Merge new fields into legacy entities |
| Design tokens | design-tokens.json | Use for new apps |
| PRD + docs | 142 sections, 4,800 lines | Requirements reference |
| Feature tracker | 235 features mapped | Progress tracking |

---

## Revised Solution Structure

```
red-taxi/
├── docs/                          (PRD, strategy, feature tracker — keep all)
├── src/
│   ├── RedTaxi.Platform/          NEW — SaaS billing, tenant management, signup
│   │   ├── PlatformDbContext.cs
│   │   ├── StripeSeedService.cs   (from new build)
│   │   ├── StripeWebhookController.cs (from new build)
│   │   └── TenantProvisioningService.cs
│   │
│   ├── RedTaxi.Tenancy/           NEW — Multi-tenancy middleware
│   │   ├── TenantMiddleware.cs
│   │   ├── TenantConnectionResolver.cs (from new build)
│   │   └── TenantDbContextFactory.cs
│   │
│   ├── TaxiDispatch.API/          LEGACY — Keep all 20 controllers, add tenant middleware
│   ├── TaxiDispatch.Lib/          LEGACY — Keep all 18 services, extract hardcoded values
│   │
│   └── RedTaxi.ConfigExtractor/   NEW — Tool to migrate hardcoded → configurable
│
├── frontend/
│   ├── ace-dispatcher/             LEGACY — Keep React dispatch console
│   ├── ace-admin-panel/            LEGACY — Keep React admin panel
│   ├── ace-account-web-booker/     LEGACY — Keep React web booker
│   └── ace-local-sms/              LEGACY — Keep MAUI SMS gateway
│
├── mobile/
│   ├── ace-driver-app/             LEGACY — Keep Flutter driver app, update API URL
│   ├── red_taxi_customer/          NEW — Flutter customer app
│   ├── red_taxi_operator/          NEW — Flutter operator mobile app
│   └── red_taxi_shared/            NEW — Shared Flutter package (from new build)
│
├── marketing/
│   └── next-app/                   NEW — Next.js marketing site + signup
│
└── design-tokens.json              Keep
```

---

## Revised Timeline

| Phase | Days | What |
|-------|------|------|
| 1 | 2-3 | Multi-tenancy wrapper on legacy backend. Tenant middleware, connection resolver, config extraction. Legacy API serves requests per-tenant. |
| 2 | 2-3 | SaaS billing. Stripe subscriptions, tenant signup, provisioning, lifecycle. |
| 3 | 3-5 | New Flutter apps. Customer app (15 screens), operator mobile (4 tabs). Reuse red_taxi_shared. |
| 4 | 2 | Marketing website + signup flow. Next.js landing page, pricing, Stripe checkout. |
| 5 | 2-3 | Config extraction. Make all 18 hardcoded items configurable. Bank holidays, pricing rates, templates. |
| 6 | 2-3 | Testing + Ace migration. Point Ace Taxis to new multi-tenant instance. Verify all flows. |
| **Total** | **~15 days** | Working SaaS platform with Ace as first tenant |

Compare: v1 (rewrite) was estimated at 3 weeks and produced 40% working scaffolding.
v2 (wrap) delivers a working platform in ~15 days with 100% of legacy features preserved.

---

## Phase 7+ (Future): Gradual Modernisation

Once the platform is live and stable, THEN modernise incrementally:

| Step | What | When |
|------|------|------|
| 7a | Replace React dispatch with Blazor | When operators request new features |
| 7b | Replace React admin with Blazor | When admin needs SaaS-specific features |
| 7c | Refactor BookingService into MediatR handlers | When adding new booking features |
| 7d | Add domain events for messaging | When adding new notification channels |
| 7e | Replace inline Distance Matrix calls with service | Already done in new build |

The key insight: **modernise when you're adding features, not as a separate project.**
Each new feature gets built in the new architecture. Old features stay working until they need changing.

---

## What Happens to the New Build Code?

| Component | Decision |
|-----------|----------|
| RedTaxi.Domain entities | Merge new fields into legacy entities (migration) |
| RedTaxi.Application handlers | Archive — reference for future MediatR refactor |
| RedTaxi.Infrastructure services | Keep Stripe, Distance Matrix, Places — wire into legacy |
| RedTaxi.Blazor (dispatch) | Archive — reference for future Blazor dispatch |
| RedTaxi.TenantAdmin (Blazor) | Archive — reference for future Blazor admin |
| RedTaxi.WebPortal (Blazor) | Archive — reference for future Blazor portal |
| Flutter apps (driver) | Archive — legacy driver app is better |
| Flutter apps (customer) | KEEP — this doesn't exist in legacy |
| Flutter apps (operator) | KEEP — this doesn't exist in legacy |
| Flutter shared package | KEEP — base for new apps |
| PRD + docs | KEEP — all 142 sections still valid |
| Feature tracker | KEEP — update to track legacy features + new additions |
