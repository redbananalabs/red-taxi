# Red Taxi V2 — Smoke Tests

> Run these after ANY code change. All must pass before committing.
> API: http://localhost:5092 | Dispatcher: http://localhost:5173

---

## Quick Smoke (Run Every Time — 2 minutes)

```bash
# 1. Build
cd src && dotnet build RedTaxi.sln
# Expected: 0 errors

# 2. Start API
dotnet run --project RedTaxi.API
# Expected: Listening on http://localhost:5092

# 3. Swagger loads
curl -s -o /dev/null -w "%{http_code}" http://localhost:5092/swagger/index.html
# Expected: 200

# 4. Login
curl -s -X POST http://localhost:5092/api/UserProfile/Login \
  -H "Content-Type: application/json" \
  -d '{"username":"Peter","password":"Test1234"}' | jq '.token | length'
# Expected: > 0 (JWT token returned)

# 5. Bookings load
TOKEN=$(curl -s -X POST http://localhost:5092/api/UserProfile/Login \
  -H "Content-Type: application/json" \
  -d '{"username":"Peter","password":"Test1234"}' | jq -r '.token')
curl -s http://localhost:5092/api/Bookings/Today \
  -H "Authorization: Bearer $TOKEN" | jq '.bookings | length'
# Expected: > 0
```

---

## Full Regression (Run Before Each Release — 15 minutes)

### 1. Authentication
| Test | Endpoint | Method | Expected |
|------|----------|--------|----------|
| Admin login | /api/UserProfile/Login | POST | 200 + JWT token + role=Admin |
| Driver login | /api/UserProfile/Login | POST | 200 + JWT token + role=Driver |
| Invalid login | /api/UserProfile/Login | POST | 401 or error message |
| Token refresh | /api/UserProfile/RefreshToken | POST | 200 + new JWT |
| Protected without token | /api/Bookings/Today | GET | 401 |

### 2. Booking CRUD
| Test | Endpoint | Method | Expected |
|------|----------|--------|----------|
| Get today's bookings | /api/Bookings/Today | GET | 200 + bookings array with data |
| Create cash booking | /api/Bookings/Create | POST | 201 + booking ID |
| Create account booking | /api/Bookings/Create | POST | 201 + booking ID + account number |
| Edit booking (change time) | /api/Bookings/Update | PUT | 200 |
| Cancel booking | /api/Bookings/Cancel | POST | 200 |
| Duplicate booking | /api/Bookings/Duplicate | POST | 201 + new booking ID |
| Create return booking | /api/Bookings/Return | POST | 201 + reversed addresses |
| Search bookings | /api/Bookings/Search | GET | 200 + filtered results |

### 3. Pricing
| Test | Endpoint | Method | Expected |
|------|----------|--------|----------|
| Cash price SP8→DT9 | /api/Bookings/GetPrice | POST | 200 + price=£50, tariff="Tariff 1 : Day Rate" |
| Night tariff (22:00+) | /api/Bookings/GetPrice | POST | 200 + Tariff 2 price |
| Account price | /api/Bookings/GetPrice | POST | 200 + dual pricing (driver + account) |
| No destination | /api/Bookings/GetPrice | POST | 200 + price=0 or handled gracefully |

### 4. Dispatch & Allocation
| Test | Endpoint | Method | Expected |
|------|----------|--------|----------|
| Get driver list | /api/AdminUI/DriversList | GET | 200 + 29 drivers |
| Allocate driver | /api/Bookings/Allocate | POST | 200 + booking updated |
| Soft allocate | /api/Bookings/SoftAllocate | POST | 200 |
| Confirm soft allocates | /api/Bookings/ConfirmSoftAllocates | POST | 200 |
| Unallocate driver | /api/Bookings/Unallocate | POST | 200 |
| Complete booking | /api/Bookings/Complete | POST | 200 |

### 5. Address Lookup
| Test | Endpoint | Method | Expected |
|------|----------|--------|----------|
| Postcode search (Ideal) | /api/Address/DispatchSearch?query=SP8+4PZ | GET | 200 + 16 results |
| Address resolve | /api/Address/Resolve | GET | 200 + full address |
| Web booker search | /api/Address/WebBookerSearch | GET | 200 + results |

