# Red Taxi Documentation

Central source of truth for the Red Taxi platform. This documentation supports developers, product designers, operators, and AI development agents.

## Documentation Index

### Product Requirements
- [Overview](prd/overview.md) - Executive summary
- [Product Vision](prd/product-vision.md) - What we're building and why
- [System Scope](prd/system-scope.md) - Boundaries and capabilities
- [User Types](prd/user-types.md) - Personas and roles
- [Roadmap](prd/roadmap.md) - Delivery phases
- [Future Features](prd/future-features.md) - Backlog and ideas

### Architecture
- [System Overview](architecture/system-overview.md) - High-level architecture
- [Services](architecture/services.md) - Service breakdown
- [Multi-tenant Design](architecture/multi-tenant-design.md) - Tenancy strategy
- [Event Model](architecture/event-model.md) - Domain events
- [Scaling Strategy](architecture/scaling-strategy.md) - Growth planning

### Features
- [Booking System](features/booking-system.md)
- [Dispatch System](features/dispatch-system.md)
- [Auto Dispatch](features/auto-dispatch.md)
- [Driver Management](features/driver-management.md)
- [Account Customers](features/account-customers.md)
- [Pricing Engine](features/pricing-engine.md)
- [Airport Bookings](features/airport-bookings.md)
- [Multi-company Support](features/multi-company-support.md)
- [Notifications](features/notifications.md)

### Workflows
- [Operator Booking](workflows/operator-booking-workflow.md)
- [Dispatch Workflow](workflows/dispatch-workflow.md)
- [Driver Job Lifecycle](workflows/driver-job-lifecycle.md)
- [Airport Run](workflows/airport-run-workflow.md)
- [Account Booking](workflows/account-booking-workflow.md)

### Data Model
- [Booking](data-model/booking.md)
- [Driver](data-model/driver.md)
- [Vehicle](data-model/vehicle.md)
- [Account](data-model/account.md)
- [Dispatch Event](data-model/dispatch-event.md)
- [Payment](data-model/payment.md)
- [Message](data-model/message.md)

### API
- [Authentication](api/authentication.md)
- [Booking API](api/booking-api.md)
- [Driver API](api/driver-api.md)
- [Dispatch API](api/dispatch-api.md)
- [Account API](api/account-api.md)
- [Webhooks](api/webhooks.md)

### Integrations
- [Google Places](integrations/google-places.md)
- [Ideal Postcodes](integrations/ideal-postcodes.md)
- [Twilio](integrations/twilio.md)
- [WhatsApp](integrations/whatsapp.md)
- [Revolut](integrations/revolut.md)
- [CMAC](integrations/cmac.md)

### Dispatch
- [Dispatch Modes](dispatch/dispatch-modes.md)
- [Auto Dispatch](dispatch/auto-dispatch.md)
- [Manual Dispatch](dispatch/manual-dispatch.md)
- [Job Offer Logic](dispatch/job-offer-logic.md)
- [Driver Selection](dispatch/driver-selection.md)

### AI Features
- [AI Voice Agent](ai/ai-voice-agent.md)
- [AI Dispatch Assistant](ai/ai-dispatch-assistant.md)
- [AI Demand Forecasting](ai/ai-demand-forecasting.md)

### UI Applications
- [Operator Dashboard](operator-ui/operator-dashboard.md)
- [Booking Screen](operator-ui/booking-screen.md)
- [Dispatch Board](operator-ui/dispatch-board.md)
- [Driver App](driver-app/README.md)

### Reporting
- [Driver Performance](reporting/driver-performance.md)
- [Revenue Reports](reporting/revenue-reports.md)
- [Booking Analytics](reporting/booking-analytics.md)

### Security & Compliance
- [GDPR](security/gdpr.md)
- [Audit Logs](security/audit-logs.md)
- [Permissions](security/permissions.md)

### Development
- [Coding Standards](dev/coding-standards.md)
- [Git Workflow](dev/git-workflow.md)
- [Testing Strategy](dev/testing-strategy.md)

---

## Versioning

- [Changelog](changelog.md) - All changes
- [Decision Log](decision-log.md) - Architecture decisions

## AI Agent Guidelines

When updating documentation:
1. Update existing files rather than rewriting entire documents
2. Each feature should have its own markdown file
3. Follow the standard document structure (Overview, Business Logic, Workflow, Edge Cases, Future Enhancements)
4. Keep documentation modular
5. Log significant changes in changelog.md
