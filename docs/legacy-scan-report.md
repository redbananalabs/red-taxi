# Legacy Codebase Full Scan Report
## 1. Hardcoded Account Numbers
TaxiDispatch.Lib/Services/AccountsService.cs:493:                if (acc.Key == 9014 || acc.Key == 10026) // harbour vale - order by passenger name
TaxiDispatch.Lib/Services/AccountsService.cs:564:                    if (accData.AccNo == 9005 || accData.AccNo == 9006 || accData.AccNo == 90004)
TaxiDispatch.Lib/Services/AccountsService.cs:569:                    else if (accData.AccNo == 9014 || accData.AccNo == 10026)
TaxiDispatch.Lib/Services/AccountsService.cs:582:                    else if (accData.AccNo == 10029)
TaxiDispatch.Lib/Services/AccountsService.cs:1340:                if (accno == 9005 || accno == 9006 || accno == 90004)
TaxiDispatch.Lib/Services/AccountsService.cs:1522:                   o.AccountNumber == 9014 &&
TaxiDispatch.Lib/Services/AccountsService.cs:1561:             o.AccountNumber == 9014 &&
TaxiDispatch.Lib/Services/AdminUIService.cs:267:                            o.AccountNumber == 9014 &&
TaxiDispatch.Lib/Services/BookingService.cs:166:                            (o.AccountNumber == 9014 || o.AccountNumber == 10026) &&
TaxiDispatch.Lib/Services/BookingService.cs:2040:            if (primary.AccountNumber == 9014 || primary.AccountNumber == 10026)
TaxiDispatch.Lib/Services/WebBookingService.cs:416:            var scope = obj.AccNo == 9999 ? obj.Scope : BookingScope.Account;
TaxiDispatch.Lib/Services/WebBookingService.cs:435:            req.DurationMinutes = obj.AccNo == 9999 ? obj.DurationMinutes.Value : journey.TotalMinutes;
TaxiDispatch.Lib/Services/WebBookingService.cs:436:            req.Mileage = obj.AccNo == 9999 ? obj.Mileage : (decimal)journey.TotalMileage;
TaxiDispatch.Lib/Services/WebBookingService.cs:437:            req.MileageText = obj.AccNo == 9999 ? obj.MileageText : journey.MileageText;
TaxiDispatch.Lib/Services/WebBookingService.cs:438:            req.DurationMinutes = obj.AccNo == 9999 ? obj.DurationMinutes.Value : journey.TotalMinutes;
TaxiDispatch.Lib/Services/WebBookingService.cs:443:                if (obj.AccNo == 9999)
TaxiDispatch.Lib/Services/WebBookingService.cs:456:                req.Price = obj.AccNo == 9999 ? (decimal)obj.Price : (decimal)journey.PriceDriver;
TaxiDispatch.Lib/Services/WebBookingService.cs:457:                req.PriceAccount = obj.AccNo == 9999 ? 0 : (decimal)journey.PriceAccount;
TaxiDispatch.Lib/Services/WebBookingService.cs:460:            if (obj.AccNo == 9999)
TaxiDispatch.Lib/Services/WebBookingService.cs:476:            if (obj.AccNo == 9999)
TaxiDispatch.Lib/Services/WebBookingService.cs:494:                if (obj.AccNo == 9999)
TaxiDispatch.Lib/Services/WebBookingService.cs:590:            if (obj.AccNo == 9999)
TaxiDispatch.Lib/Services/WebBookingService.cs:608:                if (obj.AccNo == 9999)

## 2. Hardcoded Prices & Rates
TaxiDispatch.Lib/Services/AccountsService.cs:337:                obj.CommissionDue = (((obj.EarningsCash + obj.EarningsCard) / 100) * commsRate + (obj.EarningsRank / 100) * 7.5) + cardFeesTotal;
TaxiDispatch.Lib/Services/AccountsService.cs:392:                        comms = (job.Price / 100) * 7.5;
TaxiDispatch.Lib/Services/AccountsService.cs:645:                var rankrate = 7.5;
TaxiDispatch.Lib/Services/AccountsService.cs:735:                var rankrate = 7.5;
TaxiDispatch.Lib/Services/AccountsService.cs:1023:                        job.Price = Math.Round((job.Price / 1.2),2);
TaxiDispatch.Lib/Services/AccountsService.cs:2046:            var permin = 0.33;
TaxiDispatch.Lib/Services/AccountsService.cs:2053:            var permin = 0.42;
TaxiDispatch.Lib/Services/BookingService.cs:2042:                primary.Price += 7;
TaxiDispatch.Lib/Services/BookingService.cs:2043:                primary.PriceAccount += 15;
TaxiDispatch.Lib/Services/TariffService.cs:164:            res.PriceDriver = Math.Round(miles * 2.40, 2);
TaxiDispatch.Lib/Services/TariffService.cs:167:            res.PriceDriver *= (double)0.85M;
TaxiDispatch.Lib/Services/TariffService.cs:173:                    res.PriceDriver += 7;
TaxiDispatch.Lib/Services/TariffService.cs:177:            res.PriceAccount = Math.Round(miles * 2.60, 2);
TaxiDispatch.Lib/Services/TariffService.cs:183:                    res.PriceAccount += 15;

