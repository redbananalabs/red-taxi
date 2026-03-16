# Red Taxi SaaS Platform Specification

---

## 1. Subscription Tiers

| Tier | Drivers | Bookings/mo | Monthly Price | Features |
|------|---------|-------------|--------------|----------|
| Starter | ≤15 | ≤3,000 | TBD | Core dispatch, booking, pricing, driver app, SMS/WhatsApp, web booker portal, basic reports |
| Growth | ≤40 | ≤10,000 | TBD | Everything in Starter + account invoicing, driver statements, full reporting suite, API access |
| Professional | ≤100 | ≤30,000 | TBD | Everything in Growth + partner network, cover requests, white-label customer portal, custom domain |
| Enterprise | Custom | Custom | Custom | Everything in Professional + dedicated support, SLA, custom integrations, per-tenant DB option |

Prices TBD — to be set before launch. All tiers include a 14-day free trial.

### Entitlement Enforcement

Limits are enforced at the API level via middleware that checks the tenant's active plan:

- **Driver limit:** cannot create/activate drivers beyond tier limit
- **Booking limit:** soft warning at 80%, hard block at 100% (monthly rolling count, resets 1st of month)
- **Feature gating:** partner network, custom domains, API access locked to appropriate tier
- **Overage handling:** system shows upgrade prompt, does not silently fail

---

## 2. Billing Provider: Stripe

### Integration Architecture

```
Tenant signs up → Stripe Customer created → Trial starts (no card)
Trial expires → Checkout Session → Card captured → Subscription active
Monthly billing → Stripe Invoice → Webhook → Update tenant status
Failed payment → Stripe retry logic → Webhook → Grace period
Cancellation → Webhook → Grace → Soft lock → Hard lock → Data deletion
```

### Stripe Objects per Tenant

| Stripe Object | Maps To |
|---------------|---------|
| Customer | Tenant |
| Subscription | Active plan (Starter/Growth/Professional/Enterprise) |
| Product | Each tier is a Stripe Product |
| Price | Monthly price per product |
| Checkout Session | Payment page for trial-to-paid conversion |
| Billing Portal | Self-service plan management, payment method updates |

### Webhooks to Handle

| Event | Action |
|-------|--------|
| `checkout.session.completed` | Activate subscription, update tenant plan |
| `invoice.paid` | Confirm payment, reset any grace warnings |
| `invoice.payment_failed` | Start grace period, notify tenant admin |
| `customer.subscription.updated` | Handle plan upgrade/downgrade |
| `customer.subscription.deleted` | Start expiry flow (grace → soft lock → hard lock) |

### Stripe Billing Portal
Tenants manage their own subscription via Stripe's hosted billing portal (no custom UI needed for v1):
- Update payment method
- View invoice history
- Upgrade/downgrade plan
- Cancel subscription

---

## 3. Signup Flow (Self-Service)

### Step 1: Landing Page
Tenant visits platform website → clicks "Start Free Trial"

### Step 2: Registration Form

| Field | Required | Notes |
|-------|----------|-------|
| Company Name | Yes | Becomes tenant display name |
| Subdomain | Yes | Auto-suggested from company name (e.g. "ace-taxis" → `ace-taxis.{platform-domain}`) |
| Owner Full Name | Yes | Becomes TenantAdmin user |
| Email | Yes | Login email, must verify |
| Password | Yes | Min 8 chars, 1 upper, 1 number |
| Phone | Yes | For account recovery + SMS verification |
| Country | Yes | Defaults to UK, affects currency/locale |
| Company Postcode | No | Used for default map centre |

No card required. No payment information collected at signup.

### Step 3: Email Verification
Verification email sent immediately. Tenant can access the system before verifying (soft reminder banner) but must verify within 48 hours or account is paused.

### Step 4: Tenant Provisioning (Automatic)

On registration, the system automatically:

1. Creates `Tenant` record with 14-day trial expiry date
2. Creates Stripe Customer (no subscription yet — trial)
3. Creates TenantAdmin user with owner details
4. Seeds default data:
   - 3 standard tariffs (UK defaults matching Ace structure: Day/Night/Holiday)
   - Default message templates (8 events)
   - Default company settings
   - Default message settings (all set to "None" — operator configures)
