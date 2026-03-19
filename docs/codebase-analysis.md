# RedTaxi V2 Codebase Analysis

> Updated: 2026-03-19
> Source: src/RedTaxi.API, src/RedTaxi.Lib (formerly AceTaxis, renamed + OSS merged)
> Status: COMPILES (0 errors), running on localhost:5092

## Runtime: .NET 7 (upgrade to .NET 8 planned — IN01)

## Project Structure
```
src/
├── RedTaxi.API/        16 controllers, 237 endpoints, 20 files
├── RedTaxi.Lib/        17 services + 4 cache services, 36 entities, 308 files, ~147K lines
│   ├── Services/       Business logic (17 services)
│   ├── Modules/        Merged from OSS:
│   │   ├── Membership/ Auth, JWT, Identity (AppUser, AppRole, AppRefreshToken)
│   │   └── Messaging/  SMS, Push, config
│   ├── Integrations/   AWS (Dropbox storage)
│   ├── Data/           EF Core DbContext (RedTaxiDbContext), 36 entities
│   ├── DTOs/           Request/response objects
│   ├── PDF/            QuestPDF invoice/statement generation
│   └── Shared/         Extensions, base classes
└── RedTaxi.sln
```

## Controller Inventory (237 endpoints)

| Controller | Endpoints | Purpose |
|-----------|-----------|---------|
| AdminUIController | 56 | Admin panel backend (biggest — needs service extraction) |
| BookingsController | 40 | Booking CRUD + search |
| AccountsController | 38 | Account mgmt + invoicing + statements |
| DriverAppController | 30 | Driver mobile app API (needs service extraction) |
| WeBookingController | 19 | Web booker portal (needs service extraction) |
| UserProfileController | 14 | Driver/user profiles |
| ReportingController | 13 | All reports |
| AddressController | 6 | IdealPostcodes (primary) + Google Places (secondary) |
| CallEventsController | 6 | Caller ID / phone lookup (needs service extraction) |
| LocalPOIController | 6 | Points of interest |
| AvailabilityController | 2 | Driver availability |
| SmsQueController | 2 | SMS gateway queue |
| WhatsAppController | 2 | WhatsApp webhook |
| ATestController | 1 | Test endpoint |
| QRCodeClickCounter | 1 | QR tracking (extracted to UrlTrackingService ✅) |
| RedirectController | 1 | URL shortener (extracted to UrlTrackingService ✅) |

## Service Inventory (17 services + 4 cache)

| Service | Lines | Status |
|---------|-------|--------|
| AccountsService | 2,243 | ✅ Working |
| BookingService | 2,149 | ✅ Working |
| ReportingService | 1,257 | ✅ Working |
| UserProfileService | 1,058 | ✅ Working |
| DispatchService | 1,008 | ✅ Working |
| AceMessagingService | 877 | ✅ Working |
| TariffService | 702 | ✅ Working (hardcoded Distance Matrix key at line 466) |
| AvailabilityService | 489 | ✅ Working |
| AddressLookupService | 417 | ✅ Working (IdealPostcodes + Google Places) |
| UserActionsService | 379 | ✅ Working |
| RevoluttService | 276 | ✅ Working |
| AdminUIService | 249 | ✅ Working |
| DocumentService | 246 | ✅ Working (Dropbox) |
| UINotificationService | 184 | ✅ Working |
| LocalPOIService | 169 | ✅ Working |
| UrlTrackingService | NEW | ✅ Extracted from controllers |
| GoogleCalendarService | 104 | ✅ Working |
| GeoZoneService | 39 | ✅ Working |

## Recent Changes (2026-03-18)
1. OSS project merged into RedTaxi.Lib (Modules/Membership + Modules/Messaging)
2. Renamed AceTaxis → RedTaxi (namespaces, projects, DbContext)
3. Extracted UrlTrackingService from RedirectController + QRCodeClickCounter
4. Added structured logging (Serilog)
5. All regression tests passing (89 bookings, 29 drivers, £50 pricing)

## Verified Working (localhost:5092)
- Login: POST /api/UserProfile/Login → JWT token ✅
- Bookings: GET /api/Bookings/Today → 89 bookings ✅
- Pricing: POST /api/Bookings/GetPrice → £50 (SP8→DT9) ✅
- Drivers: GET /api/AdminUI/DriversList → 29 drivers ✅
- Address: GET /api/Address/DispatchSearch → 16 results ✅
- Swagger: 237 endpoints visible ✅
