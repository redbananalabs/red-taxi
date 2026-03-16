# Red Taxi Platform — Business Rules

**Version:** 2.0  
**Last Updated:** 2026-03-16

---

## 1. Pricing Rules

### 1.1 Price Calculation Flow

```
Booking field changes → GetPrice called → Google Distance Matrix (avg A→B + B→A) → Apply tariff → Return price
```

1. Collect postcodes: pickup, destination, all vias (ordered)
2. Call Google Distance Matrix for each leg (pickup→via1→via2→destination)
3. Also calculate reverse direction for each leg
4. Average the forward and reverse distances/durations for fairness
5. Look up applicable tariff (account tariff override → default tariff)
6. Calculate: `max(BaseFare + (TotalMiles × PerMileRate) + (TotalMinutes × PerMinuteRate) + Surcharges, MinimumFare)`
7. Track dead miles separately: `DeadMiles = distance from base to pickup` (when `ChargeFromBase = true`)

### 1.2 Price Recalculation Triggers

Price recalculates automatically when ANY of these change (unless `ManuallyPriced = true`):

- Pickup address/postcode
- Destination address/postcode
- Via stops (added, removed, reordered)
- Passenger count (may trigger surcharge)
- Vehicle type (may have different tariff)
- Account number (may switch tariff)
- Journey time (if manually entered)

### 1.3 Cash / Rank / Card Jobs

- **One price** on the booking: `Price` = driver price
- Driver keeps the fare collected
- Company earns via **commission** deducted from driver at settlement
- Commission rate: configurable per driver (`UserProfile.CommissionRate`) or company default (`CompanyConfig`)
- Commission is a settlement/reporting concern — NOT calculated on the booking

### 1.4 Account Jobs

- **Two prices** on every booking:
  - `PriceAccount` — invoiced to the account
  - `Price` — paid to the driver
- Account may have custom tariff (via `AccountTariff`) overriding default rates
- Changing the account number triggers tariff lookup + price recalculation
- Both prices may differ: account may be charged more than the driver is paid (operator margin)

### 1.5 Manual Pricing

- Operator can override the calculated price
- Sets `ManuallyPriced = true`
- Auto-recalculation is disabled until operator clicks "Reset Price"
- Reset Price: clears manual flag, recalculates from current booking data

### 1.6 Tariff Components

| Component | Description |
|-----------|-------------|
| Base fare | Fixed starting charge |
| Per mile rate | Charged per mile of journey |
| Per minute rate | Charged per minute of journey |
| Minimum fare | Floor price — if calculated price is below this, minimum applies |
| Waiting time charge | Per-minute charge for driver waiting |
| Passenger surcharge | Additional charge per extra passenger (above threshold) |
| Airport surcharge | Flat surcharge for airport pickups/dropoffs |

### 1.7 Dead Miles

The system tracks:
- **Total mileage** = full distance
- **Dead miles** = distance from operator base to pickup (non-revenue miles)
- **Trip miles** = Total - Dead miles
- Display format: `97.0 Miles - (Dead Miles: 49.5) + (Trip Miles: 47.5)`

---

## 2. Booking Rules

### 2.1 Booking Scopes

| Scope | Value | Price fields used | Payment method |
|-------|-------|------------------|----------------|
| Cash | 0 | Price only | Customer pays driver directly |
| Account | 1 | Price + PriceAccount | Monthly invoice to account |
| Rank | 2 | Price only | Customer pays driver at rank |
| Card | 4 | Price only | Payment link (Revolut) |

### 2.2 Repeat Bookings

- Frequency: None, Daily, Weekly, Fortnightly
- Day selection: M/T/W/T/F/S/S (multi-select for weekly/fortnightly)
- End condition: Never, or Until (specific date)
- Creates individual booking records using `RecurrenceRule`, `RecurrenceID`, `RecurrenceException` fields
- Each generated booking can be individually edited/cancelled

### 2.3 Return Bookings

- Toggle creates a second booking with addresses swapped
- Second booking gets a separate pickup datetime
- Treated as an independent booking once created

### 2.4 ASAP Bookings

- `IsASAP = true` — pickup time is "now"
- May bypass normal dispatch queue
- Typically triggers immediate driver notification

### 2.5 Booking Duplication

- Creates a copy of all booking data
- Option to keep same datetime or set new datetime
- New booking is independent (no link to original)

### 2.6 Arrive By

- When "Arrive By" is enabled, the displayed time is the arrival deadline
- "Calculate Pickup" computes backward from arrival time using estimated journey duration
- Sets both `PickupDateTime` (calculated) and `ArriveBy` (target)

---

## 3. Dispatch Rules

### 3.1 Allocation Types

| Type | Description |
|------|-------------|
| **Allocate** | Firm assignment — driver is notified, booking status changes |
| **Soft Allocate** | Tentative — `SuggestedUserId` is set, no driver notification. Operator can bulk-confirm later |
| **Confirm All Soft Allocates** | Batch-converts soft allocations to firm allocations |

