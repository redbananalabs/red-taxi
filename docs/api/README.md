# API Reference

Red Taxi Platform REST API documentation.

## Base URL

```
Production: https://api.redtaxi.io/v1
Staging: https://api.staging.redtaxi.io/v1
```

## Authentication

All API requests require a Bearer token:

```
Authorization: Bearer {access_token}
```

See [Authentication](authentication.md) for details.

## Endpoints

| Section | Description |
|---------|-------------|
| [Authentication](authentication.md) | Login, tokens, refresh |
| [Booking API](booking-api.md) | Booking CRUD |
| [Driver API](driver-api.md) | Driver management |
| [Dispatch API](dispatch-api.md) | Job allocation |
| [Account API](account-api.md) | Corporate accounts |
| [Webhooks](webhooks.md) | Event notifications |

## Response Format

All responses follow:

```json
{
  "status": "success",
  "data": { ... },
  "meta": {
    "timestamp": "2024-03-16T10:30:00Z"
  }
}
```

## Error Format

```json
{
  "status": "error",
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Invalid pickup address",
    "details": { ... }
  }
}
```

## Rate Limits

| Plan | Requests/min |
|------|--------------|
| Starter | 60 |
| Pro | 300 |
| Enterprise | 1000 |
