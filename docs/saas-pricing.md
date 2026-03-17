# Red Taxi SaaS Pricing Model

## Pricing Philosophy

**Base plan + bolt-on marketplace.** Every tenant starts with a base plan that covers core dispatch. Additional capabilities are purchased as bolt-ons. Bolt-on pricing is deliberately set ~20% higher than what upgrading to the next tier would cost — this incentivises natural upgrades while still allowing flexibility.

---

## Base Plans

| | Solo | Team | Fleet | Enterprise |
|---|---|---|---|---|
| **Monthly Price** | £199 | £389 | £799 | Custom |
| **Drivers Included** | 5 | 20 | 50 | Unlimited |
| **Bookings Included** | 1,500/mo | 5,000/mo | 15,000/mo | Unlimited |
| **Operator Seats** | 2 | 5 | 15 | Unlimited |
| **14-Day Free Trial** | ✓ | ✓ | ✓ | ✓ |

### What's Included in Every Base Plan (No Bolt-On Required)

- Dispatch console (map-centric, command palette, timeline, floating panels)
- Booking CRUD (create, amend, cancel, complete, duplicate, repeat)
- Pricing engine (tariffs, account tariffs, fixed-price routes)
- Driver app (iOS + Android — schedule, job offers, status, GPS)
- Driver management (profiles, colours, documents, expiry tracking)
- Account management (CRUD, passengers, tariff overrides)
- Availability management (presets, multiple blocks, audit log)
- Invoice processing (individual + grouped, driver statements)
- All reports (driver, booking, financial — no gating)
- Partner network access (free for all)
- Dark/light mode
- Hangfire background jobs
- Subdomain access (`{slug}.redtaxi.io`)
- Standard support (email, in-app ticket)

---

## Bolt-Ons

### Extra Drivers
5 additional drivers per pack.

| Pack | Price/mo | Per-Driver/mo |
|------|----------|---------------|
| +5 Drivers | £89 | £17.80 |

**Upgrade incentive check:**
- Solo (5 drivers) + 3 packs (15 extra) = 20 drivers = £199 + £267 = **£466/mo**
- Team plan (20 drivers) = **£389/mo** — 20% cheaper than bolt-on route ✓
- Team (20) + 6 packs (30 extra) = 50 drivers = £389 + £534 = **£923/mo**
- Fleet plan (50 drivers) = **£799/mo** — 15% cheaper ✓

### Extra Booking Bundles
Pre-purchased booking packs. Unused bookings do NOT roll over.

| Bundle | Price/mo | Per-Booking |
|--------|----------|-------------|
| +500 bookings | £60 | £0.12 |
| +2,000 bookings | £200 | £0.10 |
| +5,000 bookings | £400 | £0.08 |

**Upgrade incentive check:**
- Solo (1,500) + 2,000 bundle + 500 bundle = 4,000 bookings = £199 + £260 = **£459/mo**
- Team (5,000 bookings) = **£389/mo** — cheaper than bolt-on route ✓
- Team (5,000) + 5,000 bundle + 5,000 bundle = 15,000 bookings = £389 + £800 = **£1,189/mo**
- Fleet (15,000 bookings) = **£799/mo** — significantly cheaper ✓

### SMS Messaging Pack

| Pack | Price/mo | Per-SMS |
|------|----------|---------|
| 500 SMS | £25 | £0.05 |
| 2,000 SMS | £75 | £0.0375 |
| 5,000 SMS | £150 | £0.03 |

### WhatsApp Messaging
Pay-as-you-go: **£0.01 per message** (1p). No packs, no minimum. Billed monthly based on usage. Metered via Twilio/WhatsApp Business API costs.

### Customer Web Portal
Branded web booking portal for account customers (Blazor WASM).

**£109/mo**

Includes: account login, create booking, active bookings, passenger management, booking history, repeat bookings.

### Custom Domain / White-Label
Map tenant's own domain to their dispatch console and customer portal.

**£65/mo**