### 3.2 Allocation Flow

1. Operator clicks "Allocate Booking" on booking detail
2. Driver list shown: all drivers with number, name, vehicle type, reg number, colour swatch
3. Driver list includes "(0) - Unallocated" option for removing allocation
4. Selecting a driver:
   - Updates `Booking.UserId`
   - Sets `Booking.AllocatedAt` and `Booking.AllocatedById`
   - Publishes `BookingAllocated` domain event
   - Event handler sends driver notification (push/SMS/WhatsApp based on config)
   - If previous driver was allocated, they receive an unallocation notification

### 3.3 School Run Merge

**Preconditions for merge:**
- Both bookings are tagged as school runs (`IsSchoolRun = true`)
- Same destination address
- Same account number

**Merge behaviour:**
1. Operator drags booking A onto booking B in the diary view
2. Booking A's pickup address is added as a new via stop on booking B
3. Booking A is marked as merged (`MergedIntoBookingId = B.Id`) and effectively cancelled/hidden
4. Price recalculates on booking B with the new via stop
5. Passenger count may be updated

### 3.4 Turn Downs

When a driver refuses a job after being asked (via phone), the operator records a turn-down. This is tracked for reporting and may influence future dispatch decisions.

---

## 4. COA (Cancel on Arrival) Rules

### 4.1 When COA Applies

The driver has arrived at the pickup location but the passenger does not show up.

### 4.2 Pricing on COA

