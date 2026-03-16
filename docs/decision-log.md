# Decision Log

Architectural and technical decisions for Red Taxi Platform.

---

## ADR-001: Multi-tenant Database Strategy

**Date**: 2024-03-16  
**Status**: Accepted  
**Deciders**: Engineering Team

### Context
Need to decide how to isolate tenant data in a SaaS platform.

### Options Considered
1. **Database per tenant** - Complete isolation, complex ops
2. **Schema per tenant** - Good isolation, migration complexity
3. **Shared database with TenantId** - Simple ops, query filter isolation

### Decision
Option 3: Shared database with TenantId column and EF Core global query filters.

### Rationale
- Simpler operations at our scale (< 1000 tenants)
- Lower infrastructure cost
- Easier querying for analytics
- Can migrate large tenants to dedicated DB later if needed

### Consequences
- Must ensure TenantId is set on all writes
- Must test query filters thoroughly
- Noisy neighbour risk (mitigated by caching/indexing)

---

## ADR-002: Address Provider Strategy

**Date**: 2024-03-16  
**Status**: Accepted  
**Deciders**: Engineering Team

### Context
GetAddress.io service discontinued. Need new address lookup providers.

### Options Considered
1. **Google Places only** - Full featured, higher cost
2. **Ideal Postcodes only** - UK optimised, limited autocomplete
3. **Hybrid: Google Places + Ideal Postcodes** - Best of both

### Decision
Option 3: Hybrid approach with intelligent routing.

### Rationale
- Google Places for general address autocomplete
- Ideal Postcodes for postcode lookups (faster, cheaper)
- Cost optimisation through smart routing
- Fallback resilience

### Implementation
- Detect if input looks like UK postcode → route to Ideal
- Otherwise → route to Google Places
- Cache postcode lookups (24h TTL)
- Session tokens for Google to reduce billing

### Consequences
- Two integrations to maintain
- Slightly complex routing logic
- Better cost control
- More resilient system

---

## ADR-003: MediatR for Application Layer

**Date**: 2024-03-16  
**Status**: Accepted  
**Deciders**: Engineering Team

### Context
Original Ace system has 2000+ line service classes mixing concerns. Need better structure.

### Options Considered
1. **Traditional services** - Familiar, tends to grow unbounded
2. **MediatR handlers** - One handler per use case, explicit
3. **Minimal APIs direct** - Simple, but mixes concerns

### Decision
Option 2: MediatR with one handler per use case.

### Rationale
- Forces separation of concerns
- Each operation is explicit and testable
- Pipeline behaviours for cross-cutting concerns
- Prevents god services

### Pattern
```
CreateBookingCommand → CreateBookingHandler
UpdateBookingCommand → UpdateBookingHandler
AllocateDriverCommand → AllocateDriverHandler
```

### Consequences
- More files (one per operation)
- Learning curve for team
- Cleaner, more maintainable code
- Easier to test in isolation

---

## ADR-004: SignalR for Real-time Updates

**Date**: 2024-03-16  
**Status**: Accepted  
**Deciders**: Engineering Team

### Context
Dispatch console needs real-time updates for bookings and driver locations.

### Options Considered
1. **Polling** - Simple, high latency, wasteful
2. **Server-Sent Events** - One-way only
3. **SignalR** - Full duplex, .NET native
4. **Raw WebSockets** - Low level, more work

### Decision
Option 3: SignalR

### Rationale
- Native .NET integration
- Handles connection management
- Automatic fallbacks (WebSocket → SSE → Long Polling)
- Hub pattern fits our use case
- Built-in groups for tenant isolation

### Consequences
- Stateful connections (consider scaling)
- Need Redis backplane for multi-instance
- Higher memory per connection

---

## ADR-005: Domain Events for Side Effects

**Date**: 2024-03-16  
**Status**: Accepted  
**Deciders**: Engineering Team

### Context
When a booking is created, multiple things happen: send SMS, update scheduler, log audit. How to coordinate?

### Options Considered
1. **Direct calls in handler** - Simple, tightly coupled
2. **Domain events** - Decoupled, multiple handlers
3. **Message queue** - Async, complex

### Decision
Option 2: Domain events dispatched via MediatR.

### Rationale
- Decouples core logic from side effects
- Each side effect is its own handler
- Easy to add new side effects
- Can be made async later if needed

### Pattern
```csharp
// In CreateBookingHandler
await _mediator.Publish(new BookingCreatedEvent(booking));

// Separate handlers
BookingCreatedEvent → SendConfirmationSmsHandler
BookingCreatedEvent → UpdateSchedulerHandler
BookingCreatedEvent → LogAuditHandler
```

### Consequences
- Must be careful about transaction boundaries
- Side effects run in same transaction (for now)
- Can evolve to outbox pattern if needed

---

## Template for New Decisions

```markdown
## ADR-XXX: Title

**Date**: YYYY-MM-DD  
**Status**: Proposed | Accepted | Deprecated | Superseded  
**Deciders**: Names

### Context
What is the issue?

### Options Considered
1. **Option A** - Pros/cons
2. **Option B** - Pros/cons

### Decision
Which option and why.

### Rationale
Detailed reasoning.

### Consequences
What happens as a result.
```