5. Assigns subdomain: `{slug}.{platform-domain}`
6. Redirects to dispatch console with onboarding wizard

### Step 5: Onboarding Wizard (First Login)

A guided setup wizard that walks the new tenant through essential configuration:

| Step | What | Why |
|------|------|-----|
| 1. Company Profile | Logo upload, company name, address, phone, email | Branding on invoices, customer comms |
| 2. Tariff Setup | Review/edit the 3 default tariffs, add account tariffs | Pricing must be right before bookings |
| 3. Add Drivers | Add at least 1 driver (name, phone, colour, vehicle) | Can't dispatch without drivers |
| 4. Messaging Setup | Configure which events trigger SMS/WhatsApp/None | Notifications are core to operations |
| 5. Import Data (Optional) | Upload existing data (CSV) or connect to legacy system | For migrating taxi companies |
| 6. Create First Booking | Guided walkthrough of booking form | Confirms everything works |

Wizard can be skipped and revisited from settings. Progress tracked — shows completion % on dashboard until all steps done.

---

## 4. Tenant Access Model

### Subdomain Routing (Default)
Every tenant gets a subdomain on sign-up: `{slug}.{platform-domain}`

- Dispatch console: `{slug}.{platform-domain}` (Blazor Server)
- Customer portal: `book.{slug}.{platform-domain}` (Blazor WASM)
- API: `api.{platform-domain}` (shared, tenant resolved from JWT)

### Custom Domain (Professional + Enterprise)
Tenants on Professional or Enterprise can map their own domain:

- `dispatch.acetaxisdorset.co.uk` → maps to their tenant
- Requires DNS CNAME record pointing to platform
- SSL provisioned automatically via Let's Encrypt
- Stored in `Tenant.CustomDomain` field
- Tenant resolution: check `Host` header → lookup custom domain → resolve tenant

### Tenant Resolution Order
1. Custom domain match (if `Host` header matches a `Tenant.CustomDomain`)
2. Subdomain match (extract slug from `{slug}.{platform-domain}`)
3. JWT claim (API requests carry `tenant_id` in token)

---

## 5. Trial & Expiry Flow

### Timeline

```
Day 0:  Signup → 14-day trial starts (full access, no card)
Day 10: Email reminder: "4 days left on your trial"
Day 12: In-app banner: "2 days left — add payment to continue"
Day 14: Trial expires → 3-day grace period starts
Day 14: Email: "Your trial has expired. Add payment within 3 days to keep your data."
Day 14: In-app: Full-screen modal on login, can dismiss but shows on every page load
Day 17: Grace period expires → SOFT LOCK
        - Read-only access (can view bookings, reports, data)
        - Cannot create bookings, allocate, dispatch, send messages
        - Full-screen message: "Your account is locked. Your data is safe for the next 7 days.
          Subscribe now to restore full access."
        - Show exit survey: "What did you like? What didn't you like? Why didn't you upgrade?"
        - Repeat: "Your data is safe for 7 days if you upgrade."
Day 24: 7-day data retention expires → HARD LOCK
        - Account fully locked
        - No access at all (login shows "Account expired" page with reactivation option)
Day 24: Email: "Your Red Taxi account has been locked. Reactivate within 30 days to recover your data."
Day 54: 30 days after hard lock → DATA DELETION
        - All tenant data permanently deleted
        - Tenant record marked as deleted
        - Stripe Customer archived
        - Cannot be recovered
```

### State Machine

```
Active (Trial) → Active (Subscribed)     [payment captured]
Active (Trial) → Grace Period            [trial expires, no payment]
Active (Subscribed) → Grace Period       [payment fails after Stripe retries]
Grace Period → Soft Locked               [3 days, no payment]
Soft Locked → Active (Subscribed)        [payment captured — instant restore]
Soft Locked → Hard Locked                [7 days, no payment]
Hard Locked → Active (Subscribed)        [payment captured within 30 days — instant restore]
Hard Locked → Deleted                    [30 days, no payment — data purged]
```