| Party | Charge |
|-------|--------|
| Account customer | May be billed **full fare** (they booked, their no-show) |
| Cash customer | No charge (they're not there to pay) |
| Driver | Paid a **reduced amount** — less than full fare since journey was not completed |

### 4.3 COA Record

A `COARecord` is created with:
- `AccountCharge` — what the account pays (may be full fare)
- `DriverPayout` — what the driver receives (reduced)
- `Reason` — operator notes

The booking is flagged `CancelledOnArrival = true`.

---

## 5. Driver Availability Rules

### 5.1 How Drivers Become Available

| Method | Description |
|--------|-------------|
| Mobile app login | Driver opens app and starts shift |
| Pre-declared shifts | Operator sets availability blocks in advance |
| Call to dispatch | Driver phones office, operator sets them available |
| Operator override | Operator manually changes driver status |
| Allocating a booking | Driver may receive a booking without explicitly going available |

### 5.2 Driver States

| State | Description |
|-------|-------------|
| Offline | Not working |
| Available | Ready for jobs |
| On Job | Currently on a booking |
| Break | On break (tracked for shift compliance) |
| Unavailable | Working but not taking new jobs |

### 5.3 Availability Grid

- Operators can view/set availability for any driver for any date
- "Use Old Driver Availability" copies previous day's pattern to current day
- Availability blocks are time ranges (e.g., 07:00-17:00)
- Some drivers have special patterns like "AM School Only" (07:30-09:30)

---

## 6. Messaging Rules

### 6.1 Automated Messages

Configured per tenant via `MessagingNotifyConfig`. Each event can be enabled/disabled and assigned a channel.

| Event | Channels | Recipient |
|-------|----------|-----------|
| Driver allocated | Push, SMS, WhatsApp | Driver |
| Driver unallocated | Push, SMS, WhatsApp | Driver |
| Booking amended | Push, SMS, WhatsApp | Driver |
| Booking cancelled | Push, SMS, WhatsApp | Driver |
| Booking confirmed | SMS, WhatsApp | Customer |
| Driver arrival | SMS, WhatsApp | Customer |
| Journey completed | SMS, WhatsApp | Customer |
| Payment link | SMS, WhatsApp | Customer |
| Direct message | Push | Driver (individual) |
| Global message | Push | All drivers |

### 6.2 Message Templates

Templates support variables:
- `{PassengerName}`, `{PickupAddress}`, `{DestinationAddress}`
- `{PickupDateTime}`, `{DriverName}`, `{RegNo}`
- `{Price}`, `{PaymentLink}`, `{BookingId}`

Templates are tenant-configurable.

---

## 7. Payment Link Rules

### 7.1 Flow

1. Operator clicks "Send Payment Link" on booking detail
2. System creates Revolut payment order for `Price` amount
3. Payment link URL is stored on booking (`PaymentLink`)
4. Link is sent to customer via SMS/WhatsApp
5. `PaymentLinkSentBy` and `PaymentLinkSentOn` are recorded
6. Customer pays via Revolut hosted page
7. Revolut webhook updates `PaymentStatus` to Paid
8. Operator can "Resend" the link if needed
9. Once paid, operator can "Send Payment Receipt" to customer

### 7.2 Payment Statuses

| Status | Meaning |
|--------|---------|
| Select (0) | No payment action taken |
| Paid (2) | Payment received |
| Pending (3) | Payment link sent, awaiting payment |

---

## 8. Account Invoicing Rules

### 8.1 Invoice Generation Flow

1. At end of billing period, operator opens Accounts module
2. Selects account and date range
3. System shows all chargeable jobs (scope = Account, not yet posted for invoicing)
4. Operator reviews and can adjust individual job prices
5. "Post" jobs marks them ready for invoicing (`PostedForInvoicing = true`)
6. "Create Invoice" generates an `AccountInvoice` record with PDF
7. Invoice is emailed or downloaded

### 8.2 Driver Statements

Similar flow for driver settlements:
1. Select driver and date range
2. Show completed jobs
3. Post jobs for statement (`PostedForStatement = true`)
4. Generate `DriverInvoiceStatement` with PDF
5. Commission is calculated at this point: `DriverCommission = Price × CommissionRate`

### 8.3 Credit Notes

Invoices can be credited (partially or fully). Creates a `CreditNote` linked to the original invoice.

---

## 9. Web Booking Rules

### 9.1 Customer Types

| Type | Auth | Capabilities |
|------|------|-------------|
| Cash customer | Anonymous (rate-limited) | Submit booking, receive quote |
| Account customer | Authenticated (JWT) | Submit booking, view active bookings, request amendments, request cancellations, select from passenger list |

### 9.2 Web Booking Flow

1. Customer submits booking via web form
2. Creates `WebBooking` record (status: Default)
3. Operator sees pending web booking in dispatch console
4. Operator reviews and either:
   - **Accept** → converts to real `Booking`, customer notified
   - **Reject** → customer notified with reason
5. Accepted bookings follow normal dispatch flow

### 9.3 Amendments & Cancellations

Account customers can request changes to existing bookings. These create `WebAmendmentRequest` records that operators review and accept/reject.

---

## 10. Partner Network / Job Sharing Rules

### 10.1 Partner Relationship Setup

Partners are other taxi companies on the Red Taxi platform. Each partner relationship is bilateral — Tenant A partners with Tenant B, creating two PartnerRelationship records (one per direction). Each side defines their own coverage rules and commercial terms.

### 10.2 Cover Request Rules

| Rule | Description |
|------|-------------|
| Eligibility | Only bookings from tenant's own customers can be offered for cover |
| Data exposure | Partner sees: pickup, destination, time, vehicle requirement, passenger count. Does NOT see: customer phone/email, account details, pricing to customer |
| Timeout | Cover request expires if not accepted within configurable timeout (default 15 min) |
| Broadcast vs directed | Configurable: offer to specific partner (priority order) or broadcast to all partners |
| Auto-escalation | If no internal driver available within X minutes, system can auto-create cover request |

### 10.3 Settlement Rules

Each partner relationship defines a settlement model:

| Model | Description | Example |
|-------|-------------|---------|
| Referral fee | Source pays fixed fee per job | Source pays partner £5 per job |
| Percentage split | Source keeps %, partner gets % | Source keeps 15%, partner gets 85% of fare |
| Net fulfilment | Partner quotes their price, source marks up | Partner charges £30, source charges customer £38 |
| Pass-through | Account rate applies, split agreed separately | For shared account customers |

Settlement records are created on job completion and feed into inter-company invoicing.

### 10.4 Substitute vs Partner — Key Differences

| Aspect | Substitute Driver | Partner Coverage |
|--------|------------------|-----------------|
| Control | Tenant dispatches directly | Partner tenant dispatches their own driver |
| Visibility | Full visibility (like own driver) | Limited visibility (booking progress only) |
| Settlement | Same as own driver (commission model) | Inter-company settlement per agreed terms |
| Reporting | Appears in tenant's driver reports (flagged) | Appears in partner reports separately |
| Permissions | Operates under tenant's rules | Operates under partner's rules |

---

## 11. Dispatch Scoring Rules

### 11.1 Scoring Gates (must pass)

- Driver availability: must be in Available state
- Vehicle compatibility: must match booking requirements (vehicle type, capacity, wheelchair, etc.)
- Shift status: must have remaining hours if shift tracking enabled

### 11.2 Scoring Factors (weighted)

| Factor | Weight | Description |
|--------|--------|-------------|
| Distance to pickup | 30% | Closer = higher score |
| ETA to pickup | 25% | Faster = higher score |
| Workload balance | 15% | Fewer recent jobs = higher score (fairness) |
| Customer affinity | 10% | Repeat customer's preferred driver gets bonus |
| Priority handling | 10% | High-priority bookings boost nearby drivers |
| Decline penalty | 10% | Recently declined jobs reduce score |

Weights are tenant-configurable. Operators always see the top 3 recommendations but can override.

### 11.3 Auto-Dispatch Rules (Phase 3+)

- Configurable per tenant: manual only, assisted (show suggestions), or auto (system assigns)
- Auto-dispatch only fires if top candidate score exceeds confidence threshold
- Auto-assigned driver must respond within timeout (configurable, default 2 min)
- If no response, job falls back to next candidate or operator queue

---

## 12. WhatsApp Chatbot Rules (Phase 2+)

### 12.1 Conversation Flow

1. Customer sends any message to tenant's WhatsApp number
2. Bot replies with greeting + "Where would you like to be picked up?"
3. Customer provides pickup (free text) → bot extracts/validates address
4. Bot asks "Where are you going?"
5. Customer provides destination → bot extracts/validates
6. Bot calls pricing engine → replies with quote
7. Customer confirms ("yes" / "book it" / etc.)
8. Bot creates WebBooking, sends confirmation with booking reference
9. On allocation: bot sends driver details to customer in same thread
10. On arrival: bot notifies customer

### 12.2 Fallback Rules

- If bot can't extract a valid address after 2 attempts → hand off to operator
- If customer asks a question the bot can't handle → hand off to operator
- Operator can take over any conversation at any time
- Bot logs full conversation for audit

### 12.3 Tenant Configuration

- Enable/disable chatbot per tenant
- Custom greeting message
- Auto-accept bookings or require operator approval
- Operating hours (outside hours: bot takes booking, flags for next-day confirmation)

---

## 13. Account Web Booker Portal (from desktop screenshots)

The account customer portal is a separate branded web app.

### Portal Home
Five main actions available to account customers:
1. **Create New Booking** — booking form with Address/Existing Passenger toggle
2. **Booking Request History** — paginated table of all submitted bookings (Accepted/Rejected status, Duplicate button)
3. **Active Bookings** — table of upcoming bookings with Amend and Cancel This Only buttons
4. **Add New Passenger** — create named passengers with description, address, postcode, phone, email
5. **Existing Passengers** — searchable passenger list (name, description, address, postcode, phone, actions)

### Account Login
Authenticated via Account Number + Password (not email-based). Tenant-branded login page.

### Booking Form (Account Portal)
- Pickup Time / Arrived By radio toggle
- Date and Time pickers
- Repeat Booking button + Return toggle
- Address entry: toggle between "Address" (manual) and "Existing Passenger" (select from passenger list — auto-fills address)
- Pickup address, postcode, destination address, postcode
- Swap addresses button
- Booking details (free text)
- Name, Email, Phone, Passengers dropdown
- Cancel / Send buttons

### Passenger Management
Account customers manage their own passenger lists:
- Passenger Name (required)
- Description (required — e.g. "Home Address", "Office")
- Address + Postcode (required)
- Phone + Email (optional)
- Passengers can be deleted from the list

This maps to the `AccountPassenger` entity. Each passenger effectively acts as a saved address with contact details.

### Booking Request Status
Web bookings submitted by accounts go through the approval flow:
- **Accepted** — converted to real booking, enters dispatch
- **Rejected** — with reason communicated to account customer
- Accepted bookings can be duplicated from history

### Active Booking Actions
- **Amend** — submit amendment request (operator reviews)
- **Cancel This Only** — cancel individual booking (for recurring bookings, only cancels the selected instance)

---

## 14. Phone Lookup / Caller ID Pop Rules

### Lookup Flow (from desktop screenshots)
1. Phone number entered or detected via caller ID
2. System searches bookings by phone number
3. Popup shows: caller number, two tabs (Current Bookings / Previous Bookings)
4. **Current Bookings** tab: today's and future bookings for this number
5. **Previous Bookings** tab: historical bookings with date, pickup, destination, name, price
6. Operator can select any previous booking row and click **Confirm** to create a repeat booking with same addresses
7. **Close** dismisses without action

### Search Bookings (from desktop screenshots)
Advanced search modal with fields:
- Booking ID
- Pickup Address + Pickup Postcode
- Destination Address + Destination Postcode
- Passenger name
- Phone Number
- Details (free text)

All fields are optional — search matches any combination provided.

---

## 15. Rank Job Workflow

Rank work is when a driver waits at a taxi rank and picks up a passenger directly (no pre-booking).

### Flow
1. Driver at taxi rank picks up a passenger
2. Driver records the job in the system (enters destination, passenger details)
3. Driver enters the final price after completing the journey
4. Job is logged as Scope = Rank
5. Operator takes commission from the driver at settlement time (same as cash jobs)

Rank jobs are effectively driver-created bookings. The dispatch system does not allocate these — the driver self-reports them.

---

## 16. Dispatch Board Visual Behaviour

The scheduler/diary view uses visual cues to show booking status:

| State | Visual | Description |
|-------|--------|-------------|
| Unallocated | Orange/brown block | No driver assigned |
| Allocated | Driver's colour (solid fill) | Assigned to driver, not yet accepted |
| Accepted | Driver's colour + crosshatch pattern | Driver accepted the job |
| Rejected | `[R]` prefix on booking text | Driver rejected — should show WHICH driver |
| Timed out | `[RT]` prefix on booking text | Driver did not respond within timeout |
| Completed | Driver's colour + striped/hatched pattern | Job finished |
| COA | Red banner at top of day | Cancel on arrival — shows passenger name |

Each driver has a unique `ColorCodeRGB` value used throughout the dispatch board.

**Improvement for Red Taxi:** When a job is rejected, show which driver rejected it (e.g. `[R: Andy Owen]`) so the operator knows who to follow up with.

---

## 17. Driver Job Offer Channels

Jobs can be offered to drivers through three distinct channels:

### 1. Local SMS Gateway (Legacy)
- Backend publishes message to RabbitMQ
- Android device polls queue every ~30 seconds
- Android sends SMS to driver
- Used because it's cheaper than provider SMS
- **Red Taxi:** Replace with direct Twilio SMS or keep as cost-saving option for tenants

### 2. WhatsApp via Twilio
- Driver receives formatted WhatsApp message with job details
- Driver replies with text: "Accept" or "Reject"
- System parses reply and updates booking state
- Managed via `WhatsAppController.RecieveReply`

### 3. Push Notification (Driver App)
- FCM push notification sent to driver's registered device
- Driver opens app, sees job details, taps Accept or Reject
- Most reliable channel for real-time response

Tenants configure which channels to use per event type via `MessagingNotifyConfig`.

---

## 18. Job Offer Retry Behaviour

When a driver doesn't respond to a job offer, the system can retry.

### Configurable Settings (per tenant)
- **Retry count**: number of attempts (default: 3)
- **Retry delay**: seconds between attempts (default: 30)
- **Retry enabled**: toggle on/off

### Escalation
- If driver ignores all retries → job returned to unallocated pool
- If driver repeatedly rejects or ignores jobs → driver may be **temporarily banned** from receiving offers
- Ban duration and threshold configurable per tenant

### Logging
Every offer attempt is logged:
- Which driver was offered
- Which channel (SMS/WhatsApp/Push)
- Offer timestamp
- Response (Accept/Reject/Timeout)
- Response timestamp

This feeds into the `JobOffer` and `TurnDown` tables.

---

## 19. Configurable Driver Status Flow

Different tenants (or even different accounts within a tenant) may require different driver status progressions.

### Minimal Flow
```
Accept → Complete
```
Used by: small operators, cash jobs, simple workflows.

### Extended Flow
```
Accept → On Route → Arrived → Passenger Onboard → Complete
```
Used by: account customers, airport transfers, compliance-heavy contracts.

### Configuration
- Tenant-level default flow
- Account-level override (some accounts mandate full status tracking)
- Driver app adapts to show only the required status buttons

---

## 20. Account Invoice Batch Processing

### Batch Pricing Logic
When generating invoices for account customers, the system groups journeys by:
- Passenger name
- Pickup postcode area
- Journey grouping rules (e.g. same route = combine)

### Draft Review
1. Operator selects account + date range
2. System generates draft invoice with grouped journeys
3. Operator reviews and can adjust individual line items
4. Operator approves → invoice finalised and PDF generated
5. Invoice sent to account contact

### Rebilling
If a journey was incorrectly priced or credited:
1. Credit note issued against original invoice
2. Journey can be rebilled at corrected price
3. New invoice generated for rebilled journeys
4. Full audit trail maintained

---

## 21. Card Processing Fee Handling

When customers pay via card (payment link):
- Revolut/Stripe charges a processing fee
- This fee is deducted from the **driver's balance** (not the operator)
- System must track:
  - Tenant-level card fee percentage
  - Per-transaction fee amount
  - Driver deduction records
  - Net driver payout after fees

---

## 22. Actual Ace Tariff Configuration (from screenshots)

The legacy Ace system has exactly three tariffs:

| Tariff | Name | When | Initial Charge | First Mile | Additional Mile |
|--------|------|------|---------------|------------|-----------------|
| Tariff 1 | Day Rate | 7am to 10pm | £0.00 | £4.80 | £3.00 |
| Tariff 2 | Day Rate | 10pm to 7am, Sundays, Bank Holidays (except where T3 applies) | £0.00 | £7.20 | £4.50 |
| Tariff 3 | Day Rate | Christmas Day, Boxing Day, New Years Day, plus from 6pm on Christmas Eve and New Years Eve | £0.00 | £9.60 | £6.00 |

### Tariff Selection Logic
- System determines which tariff applies based on the booking pickup date/time
- Time-of-day and day-of-week rules determine Tariff 1 vs 2
- Specific holiday dates trigger Tariff 3 (overrides T1 and T2)
- Account tariffs can override these defaults entirely

### Price Formula (confirmed from tariff data)
```
Price = InitialCharge + FirstMileCharge + (AdditionalMiles × AdditionalMileCharge)
```
Where:
- First mile is charged at the FirstMileCharge rate
- Every mile after the first is charged at AdditionalMileCharge
- No initial charge in current Ace config (but field exists for other tenants)

---

## 23. Availability Preset Types

From the Availability page, operators can set availability using preset buttons:

| Preset | Description |
|--------|-------------|
| Custom | Operator enters custom time range |
| SR AM Only | School run AM shift only |
| SR PM Only | School run PM shift only |
| SR Only | School run (both AM and PM) |
| UNAVAILABLE (ALL DAY) | Driver marked unavailable for entire day |

### Multiple Blocks Per Driver
A driver can have multiple availability blocks on the same day. Example:
- Jean Williams: 07:30-09:15 (AM SR) + 14:30-16:15 (PM SR)

### Availability Tags
Each block can have descriptive tags shown in the Details column:
- `(AM School Only)` — morning school run only
- `(Custom Set Manually)` — operator override
- `(+/-)` — approximate/flexible times
- `(AM SR)` — AM school run
- `(PM SR)` — PM school run

### Availability Audit Log
Every availability change is logged: Date, The Change description, Changed On timestamp, Changed by User, Driver #. Filterable by driver and date.

---

## 24. Driver Messaging

### Direct Message (to selected drivers)
- Modal shows all drivers with colour-coded rows and checkboxes
- Operator can multi-select drivers (searchable list)
- Enter message text
- Send Message → delivers via configured channel (Push/SMS/WhatsApp)

### Global Message (broadcast to all drivers)
- Simple modal: message text + Send Message
- Sends to ALL active drivers simultaneously

---

## 25. Account Tariff Configuration (from screenshots)

Account tariffs have **separate rates for account price and driver price** — this is how the dual-price model works in practice.

### Actual Ace Account Tariffs

| Name | Acc Initial | Driver Initial | Acc First Mile | Driver First Mile | Acc Additional Mile | Driver Additional Mile |
|------|-------------|---------------|----------------|-------------------|---------------------|----------------------|
| Meter + Admin | £5.00 | £4.00 | £2.00 | £1.40 | £3.15 | £2.35 |
| Meter Tariff | £0.00 | £0.00 | £5.00 | £4.08 | £3.00 | £2.55 |
| School Tariff | £0.00 | £0.00 | £4.80 | £4.80 | £3.00 | £2.20 |

### Key Insight
Each account tariff defines TWO price curves: what the account pays and what the driver earns. The difference is the operator margin. This is calculated per-mile, not as a flat percentage. For example on Meter + Admin: account pays £3.15/additional mile, driver gets £2.35 — that's a £0.80/mile operator margin.

This confirms the pricing model: account tariffs override the default tariffs AND define the driver/account split at the tariff level, not per-booking.

---

## 26. Invoice Processor Detail (from screenshots)

### Invoice Processor (Individual Jobs)
Filter by: Account dropdown, Date Range, Auto Email Invoices toggle.

Job table columns: Date, Acc#, Driver#, Pickup, Destination, Passenger, Pax, Has Vias, Waiting, Waiting Charge, Actual Miles, Driver £, Journey Charge, Parking, Total, Price.

Per-row actions: Post (green grid icon), Email (blue envelope), Cancel (red trash).

"Post All Priced" button to batch-post all priced jobs.

Expandable rows show: Booking #, Vias list, Details.

### Invoice Processor (Grouped — "Grp")
Two modes: **Singles** and **Shared**.

**Singles tab**: Groups jobs by passenger name. Expandable passenger rows showing their individual journeys. Columns: Id#, Date, Acc#, Driver#, Pax, Vias, Waiting, Wait. Charge, Actual Miles, Driver £...

**Shared tab**: Groups jobs by **route** (Pickup ↔ Destination). Shows route as expandable header (e.g. "6 COBHAM ROAD, BLANDFORD FORUM ↔ HARBOUR VALE SCHOOL, SHERBORNE"). Each route group has "Price All" and "Post All Priced" buttons. Expanded rows show: Id#, Date, Acc#, Passengers, PAX, Pickup, Destination, Driver#, Vias, Journey Miles, Vias Count, Driver, Account Price, Cancel.

This is the batch grouping logic — shared rides on the same route can be priced together at a group rate.

---

## 27. Billing & Payments Navigation (from screenshots)

```
Billing & Payments
├── Driver
│   ├── Statement Processing
│   └── Statement History
└── Account
    ├── Invoice Processor          ← individual job pricing + posting
    ├── Invoice Processor (Grp)    ← grouped by passenger (Singles) or route (Shared)
    ├── Invoice History
    ├── Credit Invoice
    ├── Credit Journeys
    └── Credit Notes
```

---

## 28. Message Settings Configuration (from screenshots)

Each messaging event has three channel options: **None**, **WhatsApp**, **Text Message** (radio buttons — one channel per event).

### Configured Events (Ace current settings)

| Event | Current Channel |
|-------|----------------|
| DRIVER - ON ALLOCATE | WhatsApp |
| DRIVER - UN-ALLOCATE | WhatsApp |
| DRIVER - ON AMEND BOOKING | Text Message |
| DRIVER - ON CANCEL BOOKING | Text Message |
| CUSTOMER - ON ALLOCATE | Text Message |
| CUSTOMER - UN-ALLOCATE | Text Message |
| CUSTOMER - ON AMEND BOOKING | None |
| CUSTOMER - ON CANCEL BOOKING | (visible, likely None or Text) |

Each event is independently configurable. This maps directly to the `MessagingNotifyConfig` entity.

---

## 29. Repeat Booking Recurrence (from screenshots)

When the "Repeat Booking" toggle is enabled, a modal appears with:

### Frequency (dropdown)
- **Daily** — no day selector shown
- **Weekly** — day selector shown (M T W T F S S toggle buttons)
- **Fortnightly** — day selector shown (same as weekly)

### Days (toggle buttons, shown for Weekly and Fortnightly only)
Seven circular toggle buttons: M T W T F S S. All selected (red) by default. Operator deselects days that don't apply. For example, school runs would select M T W T F only.

### Repeat End (dropdown)
- **Never** — bookings repeat indefinitely (operator must cancel range to stop)
- **Until** — enables the Repeat End Date field

### Repeat End Date
- Date picker (dd/mm/yyyy format)
- Only active when Repeat End = "Until"

### Buttons
- **Confirm** (red) — generates all booking instances
- **Cancel** (dark grey) — closes modal without creating

### Generation Logic
On confirm, the system generates individual booking records for each matching date:
- Daily: every day from booking date until end date (or indefinitely)
- Weekly: every selected day each week
- Fortnightly: every selected day every two weeks
- Each generated booking is independent — can be individually amended, cancelled, or allocated
- All share a `RecurrenceGroupId` linking them to the original repeat booking
- Cancel Range can target all bookings in a recurrence group

---

## 30. Soft Allocate vs Hard Allocate

| Aspect | Soft Allocate | Hard Allocate |
|--------|--------------|---------------|
| Driver notified? | No | Yes (via configured channel) |
| Diary appearance | Shows on diary in driver's colour | Same |
| Customer notified? | No | Yes (via configured channel) |
| Can be reassigned? | Yes, freely | Yes, but triggers un-allocate notification |
| Confirmation | Requires explicit "Confirm SA" action (batch or individual) | Immediate |

**Workflow:**
1. Operator drags/assigns bookings to drivers throughout the day (soft allocate)
2. Bookings appear on the diary in the driver's colour but no notifications sent
3. When ready, operator clicks "CONF. SA" button in top bar
4. All soft-allocated bookings for that day are confirmed → drivers and customers notified
5. Individual bookings can also be confirmed one at a time

This is essential for school runs where operators plan the entire day's routes before notifying drivers.

---

## 31. Commission Model

- Commission rate is **per-driver** (stored on driver profile as a percentage)
- Applied to **cash** and **rank** jobs at settlement
- **Account jobs** may or may not be subject to commission — configurable per account or per booking
- Commission is deducted from the driver's weekly settlement balance
- Dashboard shows separate columns: Cash Comms, Rank Comms, Total Comms

### Calculation
```
Commission = JobPrice × (DriverCommissionRate / 100)
```

For account jobs where commission does not apply, the driver receives the Driver Price from the account tariff directly (no commission deduction).

---

## 32. Driver Settlement

- **Period:** Weekly
- **Statement Processing** page lets the operator generate statements for a date range
- Statement includes: all completed jobs, earnings breakdown (cash/account/rank), commission deductions, card fee deductions, expenses, net payout
- **Statement History** stores all generated statements
- PDF generated via QuestPDF and optionally emailed to driver

---

## 33. Card Payment Flow (Revolut)

1. Operator creates booking and selects "Card" payment type (or sends payment link post-booking)
2. System calls Revolut API → receives `orderId` + `paymentUrl`
3. Payment link sent to customer via TextLocal branded SMS (branded as tenant company name, e.g. "Ace Taxis")
4. Customer clicks link → pays via Revolut checkout
5. Revolut sends webhook to Red Taxi API on payment completion
6. System automatically:
   - Updates booking payment status to Paid
   - Generates payment receipt PDF (QuestPDF)
   - Sends receipt to customer via SMS
7. Card processing fees tracked and deducted from driver balance at settlement

---

## 34. Fixed Price Journeys (New Implementation)

The legacy system had a partial zone-to-zone implementation. Red Taxi will implement a proper fixed pricing system:

### Route-Based Fixed Prices
- Operator defines fixed-price routes: specific pickup area → specific destination area
- Areas defined by postcode prefix (e.g. SP8 → BRS for Gillingham to Bristol Airport)
- When a booking matches a fixed-price route, the fixed price overrides tariff calculation
- Operator can still manually override the fixed price

### Zone-to-Zone Grid (Future Enhancement)
- Define zones by postcode prefix groups
- Price matrix: Zone A → Zone B = £X
- Useful for airport runs, station transfers, regular school routes

### Priority Order for Price Calculation
1. Manual override (`ManuallyPriced = true`) — always wins
2. Fixed-price route match — if one exists for this pickup→destination
3. Account tariff — if booking is for an account with a custom tariff
4. Standard tariff (T1/T2/T3) — default fallback

---

## 35. ASAP Booking

When the ASAP toggle is enabled on the booking form:

- Booking date/time is set to NOW
- Booking appears on the diary at the current time slot, flagged as urgent
- Visual indicator on diary (e.g. flashing border, urgent icon, or distinct colour)
- Operator still manually allocates — ASAP does NOT trigger auto-dispatch in v1
- Auto-dispatch for ASAP bookings is a Phase 5+ AI feature

---

## 36. Waiting Time & Parking Charges

- **Entered by:** Driver, at job completion via the driver app
- **Waiting time:** Driver enters minutes waited. Charged at a per-minute rate (configurable per tenant)
- **Parking:** Driver enters parking cost as a fixed amount
- **Both added to the booking total** and appear on the invoice
- **Operator can override** waiting time and parking during invoice processing
- Invoice Processor shows: Waiting (minutes), Waiting Charge (£), Parking (£) columns

---

## 37. Arrive By vs Pickup Time

The web booker (and booking form) has a toggle between two modes:

- **Pickup Time:** "Collect me at 14:00" — driver arrives at 14:00
- **Arrive By:** "I need to be there by 14:00" — system back-calculates pickup time using Google Distance Matrix journey duration. If journey is 30 minutes, pickup time = 13:30

The calculated pickup time is what appears on the diary and is sent to the driver. The "Arrive By" time is stored on the booking for reference.

---

## 38. Booking Status State Machine

```
Created → Allocated → Accepted → OnRoute → Arrived → PassengerOnboard → Completed
                                                                      → COA (Cancel on Arrival)
Created → Cancelled
Allocated → Unallocated → (back to Created)
Allocated → Rejected → (back to Created, driver gets [R] prefix)
Allocated → Timeout → (back to Created, driver gets [RT] prefix)
```

A completed booking CANNOT be reopened. If there's an error, a credit note is issued against the invoice.

---

## 39. Account Invoice Grouping Rules (Shared Tab)

The Invoice Processor (Grp) "Shared" tab groups bookings by route for batch pricing. Matching rules:

- **Exact match** on normalised pickup address AND normalised destination address
- Addresses are normalised (uppercase, trimmed, postcode extracted)
- Same account number required
- Date range filter applied
- Each route group shows "Price All" (apply account tariff to all) and "Post All Priced" (batch post)
- Via stops do NOT affect grouping — only the primary pickup and destination matter

---

## 40. Driver Colour Assignment

- Each driver has a unique colour stored on their profile (`Colour` field)
- Colour is set by the operator when creating/editing the driver
- Used for: diary booking blocks, availability grid rows, driver message list, dispatch board
- No auto-assignment from a palette — operator picks the colour
- Colour must be unique per tenant to avoid confusion on the diary

---

## 41. Notification Sounds

The dispatch console plays audio alerts for different event types:

| Sound File | Trigger |
|-----------|---------|
| `new_web_booking.mp3` | New web booking submitted by account customer |
| `driver_audio.mp3` | Driver-related event (job offer response, status change) |
| `system_audio.mp3` | System alert (SMS heartbeat failure, error) |
| `notification_ping.mp3` | General notification (booking amendment, message received) |

Sounds play via browser audio API. Controlled by the Notifications and Mute Notifications toggles in user settings.

---

## 42. Message Templates (Default Content)

Each messaging event sends a templated message. Variables are injected at send time. These are the defaults — configurable per tenant in Message Settings.

### Driver Messages

**DRIVER - ON ALLOCATE:**
```
Job #{BookingId}: {PickupTime} from {PickupAddress} to {DestinationAddress}. Pax: {Passengers}. {PassengerName} {PassengerPhone}. {BookingDetails}
```

**DRIVER - UN-ALLOCATE:**
```
Job #{BookingId} at {PickupTime} has been unallocated from you.
```

**DRIVER - ON AMEND BOOKING:**
```
Job #{BookingId} amended: {PickupTime} from {PickupAddress} to {DestinationAddress}. Pax: {Passengers}.
```

**DRIVER - ON CANCEL BOOKING:**
```
Job #{BookingId} at {PickupTime} from {PickupAddress} has been cancelled.
```

### Customer Messages

**CUSTOMER - ON ALLOCATE:**
```
Your taxi is confirmed for {PickupTime}. Driver: {DriverName}, Vehicle: {VehicleReg} ({VehicleType}). Tracking: {TrackingUrl}
```

**CUSTOMER - UN-ALLOCATE:**
```
Update on your {PickupTime} booking from {PickupAddress}: we are reassigning your driver. We'll confirm shortly.
```

**CUSTOMER - ON AMEND BOOKING:**
```
Your booking has been updated: {PickupTime} from {PickupAddress} to {DestinationAddress}.
```

**CUSTOMER - ON CANCEL BOOKING:**
```
Your booking for {PickupTime} from {PickupAddress} has been cancelled.
```

### Template Variables Available
`{BookingId}`, `{PickupTime}`, `{PickupAddress}`, `{DestinationAddress}`, `{PassengerName}`, `{PassengerPhone}`, `{Passengers}`, `{BookingDetails}`, `{DriverName}`, `{DriverPhone}`, `{VehicleReg}`, `{VehicleType}`, `{VehicleColour}`, `{Price}`, `{CompanyName}`, `{TrackingUrl}`, `{PaymentUrl}`