### 6. Accounts & Billing
| Test | Endpoint | Method | Expected |
|------|----------|--------|----------|
| List accounts | /api/Accounts/GetAccounts | GET | 200 + accounts |
| Get chargeable jobs | /api/Accounts/GetChargeableJobs | GET | 200 |
| Process invoice | /api/Accounts/ProcessInvoice | POST | 200 + invoice created |
| Process statement | /api/Accounts/ProcessStatement | POST | 200 + statement created |
| Get credit notes | /api/Accounts/GetCreditNotes | GET | 200 |

### 7. Driver App API
| Test | Endpoint | Method | Expected |
|------|----------|--------|----------|
| Get profile | /api/DriverApp/GetProfile | GET | 200 + driver info |
| Get job offers | /api/DriverApp/GetJobOffers | GET | 200 |
| Accept job | /api/DriverApp/JobOfferReply | POST | 200 |
| Update GPS | /api/DriverApp/UpdateUserGPS | POST | 200 |
| Start shift | /api/DriverApp/DriverShift | POST | 200 |
| Today's jobs | /api/DriverApp/TodayJobs | GET | 200 |
| Completed jobs | /api/DriverApp/CompletedJobs | GET | 200 |

### 8. Web Booker
| Test | Endpoint | Method | Expected |
|------|----------|--------|----------|
| Web booker login | /api/WeBooking/Login | POST | 200 + token |
| Create web booking | /api/WeBooking/Create | POST | 201 |
| Get active bookings | /api/WeBooking/GetActiveBookings | GET | 200 |
| Cancel web booking | /api/WeBooking/Cancel | POST | 200 |

### 9. Reports
| Test | Endpoint | Method | Expected |
|------|----------|--------|----------|
| Booking breakdown | /api/Reporting/BookingBreakdown | GET | 200 + data |
| Driver earnings | /api/Reporting/DriverEarnings | GET | 200 + data |
| Revenue report | /api/Reporting/Revenue | GET | 200 + data |

### 10. Messaging
| Test | Endpoint | Method | Expected |
|------|----------|--------|----------|
| Send SMS (test) | /api/AdminUI/SendMessageToDriver | POST | 200 |
| WhatsApp webhook | /api/WhatsApp/Webhook | POST | 200 |
| SMS queue check | /api/SmsQue/GetPending | GET | 200 |

### 11. Other Services
| Test | Endpoint | Method | Expected |
|------|----------|--------|----------|
| Local POIs | /api/LocalPOI/GetAll | GET | 200 + 450 POIs |
| Availability | /api/Availability/Get | GET | 200 |
| Caller events | /api/CallEvents/Lookup | GET | 200 |
| QR code click | /api/QRCodeClickCounter/Click | POST | 200 |
| URL redirect | /api/Redirect/{code} | GET | 302 |

### 12. Frontend — Dispatcher
| Test | How | Expected |
|------|-----|----------|
| Login page loads | Open localhost:5173 | Login form visible |
| Login works | Enter Peter/Test1234 | Redirect to dispatch view |
| Bookings visible | Check scheduler | Booking tiles on timeline |
| Map loads | Check map area | Google Maps with dark tiles |
| Create booking | Click + New, fill form | Booking saved, appears on scheduler |
| Allocate driver | Click booking, select driver | Tile changes to driver colour |
| Address autocomplete | Type in pickup field | Dropdown with suggestions |

### 13. Frontend — Admin Panel
| Test | How | Expected |
|------|-----|----------|
| Login page loads | Open admin URL | Login form visible |
| Dashboard loads | After login | KPI cards with real data |
| Driver list | Click Drivers | 29 drivers with colours |
| Account list | Click Accounts | Accounts with tariffs |
| Invoice processor | Click Billing | Chargeable jobs listed |

### 14. Structured Logging (NEW)
| Test | How | Expected |
|------|-----|----------|
| Log file created | Check Logs/ folder | JSON + text files exist |
| Booking action logged | Create a booking, check logs | BookingId, Price in log entry |
| Error logged | Trigger a 500 error | Stack trace in log file |

---

## Baseline Numbers (from production data)

| Metric | Expected Value | Source |
|--------|---------------|--------|
| Today's bookings | ~89 (varies by day) | Last verified |
| Total drivers | 29 | Last verified |
| Total accounts | 51 | Last verified |
| Total bookings (all time) | 127,321 | Last verified |
| Local POIs | 450 | Last verified |
| SP8→DT9 price | £50 | Last verified |
| Tariff name | "Tariff 1 : Day Rate" | Last verified |
| Address search SP8 4PZ | 16 results | Last verified |
