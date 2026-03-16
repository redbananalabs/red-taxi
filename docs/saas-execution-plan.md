# SaaS Execution Plan

## Foundation (Completed in Discovery)
1. Per-tenant database architecture designed (master DB + tenant DBs)
2. Tenant entity defined with Stripe fields, status enum, onboarding tracking
3. Subscription tiers defined (Starter/Growth/Professional/Enterprise)
4. Trial & expiry lifecycle specced (14-day trial → 3-day grace → soft lock → hard lock → deletion)
5. Self-service signup flow with onboarding wizard
6. Stripe integration architecture (Customer, Subscription, Checkout, Webhooks)
7. Subdomain + custom domain tenant access model
8. Design language and tokens locked

## Phase 1A: API Build (includes SaaS foundation)
1. Master DB context (`PlatformDbContext`) — Tenant, TenantExitSurvey, platform config
2. Tenant DB context (`RedTaxiDbContext`) — all business entities, per-request connection resolution
3. `ITenantConnectionResolver` middleware — subdomain / custom domain / JWT resolution
4. Tenant provisioning Hangfire job — create DB, run migrations, seed defaults
5. Stripe integration — Customer creation on signup, Checkout Session, webhook handlers
6. Entitlement middleware — check plan limits (drivers, bookings/month, features)
7. Trial expiry Hangfire jobs — reminders, grace period, soft lock, hard lock, data deletion

## Phase 1B: Frontend (includes SaaS UI)
1. Signup page (registration form, email verification)
2. Onboarding wizard (6 steps)
3. Subscription management (Stripe Billing Portal redirect)
4. Plan upgrade/downgrade prompts (when hitting limits)
5. Soft lock screen (read-only banner, exit survey, data retention message)
6. Hard lock screen (reactivation option)
7. Platform admin pages (SuperAdmin role — tenant list, revenue, surveys, impersonation)

## Deferred
1. Partner network / cross-tenant job sharing (Phase 5+)
2. White-label tenant websites (Phase 6+)
3. AI features (Phase 7+)
