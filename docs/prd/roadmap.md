# Roadmap

## Delivery Phases

### Phase 1: Core Platform (Weeks 1-4)
**Goal**: Minimum viable dispatch system

#### Deliverables
- [ ] Tenant infrastructure
- [ ] Identity and authentication
- [ ] Booking CRUD
- [ ] Basic pricing engine
- [ ] Manual dispatch
- [ ] Driver management (CRUD)
- [ ] SignalR real-time updates
- [ ] Basic operator UI

#### Success Criteria
- Create booking < 30 seconds
- Manually allocate driver
- Real-time updates work
- Single tenant operational

---

### Phase 2: Accounts & Dispatch (Weeks 5-6)
**Goal**: Account customers and smarter dispatch

#### Deliverables
- [ ] Corporate accounts
- [ ] Account tariffs
- [ ] Assisted dispatch (suggestions)
- [ ] Auto dispatch v1
- [ ] SMS integration (Twilio)
- [ ] Booking confirmation messages
- [ ] Driver notifications

#### Success Criteria
- Account bookings work
- Auto-dispatch allocates 70%+ jobs
- SMS confirmations sent
- Driver app receives jobs

---

### Phase 3: Reporting & Billing (Weeks 7-8)
**Goal**: Financial operations

#### Deliverables
- [ ] Standard reports
- [ ] Account statements
- [ ] Driver settlements
- [ ] Commission calculations
- [ ] Payment processing (Revolut)
- [ ] Invoice generation
- [ ] VAT reports

#### Success Criteria
- Generate monthly statements
- Calculate driver pay correctly
- Process card payments
- Export for accountant

---

### Phase 4: SaaS Features (Weeks 9-12)
**Goal**: Multi-tenant production ready

#### Deliverables
- [ ] Tenant onboarding flow
- [ ] Tenant branding (logo, colours)
- [ ] Feature flags by plan
- [ ] Usage-based billing
- [ ] Super-admin console
- [ ] Tenant isolation audit
- [ ] Performance optimisation

#### Success Criteria
- New tenant onboards in < 5 minutes
- Plans enforce limits correctly
- No cross-tenant data leaks
- Handle 10 concurrent tenants

---

### Phase 5: AI Features (Weeks 13+)
**Goal**: Intelligent automation

#### Deliverables
- [ ] AI dispatch suggestions
- [ ] Dynamic pricing engine
- [ ] Demand forecasting
- [ ] Route optimisation
- [ ] Driver scoring
- [ ] AI voice booking (pilot)

#### Success Criteria
- Auto-dispatch success > 85%
- Price optimisation increases revenue
- Voice booking handles simple journeys

---

## Future Backlog

### Near-term (Q2)
- WhatsApp two-way messaging
- Flight tracking integration
- School transport workflows
- Driver document expiry alerts

### Medium-term (Q3-Q4)
- Multi-currency support
- White-label mobile apps
- CMAC integration
- Subcontractor management

### Long-term (2025+)
- Autonomous vehicle support
- Cross-operator job exchange
- Advanced fraud detection
- Predictive maintenance

---

## Milestones

| Milestone | Target Date | Status |
|-----------|-------------|--------|
| Phase 1 Complete | TBD | 🔴 Not Started |
| Phase 2 Complete | TBD | 🔴 Not Started |
| First Tenant Live | TBD | 🔴 Not Started |
| 10 Tenants | TBD | 🔴 Not Started |
| AI Features Pilot | TBD | 🔴 Not Started |

---

## Dependencies

| Dependency | Phase | Risk |
|------------|-------|------|
| Google Places API access | 1 | Low |
| Twilio account | 2 | Low |
| Revolut Business API | 3 | Medium |
| Driver app updates | 2 | Medium |
| Ace data migration | 4 | High |