## 3. State Transitions
TaxiDispatch.Lib/Services/AccountsService.cs:134:                   o.Cancelled == false)              
TaxiDispatch.Lib/Services/AccountsService.cs:142:                    && o.InvoiceNumber == null && o.AccountNumber == accno && o.Cancelled == false && o.Scope == BookingScope.Account)
TaxiDispatch.Lib/Services/AccountsService.cs:172:                obj.Cancelled = job.Cancelled;
TaxiDispatch.Lib/Services/AccountsService.cs:181:                obj.PaymentStatus = job.PaymentStatus;
TaxiDispatch.Lib/Services/AccountsService.cs:200:                        o.Cancelled == false)
TaxiDispatch.Lib/Services/AccountsService.cs:232:                        o.UserId == driver && o.StatementId == null && o.Cancelled == false)
TaxiDispatch.Lib/Services/AccountsService.cs:304:                    obj.EarningsCard = driver.Where(o => o.Scope == BookingScope.Card && o.PaymentStatus == PaymentStatus.Paid).Sum(o => (o.Price/1.2));
TaxiDispatch.Lib/Services/AccountsService.cs:309:                    obj.EarningsCard = driver.Where(o => o.Scope == BookingScope.Card && o.PaymentStatus == PaymentStatus.Paid).Sum(o => o.Price);
TaxiDispatch.Lib/Services/AccountsService.cs:605:            var data = await _dB.Bookings.Where(o => o.Cancelled == false && o.PickupDateTime >= start.Date && o.PickupDateTime <= end.To2359() && o.UserId == driver)
TaxiDispatch.Lib/Services/AccountsService.cs:682:                data = await _dB.Bookings.Where(o => o.Cancelled == false && (o.PickupDateTime >= start.Date 
TaxiDispatch.Lib/Services/AccountsService.cs:694:                data = await _dB.Bookings.Where(o => o.Cancelled == false && o.PickupDateTime >= start.Date && o.PickupDateTime <= end.To2359() && o.UserId == driver)
TaxiDispatch.Lib/Services/AccountsService.cs:1425:             o.PriceAccount > 0 && o.PickupDateTime.Date < dto.PickupDateTime.Date && o.Cancelled == false)
TaxiDispatch.Lib/Services/AccountsService.cs:1567:             o.Cancelled == false)
TaxiDispatch.Lib/Services/AccountsService.cs:1757:                o.PriceAccount > 0 && o.PickupDateTime.Date <= dto.PickupDateTime.Date && o.Cancelled == false)
TaxiDispatch.Lib/Services/AccountsService.cs:2127:            var data = await _dB.Bookings.Where(o => (o.Cancelled == false) &&
TaxiDispatch.Lib/Services/AccountsService.cs:2192:                var data1 = await _dB.Bookings.Where(o => (o.Cancelled == false) && o.Scope == BookingScope.Card &&
TaxiDispatch.Lib/Services/AdminUIService.cs:227:            var data = await _dB.UINotifications.Where(o=>o.Status == NotificationStatus.Default)
TaxiDispatch.Lib/Services/AdminUIService.cs:237:                .ExecuteUpdateAsync(o => o.SetProperty(p => p.Status, NotificationStatus.Read));
TaxiDispatch.Lib/Services/AdminUIService.cs:243:                .ExecuteUpdateAsync(o => o.SetProperty(p => p.Status, NotificationStatus.Read));
TaxiDispatch.Lib/Services/AdminUIService.cs:249:                .ExecuteUpdateAsync(o => o.SetProperty(p => p.Status, NotificationStatus.Read));
TaxiDispatch.Lib/Services/AvailabilityService.cs:323:                    o.UserId != null && o.Cancelled == false && o.Status != BookingStatus.Complete)
TaxiDispatch.Lib/Services/BookingService.cs:55:                o.Cancelled == false)
TaxiDispatch.Lib/Services/BookingService.cs:95:                data.Bookings = data.Bookings.Where(o => o.Cancelled == false).ToList();
TaxiDispatch.Lib/Services/BookingService.cs:109:                           .Where(o => o.PickupDateTime >= startDate.Date && o.Cancelled == false &&
TaxiDispatch.Lib/Services/BookingService.cs:118:                if(model.Status == null)
TaxiDispatch.Lib/Services/BookingService.cs:120:                    model.Status = BookingStatus.None;
TaxiDispatch.Lib/Services/BookingService.cs:147:                        .Where(o => o.PickupDateTime >= startDate.Date && o.Cancelled == false &&
TaxiDispatch.Lib/Services/BookingService.cs:155:                            .Where(o => o.PickupDateTime >= startDate.Date && o.Cancelled == false &&
TaxiDispatch.Lib/Services/BookingService.cs:165:                            o.Cancelled == false &&
TaxiDispatch.Lib/Services/BookingService.cs:222:                    if (item.Status == BookingStatus.AcceptedJob)
TaxiDispatch.Lib/Services/BookingService.cs:224:                        model.Status = BookingStatus.AcceptedJob;
TaxiDispatch.Lib/Services/BookingService.cs:226:                    if (item.Status == BookingStatus.RejectedJob)
TaxiDispatch.Lib/Services/BookingService.cs:228:                        model.Status = BookingStatus.RejectedJob;
TaxiDispatch.Lib/Services/BookingService.cs:275:                if (item.Status == BookingStatus.AcceptedJob)
TaxiDispatch.Lib/Services/BookingService.cs:277:                    model.Status = BookingStatus.AcceptedJob;
TaxiDispatch.Lib/Services/BookingService.cs:279:                if (item.Status == BookingStatus.RejectedJob)
TaxiDispatch.Lib/Services/BookingService.cs:281:                    model.Status = BookingStatus.RejectedJob;
TaxiDispatch.Lib/Services/BookingService.cs:338:                .Where(o => o.PickupDateTime >= now && o.AccountNumber == accno && o.Cancelled == false)
TaxiDispatch.Lib/Services/BookingService.cs:366:            booking.PaymentStatus = PaymentStatus.Select;
TaxiDispatch.Lib/Services/BookingService.cs:692:                            o.Cancelled == false)
TaxiDispatch.Lib/Services/BookingService.cs:868:                                item.Status = BookingStatus.None;
TaxiDispatch.Lib/Services/BookingService.cs:1061:            booking.PaymentStatus = obj.PaymentStatus;
TaxiDispatch.Lib/Services/BookingService.cs:1179:                        res.Cancelled = true;
TaxiDispatch.Lib/Services/BookingService.cs:1217:                                booking.Cancelled = true;
TaxiDispatch.Lib/Services/BookingService.cs:1272:               o.Email.StartsWith(term)) && o.Cancelled == false)
TaxiDispatch.Lib/Services/BookingService.cs:1288:            data = data.Where(o => o.Cancelled == false).ToList();
TaxiDispatch.Lib/Services/BookingService.cs:1310:            var data3 = data2.Where(o=>o.Cancelled == false).ToList();
TaxiDispatch.Lib/Services/BookingService.cs:1411:            iquery = iquery.Where(o => o.Cancelled == false);
TaxiDispatch.Lib/Services/BookingService.cs:1426:            data = data.Where(o => o.Cancelled == false).ToList();
TaxiDispatch.Lib/Services/BookingService.cs:1592:            o.Cancelled == false &&
TaxiDispatch.Lib/Services/BookingService.cs:1622:                  .ExecuteUpdateAsync(o => o.SetProperty(u => u.PaymentStatus, status));
TaxiDispatch.Lib/Services/BookingService.cs:1667:                o.Cancelled == false && !string.IsNullOrEmpty(o.PaymentOrderId) && o.PaymentReceiptSent == false)
TaxiDispatch.Lib/Services/BookingService.cs:1682:                   .ExecuteUpdateAsync(o => o.SetProperty(u => u.PaymentStatus, PaymentStatus.Paid));
TaxiDispatch.Lib/Services/BookingService.cs:1786:                .Where(o=>o.Cancelled == true && o.PickupDateTime.Date == date.Date)
TaxiDispatch.Lib/Services/BookingService.cs:1798:                .Where(o => o.Cancelled == false && o.Scope == BookingScope.Card &&
TaxiDispatch.Lib/Services/BookingService.cs:1814:                .SetProperty(u => u.Status, BookingStatus.None)
TaxiDispatch.Lib/Services/BookingService.cs:1821:                .Where(o => o.Cancelled == false && o.PickupDateTime.Date == date.Date && o.UserId == null)
TaxiDispatch.Lib/Services/BookingService.cs:1832:                .Where(o => o.Cancelled == false && o.PickupDateTime.Date == date.Date && o.UserId != null)
TaxiDispatch.Lib/Services/BookingService.cs:1843:                .Where(o => o.Cancelled == false && o.PickupDateTime.Date == date.Date && o.Status == BookingStatus.Complete)
TaxiDispatch.Lib/Services/BookingService.cs:1857:                o.UserId != null && o.Cancelled == false && (lst.Contains(o.PickupAddress) || lst.Contains(o.DestinationAddress))
TaxiDispatch.Lib/Services/BookingService.cs:1895:                        .Where(o => o.PickupDateTime >= DateTime.Now.AddMonths(-1).Date && o.Cancelled == false &&
TaxiDispatch.Lib/Services/BookingService.cs:1968:                    o.Cancelled == false)
TaxiDispatch.Lib/Services/BookingService.cs:1984:                    o.Cancelled == false).Select(o => new { o.Id, o.PickupDateTime, o.PassengerName } ).ToListAsync();
TaxiDispatch.Lib/Services/BookingService.cs:2060:            append.Cancelled = true;
TaxiDispatch.Lib/Services/CallEventsService.cs:102:                        o.Cancelled == false)
TaxiDispatch.Lib/Services/CallEventsService.cs:112:            item.Status = BookingStatus.None;
TaxiDispatch.Lib/Services/CallEventsService.cs:117:            .Where(o => o.PhoneNumber == callerId && o.Cancelled == true);
TaxiDispatch.Lib/Services/DispatchService.cs:65:                                o.SetProperty(u => u.Status, BookingStatus.None)
TaxiDispatch.Lib/Services/DispatchService.cs:78:                        .SetProperty(u => u.Status, BookingStatus.None)
TaxiDispatch.Lib/Services/DispatchService.cs:157:                .SetProperty(o => o.Status, BookingStatus.Complete));
TaxiDispatch.Lib/Services/DispatchService.cs:176:                .ExecuteUpdateAsync(u => u.SetProperty(o => o.PaymentStatus, PaymentStatus.Paid));
TaxiDispatch.Lib/Services/DispatchService.cs:221:                        obj.Status = AppJobStatus.Clear;
TaxiDispatch.Lib/Services/DispatchService.cs:272:                        p.SetProperty(u => u.Status, BookingStatus.AcceptedJob));
TaxiDispatch.Lib/Services/DispatchService.cs:278:                            p.SetProperty(u => u.Status, BookingStatus.RejectedJob)
TaxiDispatch.Lib/Services/DispatchService.cs:286:                            p.SetProperty(u => u.Status, BookingStatus.RejectedJobTimeout)
TaxiDispatch.Lib/Services/DispatchService.cs:316:                obj.Status = status;
TaxiDispatch.Lib/Services/DispatchService.cs:971:                .SetProperty(u => u.Status, AppJobStatus.Clear));
TaxiDispatch.Lib/Services/DriverAppService.cs:57:            .Where(o => o.Status == BookingStatus.Complete &&
TaxiDispatch.Lib/Services/GoogleCalendarService.cs:68:                    if (eventItem.Start == null && eventItem.Status == "cancelled")
TaxiDispatch.Lib/Services/ReportingService.cs:35:                .Where(o => o.PickupDateTime.Date >= ukfrom && o.PickupDateTime <= ukto && (o.Cancelled == false))
TaxiDispatch.Lib/Services/ReportingService.cs:113:            (o.DateCreated.Date <= to) && o.Cancelled == false)
TaxiDispatch.Lib/Services/ReportingService.cs:145:                    (o.Cancelled == false)).CountAsync(),
TaxiDispatch.Lib/Services/ReportingService.cs:149:                        o.Cancelled == false &&
TaxiDispatch.Lib/Services/ReportingService.cs:165:                ((o.Cancelled == false)) &&
TaxiDispatch.Lib/Services/ReportingService.cs:330:            await _dB.Bookings.Where(o => o.Cancelled == false &&
TaxiDispatch.Lib/Services/ReportingService.cs:343:            var journeysToday = await _dB.Bookings.CountAsync(o => o.UserId == userId && (o.Cancelled == false) && 
TaxiDispatch.Lib/Services/ReportingService.cs:346:            var accsToday = await _dB.Bookings.CountAsync(o => o.UserId == userId && (o.Cancelled == false) &&
TaxiDispatch.Lib/Services/ReportingService.cs:349:            var earnToday = await _dB.Bookings.Where(o => o.UserId == userId && (o.Cancelled == false) &&
TaxiDispatch.Lib/Services/ReportingService.cs:352:            var jobsDoneToday = await _dB.Bookings.Where(o => o.UserId == userId && (o.Cancelled == false)  &&
TaxiDispatch.Lib/Services/ReportingService.cs:391:            var monthJobsCount = await _dB.Bookings.Where(o => o.UserId == userId && (o.Cancelled == false) &&
TaxiDispatch.Lib/Services/ReportingService.cs:395:            var monthJobsCashSum = await _dB.Bookings.Where(o => o.UserId == userId && (o.Cancelled == false) && 
TaxiDispatch.Lib/Services/ReportingService.cs:401:            var monthJobsAccSum = await _dB.Bookings.Where(o => o.UserId == userId && (o.Cancelled == false) && 
TaxiDispatch.Lib/Services/ReportingService.cs:425:            var weekJobsCount = await _dB.Bookings.Where(o => o.UserId == userId && (o.Cancelled == false) &&
TaxiDispatch.Lib/Services/ReportingService.cs:429:                var weekJobsCashSum = await _dB.Bookings.Where(o => o.UserId == userId && (o.Cancelled == false) && 
TaxiDispatch.Lib/Services/ReportingService.cs:435:            var weekJobsAccSum = await _dB.Bookings.Where(o => o.UserId == userId && (o.Cancelled == false) && 
TaxiDispatch.Lib/Services/ReportingService.cs:441:            var weekRankSum = await _dB.Bookings.Where(o => o.UserId == userId && (o.Cancelled == false) &&
TaxiDispatch.Lib/Services/ReportingService.cs:465:            var jobs = await _dB.Bookings.Where(o => o.UserId == userId && (o.Cancelled == false) &&
TaxiDispatch.Lib/Services/ReportingService.cs:547:                    && (o.Cancelled == false) 
TaxiDispatch.Lib/Services/ReportingService.cs:1035:                var cost = await _dB.Bookings.Where(o => o.InvoiceNumber == invoice.InvoiceNumber && o.Cancelled == false)
TaxiDispatch.Lib/Services/ReportingService.cs:1062:            var invoices = await _dB.Bookings.Where(o => (o.Cancelled == false) &&
TaxiDispatch.Lib/Services/ReportingService.cs:1071:            var data = await _dB.Bookings.Where(o => (o.Cancelled == false) &&
TaxiDispatch.Lib/Services/ReportingService.cs:1157:            var accData = await _dB.Bookings.Where(o => (o.Cancelled == false) &&
TaxiDispatch.Lib/Services/ReportingService.cs:1166:            var costs = await _dB.Bookings.Where(o => (o.Cancelled == false) &&
TaxiDispatch.Lib/Services/ReportingService.cs:1174:            var cash = await _dB.Bookings.Where(o => (o.Cancelled == false) &&
TaxiDispatch.Lib/Services/UINotificationService.cs:31:            not.Status = NotificationStatus.Default;
TaxiDispatch.Lib/Services/UINotificationService.cs:46:            not.Status = NotificationStatus.Default;
TaxiDispatch.Lib/Services/UINotificationService.cs:61:            not.Status = NotificationStatus.Default;
TaxiDispatch.Lib/Services/UINotificationService.cs:74:            not.Status = NotificationStatus.Default;
TaxiDispatch.Lib/Services/UINotificationService.cs:85:            not.Status = NotificationStatus.Default;
TaxiDispatch.Lib/Services/UINotificationService.cs:96:            not.Status = NotificationStatus.Default;
TaxiDispatch.Lib/Services/UINotificationService.cs:169:            var data = await _dB.UINotifications.Where(o=> o.Status == Domain.NotificationStatus.Default)
TaxiDispatch.Lib/Services/UINotificationService.cs:178:                .ExecuteUpdateAsync(o => o.SetProperty(p=>p.Status, Domain.NotificationStatus.Read));
TaxiDispatch.Lib/Services/WebBookingService.cs:299:            query = query.Where(o => o.Status == WebBookingStatus.Accepted);
TaxiDispatch.Lib/Services/WebBookingService.cs:304:            query = query.Where(o => o.Status == WebBookingStatus.Rejected);
TaxiDispatch.Lib/Services/WebBookingService.cs:551:            obj.Status = WebBookingStatus.Accepted;
TaxiDispatch.Lib/Services/WebBookingService.cs:644:            obj.Status = WebBookingStatus.Rejected;
TaxiDispatch.Lib/Services/WebBookingService.cs:682:            obj.Status = WebBookingStatus.Default;
TaxiDispatch.Lib/Services/WhatsAppService.cs:88:                        .ExecuteUpdateAsync(p => p.SetProperty(u => u.Status, BookingStatus.AcceptedJob), cancellationToken);
TaxiDispatch.Lib/Services/WhatsAppService.cs:97:                        .SetProperty(u => u.Status, BookingStatus.RejectedJob)

## 4. Validation & Error Messages
TaxiDispatch.Lib/Services/AccountsService.cs:1104:                throw new InvalidDataException("There were no jobs found that match the sent booking ids.");
TaxiDispatch.Lib/Services/AccountsService.cs:1353:                throw new NotImplementedException("This function has not been implemented.");
TaxiDispatch.Lib/Services/AccountsService.cs:1874:                return Result.Fail("Error updating price, there was an error thrown.");
TaxiDispatch.Lib/Services/AccountsService.cs:1900:                return Result.Fail("Error updating price, there was an error thrown.");
TaxiDispatch.Lib/Services/AccountsService.cs:1997:                throw new Exception($"The Account with Number {request.AccNo} already exists.");
TaxiDispatch.Lib/Services/AccountsService.cs:2030:                throw new Exception($"The Account with Number {request.AccNo} was not found.");
TaxiDispatch.Lib/Services/AddressLookupService.cs:39:                      ?? throw new InvalidOperationException("Google:PlacesApiKey missing");
TaxiDispatch.Lib/Services/AddressLookupService.cs:139:                throw new HttpRequestException($"Google Places returned {(int)res.StatusCode}: {responseBody}");
TaxiDispatch.Lib/Services/AddressLookupService.cs:285:            throw new InvalidOperationException($"Unknown address ID format: '{id}'");
TaxiDispatch.Lib/Services/AddressLookupService.cs:293:            if (data == null) throw new InvalidOperationException("POI not found");
TaxiDispatch.Lib/Services/AvailabilityService.cs:29:                return Result.Fail("The starting time must be earlier than the ending time.");
TaxiDispatch.Lib/Services/AvailabilityService.cs:43:                    return Result.Fail("The specified time overlaps with an existing availability.");
TaxiDispatch.Lib/Services/AvailabilityService.cs:49:                    return Result.Fail("An availability entry for the specified time already exists.");
TaxiDispatch.Lib/Services/BookingService.cs:203:                            throw new Exception($"The booking {item.Id} has an invalid userId");
TaxiDispatch.Lib/Services/BookingService.cs:250:                            throw new Exception($"The booking {item.Id} has an invalid userId");
TaxiDispatch.Lib/Services/BookingService.cs:910:                    return Result.Fail<List<CreatedBookingResultDto>>($"The booking with recurrance id {obj.RecurrenceID} was not found.");
TaxiDispatch.Lib/Services/BookingService.cs:992:                    return Result.Fail<List<CreatedBookingResultDto>>($"The booking with id {obj.BookingId} was not found.");
TaxiDispatch.Lib/Services/BookingService.cs:1143:            return Result.Fail("The booking was not found.");
TaxiDispatch.Lib/Services/BookingService.cs:1231:                        return Domain.Result.Fail("No RecurranceID was set."); 
TaxiDispatch.Lib/Services/BookingService.cs:1236:            return Domain.Result.Fail("The appointment was not found.");
TaxiDispatch.Lib/Services/CallEventsService.cs:174:            throw new InvalidOperationException("CallEvents Pusher configuration is missing.");
TaxiDispatch.Lib/Services/DispatchService.cs:114:            return Result.Fail("The booking was not allocated. booking not found");
TaxiDispatch.Lib/Services/DocumentService.cs:127:                throw new Exception("the refresh token is empty or invalid.");
TaxiDispatch.Lib/Services/DocumentService.cs:160:                    throw new Exception("Failed to refresh token: " + json);
TaxiDispatch.Lib/Services/LocalPOIService.cs:114:                throw new Exception($"The POI with Id {request.Id} was not found.");
TaxiDispatch.Lib/Services/LocalPOIService.cs:131:                throw new Exception($"The POI with Id {request.Id} was not found.");
TaxiDispatch.Lib/Services/RevoluttService.cs:51:            throw new Exception("Check the request, invalid result.");
TaxiDispatch.Lib/Services/RevoluttService.cs:100:            throw new Exception("Check the request, invalid result.");
TaxiDispatch.Lib/Services/RevoluttService.cs:131:            throw new Exception("Check the request, invalid result.");
TaxiDispatch.Lib/Services/RevoluttService.cs:150:            throw new Exception("Check the request, invalid result.");
TaxiDispatch.Lib/Services/SmsQueueService.cs:91:            throw new InvalidOperationException("SmsQueue configuration is missing.");
TaxiDispatch.Lib/Services/TariffService.cs:25:                ?? throw new InvalidOperationException("Google:DistanceMatrixApiKey missing");
TaxiDispatch.Lib/Services/TariffService.cs:283:                throw new ArgumentNullException(nameof(tariff));
TaxiDispatch.Lib/Services/TariffService.cs:496:                    throw new Exception($"Error occurred while requesting distance matrix: {response.StatusCode} - {response.ReasonPhrase}");
TaxiDispatch.Lib/Services/TariffService.cs:511:                throw new NullReferenceException($"Unable to get directions, possible invalid postcode.",ex);
TaxiDispatch.Lib/Services/UserProfileService.cs:440:                throw new NotFoundException($"username {username} was not found.");
TaxiDispatch.Lib/Services/UserProfileService.cs:443:            throw new ArgumentException("username cannot be null");
TaxiDispatch.Lib/Services/UserProfileService.cs:465:                throw new NotFoundException($"username {username} was not found.");
TaxiDispatch.Lib/Services/UserProfileService.cs:468:            throw new ArgumentException("username cannot be null");
TaxiDispatch.Lib/Services/UserProfileService.cs:492:                throw new NotFoundException($"user id {id} was not found.");

## 5. CompanyConfig Entity
﻿using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace TaxiDispatch.Data.Models
{
    public class CompanyConfig
    {
        [Key]
        [DatabaseGenerated(DatabaseGeneratedOption.Identity)]
        public int Id { get; set; }

        public string CompanyName { get; set; } // Ace Taxis (Dorset) Ltd
        public string Address1 { get; set; } // 1 Briar Close
        public string Address2 { get; set; } // Gillingham
        public string Address3 { get; set; } // Dorset
        public string? Address4 { get; set; }
        public string Postcode { get; set; } // SP8 4SS

        public string Email { get; set; } // bookings@acetaxisdorset.co.uk
        public string Website { get; set; } // www.acetaxisdorset.co.uk
        public string Phone { get; set; } // 01747

        public string CompanyNumber { get; set; } // 08920947
        public string VATNumber { get; set; } // 325 1273 31

        public double CardTopupRate { get; set; }

        public string RevoluttSecretKey { get; set; }

        public List<string> BrowserFCMs { get; set; }

        public bool AddVatOnCardPayments { get; set; } = false;
    }
}


## 6. Booking Entity
﻿using TaxiDispatch.Domain;
using Microsoft.EntityFrameworkCore;
using System.ComponentModel;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using System.Runtime.Serialization;

namespace TaxiDispatch.Data.Models
{
    public class Booking : ICloneable
    {
        public Booking()
        {
            var date = DateTime.Now.ToUKTime();
            VehicleType = VehicleType.Unknown;
            DateCreated = date;
        }

        [Key]
        [DatabaseGenerated(DatabaseGeneratedOption.Identity)]
        public int Id { get; set; }

        [MaxLength(250)]
        public string PickupAddress { get; set; } = string.Empty;

        [StringLength(9, ErrorMessage = "Pickup postcode should not exceed 9 characters")]
        [MaxLength(9)]
        public string PickupPostCode { get; set; } = string.Empty;

        [MaxLength(250)]
        public string DestinationAddress { get; set; } = string.Empty;

        [StringLength(9, ErrorMessage = "Destination postcode should not exceed 9 characters")]
        [MaxLength(9)]
        public string DestinationPostCode { get; set; } = string.Empty;

        [MaxLength(2000)]
        public string Details { get; set; } = string.Empty;

        [MaxLength(250)]
        public string? PassengerName { get; set; } = string.Empty;

        public int Passengers { get; set; } = 1;

        [MaxLength(20)]
        public string? PhoneNumber { get; set; } = string.Empty;

        [MaxLength(250)]
        public string Email { get; set; } = string.Empty;

        public DateTime PickupDateTime { get; set; }

        public DateTime? ArriveBy { get; set; }

        public bool IsAllDay { get; set; }

        [DefaultValue(15)]
        public int DurationMinutes { get; set; }

        public string? RecurrenceRule { get; set; } = string.Empty;
        public int? RecurrenceID { get; set; }
        public string? RecurrenceException { get; set; } = string.Empty;

        [MaxLength(250)]
        public string BookedByName { get; set; } = string.Empty;

        public ConfirmationStatus? ConfirmationStatus { get; set; }
        
        public PaymentStatus? PaymentStatus { get; set; }

        public BookingScope? Scope { get; set; }

        public int? AccountNumber { get; set; }
        public int? InvoiceNumber { get; set; }

        [Precision(18,2)]
        public decimal Price { get; set; }

        [Precision(18, 2)]
        public decimal Tip { get; set; }

        public bool ManuallyPriced { get; set; } = false;
        
        [Precision(18, 2)]
        public decimal PriceAccount { get; set; }
        
        [Precision(18, 2)]
        public decimal? Mileage { get; set; }
        public string? MileageText { get; set; }
        public string? DurationText { get; set; }

        [DefaultValue(false)]
        public bool ChargeFromBase { get; set; } = false;

        [DefaultValue(false)]
        public bool Cancelled { get; set; } = false;

        [DefaultValue(false)]
        public bool CancelledOnArrival { get; set; } = false;

        public int? UserId { get; set; }

        public int? SuggestedUserId { get; set; }

        [ForeignKey(nameof(UserId))]
        public virtual UserProfile? User { get; set; }

        [SwaggerIgnoreProperty]
        public DateTime DateCreated { get; set; }

        [SwaggerIgnoreProperty]
        public DateTime? DateUpdated { get; set; }

        [MaxLength(250)]
        public string? UpdatedByName { get; set; } = string.Empty;

        [MaxLength(250)]
        public string? CancelledByName { get; set; } = string.Empty;
        
       // [NotMapped]
        public int ActionByUserId { get; set; }

        [SwaggerIgnoreProperty]
        [IgnoreDataMember]
        public virtual List<BookingVia>? Vias { get; set; }

        [ForeignKey(nameof(StatementId))]
        public virtual DriverInvoiceStatement? DriverInvoiceStatement { get; set; }
        
        public int? StatementId { get; set; }

        //[Required]
        public VehicleType VehicleType { get; set; }

        public int WaitingTimeMinutes {  get; set; }
        [Precision(18, 2)]
        public decimal WaitingTimePriceDriver { get; set; }
        [Precision(18, 2)]
        public decimal WaitingTimePriceAccount { get; set; }
        [Precision(18, 2)]
        public decimal ParkingCharge { get; set; }

        public bool PostedForInvoicing { get; set; }

        public bool PostedForStatement { get; set; }

        public DateTime? AllocatedAt { get; set; }

        public int? AllocatedById { get; set; }

        public BookingStatus? Status { get; set; }

        public string? PaymentOrderId { get; set; }

        public string? PaymentLink { get; set; }

        public string? PaymentLinkSentBy { get; set; }
        public DateTime? PaymentLinkSentOn { get; set; }
        public bool PaymentReceiptSent { get; set; }
        
        public bool IsASAP { get; set; }
        [Precision(18, 2)]
        public decimal VatAmountAdded { get; set; }

        [IgnoreDataMember]
        public string CellText
        {
            get 
            {
                var ct = Scope == BookingScope.Account ? PassengerName : $"{PickupAddress} -- {DestinationAddress}";
                return ct;
            }   
        }
        

        public object Clone()
        {
            return MemberwiseClone();
        }
    }
}


## 7. Account Entity
﻿
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace TaxiDispatch.Data.Models
{
    public class Account
    {
        [Key]
        [DatabaseGenerated(DatabaseGeneratedOption.Identity)]
        public int AccNo { get; set; }

        [Required]
        public string ContactName { get; set; }

        [Required]
        public string BusinessName { get; set; }
        [Required]
        public string Address1 { get; set; }
        [Required]
        public string Address2 { get; set; }

        public string Address3 { get; set; } = string.Empty;
        public string Address4 { get; set; } = string.Empty;

        [Required]
        public string Postcode { get; set; }
        
        [Required]
        public string Telephone { get; set; }

        public string? PurchaseOrderNo { get; set; }
        public string? Reference { get; set; }

        [Required]
        public string Email { get; set; }

        public string BookerEmail { get; set; } = string.Empty;
        public string BookerName { get; set; } = string.Empty;

        public bool Deleted { get; set; }

        public int? AccountTariffId { get; set; }

        [ForeignKey(nameof(AccountTariffId))]
        public virtual AccountTariff? AccountTariff { get; set; }
    }
}


## 8. UserProfile Entity
﻿using TaxiDispatch.Domain;
using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace TaxiDispatch.Data.Models
{
    public partial class UserProfile
    {
        public UserProfile()
        {
            VehicleType = VehicleType.Unknown;
        }

        [PersonalData, StringLength(20)]
        public string? RegNo { get; set; }

        [PersonalData, StringLength(12)]
        public string? ColorCodeRGB { get; set; }

        [PersonalData, StringLength(500)]
        public string? NotificationFCM { get; set; }

        [PersonalData, StringLength(500)]
        public string? ChromeFCM { get; set; }

        // GPS
        [PersonalData]
        [Precision(10, 7)]
        public decimal? Longitude { get; set; }

        [PersonalData]
        [Precision(9, 7)]
        public decimal? Latitude { get; set; }

        [PersonalData]
        [Precision(6, 3)]
        public decimal? Heading { get; set; }

        [PersonalData]
        [Precision(6, 2)]
        public decimal? Speed { get; set; }

        [PersonalData]
        public DateTime? GpsLastUpdated { get; set; }
        // GPS

        [PersonalData, StringLength(20)]
        public string? VehicleMake { get; set; }
        [PersonalData, StringLength(30)]
        public string? VehicleModel { get; set; }
        [PersonalData, StringLength(20)]
        public string? VehicleColour { get; set; }

        public bool ShowAllBookings { get; set; }
        public bool ShowHVSBookings { get; set; }

        public bool IsDeleted { get; set; }

        public DateTime? LastLogin { get; set; }

        public int CashCommissionRate { get; set; }

        [Required]
        public VehicleType VehicleType { get; set; }

        [Required]
        public bool NonAce { get; set; }

        public SendMessageOfType CommsPlatform { get; set; } = SendMessageOfType.WhatsApp;

        [Key]
        public int UserId { get; set; }

        [ForeignKey(nameof(UserId))]
        public virtual AppUser User { get; set; }

    }
}




## 9. DriverInvoiceStatement Entity
﻿using System.ComponentModel.DataAnnotations.Schema;
using System.ComponentModel.DataAnnotations;
using System.Runtime.Serialization;

namespace TaxiDispatch.Data.Models
{
    public class DriverInvoiceStatement
    {
        public DriverInvoiceStatement()
        {
            DateCreated = DateTime.Now.ToUKTime();
        }

        [Key]
        [DatabaseGenerated(DatabaseGeneratedOption.Identity)]
        public int StatementId { get; set; }

        [Required]
        public int UserId { get; set; }
        [Required]
        public DateTime StartDate { get; set; }
        [Required]
        public DateTime EndDate { get; set; }

        [IgnoreDataMember]
        public int TotalJobCount { get { return AccountJobsTotalCount + CashJobsTotalCount; } }

        [Required]
        public int AccountJobsTotalCount { get; set; }

        [Required]
        public int CashJobsTotalCount { get; set; }

        [Required]
        public int RankJobsTotalCount { get; set; }

        [Required]
        public double EarningsAccount { get; set; }

        [Required]
        public double EarningsCash { get; set; }

        [Required]
        public double EarningsCard { get; set; }

        [Required]
        public double CardFees { get; set; }

        [Required]
        public double EarningsRank { get; set; }

        [Required]
        public double CommissionDue { get; set; }

        [NotMapped]
        public double PaymentDue { get { return EarningsAccount + EarningsCard - CommissionDue; } }

        [Required]
        public double SubTotal { get; set; }

        [Required]
        public bool PaidInFull { get; set; }

        [SwaggerIgnoreProperty]
        public DateTime DateCreated { get; set; } = DateTime.Now.ToUKTime();

        [SwaggerIgnoreProperty]
        [DatabaseGenerated(DatabaseGeneratedOption.Computed)]
        public DateTime? DateUpdated { get; set; }

    }
}


## 10. AccountInvoice Entity
﻿using System.ComponentModel.DataAnnotations.Schema;
using System.ComponentModel.DataAnnotations;
using Microsoft.EntityFrameworkCore;

namespace TaxiDispatch.Data.Models
{
    public class AccountInvoice
    {
        public AccountInvoice() 
        {

        }

        [Key]
        [DatabaseGenerated(DatabaseGeneratedOption.Identity)]
        public int InvoiceNumber { get; set; }

        [Required]
        public DateTime Date { get; set; }

        [Required]
        [Precision(18, 2)]
        public decimal VatTotal { get; set; }

        [Required]
        [Precision(18, 2)]
        public decimal NetTotal { get; set; }

        [Required]
        [Precision(18, 2)]
        public decimal Total { get; set; }

        [Required]
        public int NumberOfJourneys { get; set; }

        [Required]
        public bool Paid { get; set; }
        
        [Required]
        public bool Cancelled { get; set; }
        
        [Required]
        public int AccountNo { get; set; }

        public string? PurchaseOrderNo { get; set; }
        public string? Reference { get; set; }
    }
}


## 11. Tariff Entity
﻿using TaxiDispatch.Domain;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace TaxiDispatch.Data.Models
{
    public class Tariff
    {
        public Tariff()
        {
            DateCreated = DateTime.Now.ToUKTime();
        }
        [Key]
        [DatabaseGenerated(DatabaseGeneratedOption.Identity)]
        public int Id { get; set; }

        public TariffType Type { get; set; }
        public string Name { get; set; }
        public string Description { get; set; }
        public double InitialCharge { get; set; }
        public double FirstMileCharge { get; set; }
        public double AdditionalMileCharge { get; set; }

        [SwaggerIgnoreProperty]
        public DateTime DateCreated { get; set; } = DateTime.Now.ToUKTime();
        [SwaggerIgnoreProperty]
        public DateTime? DateUpdated { get; set; }
    }
}


## 12. AccountTariff Entity
﻿using System.ComponentModel.DataAnnotations.Schema;
using System.ComponentModel.DataAnnotations;

namespace TaxiDispatch.Data.Models
{
    public class AccountTariff
    {
        public AccountTariff() { }

        [Key]
        [DatabaseGenerated(DatabaseGeneratedOption.Identity)]
        public int Id { get; set; }
        
        public string Name { get; set; }

        public double AccountInitialCharge { get; set; }
        public double DriverInitialCharge { get; set; }
        
        public double AccountFirstMileCharge { get; set; }
        public double DriverFirstMileCharge { get; set; }

        public double AccountAdditionalMileCharge { get; set; }
        public double DriverAdditionalMileCharge { get; set; }

        [SwaggerIgnoreProperty]
        public DateTime DateCreated { get; set; } = DateTime.Now.ToUKTime();
        [SwaggerIgnoreProperty]
        public DateTime? DateUpdated { get; set; }
    }
}


## 13. MessagingNotifyConfig Entity
﻿using TaxiDispatch.Domain;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace TaxiDispatch.Data.Models
{
    public class MessagingNotifyConfig
    {
        [Key]
        [DatabaseGenerated(DatabaseGeneratedOption.Identity)]
        public int Id { get; set; }

        [Required]
        public SendMessageOfType DriverOnAllocate { get; set; } = SendMessageOfType.None;

        [Required]
        public SendMessageOfType DriverOnUnAllocate { get; set; } = SendMessageOfType.None;

        [Required]
        public SendMessageOfType CustomerOnAllocate { get; set; } = SendMessageOfType.None;

        [Required]
        public SendMessageOfType CustomerOnUnAllocate { get; set; } = SendMessageOfType.None;

        [Required]
        public SendMessageOfType DriverOnAmend { get; set; } = SendMessageOfType.None;

        [Required]
        public SendMessageOfType CustomerOnAmend { get; set; } = SendMessageOfType.None;

        [Required]
        public SendMessageOfType DriverOnCancel { get; set; } = SendMessageOfType.None;

        [Required]
        public SendMessageOfType CustomerOnCancel { get; set; } = SendMessageOfType.None;

        [Required]
        public SendMessageOfType CustomerOnComplete { get; set; } = SendMessageOfType.None;

        public string IgnoreAccountNos { get; set; }

        public DateTime? SmsPhoneHeartBeat { get; set; }

    }
}


## 14. WebBooking Entity
﻿using System.ComponentModel.DataAnnotations.Schema;
using System.ComponentModel.DataAnnotations;
using TaxiDispatch.Domain;
using Microsoft.EntityFrameworkCore;

namespace TaxiDispatch.Data.Models
{
    public class WebBooking
    {
        [Key]
        [DatabaseGenerated(DatabaseGeneratedOption.Identity)]
        public int Id { get; set; }
        public int AccNo { get; set; }

        public DateTime PickupDateTime { get; set; }
        public bool ArriveBy { get; set; }
        public string? RecurrenceRule { get; set; } = string.Empty;

        [MaxLength(250)]
        public string PickupAddress { get; set; } = string.Empty;

        [StringLength(9, ErrorMessage = "Pickup postcode should not exceed 9 characters")]
        [MaxLength(9)]
        public string PickupPostCode { get; set; } = string.Empty;

        [MaxLength(250)]
        public string DestinationAddress { get; set; } = string.Empty;

        [StringLength(9, ErrorMessage = "Destination postcode should not exceed 9 characters")]
        [MaxLength(9)]
        public string DestinationPostCode { get; set; } = string.Empty;

        [MaxLength(2000)]
        public string Details { get; set; } = string.Empty;

        [MaxLength(250)]
        public string? PassengerName { get; set; } = string.Empty;

        public int Passengers { get; set; } = 1;

        [MaxLength(20)]
        public string? PhoneNumber { get; set; } = string.Empty;

        [MaxLength(250)]
        public string Email { get; set; } = string.Empty;
        public BookingScope? Scope { get; set; }

        //
        public int? Luggage { get; set; }
        public int? DurationMinutes { get; set; }
        [Precision(18,2)]
        public decimal? Mileage { get; set; }
        public string? MileageText { get; set; }
        public string? DurationText { get; set; }
        public double? Price { get; set; }
        //

        public DateTime CreatedOn { get; set; }
        public string CreatedBy { get; set; } = string.Empty;
        public string AcceptedRejectedBy { get; set; } = string.Empty;
        public DateTime? AcceptedRejectedOn { get; set; }
        public string? RejectedReason { get; set; } = string.Empty;
        public bool Processed { get; set; } = false;
        public WebBookingStatus Status { get; set; } = WebBookingStatus.Default;
        
        [NotMapped]
        public string RepeatText { get; set; } = string.Empty;

        public object Clone()
        {
            return MemberwiseClone();
        }
    }
}


## 15. CreditNote Entity
﻿using Microsoft.EntityFrameworkCore;
using System.ComponentModel.DataAnnotations.Schema;
using System.ComponentModel.DataAnnotations;

namespace TaxiDispatch.Data.Models
{
    public class CreditNote
    {
        [Key]
        [DatabaseGenerated(DatabaseGeneratedOption.Identity)]
        public int Id { get; set; }

        [Required]
        public DateTime Date { get; set; }

        [Required]
        [Precision(18, 2)]
        public decimal VatTotal { get; set; }

        [Required]
        [Precision(18, 2)]
        public decimal NetTotal { get; set; }

        [Required]
        [Precision(18, 2)]
        public decimal Total { get; set; }

        [Required]
        public int NumberOfJourneys { get; set; }
        
        [Required]
        public string AccountNo { get; set; }
        
        public int InvoiceNumber { get; set; }
        
        public DateTime InvoiceDate { get; set; }
        
        public string Reason { get; set; }
    }
}


## 16. All Entities (DbSet)
        public virtual DbSet<AppRefreshToken> AppRefreshTokens { get; set; }
        public virtual DbSet<TenantUser> TenantUsers { get; set; }
        public virtual DbSet<DriverUserProfile> DriverUserProfiles { get; set; }
        public virtual DbSet<AccountUserLink> AccountUserLinks { get; set; }
        public virtual DbSet<UserDeviceRegistration> UserDeviceRegistrations { get; set; }
        public virtual DbSet<Booking> Bookings { get; set; }
        public virtual DbSet<BookingVia> BookingVias { get; set; }
        public virtual DbSet<BookingChangeAudit> BookingChangeAudits { get; set; }
        public virtual DbSet<Tariff> Tariffs { get; set; }
        public virtual DbSet<LocalPOI> LocalPOIs { get; set; }
        public virtual DbSet<UserProfile> UserProfiles { get; set; }
        public virtual DbSet<DriverInvoiceStatement> DriverInvoiceStatements { get; set; }
        public virtual DbSet<DriverAvailability> DriverAvailabilities { get; set; }
        public virtual DbSet<DriverLocationHistory> DriverLocationHistories { get; set; }
        public virtual DbSet<DriverMessage> DriverMessages { get; set; }
        public virtual DbSet<DriverAllocation> DriverAllocations { get; set; }
        public virtual DbSet<Account> Accounts { get; set; }
        public virtual DbSet<AccountInvoice> AccountInvoices { get; set; }
        public virtual DbSet<CompanyConfig> CompanyConfig { get; set; }
        public virtual DbSet<MessagingNotifyConfig> MessagingNotifyConfig { get; set; }
        public virtual DbSet<ReviewRequest> ReviewRequests { get; set; }
        public virtual DbSet<DriverAvailabilityAudit> DriverAvailabilityAudits { get; set; }
        public virtual DbSet<TurnDown> TurnDowns { get; set; }
        public virtual DbSet<WebBooking> WebBookings { get; set; }
        public virtual DbSet<AccountPassenger> AccountPassengers { get; set; }
        public virtual DbSet<DriverOnShift> DriversOnShift { get; set; }
        public virtual DbSet<DriverExpense> DriverExpenses { get; set; }
        public virtual DbSet<DriverShiftLog> DriversShiftLogs { get; set; }
        public virtual DbSet<UINotification> UINotifications { get; set; }
        public virtual DbSet<WebAmendmentRequest> WebAmendmentRequests { get; set; }
        public virtual DbSet<DocumentExpiry> DocumentExpirys { get; set; }
        public virtual DbSet<UserActionLog> UserActionsLog { get; set; }
        public virtual DbSet<JobOffer> JobOffers { get; set; }
        public virtual DbSet<UrlMapping> UrlMappings { get; set; }
        public virtual DbSet<CreditNote> CreditNotes { get; set; }
        public virtual DbSet<COARecord> COARecords { get; set; }
        public virtual DbSet<AccountTariff> AccountTariffs { get; set; }
        public virtual DbSet<GeoFence> GeoFences { get; set; }
        public virtual DbSet<QRCodeClick> QRCodeClicks { get; set; }
        public virtual DbSet<ZoneToZonePrice> ZoneToZonePrices { get; set; }

## 17. Messaging Service Methods
21:    public class AceMessagingService : MessageService, IMessageService
23:        private readonly TaxiDispatchContext _db;
24:        private readonly ILogger<AceMessagingService> _logger;
25:        private AvailabilityService _availabilityService;
26:        private readonly UINotificationService _notificationService;
29:        public AceMessagingService(
44:        public async Task<SendMessageOfType> GetMessageTypeToSend(SentMessageType type)
53:                    case SentMessageType.DriverOnAllocate:
56:                    case SentMessageType.DriverOnUnAllocate:
59:                    case SentMessageType.DriverOnAmend:
62:                    case SentMessageType.DriverOnCancel:
65:                    case SentMessageType.CustomerOnAllocate:
68:                    case SentMessageType.CustomerOnUnAllocate:
71:                    case SentMessageType.CustomerOnAmend:
74:                    case SentMessageType.CustomerOnCancel:
77:                    case SentMessageType.CustomerOnComplete:
88:        public async Task SendEmailRaiseTicket(string subject, string messageBody, Stream stream, string filename)
125:        public async Task SendCashBookingAcceptedEmail(string toEmail, string toName, BookingAcceptedEmail dto)
131:        public async Task SendAccountBookingCancelledEmail(string toEmail, string toName, BookingCancelledEmail dto)
137:        public async Task SendAccountBookingAcceptedEmail(string toEmail, string toName, BookingAcceptedEmail dto)
143:        public async Task SendCashBookingRejectedEmail(string toEmail, string toName, BookingRejectedEmail dto)
149:        public async Task SendAccountBookingRejectedEmail(string toEmail, string toName, BookingRejectedEmail dto)
155:        public async Task SendAccountRegistrationEmail(string toEmail, string toName, NewUserRegisteredDto dto)
161:        public async Task SendRegistrationEmail(string toEmail, string toName, NewUserRegisteredDto dto)
167:        public async Task SendDriverStatementEmail(string toEmail, string toName, DriverStatementDto dto)
173:        public async Task SendDriverStatementEmail(string toEmail, string toName, DriverStatementDto dto, string filename, string base64Content)
179:        public async Task SendDriverStatementResendEmail(string toEmail, string toName,  string filename, string base64Content)
186:        public async Task SendAccountInvoiceEmail(string toEmail, string toName, AccountInvoiceTemplateDto dto, string filename, string base64Content)
192:        public async void SendCustomerQuoteEmail(SendQuoteDto req)
205:        public async Task SendAccountCreditNoteEmail(string toEmail, string toName, string filename, string base64Content)
212:        public async Task SendAccountInvoiceEmailProDisability(string toEmail, string passengerName, string toName, AccountInvoiceTemplateDto dto, string filename, string base64Content)
214:            var templateid = "d-81e7ebe0e76241448e37b5b3cf0ac8e4";
217:            await SendTransactionalEmail(toEmail, toName, subject, templateid, dto, filename, base64Content);
220:        public async Task SendPaymentLinkEmail(string toEmail, string toName, PaymentLinkTemplateDto dto)
226:        public async Task<bool> SendPaymentReceiptEmail(string toEmail, string toName, string filename, string base64Content)
228:            var templateid = "d-46dd090bd0a44088ab2b490728ce7b00";
230:            return await SendTransactionalEmail(toEmail, toName, "Ace Taxis - Payment Receipt", templateid ,dto, filename, base64Content);
233:        public async Task<bool> SendAccountInvoiceAttachmentsEmail(string toEmail, string toName, Dictionary<string,string> attachments)
235:            var templateid = "d-7971cadd2ddd4532aa0f8192cfbe26a7";
237:            return await SendTransactionalEmail(toEmail, toName, "Ace Taxis - Invoice", templateid, dto, attachments);
240:        private async Task SendEmailTemplate(string toEmail, string toName, EmailTemplates template, object data, string filename = "", string base64Content = "")
242:            var templateid = string.Empty;
248:                    templateid = "d-588cd7318d7e40e4b4246e0fca058d59";
251:                    templateid = "d-d2a3ffefe29940369e7426df64169845";
254:                    templateid = "d-7971cadd2ddd4532aa0f8192cfbe26a7";
257:                    templateid = "d-743a839078a34921929932a5a73ef49a";
260:                    templateid = "d-46dd090bd0a44088ab2b490728ce7b00";
263:                    templateid = "d-6378c357f86244f696a4d63db4239c4c";
266:                    templateid = "d-b1c28ecd630b4d3dab7866d8137fc946";
269:                    templateid = "d-267592ce42de41e2909b2ad667cdbddd";
272:                    templateid = "d-312f2ba92b364f84addffcffbe247724";
275:                    templateid = "d-877358eb4ca54c62bd24432ce55f6d4b";
278:                    templateid = "d-2dbd0524f3ed475c8d28a190ec0d1fa4";
281:                    templateid = "d-17d734a8a9054d51981ead3eaf904fc0";
284:                    templateid = "d-e50cef9cdd5347d79eda80c8de33188d";
287:                    templateid = "d-0b8454822a1e4571bb925126f5e7683e";
292:                await SendTransactionalEmail(toEmail, toName, subject, templateid, data);
294:                await SendTransactionalEmail(toEmail, toName, subject, templateid, data, filename, base64Content);
300:        public async Task SendWhatsAppCancelled(string passengerName, DateTime date, string telephone)
313:        public async Task SendWhatsAppUnAllocated(string passengerName, DateTime date, string telephone)

## 18. Driver App API Endpoints
api/DriverApp
api/DriverApp/DeleteAvailability
api/DriverApp/RetrieveJobOffer
api/logs

## 19. Driver App Screens
ace-driver-app/lib/screens/add_expense_screen.dart
ace-driver-app/lib/screens/availability_screen.dart
ace-driver-app/lib/screens/booking_log_screen.dart
ace-driver-app/lib/screens/booking_screen.dart
ace-driver-app/lib/screens/bookings_details_screen.dart
ace-driver-app/lib/screens/completed_job_screen.dart
ace-driver-app/lib/screens/create_booking_screen.dart
ace-driver-app/lib/screens/dashboard_screen.dart
ace-driver-app/lib/screens/document_screen.dart
ace-driver-app/lib/screens/earning_report_screen.dart
ace-driver-app/lib/screens/gps_service.dart
ace-driver-app/lib/screens/home_screen.dart
ace-driver-app/lib/screens/job_offer_screen.dart
ace-driver-app/lib/screens/live_gps_logs_screen.dart
ace-driver-app/lib/screens/login_screen.dart
ace-driver-app/lib/screens/messages_screen.dart
ace-driver-app/lib/screens/profile_screen.dart
ace-driver-app/lib/screens/report_screen.dart
ace-driver-app/lib/screens/scheduler_screen.dart
ace-driver-app/lib/screens/settings_screen.dart
ace-driver-app/lib/screens/splash_screen.dart
ace-driver-app/lib/screens/trip_details_screen.dart
ace-driver-app/lib/screens/view_expenses_screen.dart
ace-driver-app/lib/screens/webview_screen.dart
ace-driver-app/lib/screens/your_statement_screen.dart

## 20. Admin Panel Pages
ace-admin-panel/src/pages/account/PageNavbar.jsx
ace-admin-panel/src/pages/account/activity/AccountActivityContent.jsx
ace-admin-panel/src/pages/account/activity/AccountActivityPage.jsx
ace-admin-panel/src/pages/account/api-keys/AccountApiKeysContent.jsx
ace-admin-panel/src/pages/account/api-keys/AccountApiKeysPage.jsx
ace-admin-panel/src/pages/account/api-keys/blocks/Webhooks.jsx
ace-admin-panel/src/pages/account/appearance/AccountAppearanceContent.jsx
ace-admin-panel/src/pages/account/appearance/AccountAppearancePage.jsx
ace-admin-panel/src/pages/account/appearance/blocks/Accessibility.jsx
ace-admin-panel/src/pages/account/appearance/blocks/DisableDefaultBrand.jsx
ace-admin-panel/src/pages/account/appearance/blocks/Webhooks.jsx
ace-admin-panel/src/pages/account/billing/basic/AccountBasicContent.jsx
ace-admin-panel/src/pages/account/billing/basic/AccountBasicPage.jsx
ace-admin-panel/src/pages/account/billing/enterprise/AccountEnterpriseContent.jsx
ace-admin-panel/src/pages/account/billing/enterprise/AccountEnterprisePage.jsx
ace-admin-panel/src/pages/account/billing/history/AccountHistoryContent.jsx
ace-admin-panel/src/pages/account/billing/history/AccountHistoryPage.jsx
ace-admin-panel/src/pages/account/billing/plans/AccountPlansContent.jsx
ace-admin-panel/src/pages/account/billing/plans/AccountPlansPage.jsx
ace-admin-panel/src/pages/account/home/company-profile/AccountCompanyProfileContent.jsx
ace-admin-panel/src/pages/account/home/company-profile/AccountCompanyProfilePage.jsx
ace-admin-panel/src/pages/account/home/get-started/AccountGetStartedContent.jsx
ace-admin-panel/src/pages/account/home/get-started/AccountGetStartedPage.jsx
ace-admin-panel/src/pages/account/home/settings-enterprise/AccountSettingsEnterpriseContent.jsx
ace-admin-panel/src/pages/account/home/settings-enterprise/AccountSettingsEnterprisePage.jsx
ace-admin-panel/src/pages/account/home/settings-modal/AccountSettingsModal.jsx
ace-admin-panel/src/pages/account/home/settings-modal/AccountSettingsModalPage.jsx
ace-admin-panel/src/pages/account/home/settings-modal/AccountSettingsModal_.jsx
ace-admin-panel/src/pages/account/home/settings-plain/AccountSettingsPlainContent.jsx
ace-admin-panel/src/pages/account/home/settings-plain/AccountSettingsPlainPage.jsx
ace-admin-panel/src/pages/account/home/settings-sidebar/AccountSettingsSidebar.jsx
ace-admin-panel/src/pages/account/home/settings-sidebar/AccountSettingsSidebarContent.jsx
ace-admin-panel/src/pages/account/home/settings-sidebar/AccountSettingsSidebarPage.jsx
ace-admin-panel/src/pages/account/home/user-profile/AccountUserProfileContent.jsx
ace-admin-panel/src/pages/account/home/user-profile/AccountUserProfilePage.jsx
ace-admin-panel/src/pages/account/integrations/AccountIntegrationsContent.jsx
ace-admin-panel/src/pages/account/integrations/AccountIntegrationsPage.jsx
ace-admin-panel/src/pages/account/integrations/blocks/Integrations.jsx
ace-admin-panel/src/pages/account/invite-a-friend/AccountInviteAFriendContent.jsx
ace-admin-panel/src/pages/account/invite-a-friend/AccountInviteAFriendPage.jsx
ace-admin-panel/src/pages/account/invite-a-friend/blocks/InvitePeople.jsx
ace-admin-panel/src/pages/account/members/import-members/AccountImportMembersContent.jsx
ace-admin-panel/src/pages/account/members/import-members/AccountImportMembersPage.jsx
ace-admin-panel/src/pages/account/members/members-starter/AccountMembersStarterContent.jsx
ace-admin-panel/src/pages/account/members/members-starter/AccountMembersStarterPage.jsx
ace-admin-panel/src/pages/account/members/permissions-check/AccountPermissionsCheckContent.jsx
ace-admin-panel/src/pages/account/members/permissions-check/AccountPermissionsCheckPage.jsx
ace-admin-panel/src/pages/account/members/permissions-toggle/AccountPermissionsToggleContent.jsx
ace-admin-panel/src/pages/account/members/permissions-toggle/AccountPermissionsTogglePage.jsx
ace-admin-panel/src/pages/account/members/roles/AccountRolesContent.jsx
ace-admin-panel/src/pages/account/members/roles/AccountRolesPage.jsx
ace-admin-panel/src/pages/account/members/team-info/AccountTeamInfoContent.jsx
ace-admin-panel/src/pages/account/members/team-info/AccountTeamInfoPage.jsx
ace-admin-panel/src/pages/account/members/team-members/AccountTeamMembersContent.jsx
ace-admin-panel/src/pages/account/members/team-members/AccountTeamMembersPage.jsx
ace-admin-panel/src/pages/account/members/team-starter/AccountTeamsStarterContent.jsx
ace-admin-panel/src/pages/account/members/team-starter/AccountTeamsStarterPage.jsx
ace-admin-panel/src/pages/account/members/teams/AccountTeamsContent.jsx
ace-admin-panel/src/pages/account/members/teams/AccountTeamsPage.jsx
ace-admin-panel/src/pages/account/notifications/AccountNotificationsContent.jsx
ace-admin-panel/src/pages/account/notifications/AccountNotificationsPage.jsx
ace-admin-panel/src/pages/account/notifications/blocks/Channels.jsx
ace-admin-panel/src/pages/account/notifications/blocks/DoNotDistrub.jsx
ace-admin-panel/src/pages/account/notifications/blocks/OtherNotifications.jsx
ace-admin-panel/src/pages/account/security/allowed-ip-addresses/AccountAllowedIPAddressesContent.jsx
ace-admin-panel/src/pages/account/security/allowed-ip-addresses/AccountAllowedIPAddressesPage.jsx
ace-admin-panel/src/pages/account/security/backup-and-recovery/AccountBackupAndRecoveryContent.jsx
ace-admin-panel/src/pages/account/security/backup-and-recovery/AccountBackupAndRecoveryPage.jsx
ace-admin-panel/src/pages/account/security/current-sessions/AccountCurrentSessionsContent.jsx
ace-admin-panel/src/pages/account/security/current-sessions/AccountCurrentSessionsPage.jsx
ace-admin-panel/src/pages/account/security/device-management/AccountDeviceManagementContent.jsx
ace-admin-panel/src/pages/account/security/device-management/AccountDeviceManagementPage.jsx
ace-admin-panel/src/pages/account/security/get-started/AccountSecurityGetStartedContent.jsx
ace-admin-panel/src/pages/account/security/get-started/AccountSecurityGetStartedPage.jsx
ace-admin-panel/src/pages/account/security/overview/AccountOverviewContent.jsx
ace-admin-panel/src/pages/account/security/overview/AccountOverviewPage.jsx
ace-admin-panel/src/pages/account/security/privacy-settings/AccountPrivacySettingsContent.jsx
ace-admin-panel/src/pages/account/security/privacy-settings/AccountPrivacySettingsPage.jsx
ace-admin-panel/src/pages/account/security/security-log/AccountSecurityLogContent.jsx
ace-admin-panel/src/pages/account/security/security-log/AccountSecurityLogPage.jsx
ace-admin-panel/src/pages/accountTariffs/addAccountTariffs/addAccountTariffs.jsx
ace-admin-panel/src/pages/accountTariffs/editAccountTariffs/editAccountTariffs.jsx
ace-admin-panel/src/pages/accountTariffs/listAccountTariffs/listAccountTariffs.jsx
ace-admin-panel/src/pages/accounts/addAccounts/addAccounts.jsx
ace-admin-panel/src/pages/accounts/deleteAccounts/deleteAccounts.jsx
ace-admin-panel/src/pages/accounts/editAccounts/editAccounts.jsx
ace-admin-panel/src/pages/accounts/listAccounts/listAccounts.jsx
ace-admin-panel/src/pages/authentication/account-deactivated/AuthenticationAccountDeactivatedPage.jsx
ace-admin-panel/src/pages/authentication/get-started/AuthenticationGetStartedPage.jsx
ace-admin-panel/src/pages/authentication/welcome-message/AuthenticationWelcomeMessagePage.jsx
ace-admin-panel/src/pages/billing&Payments/account/creditJourneys/creditJourneys.jsx
ace-admin-panel/src/pages/billing&Payments/account/creditNotes/creditNotes.jsx
ace-admin-panel/src/pages/billing&Payments/account/invoiceDelete/invoiceDelete.jsx
ace-admin-panel/src/pages/billing&Payments/account/invoiceHistory/invoiceHistory.jsx
ace-admin-panel/src/pages/billing&Payments/account/invoiceProcessor/invoiceProcessor.jsx
ace-admin-panel/src/pages/billing&Payments/account/invoiceProcessorGroups/SharedTab.jsx
ace-admin-panel/src/pages/billing&Payments/account/invoiceProcessorGroups/SinglesTab.jsx
ace-admin-panel/src/pages/billing&Payments/account/invoiceProcessorGroups/invoiceProcessorGroups.jsx
ace-admin-panel/src/pages/billing&Payments/driver/statementHistory/statementHistory.jsx
ace-admin-panel/src/pages/billing&Payments/driver/statementProcessing/stateProcessing.jsx
ace-admin-panel/src/pages/billing&Payments/tableFilterBar/tableFilterBar.jsx
ace-admin-panel/src/pages/billing&Payments/vatOutputs/vatOutputs.jsx
ace-admin-panel/src/pages/booking/acceptedBookings/acceptedBookings.jsx
ace-admin-panel/src/pages/booking/airportRuns/airportRuns.jsx
ace-admin-panel/src/pages/booking/airportRuns/tablejourney.jsx
ace-admin-panel/src/pages/booking/amendmentBookings/amendmentBookings.jsx
ace-admin-panel/src/pages/booking/amendmentBookings/cancelModal/cancelModal.jsx
ace-admin-panel/src/pages/booking/auditBooking/auditBooking.jsx
ace-admin-panel/src/pages/booking/availability/availability-table.jsx
ace-admin-panel/src/pages/booking/availability/availability.jsx
ace-admin-panel/src/pages/booking/availability/customModal.jsx
ace-admin-panel/src/pages/booking/availability/selectedAvaliability.jsx
ace-admin-panel/src/pages/booking/availabilitylogs/availability-logs.jsx
ace-admin-panel/src/pages/booking/availabilityreport/availability-report.jsx
ace-admin-panel/src/pages/booking/booking&dispatch/booking-dispatch.jsx
ace-admin-panel/src/pages/booking/cancelbyrange/cancelbyRange.jsx
ace-admin-panel/src/pages/booking/cancelbyrangereport/cancelByRangeReport.jsx
ace-admin-panel/src/pages/booking/cardBookings/cardBookings.jsx
ace-admin-panel/src/pages/booking/new-booking/acceptWebBooking/acceptWebBooking.jsx
ace-admin-panel/src/pages/booking/new-booking/new-booking-from.jsx
ace-admin-panel/src/pages/booking/new-booking/rejectWebBooking/rejectWebBooking.jsx
ace-admin-panel/src/pages/booking/rejectedBookings/amendRejectedBooking/amendRejectBooking.jsx
ace-admin-panel/src/pages/booking/rejectedBookings/rejectedBookings.jsx
ace-admin-panel/src/pages/booking/searchBooking/addAccounts/addAccounts.jsx
ace-admin-panel/src/pages/booking/searchBooking/deleteAccounts/deleteAccounts.jsx
ace-admin-panel/src/pages/booking/searchBooking/editAccounts/editAccounts.jsx
ace-admin-panel/src/pages/booking/searchBooking/listAccounts/searchBooking.jsx
ace-admin-panel/src/pages/booking/tariff/tariff.jsx
ace-admin-panel/src/pages/booking/tracking/driver-tracking.jsx
ace-admin-panel/src/pages/booking/turndownBookings/turndownBookings.jsx
ace-admin-panel/src/pages/bookingSettings/companySettings/companySetting.jsx
ace-admin-panel/src/pages/bookingSettings/msgSettings/msgSettings.jsx
ace-admin-panel/src/pages/bookingUtilities/hvsAccountChanges/hvsAccountChanges.jsx
ace-admin-panel/src/pages/dashboards/default/DefaultPage.jsx
ace-admin-panel/src/pages/dashboards/demo1/dark-sidebar/Demo1DarkSidebarPage.jsx
ace-admin-panel/src/pages/dashboards/demo1/light-sidebar/Demo1LightSidebarContent.jsx
ace-admin-panel/src/pages/dashboards/demo1/light-sidebar/Demo1LightSidebarPage.jsx
ace-admin-panel/src/pages/dashboards/demo2/Demo2Content.jsx
ace-admin-panel/src/pages/dashboards/demo2/Demo2Page.jsx
ace-admin-panel/src/pages/dashboards/demo2/blocks/Integrations.jsx
ace-admin-panel/src/pages/dashboards/demo2/blocks/ManageData.jsx
ace-admin-panel/src/pages/dashboards/demo2/blocks/MyBalance.jsx
ace-admin-panel/src/pages/dashboards/demo2/blocks/Options.jsx
ace-admin-panel/src/pages/dashboards/demo3/Demo3Content.jsx
ace-admin-panel/src/pages/dashboards/demo3/Demo3Page.jsx
ace-admin-panel/src/pages/dashboards/demo3/blocks/Integrations.jsx
ace-admin-panel/src/pages/dashboards/demo4/Demo4Content.jsx
ace-admin-panel/src/pages/dashboards/demo4/Demo4Page.jsx
ace-admin-panel/src/pages/dashboards/demo5/Demo5Content.jsx
ace-admin-panel/src/pages/dashboards/demo5/Demo5Page.jsx
ace-admin-panel/src/pages/dashboards/demo5/blocks/Options.jsx
ace-admin-panel/src/pages/dispatch/allocated/allocated.jsx
ace-admin-panel/src/pages/dispatch/cancelled/cancelled.jsx
ace-admin-panel/src/pages/dispatch/completed/completed.jsx
ace-admin-panel/src/pages/dispatch/unAllocated/allocateBookingModal/allocatedBookingModal.jsx
ace-admin-panel/src/pages/dispatch/unAllocated/unAllocated.jsx
ace-admin-panel/src/pages/driverEarningReport/driverEarning/driverEarningReport.jsx
ace-admin-panel/src/pages/driverExpenses/driverExpense/driverExpenses.jsx
ace-admin-panel/src/pages/drivers/deleteDriver/deleteDriver.jsx
ace-admin-panel/src/pages/drivers/driverExpiry/addExpiry/addExpiry.jsx
ace-admin-panel/src/pages/drivers/driverExpiry/driverExpiryList/driverExpiryList.jsx
ace-admin-panel/src/pages/drivers/driverExpiry/updateExpiry/updateExpiry.jsx
ace-admin-panel/src/pages/drivers/editDriver/editDriver.jsx
ace-admin-panel/src/pages/drivers/listDriver/listDriver.jsx
ace-admin-panel/src/pages/drivers/registerDriver/registerDriver.jsx
ace-admin-panel/src/pages/localPoi/addLocalPoi/addLocalPoi.jsx
ace-admin-panel/src/pages/localPoi/deleteLocalPoi/deleteLocalPoi.jsx
ace-admin-panel/src/pages/localPoi/editLocalPoi/editLocalPoi.jsx
ace-admin-panel/src/pages/localPoi/listLocalPoi/listLocalPoi.jsx
ace-admin-panel/src/pages/network/get-started/NetworkGetStartedContent.jsx
ace-admin-panel/src/pages/network/get-started/NetworkGetStartedPage.jsx
ace-admin-panel/src/pages/network/get-started/blocks/Options.jsx
ace-admin-panel/src/pages/network/user-cards/author/NetworkAuthorContent.jsx
ace-admin-panel/src/pages/network/user-cards/author/NetworkAuthorPage.jsx
ace-admin-panel/src/pages/network/user-cards/mini-cards/NetworkMiniCardsContent.jsx
ace-admin-panel/src/pages/network/user-cards/mini-cards/NetworkMiniCardsPage.jsx
ace-admin-panel/src/pages/network/user-cards/nft/NetworkNFTContent.jsx
ace-admin-panel/src/pages/network/user-cards/nft/NetworkNFTPage.jsx
ace-admin-panel/src/pages/network/user-cards/social/NetworkSocialContent.jsx
ace-admin-panel/src/pages/network/user-cards/social/NetworkSocialPage.jsx
ace-admin-panel/src/pages/network/user-cards/team-crew/NetworkUserCardsTeamCrewContent.jsx
ace-admin-panel/src/pages/network/user-cards/team-crew/NetworkUserCardsTeamCrewPage.jsx
ace-admin-panel/src/pages/network/user-table/app-roster/NetworkAppRosterContent.jsx
ace-admin-panel/src/pages/network/user-table/app-roster/NetworkAppRosterPage.jsx
ace-admin-panel/src/pages/network/user-table/market-authors/NetworkMarketAuthorsContent.jsx
ace-admin-panel/src/pages/network/user-table/market-authors/NetworkMarketAuthorsPage.jsx
ace-admin-panel/src/pages/network/user-table/saas-users/NetworkSaasUsersContent.jsx
ace-admin-panel/src/pages/network/user-table/saas-users/NetworkSaasUsersPage.jsx
ace-admin-panel/src/pages/network/user-table/store-clients/NetworkStoreClientsContent.jsx
ace-admin-panel/src/pages/network/user-table/store-clients/NetworkStoreClientsPage.jsx
ace-admin-panel/src/pages/network/user-table/team-crew/NetworkUserTableTeamCrewContent.jsx
ace-admin-panel/src/pages/network/user-table/team-crew/NetworkUserTableTeamCrewPage.jsx
ace-admin-panel/src/pages/network/user-table/visitors/NetworkVisitorsContent.jsx
ace-admin-panel/src/pages/network/user-table/visitors/NetworkVisitorsPage.jsx
ace-admin-panel/src/pages/public-profile/PageMenu.jsx
ace-admin-panel/src/pages/public-profile/activity/ProfileActivityContent.jsx
ace-admin-panel/src/pages/public-profile/activity/ProfileActivityPage.jsx
ace-admin-panel/src/pages/public-profile/campaigns/card/CampaignsCardPage.jsx
ace-admin-panel/src/pages/public-profile/campaigns/card/CampaignsContent.jsx
ace-admin-panel/src/pages/public-profile/campaigns/list/CampaignsListPage.jsx
ace-admin-panel/src/pages/public-profile/empty/ProfileEmptyPage.jsx
ace-admin-panel/src/pages/public-profile/empty/blocks/Empty.jsx
ace-admin-panel/src/pages/public-profile/network/ProfileNetworkPage.jsx
ace-admin-panel/src/pages/public-profile/network/blocks/Network.jsx
ace-admin-panel/src/pages/public-profile/profiles/blogger/ProfileBloggerContent.jsx
ace-admin-panel/src/pages/public-profile/profiles/blogger/ProfileBloggerPage.jsx
ace-admin-panel/src/pages/public-profile/profiles/company/ProfileCompanyContent.jsx
ace-admin-panel/src/pages/public-profile/profiles/company/ProfileCompanyPage.jsx
ace-admin-panel/src/pages/public-profile/profiles/creator/ProfileCreatorContent.jsx
ace-admin-panel/src/pages/public-profile/profiles/creator/ProfileCreatorPage.jsx
ace-admin-panel/src/pages/public-profile/profiles/crm/ProfileCRMContent.jsx
ace-admin-panel/src/pages/public-profile/profiles/crm/ProfileCRMPage.jsx
ace-admin-panel/src/pages/public-profile/profiles/default/ProfileDefaultContent.jsx
ace-admin-panel/src/pages/public-profile/profiles/default/ProfileDefaultPage.jsx
ace-admin-panel/src/pages/public-profile/profiles/feeds/ProfileFeedsContent.jsx
ace-admin-panel/src/pages/public-profile/profiles/feeds/ProfileFeedsPage.jsx
ace-admin-panel/src/pages/public-profile/profiles/gamer/ProfileGamerContent.jsx
ace-admin-panel/src/pages/public-profile/profiles/gamer/ProfileGamerPage.jsx
ace-admin-panel/src/pages/public-profile/profiles/modal/ProfileModalContent.jsx
ace-admin-panel/src/pages/public-profile/profiles/modal/ProfileModalPage.jsx
ace-admin-panel/src/pages/public-profile/profiles/nft/ProfileNFTContent.jsx
ace-admin-panel/src/pages/public-profile/profiles/nft/ProfileNFTPage.jsx
ace-admin-panel/src/pages/public-profile/profiles/plain/ProfilePlainContent.jsx
ace-admin-panel/src/pages/public-profile/profiles/plain/ProfilePlainPage.jsx
ace-admin-panel/src/pages/public-profile/projects/2-columns/ProjectColumn2Page.jsx
ace-admin-panel/src/pages/public-profile/projects/3-columns/ProjectColumn3Page.jsx
ace-admin-panel/src/pages/public-profile/teams/ProfileTeamsPage.jsx
ace-admin-panel/src/pages/public-profile/teams/blocks/Teams.jsx
ace-admin-panel/src/pages/public-profile/works/ProfileWorksPage.jsx
ace-admin-panel/src/pages/public-profile/works/blocks/Works.jsx
ace-admin-panel/src/pages/public-profile/works/cards/Offer.jsx
ace-admin-panel/src/pages/public-profile/works/cards/OfferRow.jsx
ace-admin-panel/src/pages/reports/bookingsReport/averageDuration/avergeDuration.jsx
ace-admin-panel/src/pages/reports/bookingsReport/byVehicleType/byVehicleType.jsx
ace-admin-panel/src/pages/reports/bookingsReport/countByScope/countByScope.jsx
ace-admin-panel/src/pages/reports/bookingsReport/duplicateBookings/duplicateBooking.jsx
ace-admin-panel/src/pages/reports/bookingsReport/growthByPeriod/growthByPeriod.jsx
ace-admin-panel/src/pages/reports/bookingsReport/pickupsByPostcode/pickupsByPostcode.jsx
ace-admin-panel/src/pages/reports/bookingsReport/topCustomer/topCustomer.jsx
ace-admin-panel/src/pages/reports/financialReport/payoutsByMonth/payoutByMonth.jsx
ace-admin-panel/src/pages/reports/financialReport/profitabilityByDateRange/StatsBlocks.jsx
ace-admin-panel/src/pages/reports/financialReport/profitabilityByDateRange/profitabiltyByDateRange.jsx
ace-admin-panel/src/pages/reports/financialReport/profitabilityOnInvoice/profitabilityOnInvoice.jsx
ace-admin-panel/src/pages/reports/financialReport/qrScansAdverts/qrScansAdverts.jsx
ace-admin-panel/src/pages/reports/financialReport/revenueByMonth/revenueByMonth.jsx
ace-admin-panel/src/pages/reports/financialReport/totalProfitabilityByPeriod/totalProfitabilityByPeriod.jsx
ace-admin-panel/src/pages/sendDriverMsgModal/sendDriverMsgModal.jsx

## 21. Admin Panel API Methods
ace-admin-panel/src/service/operations/accountApi.js:17:export async function createAccounts(data) {
ace-admin-panel/src/service/operations/accountApi.js:37:export async function getAccounts() {
ace-admin-panel/src/service/operations/accountApi.js:58:export async function updateAccounts(data) {
ace-admin-panel/src/service/operations/accountApi.js:78:export async function registerAccountOnWebBooker(data) {
ace-admin-panel/src/service/operations/accountApi.js:98:export async function deleteAccounts(accno) {
ace-admin-panel/src/service/operations/accountApi.js:117:export async function getClearInvoice(invoiceNo) {
ace-admin-panel/src/service/operations/authApi.js:17:export function register(data, navigate) {
ace-admin-panel/src/service/operations/authApi.js:44:export function login(data, navigate) {
ace-admin-panel/src/service/operations/authApi.js:90:export function getUser(navigate) {
ace-admin-panel/src/service/operations/authApi.js:144:export function verify(navigate) {
ace-admin-panel/src/service/operations/authApi.js:203:export async function resetUserPassword(userId) {
ace-admin-panel/src/service/operations/authApi.js:234:export function logout(navigate) {
ace-admin-panel/src/service/operations/availabilityApi.js:15:export async function getAvailability(userId, date) {
ace-admin-panel/src/service/operations/availabilityApi.js:36:export async function getAvailabilityLog(userId, date) {
ace-admin-panel/src/service/operations/availabilityApi.js:56:export async function updateAvailability(data) {
ace-admin-panel/src/service/operations/availabilityApi.js:76:export async function availabilityReport(data) {
ace-admin-panel/src/service/operations/availabilityApi.js:96:export async function deleteAvailability(id) {
ace-admin-panel/src/service/operations/billing&Payment.js:42:export async function getVATOutputs(data) {
ace-admin-panel/src/service/operations/billing&Payment.js:61:export async function driverPriceJobByMileage(data) {
ace-admin-panel/src/service/operations/billing&Payment.js:82:export async function driverPostOrUnpostJobs(postJob, id) {
ace-admin-panel/src/service/operations/billing&Payment.js:101:export async function driverGetChargeableJobs(userId, scope, lastDate) {
ace-admin-panel/src/service/operations/billing&Payment.js:122:export async function driverUpdateChargesData(data) {
ace-admin-panel/src/service/operations/billing&Payment.js:140:export async function driverCreateStatements(data) {
ace-admin-panel/src/service/operations/billing&Payment.js:158:export async function driverGetStatements(from, to, userId) {
ace-admin-panel/src/service/operations/billing&Payment.js:179:export async function resendDriverStatement(statementNo) {
ace-admin-panel/src/service/operations/billing&Payment.js:198:export async function markStatementAsPaid(statementNo) {
ace-admin-panel/src/service/operations/billing&Payment.js:217:export async function accountPriceManually(data) {
ace-admin-panel/src/service/operations/billing&Payment.js:237:export async function accountPriceJobByMileage(data) {
ace-admin-panel/src/service/operations/billing&Payment.js:260:export async function accountPriceJobHVS(data) {
ace-admin-panel/src/service/operations/billing&Payment.js:280:export async function accountPriceJobHVSBulk(data) {
ace-admin-panel/src/service/operations/billing&Payment.js:300:export async function accountPostOrUnpostJobs(postJob, id) {
ace-admin-panel/src/service/operations/billing&Payment.js:326:export async function accountDriverPostOrUnpostJobs(postJob, id) {
ace-admin-panel/src/service/operations/billing&Payment.js:352:export async function accountGetChargeableJobs(accNo, from, to) {
ace-admin-panel/src/service/operations/billing&Payment.js:377:export async function accountGetChargeableGroupJobs(accNo, from, to) {
ace-admin-panel/src/service/operations/billing&Payment.js:402:export async function accountGetChargeableGroupSplitJobs(accNo, from, to) {
ace-admin-panel/src/service/operations/billing&Payment.js:427:export async function accountUpdateChargesData(data) {
ace-admin-panel/src/service/operations/billing&Payment.js:450:export async function accountCreateInvoice(emailInvoices, data) {
ace-admin-panel/src/service/operations/billing&Payment.js:473:export async function markInvoiceAsPaid(invoiceNo) {
ace-admin-panel/src/service/operations/billing&Payment.js:493:export async function deleteInvoice(invoiceNo) {
ace-admin-panel/src/service/operations/billing&Payment.js:513:export async function creditInvoice(invoiceNo, reason) {
ace-admin-panel/src/service/operations/billing&Payment.js:533:export async function creditJourneys(data) {
ace-admin-panel/src/service/operations/billing&Payment.js:553:export async function getCreditNotes(accno) {
ace-admin-panel/src/service/operations/billing&Payment.js:573:export async function downloadCreditNotes(creditnoteId) {
ace-admin-panel/src/service/operations/billing&Payment.js:604:export async function clearInvoice(invoiceNo) {
ace-admin-panel/src/service/operations/billing&Payment.js:624:export async function getInvoices(from, to, accno) {
ace-admin-panel/src/service/operations/billing&Payment.js:644:export async function downloadInvoice(invoiceNo) {
ace-admin-panel/src/service/operations/billing&Payment.js:675:export async function downloadInvoiceCSV(invoiceNo) {
ace-admin-panel/src/service/operations/billing&Payment.js:706:export async function resendAccountInvoice(invoiceNo) {
ace-admin-panel/src/service/operations/bookingApi.js:19:export async function cancelBookingByDateRange(data) {
ace-admin-panel/src/service/operations/bookingApi.js:39:export async function cancelReportByDateRange(data) {
ace-admin-panel/src/service/operations/bookingApi.js:59:export async function getAllCardBookings() {
ace-admin-panel/src/service/operations/bookingApi.js:78:export async function getBookingAudit(id) {
ace-admin-panel/src/service/operations/bookingApi.js:97:export async function sendReminderCardPayment(data) {
ace-admin-panel/src/service/operations/bookingApi.js:118:export async function getBookingByStatus(date, scope, status) {
ace-admin-panel/src/service/operations/bookingApi.js:137:export async function allocateBooking(data) {
ace-admin-panel/src/service/operations/bookingApi.js:158:export async function getAirportRuns(month) {
ace-admin-panel/src/service/operations/bookingApi.js:177:export async function getTurndownBookings(from, to) {
ace-admin-panel/src/service/operations/bookingApi.js:196:export async function restoreCancelledBooking(bookingId) {
ace-admin-panel/src/service/operations/dashboardApi.js:15:export async function dashboard() {
ace-admin-panel/src/service/operations/dashboardApi.js:34:export async function getSmaHeartBeat() {
ace-admin-panel/src/service/operations/dashboardApi.js:53:export async function sendDirectMsgToDriver(driver, msg) {
ace-admin-panel/src/service/operations/dashboardApi.js:75:export async function sendGlobalMsgToDriver(msg) {
ace-admin-panel/src/service/operations/dashboardApi.js:94:export async function driverEarningsReport(data) {
ace-admin-panel/src/service/operations/driverApi.js:21:export async function getAllDrivers() {
ace-admin-panel/src/service/operations/driverApi.js:40:export async function createDriver(data) {
ace-admin-panel/src/service/operations/driverApi.js:59:export async function updateDriver(data) {
ace-admin-panel/src/service/operations/driverApi.js:78:export async function deleteDriver(id) {
ace-admin-panel/src/service/operations/driverApi.js:97:export async function driverExpenses(data) {
ace-admin-panel/src/service/operations/driverApi.js:115:export async function driverResendLogin(id) {
ace-admin-panel/src/service/operations/driverApi.js:133:export async function driverShowAllJobs(id, turnOn) {
ace-admin-panel/src/service/operations/driverApi.js:151:export async function driverShowHvsJobs(id, turnOn) {
ace-admin-panel/src/service/operations/driverApi.js:169:export async function driverLockout(id, lockout) {
ace-admin-panel/src/service/operations/driverApi.js:187:export async function driverExpirys() {
ace-admin-panel/src/service/operations/driverApi.js:205:export async function updateDriverExpirys(data) {
ace-admin-panel/src/service/operations/gpsApi.js:9:export async function gstAllGPS() {
ace-admin-panel/src/service/operations/gpsApi.js:29:export async function updateFCM(fcm) {
ace-admin-panel/src/service/operations/gpsApi.js:49:export async function removeFCM() {
ace-admin-panel/src/service/operations/gpsApi.js:69:export async function getHvsAccountChanges(from, to, action) {
ace-admin-panel/src/service/operations/localPOIApi.js:11:export async function getAllPois() {
ace-admin-panel/src/service/operations/localPOIApi.js:30:export async function createPoi(data) {

## 22. Scope-Based Business Rules
TaxiDispatch.Lib/Services/AccountsService.cs:1020:                    foreach (var job in jobs.Where(o => o.Scope == BookingScope.Card))
TaxiDispatch.Lib/Services/AccountsService.cs:133:                   o.InvoiceNumber == null && o.AccountNumber != null && o.Scope == BookingScope.Account &&
TaxiDispatch.Lib/Services/AccountsService.cs:1421:            var found = await _dB.Bookings.Where(o => o.Scope == BookingScope.Account && o.Id != bookingId &&
TaxiDispatch.Lib/Services/AccountsService.cs:142:                    && o.InvoiceNumber == null && o.AccountNumber == accno && o.Cancelled == false && o.Scope == BookingScope.Account)
TaxiDispatch.Lib/Services/AccountsService.cs:1520:                   o.Scope == BookingScope.Account &&
TaxiDispatch.Lib/Services/AccountsService.cs:1559:            var founds = await _dB.Bookings.Where(o => o.Scope == BookingScope.Account &&
TaxiDispatch.Lib/Services/AccountsService.cs:1754:            var found = await _dB.Bookings.Where(o => o.Scope == BookingScope.Account && o.Id != dto.BookingId &&
TaxiDispatch.Lib/Services/AccountsService.cs:2128:                (o.Scope == BookingScope.Cash || o.Scope == BookingScope.Rank || o.Scope == BookingScope.Card) &&
TaxiDispatch.Lib/Services/AccountsService.cs:2165:                            foreach (var item in lst.Where(o => o.Scope == BookingScope.Card))
TaxiDispatch.Lib/Services/AccountsService.cs:2192:                var data1 = await _dB.Bookings.Where(o => (o.Cancelled == false) && o.Scope == BookingScope.Card &&
TaxiDispatch.Lib/Services/AccountsService.cs:263:                list = list.Where(o => o.Scope == scope).ToList();
TaxiDispatch.Lib/Services/AccountsService.cs:299:                obj.EarningsCash = driver.Where(o => o.Scope == BookingScope.Cash).Sum(o => o.Price);
TaxiDispatch.Lib/Services/AccountsService.cs:304:                    obj.EarningsCard = driver.Where(o => o.Scope == BookingScope.Card && o.PaymentStatus == PaymentStatus.Paid).Sum(o => (o.Price/1.2));
TaxiDispatch.Lib/Services/AccountsService.cs:309:                    obj.EarningsCard = driver.Where(o => o.Scope == BookingScope.Card && o.PaymentStatus == PaymentStatus.Paid).Sum(o => o.Price);
TaxiDispatch.Lib/Services/AccountsService.cs:313:                obj.CashJobsTotalCount = driver.Where(o => o.Scope == BookingScope.Cash || o.Scope == BookingScope.Card).Count();
TaxiDispatch.Lib/Services/AccountsService.cs:314:                obj.AccountJobsTotalCount = driver.Where(o => o.Scope == BookingScope.Account).Count();
TaxiDispatch.Lib/Services/AccountsService.cs:316:                var parking = driver.Where(o => o.Scope == BookingScope.Account).Sum(o => o.ParkingCharge);
TaxiDispatch.Lib/Services/AccountsService.cs:317:                var waiting = driver.Where(o => o.Scope == BookingScope.Account).Sum(o => o.WaitingPriceDriver);
TaxiDispatch.Lib/Services/AccountsService.cs:319:                obj.EarningsAccount = driver.Where(o => o.Scope == BookingScope.Account).Sum(o => o.Price);
TaxiDispatch.Lib/Services/AccountsService.cs:325:                obj.RankJobsTotalCount = driver.Where(o => o.Scope == BookingScope.Rank).Count();
TaxiDispatch.Lib/Services/AccountsService.cs:326:                obj.EarningsRank = driver.Where(o => o.Scope == BookingScope.Rank).Sum(o => o.Price);
TaxiDispatch.Lib/Services/AccountsService.cs:380:                    if (job.Scope == BookingScope.Cash)
TaxiDispatch.Lib/Services/AccountsService.cs:385:                    else if (job.Scope == BookingScope.Card)
TaxiDispatch.Lib/Services/AccountsService.cs:390:                    else if (job.Scope == BookingScope.Rank)
TaxiDispatch.Lib/Services/AccountsService.cs:629:                    card = (decimal)date.Where(p => p.Scope == BookingScope.Card).Sum(o => (o.Price / (decimal)1.2));
TaxiDispatch.Lib/Services/AccountsService.cs:633:                    card = (decimal)date.Where(p => p.Scope == BookingScope.Card).Sum(o => o.Price);
TaxiDispatch.Lib/Services/AccountsService.cs:637:                var cash = date.Where(p => p.Scope == BookingScope.Cash).Sum(o => o.Price) + card;
TaxiDispatch.Lib/Services/AccountsService.cs:638:                var acc = date.Where(p => p.Scope == BookingScope.Account).Sum(o => o.Price);
TaxiDispatch.Lib/Services/AccountsService.cs:639:                var rank = date.Where(p => p.Scope == BookingScope.Rank).Sum(o => o.Price);
TaxiDispatch.Lib/Services/AccountsService.cs:651:                model.CashJobsCount = date.Where(o => o.Scope == BookingScope.Cash || o.Scope == BookingScope.Card).Count();
TaxiDispatch.Lib/Services/AccountsService.cs:652:                model.AccJobsCount = date.Where(o => o.Scope == BookingScope.Account).Count();
TaxiDispatch.Lib/Services/AccountsService.cs:653:                model.RankJobsCount = date.Where(o => o.Scope == BookingScope.Rank).Count();
TaxiDispatch.Lib/Services/AccountsService.cs:655:                model.CashMilesCount = date.Where(o => o.Scope == BookingScope.Cash || o.Scope == BookingScope.Card).Sum(o => o.Mileage);
TaxiDispatch.Lib/Services/AccountsService.cs:656:                model.AccMilesCount = date.Where(o => o.Scope == BookingScope.Account).Sum(o => o.Mileage);
TaxiDispatch.Lib/Services/AccountsService.cs:657:                model.RankMilesCount = date.Where(o => o.Scope == BookingScope.Rank).Sum(o => o.Mileage);
TaxiDispatch.Lib/Services/AccountsService.cs:719:                    card = (decimal)drv.Where(p => p.Scope == BookingScope.Card).Sum(o => o.Price / (decimal)(1.2));
TaxiDispatch.Lib/Services/AccountsService.cs:723:                    card = (decimal)drv.Where(p => p.Scope == BookingScope.Card).Sum(o => o.Price);
TaxiDispatch.Lib/Services/AccountsService.cs:727:                var cash = drv.Where(p => p.Scope == BookingScope.Cash).Sum(o => o.Price) + card;
TaxiDispatch.Lib/Services/AccountsService.cs:728:                var acc = drv.Where(p => p.Scope == BookingScope.Account).Sum(o => o.Price);
TaxiDispatch.Lib/Services/AccountsService.cs:729:                var rank = drv.Where(p => p.Scope == BookingScope.Rank).Sum(o => o.Price);
TaxiDispatch.Lib/Services/AccountsService.cs:741:                model.CashJobsCount = drv.Where(o => o.Scope == BookingScope.Cash || o.Scope == BookingScope.Card).Count();
TaxiDispatch.Lib/Services/AccountsService.cs:742:                model.AccJobsCount = drv.Where(o => o.Scope == BookingScope.Account).Count();
TaxiDispatch.Lib/Services/AccountsService.cs:743:                model.RankJobsCount = drv.Where(o => o.Scope == BookingScope.Rank).Count();
TaxiDispatch.Lib/Services/AccountsService.cs:745:                model.CashMilesCount = drv.Where(o => o.Scope == BookingScope.Cash || o.Scope == BookingScope.Card).Sum(o => o.Mileage);
TaxiDispatch.Lib/Services/AccountsService.cs:746:                model.AccMilesCount = drv.Where(o => o.Scope == BookingScope.Account).Sum(o => o.Mileage);
TaxiDispatch.Lib/Services/AccountsService.cs:747:                model.RankMilesCount = drv.Where(o => o.Scope == BookingScope.Rank).Sum(o => o.Mileage);
TaxiDispatch.Lib/Services/BookingService.cs:1113:            if (booking.Scope == BookingScope.Cash || booking.Scope == BookingScope.Card)
TaxiDispatch.Lib/Services/BookingService.cs:1798:                .Where(o => o.Cancelled == false && o.Scope == BookingScope.Card &&
TaxiDispatch.Lib/Services/BookingService.cs:1896:                        o.PickupDateTime < DateTime.Now && o.Scope == BookingScope.Account).ToListAsync();
TaxiDispatch.Lib/Services/DispatchService.cs:173:            if (obj.Scope == BookingScope.Cash)
TaxiDispatch.Lib/Services/DispatchService.cs:179:            if (!string.IsNullOrEmpty(obj.PhoneNumber) && (obj.Scope == BookingScope.Cash 
TaxiDispatch.Lib/Services/DispatchService.cs:180:                || obj.Scope == BookingScope.Card))
TaxiDispatch.Lib/Services/DispatchService.cs:457:            if (!string.IsNullOrEmpty(booking.PhoneNumber) && (booking.Scope == BookingScope.Cash || booking.Scope == BookingScope.Card))
TaxiDispatch.Lib/Services/DispatchService.cs:773:                (booking.Scope == BookingScope.Cash ||
TaxiDispatch.Lib/Services/DispatchService.cs:774:                booking.Scope == BookingScope.Card))
TaxiDispatch.Lib/Services/ReportingService.cs:1063:                 (o.Scope == BookingScope.Account) && o.AccountNumber != 10027 && 
TaxiDispatch.Lib/Services/ReportingService.cs:1072:                 (o.Scope == BookingScope.Cash || o.Scope == BookingScope.Rank || o.Scope == BookingScope.Card) &&
TaxiDispatch.Lib/Services/ReportingService.cs:1158:                (o.Scope == BookingScope.Account) && o.AccountNumber != 10027 &&
TaxiDispatch.Lib/Services/ReportingService.cs:1167:                (o.Scope == BookingScope.Account) && o.AccountNumber == 10027 &&
TaxiDispatch.Lib/Services/ReportingService.cs:1175:              (o.Scope == BookingScope.Cash || o.Scope == BookingScope.Rank || o.Scope == BookingScope.Card) &&
TaxiDispatch.Lib/Services/ReportingService.cs:1188:            var csh = cash.Where(o => o.Scope == BookingScope.Cash).ToList();
TaxiDispatch.Lib/Services/ReportingService.cs:1189:            var rnk = cash.Where(o => o.Scope == BookingScope.Rank).ToList();
TaxiDispatch.Lib/Services/ReportingService.cs:124:                obj.AccountJobs = item.Count(o => o.Scope == BookingScope.Account);
TaxiDispatch.Lib/Services/ReportingService.cs:125:                obj.RankJobs = item.Count(o => o.Scope == BookingScope.Rank);
TaxiDispatch.Lib/Services/ReportingService.cs:126:                obj.CashJobs = item.Count(o => o.Scope == BookingScope.Cash || o.Scope == BookingScope.Card);
TaxiDispatch.Lib/Services/ReportingService.cs:344:                o.PickupDateTime.Date == now.Date && (o.Scope == BookingScope.Cash || o.Scope == BookingScope.Card || o.Scope == BookingScope.Rank));
TaxiDispatch.Lib/Services/ReportingService.cs:347:                o.PickupDateTime.Date == now.Date && o.Scope == BookingScope.Account);
TaxiDispatch.Lib/Services/ReportingService.cs:396:            (o.Scope == BookingScope.Cash || o.Scope == BookingScope.Card) &&
TaxiDispatch.Lib/Services/ReportingService.cs:402:            (o.Scope == BookingScope.Account || o.Scope == BookingScope.Rank) &&
TaxiDispatch.Lib/Services/ReportingService.cs:41:                data.RemoveAll(o => o.Scope == BookingScope.Account && 
TaxiDispatch.Lib/Services/ReportingService.cs:430:                (o.Scope == BookingScope.Cash || o.Scope == BookingScope.Card) &&
TaxiDispatch.Lib/Services/ReportingService.cs:436:            (o.Scope == BookingScope.Account) &&
TaxiDispatch.Lib/Services/ReportingService.cs:442:                (o.Scope == BookingScope.Rank) &&
TaxiDispatch.Lib/Services/ReportingService.cs:44:                data.RemoveAll(o => o.Scope == BookingScope.Account &&
TaxiDispatch.Lib/Services/ReportingService.cs:492:                    .Where(o => o.Scope == BookingScope.Cash || o.Scope == BookingScope.Card)
TaxiDispatch.Lib/Services/ReportingService.cs:498:                    .Where(o => o.Scope == BookingScope.Account)
TaxiDispatch.Lib/Services/ReportingService.cs:504:                    .Where(o => o.Scope == BookingScope.Rank)
TaxiDispatch.Lib/Services/ReportingService.cs:530:            var cashs = jobs.Where(o => o.Scope == BookingScope.Cash || o.Scope == BookingScope.Card).Count();
TaxiDispatch.Lib/Services/ReportingService.cs:531:            var accs = jobs.Where(o => o.Scope == BookingScope.Account).Count();
TaxiDispatch.Lib/Services/ReportingService.cs:532:            var ranks = jobs.Where(o => o.Scope == BookingScope.Rank).Count();
TaxiDispatch.Lib/Services/ReportingService.cs:760:                    query = query.Where(b => b.Scope == scope);
TaxiDispatch.Lib/Services/ReportingService.cs:795:                    query = query.Where(b => b.Scope == scope);
TaxiDispatch.Lib/Services/ReportingService.cs:81:                    var totCash = grp.Where(o=>o.Scope == BookingScope.Cash || o.Scope == BookingScope.Card).Sum(o => o.Price);
TaxiDispatch.Lib/Services/ReportingService.cs:827:                    query = query.Where(b => b.Scope == scope);
TaxiDispatch.Lib/Services/ReportingService.cs:82:                    var totAcc = grp.Where(o => o.Scope == BookingScope.Account).Sum(o => o.Price);
TaxiDispatch.Lib/Services/ReportingService.cs:83:                    var totRank = grp.Where(o => o.Scope == BookingScope.Rank).Sum(o => o.Price);
TaxiDispatch.Lib/Services/ReportingService.cs:855:                    query = query.Where(b => b.Scope == scope); 

SCAN COMPLETE
