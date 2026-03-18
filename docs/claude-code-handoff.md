# Claude Code Handoff — Red Taxi Platform (v2 Strategy)

> **APPROACH: Wrap the working legacy system. Don't rewrite it.**
> The legacy codebase is 142K lines of battle-tested code used in production daily.
> We add multi-tenancy + SaaS billing on top. Only build what's genuinely new.

## Repository
```
git clone https://github.com/onesoftuk/red-taxi.git
```

## Read These First
1. **docs/build-strategy-v2.md** — THE strategy (wrap & extend)
2. **docs/PRD.md** — 143 sections, complete product spec
3. **docs/feature-tracker.md** — 125 legacy features ✅, 40 new to build 🆕

## Repo Structure
```
red-taxi/
├── docs/                          70+ docs (PRD, strategy, tracker — all valid)
├── legacy/                        THE MAIN CODEBASE (production code)
│   ├── AceTaxis.API/              .NET 8 backend API (or TaxiDispatch.API)
│   ├── AceTaxis.Lib/              Services, entities, business logic
│   ├── ace-dispatcher/            React dispatch console (14K lines)
│   ├── ace-admin-panel/           React admin panel (89K lines)
│   ├── ace-driver-app/            Flutter driver app (18K lines)
│   ├── ace-account-web-booker/    React account web booker
│   └── ace-local-sms/             .NET MAUI Android SMS gateway
├── src/
│   └── reusable/                  Pieces from new build to integrate
│       ├── tenancy/               TenantConnectionResolver, DbContextFactory
│       ├── external-services/     StripeSeedService, PaymentService, Google*
│       └── flutter/               red_taxi_shared, red_taxi_customer, red_taxi_operator
├── archive/
│   └── new-build-v1/              Full v1 rewrite (reference only)
└── design-tokens.json
```

## What's Working (Don't Touch Unless Extracting Config)
- All booking CRUD, pricing, dispatch, allocation, completion
- All invoicing, statements, commission, VAT
- All messaging (WhatsApp, SMS, Push, Email)
- All reporting (18 reports)
- React dispatch console, admin panel, web booker
- Flutter driver app
- Address lookup (IdealPostcodes primary, Google commented out)
- Revolut payments

## What Needs Building (40 features)
See docs/feature-tracker.md for full list.

Phase 1: Multi-tenancy wrapper on legacy API
Phase 2: Stripe SaaS billing + tenant lifecycle
Phase 3: Config extraction (18 hardcoded items → CompanyConfig)
Phase 4: Customer app + Operator mobile app + Marketing site
Phase 5: Test with Ace Taxis as first tenant

## API Keys
- Stripe PK: pk_test_2Bev2SetXUmgnJMqgIOXDLPm
- Stripe SK: sk_test_yXkGfVZbzDtHTA8W9lKwXYzR
- Google Maps: AIzaSyDtmccRciM2vDtBik-cH9tyFMBCjhjqukI

## Rules
- DO NOT rewrite working code. Wrap and extend.
- Build ONE feature → verify → commit → next
- Always merge to main after features
- Update docs/feature-tracker.md after each feature
