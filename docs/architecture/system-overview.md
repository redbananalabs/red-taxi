> **⚠️ NOTE:** Any references to TenantId columns or global query filters in this document are from an earlier design. Red Taxi now uses **per-tenant databases** — see `docs/PRD.md §36`.

# System Overview

## Architecture Style

Clean Architecture with CQRS-lite pattern using MediatR.

```
┌─────────────────────────────────────────────────────────────┐
│                        Clients                               │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐    │
│  │ Operator │  │  Admin   │  │  Driver  │  │ Passenger│    │
│  │ Console  │  │  Portal  │  │   App    │  │  Booker  │    │
│  └────┬─────┘  └────┬─────┘  └────┬─────┘  └────┬─────┘    │
└───────┼─────────────┼─────────────┼─────────────┼──────────┘
        │             │             │             │
        └─────────────┴──────┬──────┴─────────────┘
                             │
┌────────────────────────────┼────────────────────────────────┐
│                    RedTaxi.API                               │
│  ┌─────────────┐  ┌────────┴───────┐  ┌─────────────────┐  │
│  │  Minimal    │  │    SignalR     │  │   Background    │  │
│  │  API        │  │    Hubs        │  │   Jobs          │  │
│  │  Endpoints  │  │                │  │   (Hangfire)    │  │
│  └──────┬──────┘  └───────┬────────┘  └────────┬────────┘  │
└─────────┼─────────────────┼────────────────────┼───────────┘
          │                 │                    │
          └─────────────────┼────────────────────┘
                            │
┌───────────────────────────┼────────────────────────────────┐
│                  RedTaxi.Application                        │
│  ┌────────────────────────┴────────────────────────────┐   │
│  │                    MediatR                           │   │
│  │  ┌──────────┐  ┌──────────┐  ┌──────────┐          │   │
│  │  │ Commands │  │ Queries  │  │ Events   │          │   │
│  │  │ Handlers │  │ Handlers │  │ Handlers │          │   │
│  │  └──────────┘  └──────────┘  └──────────┘          │   │
│  └─────────────────────────────────────────────────────┘   │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐     │
│  │    DTOs      │  │  Validators  │  │  Interfaces  │     │
│  └──────────────┘  └──────────────┘  └──────────────┘     │
└───────────────────────────┬────────────────────────────────┘
                            │
┌───────────────────────────┼────────────────────────────────┐
│                    RedTaxi.Domain                           │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐     │
│  │   Entities   │  │Value Objects │  │Domain Events │     │
│  └──────────────┘  └──────────────┘  └──────────────┘     │
│  ┌──────────────┐  ┌──────────────┐                       │
│  │    Enums     │  │ Exceptions   │                       │
│  └──────────────┘  └──────────────┘                       │
└───────────────────────────┬────────────────────────────────┘
                            │
┌───────────────────────────┼────────────────────────────────┐
│                 RedTaxi.Infrastructure                      │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐     │
│  │  EF Core     │  │    Redis     │  │  External    │     │
│  │  DbContext   │  │    Cache     │  │  Services    │     │
│  └──────────────┘  └──────────────┘  └──────────────┘     │
│  ┌──────────────┐  ┌──────────────┐                       │
│  │  SignalR     │  │  Hangfire    │                       │
│  │  Clients     │  │  Jobs        │                       │
│  └──────────────┘  └──────────────┘                       │
└────────────────────────────────────────────────────────────┘
```

## Project Structure

```
/src
  /RedTaxi.API
    /Endpoints
    /Hubs
    /Middleware
    /Extensions
    Program.cs
    
  /RedTaxi.Application
    /Bookings
      /Commands
      /Queries
      /Events
    /Drivers
    /Accounts
    /Dispatch
    /Common
      /Interfaces
      /Behaviours
      
  /RedTaxi.Domain
    /Entities
    /ValueObjects
    /Events
    /Enums
    /Exceptions
    
  /RedTaxi.Infrastructure
    /Persistence
      /Configurations
      /Migrations
    /Services
    /Caching
```

## Technology Stack

| Layer | Technology |
|-------|------------|
| Runtime | .NET 8 (LTS) |
| API | ASP.NET Core Minimal APIs |
| Mediation | MediatR |
| Validation | FluentValidation |
| ORM | Entity Framework Core 8 |
| Database | SQL Server / Azure SQL |
| Caching | Redis (StackExchange.Redis) |
| Real-time | SignalR |
| Background | Hangfire |
| Auth | ASP.NET Core Identity + JWT |

## Key Patterns

### One Handler Per Use Case
Each business operation has its own MediatR handler. No god services.

```csharp
// Good
CreateBookingCommand → CreateBookingHandler
AllocateDriverCommand → AllocateDriverHandler

// Bad
BookingService.Create()
BookingService.Update()
BookingService.Allocate()
```

### Domain Events
Side effects triggered by domain events, not direct calls.

```csharp
// When booking is created
BookingCreatedEvent → SendConfirmationHandler
BookingCreatedEvent → UpdateSchedulerHandler
BookingCreatedEvent → LogAuditHandler
```

### Global Query Filters
Tenant isolation via EF Core filters.

```csharp
modelBuilder.Entity<Booking>()
    .HasQueryFilter(b => b.TenantId == _tenantId);
```

## Cross-Cutting Concerns

| Concern | Implementation |
|---------|---------------|
| Logging | Serilog |
| Validation | FluentValidation pipeline |
| Caching | Redis + memory |
| Exceptions | Global handler middleware |
| Transactions | Unit of work pattern |
| Audit | Domain events |

## Related Documents

- [Services](services.md)
- [Multi-tenant Design](multi-tenant-design.md)
- [Event Model](event-model.md)
