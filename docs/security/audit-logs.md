# Audit Logs

## Events Logged

- User login/logout
- Booking create/update/cancel
- Dispatch allocation
- Price overrides
- Settings changes

## Log Format

```json
{
  "timestamp": "2024-03-16T10:30:00Z",
  "tenantId": "...",
  "userId": "...",
  "action": "BOOKING_CREATED",
  "entityId": "...",
  "details": {}
}
```

_Full documentation TODO_
