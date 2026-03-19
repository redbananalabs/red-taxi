# Red Taxi V2 — Feature Tracker

> **V2 = Wrap & extend the proven AceTaxis codebase (now RedTaxi).**
> Updated: 2026-03-19 from operator feature review spreadsheet.
> Google Sheet: https://docs.google.com/spreadsheets/d/14BuzERAQg5RrkEYiIxhuM3SvZvFXF7-7

## Status Key
- ✅ Done (working, verified)
- 🔧 Needs Fix (exists but needs improvement)
- 🆕 Build New (doesn't exist yet)
- ❌ Removed (cut from scope)
- ⏳ Later (deferred post-launch)
- 🔍 Review (needs checking in existing app)

---

## DISPATCH CONSOLE

### Layout & Structure
| Ref | Feature | Status | Priority |
|-----|---------|--------|----------|
| DC01 | Split layout: form LEFT, scheduler/map RIGHT | ✅ Done | — |
| DC02 | Draggable splitter (35%/65%) | ✅ Done | — |
| DC03 | Tabbed right panel: Scheduler / Map | 🔍 Review | — |
| DC04 | Booking form always visible | ✅ Done | — |
| DC05 | Day view as default | ✅ Done | — |
| DC06 | Sidebar navigation | ✅ Done | — |
| DC07 | Top bar (search, SMS, DM, GM, bell, +New) | ✅ Done | — |
| DC08 | 3 view modes: Map, Diary, Split | ✅ Done | — |
| DC09 | Multi-monitor pop-out | ⏳ Later | P5 |
| DC10 | Material Dark theme | ⏳ Later | P5 |
| DC11 | Responsive tablet (768-1280px) | 🔍 Review | — |

### Booking Form
| Ref | Feature | Status |
|-----|---------|--------|
| BF01-BF16 | All 16 booking form features | ✅ Done |

### Scheduler / Timeline
| Ref | Feature | Status |
|-----|---------|--------|
| SC01-SC14 | All 14 scheduler features | ✅ Done |

### Map
| Ref | Feature | Status |
|-----|---------|--------|
| MP01 | Google Maps (dark theme) | ✅ Done |
| MP02 | Centred from CompanyConfig | 🆕 Build |
| MP03 | Driver position pins (live GPS) | ✅ Done |
| MP04 | Booking pickup markers | ✅ Done |
| MP05 | Click marker → detail popup | ⏳ Later |
| MP06 | Driver info on hover | 🔍 Review |

### Caller Popup & Allocation
| Ref | Feature | Status |
|-----|---------|--------|
| CA01-CA07 | All 7 caller/allocation features | ✅ Done |

### Notifications & Alerts
| Ref | Feature | Status |
|-----|---------|--------|
| NT01 | Notification bell with badge | 🔧 Needs Fix |
| NT02-NT07 | All other notification features | ✅ Done |
| NT08 | Replace Pusher → SignalR | ⏳ Later |

### Keyboard Shortcuts
| Ref | Feature | Status |
|-----|---------|--------|
| KB01 | Ctrl+K → command palette | ❌ Removed |
| KB02 | Ctrl+N → new booking | ❌ Removed |
| KB03 | Ctrl+S → save booking | ❌ Removed |
| KB04 | Tab → cycle focus | ✅ Done |
| KB05 | Escape → close dialog | ❌ Removed |
| KB06 | Number keys → allocate driver | ✅ Done |

### CSS & Responsive
| Ref | Feature | Status |
|-----|---------|--------|
| CSS01 | Desktop full split layout | 🔧 Needs Fix |
| CSS02 | Tablet responsive | 🆕 Build |
| CSS03 | Mobile → redirect to operator app | 🆕 Build |
| CSS04-CSS07 | Spacing, loading, errors, print | 🔍 Review |

---

## ADMIN PANEL

### Invoice Processing (AP01-AP09) | ✅ All Done
### Statement Processing (AP10-AP16) | ✅ All Done
### Driver Management (AP17-AP20) | ✅ All Done

### Zone Pricing
| Ref | Feature | Status |
|-----|---------|--------|
| AP21 | Polygon editor | 🆕 Build |
| AP22 | Zone pricing matrix | 🆕 Build |
| AP23 | Point-in-polygon matching | 🆕 Build |

### Availability (AP24-AP26) | ✅ All Done

### Reports & Settings
| Ref | Feature | Status |
|-----|---------|--------|
| AP27 | All 18 reports | ✅ Done |
| AP28 | Export CSV/PDF | 🔍 Review |
| AP29 | Company Settings (current) | ✅ Done |
| AP30 | Map centre config | 🆕 Build |
| AP31 | Payment processor choice | 🆕 Build |
| AP32 | Bank holiday management | 🆕 Build |
| AP33 | Configurable rates | 🆕 Build |
| AP34-AP35 | Message + Tariff settings | ✅ Done |
| AP36 | Fixed Route Pricing | 🔍 Review |
| AP37 | Local POI management | ✅ Done |
| AP38 | Tracking page | 🔍 Review |

---

## BACKEND API

### Config Extraction (C01-C16) | 🔧 All 16 Need Fixing
### Controller → Service (EX01-EX04) | 🔧 4 Remaining
### Controller → Service (EX05-EX06) | ✅ Done

### Multi-Tenancy (MT01-MT06) | 🆕 All 6 Build New
### SaaS Billing (SB01-SB09) | 🆕 All 9 Build New

### Infrastructure
| Ref | Feature | Status |
|-----|---------|--------|
| IN01 | .NET 7 → .NET 8 | 🔧 Needs Fix |
| IN02 | Structured logging (Serilog) | ✅ Done |
| IN03 | Sentry error monitoring | ✅ Done |
| IN04-IN08 | Health check, rate limit, CORS, Docker, CI/CD | 🆕 Build |
| IN09 | RBAC enforcement | 🔍 Review |
| IN10 | Replace Pusher → SignalR | ⏳ Later |

---

## MOBILE APPS

### Customer App (CU01-CU13) | 🆕 All 13 Build New
### Operator Mobile (OP01-OP05) | 🆕 All 5 Build New

### Driver App (Existing)
| Ref | Feature | Status |
|-----|---------|--------|
| DR01 | All 25 screens | ✅ Done |
| DR02-DR04 | Timer UX, hackney, offline | 🔍 Review |
| DR05 | Multi-tenant API URL | 🔧 Needs Fix |

### Local SMS (SM01-SM03) | ✅ Done (move to mobile/local-sms/)

---

## MARKETING & SAAS

### Marketing Website (MK01-MK06) | 🆕 All 6 Build New
### Tenant Onboarding (ON01-ON06) | 🆕 All 6 Build New

---

## SUMMARY

| Status | Count |
|--------|-------|
| ✅ Done | ~115 |
| 🔧 Needs Fix | ~22 |
| 🆕 Build New | ~45 |
| ❌ Removed | 4 |
| ⏳ Later | 4 |
| 🔍 Review | ~10 |
| **Total** | **~200** |