### Exit Survey (shown at Soft Lock)

Displayed as a modal before the soft lock screen:

**Questions:**
1. "What did you like about Red Taxi?" (free text)
2. "What could we improve?" (free text)
3. "Why didn't you upgrade?" (multi-select):
   - Too expensive
   - Missing features I need
   - Switched to another provider
   - Not ready to go live yet
   - Just evaluating / no immediate need
   - Other (free text)

Survey responses stored in a `TenantExitSurvey` table for product analytics.
After submitting (or dismissing), show the data retention message and soft lock screen.

---

## 6. Tenant Entity (Updated)

```csharp
public class Tenant
{
    public Guid Id { get; set; }
    public string CompanyName { get; set; }
    public string Slug { get; set; }                    // subdomain: "ace-taxis"
    public string? CustomDomain { get; set; }           // "dispatch.acetaxisdorset.co.uk"
    public string OwnerName { get; set; }
    public string OwnerEmail { get; set; }
    public string OwnerPhone { get; set; }
    public string? CompanyPostcode { get; set; }
    public string? LogoUrl { get; set; }
    public string Country { get; set; } = "GB";
    public string Currency { get; set; } = "GBP";

    // Subscription
    public string StripeCustomerId { get; set; }
    public string? StripeSubscriptionId { get; set; }
    public SubscriptionPlan Plan { get; set; } = SubscriptionPlan.Trial;
    public TenantStatus Status { get; set; } = TenantStatus.ActiveTrial;
    public DateTime TrialExpiresAt { get; set; }
    public DateTime? GraceExpiresAt { get; set; }
    public DateTime? SoftLockExpiresAt { get; set; }
    public DateTime? HardLockExpiresAt { get; set; }
    public DateTime? DataDeletionAt { get; set; }
    public bool EmailVerified { get; set; } = false;

    // Onboarding
    public bool OnboardingCompleted { get; set; } = false;
    public string? OnboardingProgress { get; set; }     // JSON: {"tariffs": true, "drivers": false, ...}

    // Limits
    public int MaxDrivers { get; set; }
    public int MaxBookingsPerMonth { get; set; }
    public int CurrentMonthBookingCount { get; set; }

    // Config
    public string SchedulerUnallocatedColour { get; set; } = "#D97706";

    // Timestamps
    public DateTime CreatedAt { get; set; }
    public DateTime? CancelledAt { get; set; }
    public DateTime? DeletedAt { get; set; }
}

public enum SubscriptionPlan
{
    Trial,
    Starter,
    Growth,
    Professional,
    Enterprise
}

public enum TenantStatus
{
    ActiveTrial,
    ActiveSubscribed,
    GracePeriod,
    SoftLocked,
    HardLocked,
    Deleted
}
```

---

## 7. Hangfire Background Jobs (SaaS)

| Job | Schedule | Action |
|-----|----------|--------|
| TrialExpiryReminder | Daily | Email tenants with 4 days and 2 days remaining |
| TrialExpiry | Daily | Move expired trials to GracePeriod status |
| GraceExpiry | Daily | Move expired grace periods to SoftLocked |
| SoftLockExpiry | Daily | Move expired soft locks to HardLocked |
| HardLockExpiry | Daily | Move expired hard locks to Deleted, purge data |
| MonthlyBookingCountReset | 1st of month | Reset CurrentMonthBookingCount for all tenants |
| StripeWebhookRetry | Hourly | Retry any failed webhook processing |

---

## 8. Platform Admin (Super Admin)

A separate admin view (not tenant-facing) for Red Taxi platform operators:

- View all tenants (status, plan, usage, trial expiry)
- Manually activate/deactivate tenants
- View subscription revenue (Stripe dashboard link)
- View exit survey responses
- Manage platform-wide settings
- View system health (SMS heartbeat, API latency, error rates)
- Impersonate tenant (login as tenant admin for support)

This is a page within the main Blazor Server app, restricted to the SuperAdmin role.
