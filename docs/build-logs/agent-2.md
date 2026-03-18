# Agent 2 Build Log — Identity + Accounts + Billing API
Started: 2026-03-18
Last Updated: 2026-03-18
Status: Complete

## Context
- Working on: Phase 1A — Auth, user management, accounts, billing, fleet, messaging, config
- PRD sections: §63, §79-80, §83, §103, §105, §118, §120
- Dependencies: Phase 0 foundation (complete)
- Branch: main

## Completed Work

### 2026-03-18 — Full Identity+Accounts+Billing Implementation

**Identity (6 files):**
- JwtTokenService: 15-min access tokens with claims (sub, role, tenant_id, tenant_slug), 30-day refresh tokens
- LoginCommand: BCrypt password validation, token pair generation, LastLogin update
- RefreshTokenCommand: token rotation with revocation chain (ReplacedByToken)
- RegisterUserCommand: BCrypt hashing, auto-increment UserId, FluentValidation
- GetUserQuery, ListUsersQuery: by ID or filtered by role/active

**Accounts (7 files):**
- CreateAccount: auto-incremented AccountNumber
- UpdateAccount: all fields
- AccountPassenger CRUD: create + soft-delete (IsActive=false)
- Queries: GetAccounts (search), GetAccountById (with tariff join), GetAccountPassengers

**Billing (11 files):**
- SettlementCalculator: EXACT §105 formula
  - Commission: Cash/Card use CashCommRate, Rank uses RankCommRate, Account=0
  - Card VAT: Price/1.2 when AddVatOnCardPayments
  - CardFees = EarningsCard × CardRate / 100
  - SubTotal = (Cash+Card+Rank) - TotalCommission + Account
- PostJobsForInvoicing / PostJobsForStatement: marks jobs ready
- CreateInvoice: from posted jobs, uses PriceAccount, auto-increments InvoiceNumber
- CreateStatement: runs SettlementCalculator, includes expenses, links via StatementId
- CreateCreditNote, MarkInvoicePaid
- Queries: ChargeableJobs, Invoices, Statements, VatOutputs

**Fleet (8 files):**
- UpdateDriverProfile, SetDriverAvailability (with audit), UpdateDriverGps
- DriverShift: start/finish/break with DriverShiftLog + DriverOnShift management
- UploadDocument: DocumentExpiry records
- Queries: GetDriverProfile, GetDriverAvailability, GetDriverDocuments

**Messaging (3 files):**
- SendMessage: direct (specific driver) or global (all drivers)
- UpdateMessagingConfig: upsert for 11 event types
- GetMessagingConfig: returns all configs

**Config (2 files):**
- UpdateCompanyConfig: upserts single-row config
- GetCompanyConfig: returns config

**API Controllers (7 files):**
- AuthController: login (anonymous), refresh (anonymous), register (Admin only)
- UsersController, AccountsController, BillingController, DriversController, MessagingController, ConfigController

**Entity Modified:** UserProfile — added Email, PasswordHash, Role properties

**Total: 45 files, 2,415 lines**

## Handoff Notes
- Auth uses custom UserProfile table, NOT ASP.NET Core Identity — simpler for multi-tenant
- SettlementCalculator is a pure service, easy to unit test
- Invoice grouping (Singles vs Shared/Grp) is not yet implemented — currently flat list
- Message sending is record-only (creates DriverMessage) — actual SMS/WhatsApp delivery is Phase 2
- CompanyConfig is single-row per tenant DB, upserted on first access
