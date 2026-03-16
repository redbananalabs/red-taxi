# System Scope

## In Scope

### Core Operations
- Booking creation and management
- Real-time dispatch (manual, assisted, auto)
- Driver management and tracking
- Account customer management
- Pricing and quotes
- Payment processing
- Messaging (SMS, WhatsApp, email, push)
- Reporting and analytics

### Multi-tenancy
- Tenant provisioning
- Tenant-specific configuration
- Data isolation
- Custom branding
- Feature flags by plan

### Integrations
- Address lookup (Google Places, Ideal Postcodes)
- Mapping and routing (Google Maps)
- SMS (Twilio, TextLocal)
- WhatsApp Business API
- Payment processing (Revolut, Stripe)
- Push notifications (FCM)

### Applications
- Operator dispatch console (web)
- Admin portal (web)
- Driver app (mobile)
- Passenger booking portal (web)
- Public API

## Out of Scope (Phase 1)

### Deferred Features
- AI voice booking agent
- Autonomous vehicle support
- Multi-currency billing
- White-label mobile apps
- Offline mode for driver app

### Not Planned
- Vehicle maintenance scheduling
- HR/payroll management
- Customer loyalty programs
- Food delivery dispatch
- Courier/parcel delivery

## System Boundaries

### External Systems
| System | Integration Type | Direction |
|--------|-----------------|-----------|
| Google Places | REST API | Outbound |
| Ideal Postcodes | REST API | Outbound |
| Google Maps | REST API | Outbound |
| Twilio | REST API + Webhooks | Both |
| WhatsApp | REST API + Webhooks | Both |
| Revolut | REST API | Outbound |
| FCM | REST API | Outbound |
| CMAC | REST API | Both |

### Data Ownership
- All booking data owned by tenant
- Driver personal data subject to GDPR
- Payment data handled by processors (PCI compliance)
- Location data retained per policy

## Assumptions

1. Operators have stable internet connectivity
2. Drivers have smartphones (iOS 14+ / Android 10+)
3. UK market focus initially (GBP, UK addresses)
4. English language UI (i18n ready for future)

## Constraints

1. Must support existing Ace Taxis data migration
2. Must integrate with existing driver apps during transition
3. Real-time dispatch requires WebSocket support
4. GDPR compliance mandatory
