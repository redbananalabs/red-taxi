> **⚠️ NOTE:** References to TenantId columns in this document are from an earlier design. Red Taxi now uses **per-tenant databases** — entities do NOT have TenantId columns. See `docs/data-model/master-data-model.md` for the authoritative data model.

# Data Model

Core domain entities for Red Taxi Platform.

## Entity Index

| Entity | Description | Status |
|--------|-------------|--------|
| [Booking](booking.md) | Journey request | ✅ Complete |
| [BookingVia](booking-via.md) | Intermediate stops | 🔲 TODO |
| [BookingStatusHistory](booking-status-history.md) | Audit trail | 🔲 TODO |
| [Driver](driver.md) | Driver/User | 🔲 TODO |
| [Vehicle](vehicle.md) | Vehicle details | 🔲 TODO |
| [Account](account.md) | Corporate customer | 🔲 TODO |
| [AccountTariff](account-tariff.md) | Pricing rules | 🔲 TODO |
| [Tenant](tenant.md) | SaaS tenant | 🔲 TODO |
| [LocalPOI](local-poi.md) | Points of interest | 🔲 TODO |
| [Message](message.md) | SMS/Email log | 🔲 TODO |
| [Payment](payment.md) | Payment record | 🔲 TODO |
| [DispatchEvent](dispatch-event.md) | Dispatch audit | 🔲 TODO |

## Entity Relationships

```
Tenant (1) ──────────────────────────────────────────────────┐
   │                                                          │
   ├── (n) User/Driver                                        │
   │       └── (n) Booking (as driver)                        │
   │                                                          │
   ├── (n) Account                                            │
   │       ├── (1) AccountTariff                              │
   │       └── (n) Booking                                    │
   │                                                          │
   ├── (n) Booking                                            │
   │       ├── (n) BookingVia                                 │
   │       ├── (n) BookingStatusHistory                       │
   │       ├── (n) Message                                    │
   │       ├── (n) Payment                                    │
   │       └── (n) DispatchEvent                              │
   │                                                          │
   ├── (n) LocalPOI                                           │
   │                                                          │
   └── (n) AccountTariff                                      │
                                                              │
All entities have TenantId for isolation ─────────────────────┘
```

## Common Patterns

### Base Entity
```csharp
public abstract class BaseEntity
{
    public Guid Id { get; set; }
    public DateTimeOffset CreatedAt { get; set; }
    public DateTimeOffset UpdatedAt { get; set; }
}
```

### Tenant Scoped
```csharp
public interface ITenantScoped
{
    Guid TenantId { get; set; }
}
```

### Soft Delete
```csharp
public interface ISoftDelete
{
    bool IsDeleted { get; set; }
    DateTimeOffset? DeletedAt { get; set; }
}
```

## Conventions

- All IDs are `Guid`
- All timestamps are `DateTimeOffset` (UTC)
- All entities implement `ITenantScoped`
- Money stored as `decimal` (2 decimal places)
- Coordinates stored as `decimal` (6 decimal places)
