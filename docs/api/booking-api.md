# Booking API

See [API README](README.md) for common patterns.

## Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | /bookings | Create booking |
| GET | /bookings/{id} | Get booking |
| PUT | /bookings/{id} | Update booking |
| POST | /bookings/{id}/cancel | Cancel booking |
| POST | /bookings/date-range | List by date range |
| POST | /bookings/get-price | Get quote |

## Create Booking

```http
POST /bookings
Content-Type: application/json

{
  "pickupDateTime": "2024-03-16T14:30:00Z",
  "pickupAddress": "123 High Street, London",
  "destinationAddress": "Heathrow Terminal 5",
  "passengerName": "John Smith",
  "passengerCount": 2,
  "phoneNumber": "07700900123"
}
```

_Full documentation TODO_
