# AceTaxis Codebase Analysis

> Analysed: 2026-03-18
> Source: legacy/AceTaxis.Lib, legacy/AceTaxisAPI, legacy/OSS
> Status: COMPILES (0 errors, 1099 nullable warnings)

## Runtime: .NET 7 (upgrade to .NET 8 needed for LTS support)

## Project Dependency Graph
```
OSS (.NET 7)
├── IdentityDbContext base (AppUser, AppRole, AppRefreshToken)
├── Shared extensions, membership module
├── Controllers: Auth, Messaging, Users
└── Modules: Messaging (Push), Storage (AWS)
    ↑
AceTaxis.Lib (.NET 7, 288 files, 147,157 lines)
├── 17 services, 36 entities, EF Core 7
├── References: OSS, AutoMapper, Dropbox, QuestPDF, RabbitMQ, RestSharp, Google Calendar
└── Key services: BookingService (2,149), AccountsService (2,243), TariffService (702)
    ↑
AceTaxisAPI (.NET 7, 20 files, 6,845 lines)
├── 16 controllers, 237 endpoints
└── References: AceTaxis.Lib, OSS
```

## Controller Inventory (237 endpoints)

| Controller | Endpoints | Purpose |
|-----------|-----------|---------|
| AdminUIController | 56 | Admin panel backend |
| BookingsController | 40 | Booking CRUD + search |
| AccountsController | 38 | Account mgmt + invoicing + statements |
| DriverAppController | 30 | Driver mobile app API |
| WeBookingController | 19 | Web booker portal |
| UserProfileController | 14 | Driver/user profiles |
| ReportingController | 13 | All reports |
| AddressController | 6 | Address autocomplete (IdealPostcodes + Google) |
| CallEventsController | 6 | Caller ID / phone lookup |
| LocalPOIController | 6 | Points of interest |
| AvailabilityController | 2 | Driver availability |
| SmsQueController | 2 | SMS gateway queue |
| WhatsAppController | 2 | WhatsApp webhook |
| ATestController | 1 | Test endpoint |
| QRCodeClickCounter | 1 | QR tracking |
| RedirectController | 1 | URL shortener |

## Service Inventory (11,846 lines)

| Service | Lines | Purpose |
|---------|-------|---------|
| AccountsService | 2,243 | Invoicing, statements, settlement |
| BookingService | 2,149 | Booking CRUD, pricing triggers |
| ReportingService | 1,257 | All 13 reports |
| UserProfileService | 1,058 | Driver/user management |
| DispatchService | 1,008 | Allocation, job offers |
| AceMessagingService | 877 | SMS/WhatsApp/Push dispatch |
| TariffService | 702 | Pricing engine (5-level priority) |
| AvailabilityService | 489 | Shift management |
| AddressLookupService | 417 | Dual: IdealPostcodes + Google Places |
| UserActionsService | 379 | Audit logging |
| RevoluttService | 276 | Payment links |
| AdminUIService | 249 | Admin UI helpers |
| DocumentService | 246 | Dropbox uploads |
| UINotificationService | 184 | In-app notifications |
| LocalPOIService | 169 | POI management |
| GoogleCalendarService | 104 | Calendar sync |
| GeoZoneService | 39 | Zone pricing |

## Entities (36)
Booking (60 fields), WebBooking (29), UserProfile (22), CompanyConfig (16),
Account (17), AccountInvoice, AccountPassenger, AccountTariff, AccountUserLink,
AppRefreshToken, BookingChangeAudit, BookingVia, COARecord, CreditNote,
DocumentExpiry, DriverAllocation, DriverAvailability, DriverAvailabilityAudit,
DriverExpense, DriverInvoiceStatement, DriverLocationHistory, DriverMessage,
DriverOnShift, DriverShiftLog, GeoFence, LocalPOI, MessagingNotifyConfig,
QRCodeClick, ReviewRequest, Tariff, TurnDown, UINotification, UrlMapping,
UserActionLog, UserDeviceRegistration, WebAmendmentRequest, ZoneToZonePrice.

## Secrets/Config (all in appsettings.json)

| Key | Status |
|-----|--------|
| SQL connection | ✅ Production string present |
| JWT secret | ✅ Present |
| Google Places API key | ✅ Present |
| IdealPostcodes API key | ✅ Present |
| TextLocal SMS | ✅ Present |
| SendGrid | ✅ Present |
| FCM push | ✅ Present |
| Twilio WhatsApp | ✅ Present |
| Sentry DSN | ✅ Present |
| Dropbox | ✅ Present |
| Distance Matrix | ⚠️ HARDCODED in TariffService line 466 |
| Redis | ✅ localhost |

## Key Findings

### Address Integration
- **IdealPostcodes**: Primary. Custom `IdealPostcodesClient` (73 fields in response)
- **Google Places**: Secondary. New API v1 (`places.googleapis.com/v1/places:autocomplete`)
- Both live in `AddressLookupService.cs` (417 lines)

### vs TaxiDispatch.Lib (older version)
AceTaxis.Lib is a refactored version — 6 services consolidated:
- CallEventsService → merged into controllers
- DriverAppService → merged into controllers
- SmsQueueService → replaced by AceMessagingService
- UrlTrackingService → removed
- WebBookingService → merged into controllers
- WhatsAppService → merged into AceMessagingService

Same 36 entities. Fewer services, consolidated messaging.

## Refactoring Notes
1. **Controllers contain business logic** — need to extract back to services
2. **OSS project** — contains shared code AceTaxis.Lib depends on. Merge eventually.
3. **.NET 7 → .NET 8** upgrade needed (7 is EOL)
4. **Distance Matrix key hardcoded** — extract to config
5. **Don't change controller paths or parameters** — frontends depend on them
