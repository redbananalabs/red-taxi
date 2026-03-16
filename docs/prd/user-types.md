# User Types

## Overview

The platform serves four primary user types across three applications.

## User Roles

### Super Admin
**Application**: Admin Portal  
**Tenant**: Platform-wide

Responsibilities:
- Tenant provisioning
- Platform configuration
- System monitoring
- Usage billing

Permissions:
- Full access to all tenants (read-only by default)
- Platform configuration
- Billing management

---

### Tenant Admin
**Application**: Admin Portal  
**Tenant**: Single tenant

Responsibilities:
- Company settings
- User management
- Driver onboarding
- Account setup
- Tariff configuration
- Billing/invoicing

Permissions:
- Full access within tenant
- Cannot access other tenants
- Cannot modify platform settings

---

### Operator
**Application**: Dispatch Console  
**Tenant**: Single tenant

Responsibilities:
- Booking creation
- Dispatch management
- Customer communication
- Driver coordination
- Handling calls

Permissions:
- Create/edit bookings
- Allocate drivers
- Send messages
- View driver locations
- Cannot modify settings
- Cannot access billing

---

### Driver
**Application**: Driver Mobile App  
**Tenant**: Single tenant

Responsibilities:
- Accept/reject jobs
- Navigate to pickups
- Update job status
- Collect payment
- Track earnings

Permissions:
- View allocated jobs
- Update own status
- View own earnings
- Cannot see other drivers
- Cannot modify bookings

---

## Personas

### Sarah - Small Fleet Operator
- 12 drivers
- Handles dispatch herself
- Needs fast booking, auto-dispatch
- Price sensitive

### Mike - Multi-site Manager  
- 80 drivers across 3 locations
- Team of 5 operators
- Needs reporting, account management
- Wants subcontracting support

### Dave - Owner-Driver
- Drives and takes bookings
- Uses app and console
- Needs simple interface
- Values earnings visibility

### James - Full-time Driver
- 40+ hours per week
- Wants fair job allocation
- Needs reliable navigation
- Values clear communication

---

## Access Matrix

| Feature | Super Admin | Tenant Admin | Operator | Driver |
|---------|-------------|--------------|----------|--------|
| Platform config | ✅ | ❌ | ❌ | ❌ |
| Tenant settings | ✅ | ✅ | ❌ | ❌ |
| User management | ✅ | ✅ | ❌ | ❌ |
| Driver management | ✅ | ✅ | View | ❌ |
| Create bookings | ❌ | ✅ | ✅ | ❌ |
| Dispatch | ❌ | ✅ | ✅ | ❌ |
| View all bookings | ✅ | ✅ | ✅ | ❌ |
| View own jobs | N/A | N/A | N/A | ✅ |
| Reports | ✅ | ✅ | Limited | Own |
| Billing | ✅ | ✅ | ❌ | ❌ |
