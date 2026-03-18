# Red Taxi — Feature Tracker (v2 — Wrap & Extend)

> **125 legacy features already working. 40 new features to build. 18 configs to extract.**
> Strategy: docs/build-strategy-v2.md

Last Updated: 2026-03-18

## LEGACY = ✅ Already Working (125 features)
BookingService (L01-L21), TariffService (L22-L31), DispatchService (L32-L41),
AccountsService (L42-L55), Messaging (L56-L65), Payments (L66-L71),
Other Services (L72-L85), Dispatch UI (L86-L97), Admin Panel (L98-L110),
Driver App (L111-L121), Web Booker (L122-L125).
See full list: docs/feature-tracker-full.md

## CONFIG EXTRACTION = 🔧 (18 items, Phase 3)
C01 Base postcode | C02 Bank holidays | C03-C05 HVS accounts+rates |
C06 Rank commission | C07 Waiting rates | C08 Revolut key |
C09 SendGrid templates | C10 WhatsApp SIDs | C11 Airport strings |
C12 Webhook URL | C13 Map centre | C14-C16 Other constants

## NEW FEATURES = 🆕 (40 features)

### Phase 1: Multi-Tenancy (N01-N05)
| # | Feature | Status |
|---|---------|--------|
| N01 | Tenant middleware (slug → DB) | 🆕 |
| N02 | Master DB (RedTaxi_Platform) | 🆕 |
| N03 | Tenant provisioning (create DB, migrate, seed) | 🆕 |
| N04 | Per-tenant connection resolver | 🆕 Reuse from archive |
| N05 | Tenant subdomain routing | 🆕 |

### Phase 2: SaaS Billing (N06-N13)
| # | Feature | Status |
|---|---------|--------|
| N06 | Stripe product/price seeding | 🆕 Reuse from archive |
| N07 | Stripe checkout for signup | 🆕 |
| N08 | Stripe webhook processing | 🆕 Reuse from archive |
| N09 | Stripe Customer Portal | 🆕 |
| N10 | Trial lifecycle | 🆕 |
| N11 | Usage tracking | 🆕 |
| N12 | Bolt-on management | 🆕 |
| N13 | Tenant payment choice (Stripe/Revolut) | 🆕 Reuse from archive |

### Phase 4: Customer App (N14-N25)
| # | Feature | Status |
|---|---------|--------|
| N14 | Tenant selection by GPS | 🆕 Scaffold exists |
| N15 | Phone + OTP login | 🆕 |
| N16 | Home map + search | 🆕 |
| N17 | Booking + upfront price | 🆕 |
| N18 | Live tracking + ETA | 🆕 |
| N19 | Rating + review | 🆕 |
| N20 | Payment methods | 🆕 |
| N21 | Booking history | 🆕 |
| N22 | Saved places | 🆕 |
| N23 | In-app chat | 🆕 |
| N24 | Share trip | 🆕 |
| N25 | Profile + GDPR | 🆕 |

### Phase 4: Operator Mobile (N26-N30)
| # | Feature | Status |
|---|---------|--------|
| N26 | Bookings tab | 🆕 Scaffold exists |
| N27 | Alerts tab | 🆕 |
| N28 | Live Map tab | 🆕 |
| N29 | More tab | 🆕 |
| N30 | Push notifications | 🆕 |

### Phase 4: Marketing Website (N31-N33)
| # | Feature | Status |
|---|---------|--------|
| N31 | Landing page | 🆕 |
| N32 | Pricing page | 🆕 |
| N33 | Signup flow | 🆕 |

### Phase 5+: Improvements (N34-N40)
| # | Feature | Status |
|---|---------|--------|
| N34 | Zone pricing polygon UI | 🆕 Replit prototype exists |
| N35 | Configurable map centre | 🆕 Reuse from archive |
| N36 | Review request system | 🆕 |
| N37 | Google Places (secondary) | 🆕 Uncomment + configure |
| N38 | Replace Pusher → SignalR | ⏳ Future |
| N39 | Separate booker logins | ⏳ Future |
| N40 | Auto-dispatch | ⏳ Future |

## SUMMARY
| Category | Count |
|----------|-------|
| ✅ Legacy (working) | 125 |
| 🔧 Config extraction | 18 |
| 🆕 New to build | 40 |
| ⏳ Future | 3 |
| **Total** | **186** |