Includes: custom domain mapping, SSL provisioning (Let's Encrypt), white-label removal of Red Taxi branding, custom favicon.

### API Access
Full REST API access for third-party integrations.

**£109/mo**

Includes: API key management, webhook configuration, rate limits (1,000 req/min), OpenAPI documentation, sandbox environment.

### Priority Support

**Free** (included in all plans)

All tenants get: email support, in-app ticket system, knowledge base. No tiered support gating — this is a differentiator.

### Advanced Reporting

**Free** (included in all plans)

All 18 reports available on every plan. No gating.

### Partner Network

**Free** (included in all plans)

Cross-tenant job sharing, cover requests, settlement engine. Available to all tenants.

---

## Pricing Summary Table

| Item | Solo | Team | Fleet | Enterprise |
|------|------|------|-------|------------|
| Base | £199 | £389 | £799 | Custom |
| Drivers | 5 | 20 | 50 | Unlimited |
| Bookings | 1,500 | 5,000 | 15,000 | Unlimited |
| +5 Drivers | £89/mo | £89/mo | £89/mo | — |
| +500 Bookings | £60/mo | £60/mo | £60/mo | — |
| +2,000 Bookings | £200/mo | £200/mo | £200/mo | — |
| +5,000 Bookings | £400/mo | £400/mo | £400/mo | — |
| SMS 500 | £25/mo | £25/mo | £25/mo | Included |
| SMS 2,000 | £75/mo | £75/mo | £75/mo | Included |
| SMS 5,000 | £150/mo | £150/mo | £150/mo | Included |
| WhatsApp | 1p/msg | 1p/msg | 1p/msg | 1p/msg |
| Web Portal | £109/mo | £109/mo | £109/mo | Included |
| Custom Domain | £65/mo | £65/mo | £65/mo | Included |
| API Access | £109/mo | £109/mo | £109/mo | Included |
| Reports | Free | Free | Free | Free |
| Partner Network | Free | Free | Free | Free |
| Support | Free | Free | Free | Dedicated |

---

## Annual Discount

20% discount for annual billing (2 months free):

| Plan | Monthly | Annual (per month) | Annual Total |
|------|---------|-------------------|-------------|
| Solo | £199 | £159 | £1,908 |
| Team | £389 | £311 | £3,732 |
| Fleet | £799 | £639 | £7,668 |

Bolt-ons are always monthly — no annual commitment on add-ons.

---

## Stripe Implementation

### Products & Prices

Each plan and bolt-on is a separate Stripe Product with a recurring Price:

```
Products:
  red-taxi-solo          → Price: £199/mo, £159/mo (annual)
  red-taxi-team          → Price: £389/mo, £311/mo (annual)
  red-taxi-fleet         → Price: £799/mo, £639/mo (annual)
  bolt-on-drivers-5      → Price: £89/mo
  bolt-on-bookings-500   → Price: £60/mo
  bolt-on-bookings-2000  → Price: £200/mo
  bolt-on-bookings-5000  → Price: £400/mo
  bolt-on-sms-500        → Price: £25/mo
  bolt-on-sms-2000       → Price: £75/mo
  bolt-on-sms-5000       → Price: £150/mo
  bolt-on-web-portal     → Price: £109/mo
  bolt-on-custom-domain  → Price: £65/mo
  bolt-on-api-access     → Price: £109/mo
```

WhatsApp is metered billing via Stripe's usage-based pricing: report usage at end of month, Stripe invoices accordingly.

### Subscription Structure

Each tenant has ONE Stripe Subscription with multiple line items:
- Base plan (required)
- Bolt-ons (optional, added/removed via Stripe Billing Portal or in-app)

```
Subscription for "Ace Taxis":
  - red-taxi-team: £389/mo
  - bolt-on-drivers-5: £89/mo (×1)
  - bolt-on-sms-2000: £75/mo
  - bolt-on-web-portal: £109/mo
  Total: £662/mo
```

### Upgrade/Downgrade

- **Upgrade:** immediate, prorated. Stripe handles the billing math.
- **Downgrade:** takes effect at next billing cycle. System checks entitlement limits — if current usage exceeds new plan limits, warns tenant and requires them to reduce (deactivate drivers, etc.) before downgrade processes.
- **Bolt-on add:** immediate, prorated.
- **Bolt-on remove:** end of billing cycle.

---

## Usage Metering

### Booking Count
- Incremented on every `CreateBooking` API call
- Stored in `Tenant.CurrentMonthBookingCount`
- Reset to 0 on 1st of each month (Hangfire job)
- At 80% of plan + bundle allowance: in-app warning banner
- At 100%: block booking creation, show upgrade/buy-bundle prompt

### SMS Count
- Decremented from pack balance on each send
- When pack depleted: queue message but don't send, show "Buy SMS pack" prompt
- Remaining count visible in Settings

### WhatsApp Count
- Incremented per message sent
- Reported to Stripe as metered usage at month end
- No blocking — always sends, billed retrospectively

### Driver Count
- Checked on `CreateDriver` / `ActivateDriver`
- Cannot exceed plan + bolt-on allowance
- Deactivated drivers don't count against limit

---

## Marketing & Upsell Triggers

The system tracks usage patterns and triggers marketing prompts:

| Trigger | Action |
|---------|--------|
| Booking count > 80% of allowance | Banner: "Running low on bookings — upgrade or buy a bundle" |
| Driver count = limit | Modal on "Add Driver": "You've reached your driver limit — upgrade or add a driver pack" |
| SMS pack depleted | Banner: "SMS pack empty — buy more to keep notifications flowing" |
| Solo user hitting Team-level usage for 2+ months | Email: "You'd save £X/month by upgrading to Team" |
| Bolt-on cost > 20% of next tier base price | Email: "You're spending £X on bolt-ons — upgrading to [next tier] would save you £Y/month" |
| Feature attempted that requires bolt-on | Modal: "Custom domains are available as a bolt-on — add for £65/mo" |

---

## Pricing Page UX

The pricing page should show:

1. **Plan comparison cards** (Solo / Team / Fleet / Enterprise) with included features
2. **"Calculate your cost" slider** — driver count + estimated monthly bookings → recommended plan + estimated total
3. **Bolt-on marketplace** below the plans — toggle add-ons to see updated monthly total
4. **Annual toggle** — switch between monthly and annual (showing savings)
5. **"Start Free Trial"** CTA on every plan card — no card required
