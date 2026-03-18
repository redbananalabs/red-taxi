using AceTaxis.Data;
using AceTaxis.Data.Models;
using AceTaxis.Domain;
using AceTaxis.DTOs;
using AceTaxis.DTOs.Booking;
using AceTaxis.DTOs.LocalPOI;
using AceTaxis.DTOs.User;
using AceTaxis.DTOs.User.Requests;
using AceTaxis.Services;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace AceTaxisAPI.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class AdminUIController : ControllerBase
    {
        private readonly AvailabilityService _availabilityService;
        private readonly UserManager<AppUser> _userManager;
        private readonly AdminUIService _adminUIService;
        private readonly TariffService _tariffService;
        private readonly AceMessagingService _messagingService;
        private readonly LocalPOIService _poiService;
        private readonly AceDbContext _db;
        private readonly AccountsService _accountsService;
        private readonly UserProfileService _profileService;
        private readonly BookingService _bookingService;
        

        public AdminUIController(
            AvailabilityService availabilityService,
            AdminUIService adminUIService,
            UserManager<AppUser> userManager,
            TariffService tariffService,
            AceMessagingService messagingService, 
            LocalPOIService poiService,
            AceDbContext db,
            AccountsService accountsService,
            UserProfileService profileService,
            BookingService bookingService
            )
        {
            _availabilityService = availabilityService;
            _adminUIService = adminUIService;
            _userManager = userManager;
            _tariffService = tariffService; 
            _messagingService = messagingService;
            _poiService = poiService;
            _db = db;
            _accountsService = accountsService;
            _profileService = profileService;
            _bookingService = bookingService;
        }


        [HttpGet]
        [Route("Move9014To10026")]
        public async Task<IActionResult> Move9014To10026(DateTime from, DateTime to, bool action)
        {
            var homes = await _db.LocalPOIs
                  .Where(o => o.Type == LocalPOIType.House)
                  .Select(o => o.Postcode)
                  .ToListAsync();

            var normalizedHomes = homes
                .Select(h => h.Trim().ToLower())
                .ToList();

            var start = from;
            var end = to;

            var data = await _db.Bookings
                .Where(o => !o.Cancelled &&
                            o.PickupDateTime >= start &&
                            o.PickupDateTime <= end &&
                            o.AccountNumber == 9014 &&
                            o.PickupPostCode == "DT9 4DN" &&
                            !normalizedHomes.Contains(o.DestinationPostCode.Trim().ToLower()))
                .Select(o => new
                {
                    o.Id,
                    o.PickupDateTime,
                    o.PickupAddress,
                    o.PickupPostCode,
                    o.DestinationAddress,
                    o.DestinationPostCode,
                    o.PassengerName
                })
                .ToListAsync();

            if (action)
            {
                foreach (var oo in data)
                {
                    await _db.Bookings.Where(o => o.Id == oo.Id)
                         .ExecuteUpdateAsync(o => o.SetProperty(u => u.AccountNumber, 10026));
                }
            }

            return Ok(data);
        }
     
        //public async Task<IActionResult> Move9014To10026()
        //{
        //    var homes = await _db.LocalPOIs
        //        .Where(o => o.Type == LocalPOIType.House)
        //        .Select(o => o.Postcode)
        //        .ToListAsync();

        //    var normalizedHomes = homes
        //        .Select(h => h.Trim().ToLower())
        //        .ToList();

        //    //var e = normalizedHomes.Where(o=>o == "dt11 7lz").Count();

        //    var start = new DateTime(2025, 3, 1, 0, 0, 0);
        //    var end = new DateTime(2025, 7, 30, 23, 59, 0);

        //    var notHomeNotHVS = await _db.Bookings
        //        .Where(o => !o.Cancelled &&
        //                    o.PickupDateTime >= start &&
        //                    o.PickupDateTime <= end &&
        //                    o.AccountNumber == 9014 &&
        //                    !normalizedHomes.Contains(o.DestinationPostCode.Trim().ToLower()) &&
        //                    !normalizedHomes.Contains(o.PickupPostCode.Trim().ToLower()) &&
        //                    o.PickupPostCode != "DT9 4DN" &&
        //                    o.DestinationPostCode != "DT9 4DN")
        //        .Select(o => new
        //        {
        //            o.Id,
        //            o.PickupDateTime,
        //            o.PickupAddress,
        //            o.PickupPostCode,
        //            o.DestinationAddress,
        //            o.DestinationPostCode,
        //            o.PassengerName
        //        })
        //        .ToListAsync();

        //    var homeToAnywhereNotHVS = await _db.Bookings
        //        .Where(o => !o.Cancelled &&
        //                    o.PickupDateTime >= start &&
        //                    o.PickupDateTime <= end &&
        //                    o.AccountNumber == 9014 &&
        //                    normalizedHomes.Contains(o.PickupPostCode.Trim().ToLower()) &&
        //                    o.DestinationPostCode != "DT9 4DN")
        //        .Select(o => new
        //        {
        //            o.Id,
        //            o.PickupDateTime,
        //            o.PickupAddress,
        //            o.PickupPostCode,
        //            o.DestinationAddress,
        //            o.DestinationPostCode,
        //            o.PassengerName
        //        })
        //        .ToListAsync();

        //    var hvsToanywhere = await _db.Bookings
        //        .Where(o => !o.Cancelled &&
        //                    o.PickupDateTime >= start &&
        //                    o.PickupDateTime <= end &&
        //                    o.AccountNumber == 9014 &&
        //                    !normalizedHomes.Contains(o.DestinationPostCode.Trim().ToLower()) &&
        //                    o.PickupPostCode == "DT9 4DN")
        //        .Select(o => new
        //        {
        //            o.Id,
        //            o.PickupDateTime,
        //            o.PickupAddress,
        //            o.PickupPostCode,
        //            o.DestinationAddress,
        //            o.DestinationPostCode,
        //            o.PassengerName
        //        })
        //        .ToListAsync();

        //    var anywhereToHomeNotHVS = await _db.Bookings
        //        .Where(o => !o.Cancelled &&
        //                    o.PickupDateTime >= start &&
        //                    o.PickupDateTime <= end &&
        //                    o.AccountNumber == 9014 &&
        //                    !normalizedHomes.Contains(o.PickupPostCode.Trim().ToLower()) &&
        //                    o.PickupPostCode != "DT9 4DN" &&
        //                    o.DestinationPostCode != "DT9 4DN")
        //        .Select(o => new
        //        {
        //            o.Id,
        //            o.PickupDateTime,
        //            o.PickupAddress,
        //            o.PickupPostCode,
        //            o.DestinationAddress,
        //            o.DestinationPostCode,
        //            o.PassengerName
        //        })
        //        .ToListAsync();

        //    var anywhereToHomeHVS = await _db.Bookings
        //         .Where(o => !o.Cancelled &&
        //                     o.PickupDateTime >= start &&
        //                     o.PickupDateTime <= end &&
        //                     o.AccountNumber == 9014 &&
        //                     !normalizedHomes.Contains(o.PickupPostCode.Trim().ToLower()) &&
        //                     o.PickupPostCode != "DT9 4DN"
        //                     )
        //         .Select(o => new
        //         {
        //             o.Id,
        //             o.PickupDateTime,
        //             o.PickupAddress,
        //             o.PickupPostCode,
        //             o.DestinationAddress,
        //             o.DestinationPostCode,
        //             o.PassengerName
        //         })
        //         .ToListAsync();


        //    notHomeNotHVS.AddRange(hvsToanywhere);
        //    notHomeNotHVS.AddRange(homeToAnywhereNotHVS);
        //    notHomeNotHVS.AddRange(anywhereToHomeNotHVS);
        //    notHomeNotHVS.AddRange(anywhereToHomeHVS);


        //    foreach (var oo in notHomeNotHVS)
        //    {
        //        await _db.Bookings.Where(o => o.Id == oo.Id)
        //             .ExecuteUpdateAsync(o => o.SetProperty(u => u.AccountNumber, 9014));
        //    }

        //    return Ok(notHomeNotHVS);
        //}

        #region SEND MESSAGE
        [HttpPost]
        [Route("SendMessageToDriver")]
        [Authorize]
        public async Task<IActionResult> SendMessageToDriver(int driver, string message)
        {
            var uname = User.Identity.Name;

            if (!string.IsNullOrEmpty(uname))
            {
                var user = await _userManager.FindByNameAsync(uname);

                await _adminUIService.SendDriverMessage(driver, message, user.FullName);
                return Ok();
            }

            return NotFound("the user (sender) was not found.");

        }

        [HttpPost]
        [Route("SendMessageToAllDrivers")]
        [Authorize]
        public async Task<IActionResult> SendMessageToAllDrivers(string message)
        {
            var uname = User.Identity.Name;

            if (!string.IsNullOrEmpty(uname))
            {
                var user = await _userManager.FindByNameAsync(uname);

                await _adminUIService.SendAllDriversMessage(message, user.FullName);
                return Ok();
            }

            return NotFound("the user (sender) was not found.");
        }

        

        #endregion

        [Authorize]
        [HttpGet]
        [Route("Dashboard")]
        public async Task<IActionResult> GetDashData()
        {
            var uname = User.Identity.Name;

            if (!string.IsNullOrEmpty(uname))
            {
                var user = await _userManager.FindByNameAsync(uname);

                if (user != null) 
                {
                    return Ok(await _adminUIService.GetDashData(user.Id));
                }

                return NotFound("the user was not found.");
            }

            return NotFound("the username was not returned from identity.");
        }

        [Authorize]
        [HttpGet]
        [Route("GetSMSHeartBeat")]
        public async Task<IActionResult> GetHeartbeat()
        {
            return Ok(await _adminUIService.GetSMSHeartBeat());
        }

        //[Authorize]
        [HttpGet]
        [Route("DriversOnShift")]
        public async Task<IActionResult> DriversOnShift()
        {
            var data = await _availabilityService.GetOnShiftDrivers();
            return Ok(data);
        }

        [HttpPost]
        [Route("DriverEarningsReport")]
        public async Task<IActionResult> DriverEarningsReport(DriverEarningsRequestDto dto)
        {
            var res = new DriverExpensesResponseDto();
            var data = await _accountsService.GetEarningsWithinRange(dto.From, dto.To, dto.UserId);

            var obj = new JobsCountModelDto();

            foreach (var item in data)
            {
                obj.AccJobsCount += item.AccJobsCount;
                obj.CashJobsCount += item.CashJobsCount;
                obj.RankJobsCount += item.RankJobsCount;
            }

            res.JobsCount = obj;

            res.JobCountDateRangeLabels = new string[] { $"Cash Jobs ({obj.CashJobsCount})", $"Account Jobs ({obj.AccJobsCount})", $"Rank Jobs ({obj.RankJobsCount})" };
            res.JobCountDateRangeValues = new double[] { obj.CashJobsCount, obj.AccJobsCount, obj.RankJobsCount };
            res.Earnings = data;

            return Ok(res);
        }

        #region DRIVER EXPENSES
        [HttpPost]
        [Route("DriverExpenses")]
        public async Task<IActionResult> DriverExpenses(GetDriverExpensesRequestDto req)
        {
            if (!req.IsValid)
            {
                return BadRequest("Invalid data or missing required fields");
            }

            var to = req.To.To2359();

            List<DriverExpense> data;

            if (req.UserId == 0)
            {
                data = await _db.DriverExpenses.Where(o => (o.Date >= req.From.Date && o.Date <= to)).ToListAsync();
            }
            else
            {
                data = await _db.DriverExpenses.Where(o => o.UserId == req.UserId &&
                    (o.Date >= req.From.Date && o.Date <= to)).ToListAsync();
            }

            var total = data.Sum(o => o.Amount);

            var res = new { Data = data, Total = total };
            return Ok(res);
        }
        #endregion

        #region DRIVERS
        [HttpGet]
        [Route("DriversList")]
        public async Task<IActionResult> DriversList()
        {
            var res = await _profileService.ListUsersAll();
            var users = res.Users.ToList().OrderBy(o => o.LockoutEnabled).ToList();

            return Ok(users);
        }

        [HttpPost]
        [Route("DriverAdd")]
        public async Task<IActionResult> DriverAdd(UserRegistrationRequestDto obj)
        {
            var res = await _profileService.Create(new AppUser()
            {
                UserName = obj.Username,
                Email = obj.Email,
                PhoneNumber = obj.PhoneNumber,
                FullName = obj.Fullname,
            }, obj.Password,
               new UserProfile
               {
                   ColorCodeRGB = obj.ColorCode,
                   RegNo = obj.RegistrationNo,
                   ShowAllBookings = obj.ShowAllBookings,
                   ShowHVSBookings = false,
                   VehicleColour = obj.VehicleColor,
                   VehicleMake = obj.VehicleMake,
                   VehicleModel = obj.VehicleModel,
                   VehicleType = obj.VehicleType,
                   CashCommissionRate = 15,
                   CommsPlatform = obj.Comms
               });

            if(res.Succeeded)
                return Ok();
            else
            {
                var errors = string.Join("\r\n", res.Errors.Select(o => o.Description));
                return BadRequest($"Failed to create account user.\r\n{errors}");
            }
        }

        [HttpPost]
        [Route("DriverUpdate")]
        public async Task<IActionResult> DriverUpdate(UserUpdateRequestDto obj)
        {
            if (obj.UserId == 0)
            {
                return BadRequest("Invalid user id");
            }

            var username = await _profileService.GetUsername(obj.UserId);
            var profile = await _profileService.GetProfile(username);

            if (profile != null)
            {
                profile.User.FullName = obj.Fullname;
                profile.User.Email = obj.Email;
                profile.User.PhoneNumber = obj.PhoneNumber;
                profile.RegNo = obj.RegistrationNo;
                profile.ColorCodeRGB = obj.ColorCode;
                profile.ShowAllBookings = obj.ShowAllBookings;
                profile.VehicleColour = obj.VehicleColor;
                profile.VehicleMake = obj.VehicleMake;
                profile.VehicleModel = obj.VehicleModel;
                profile.VehicleType = obj.VehicleType;
                profile.ShowHVSBookings = obj.ShowAllBookings;
                profile.CashCommissionRate = obj.CashCommisionRate;
                profile.CommsPlatform = obj.Comms;
                profile.NonAce = obj.NonAce;

                // update roles
                var roles = await _userManager.GetRolesAsync(profile.User);

                foreach (var role in roles)
                {
                    await _profileService.RemoveUserFromRole(profile.UserId, role);
                }

                await _profileService.AddUserToRole(profile.User, obj.Role.ToString());
                await _profileService.UpdateProfile(profile);
            }

            return Ok();
        }

        [HttpPost]
        [Route("DriverDelete")]
        public async Task<IActionResult> DriverDelete(int userId)
        {
            if (userId == 0)
            {
                return BadRequest("Invalid user id");
            }
            
            await _profileService.SetProfileDeleted(userId, true);
            return Ok();
        }

        [HttpGet]
        [Route("DriverResendLogin")]
        public async Task<IActionResult> DriverResendLogin(int userId)
        {
            if (userId == 0)
            {
                return BadRequest("Invalid user id");
            }

            await _profileService.ChangePassword(userId);

            return Ok();
        }

        [HttpGet]
        [Route("DriverShowAllJobs")]
        public async Task<IActionResult> DriverShowAllJobs(int userId, bool turnOn)
        {
            if (userId == 0)
            {
                return BadRequest("Invalid user id");
            }

            await _profileService.ShowAllOnOff(userId, turnOn);
            return Ok();
        }

        [HttpGet]
        [Route("DriverShowHVSJobs")]
        public async Task<IActionResult> DriverShowHVSJobs(int userId, bool turnOn)
        {
            if (userId == 0)
            {
                return BadRequest("Invalid user id");
            }

            await _profileService.ShowHVSOnOff(userId, turnOn);
            return Ok();
        }

        [HttpGet]
        [Route("DriverLockout")]
        public async Task<IActionResult> DriverLockout(int userId, bool lockout)
        {
            if (userId == 0)
            {
                return BadRequest("Invalid user id");
            }
            
            await _profileService.LockoutOnOff(userId, lockout);
            return Ok();
        }

        [HttpGet]
        [Route("GetDriverExpirys")]
        public async Task<IActionResult> DriverExpirys()
        {
            var data = await _db.DocumentExpirys.ToListAsync();

            var drvrs = data.Select(o => o.UserId).Distinct().ToList();

            // remove driver 0
            data.RemoveAll(o => o.UserId == 0);

            foreach (var item in drvrs)
            {
                var profile = await _db.UserProfiles
                    .Where(o => o.UserId == item)
                    .Include(o => o.User)
                    .AsNoTracking()
                    .FirstOrDefaultAsync();

                if (profile != null)
                {
                    var data2 = data.Where(d => d.UserId == item).ToList();

                    foreach (var obj in data2)
                    {
                        obj.ColorCode = profile.ColorCodeRGB;
                        obj.Fullname = profile.User.FullName;
                    }
                }
            }

            return Ok(data);
        }

        [HttpPost]
        [Route("UpdateDriverExpiry")]
        public async Task<IActionResult> UpdateDriverExpiry(UpdateExpiryDto dto)
        {
            if (dto.IsValid)
            { 
                var exists = await _db.DocumentExpirys
                    .Where(o => o.DocumentType == dto.DocType && o.UserId == dto.UserId)
                    .FirstOrDefaultAsync();

                if (exists != null)
                {
                    exists.ExpiryDate = dto.ExpiryDate;
                    _db.DocumentExpirys.Update(exists);
                }
                else // create
                {
                    var exp = new DocumentExpiry();
                    exp.UserId = dto.UserId;
                    exp.ExpiryDate = dto.ExpiryDate;
                    exp.DocumentType = dto.DocType;
                    exp.LastUpdatedOn = DateTime.Now.ToUKTime();

                    await _db.DocumentExpirys.AddAsync(exp);
                }

                await _db.SaveChangesAsync();
                return Ok();
            }

            return BadRequest("Invalid data or missing required fields");

        }

        #endregion

        #region SEARCH
        [HttpPost]
        [Route("BookingsByStatus")]
        public async Task<IActionResult> DriverEarningsReport(DateTime date, BookingScope scope, BookingsByStatus status)
        {
            switch(status)
            {
                case BookingsByStatus.Cancelled:
                    {
                        var data = await _bookingService.GetCancelledJobs(date);

                        if (scope != BookingScope.All)
                        {
                            data = data.Where(o => o.Scope == scope).ToList();
                        }

                        return Ok(data.OrderByDescending(o => o.PickupDateTime).ToList());
                    }
                case BookingsByStatus.Completed:
                    {
                        var data = await _bookingService.GetCompletedJobs(date);

                        if (scope != BookingScope.All)
                        {
                            data = data.Where(o => o.Scope == scope).ToList();
                        }

                        return Ok(data.OrderByDescending(o => o.PickupDateTime).ToList());
                    }
                case BookingsByStatus.Allocated:
                    {
                        var data = await _bookingService.GetAllocatedJobs(date);

                        if (scope != BookingScope.All)
                        {
                            data = data.Where(o => o.Scope == scope).ToList();
                        }

                        return Ok(data.OrderByDescending(o => o.PickupDateTime).ToList());
                    }
                case BookingsByStatus.Unallocated:
                    {
                        var data = await _bookingService.GetUnallocatedJobs(date);

                        if (scope != BookingScope.All)
                        {
                            data = data.Where(o => o.Scope == scope).ToList();
                        }

                        return Ok(data.OrderByDescending(o => o.PickupDateTime).ToList());
                    }
                default:
                    return BadRequest("Invalid status");
            }
        }

        #endregion

        #region BOOKINGS

        [HttpGet]
        [Route("AirportRuns")]
        public async Task<IActionResult> AirportRuns(int months)
        {
            var lastJourneys = new List<AirportSearchModel.LastTripModel>();
            months = months * -1;

            var date = DateTime.Now.AddMonths(months);
            var data = await _bookingService.GetAirportRuns(date);

            lastJourneys.Clear();

            var grp = data.LastAirports.GroupBy(o => o.UserId).ToList();

            foreach (var u in grp)
            {
                var max = u.Max(o => o.Date);
                var obj = u.FirstOrDefault(o => o.Date == max);

                lastJourneys.Add(obj);
            }

            lastJourneys = lastJourneys.OrderBy(o => o.UserId).ToList();
            var res = new { data, lastJourneys };

            return Ok(res);
        }

        [HttpGet]
        [Route("BookingAudit")]
        public async Task<IActionResult> BookingAudit(int bookingId)
        {
            if (bookingId == 0)
            {
                return BadRequest("Invalid booking id");
            }

            var data = await _bookingService.GetAuditLog(bookingId.ToString());

            return Ok(data);
        }

        [HttpGet]
        [Route("CardBookings")]
        public async Task<IActionResult> CardBookings()
        {
            var data = await _bookingService.GetActiveCardJobs();
            data = data.OrderByDescending(o => o.PickupDateTime).ToList();

            return Ok(data);
        }

        [HttpPost]
        [Route("SendCardPaymentReminder")]
        public async Task<IActionResult> SendCardPaymentReminder(SendCardPaymentReminderDto req)
        {
            if(req.IsValid)
                return BadRequest("Invalid data or missing required fields");

            var data = await _bookingService.GetPaymentLink(req.BookingId);

            if (!string.IsNullOrEmpty(data))
            { 
                _messagingService.SendPaymentLinkReminderSMS(req.Phone, data);
                return Ok();
            }
            else
            {
                return NotFound("Payment link not found");
            }
        }

        [Authorize]
        [HttpPost]
        [Route("CancelBookingsInRange")]
        public async Task<IActionResult> CancelBookingsInRange(DeleteByRangeRequestDto req)
        {
            if(!req.IsValid)
            {
                return BadRequest("Invalid data or missing required fields");
            }

            var uname = User.Identity.Name;

            if (!string.IsNullOrEmpty(uname))
            {
                var user = await _userManager.FindByNameAsync(uname);

                    await _bookingService.CancelBookingsByDateRange(req,user.FullName);
                    return Ok();
            }

            return NotFound("the username was not found.");
        }
        [Authorize]
        [HttpPost]
        [Route("CancelBookingsInRangeReport")]
        public async Task<IActionResult> CancelBookingsInRangeReport(DeleteByRangeRequestDto req)
        {
            if (!req.IsValid)
            {
                return BadRequest("Invalid data or missing required fields");
            }

            var uname = User.Identity.Name;

            if (!string.IsNullOrEmpty(uname))
            {
                var user = await _userManager.FindByNameAsync(uname);

                var data = await _bookingService.CancelBookingsByDateRangeReport(req, user.FullName);
                return Ok(data);
            }

            return NotFound("the username was not found.");
        }

        [HttpPost]
        [Route("GetTurndowns")]
        public async Task<IActionResult> GetTurndowns(DateTime from, DateTime to)
        {
            var data = await _db.TurnDowns
                .Where(o => o.DateTime >= from && o.DateTime <= to)
                .ToListAsync();

            var total = data.Sum(o => o.Amount);
            var count = data.Count;

            return Ok(new { data, total, count });
        }

        #endregion

        #region ACCOUNTS
        [HttpPost]
        [Route("AddAccount")]
        public async Task<IActionResult> AddAccount(AccountDto req)
        {
            if (req.IsValid)
            {
                var accno = await _accountsService.CreateAccount(req);
                return Ok(accno);
            }
            return BadRequest("Invalid data or missing required fields");
        }

        [HttpPost]
        [Route("UpdateAccount")]
        public async Task<IActionResult> UpdateAccount(AccountDto req)
        {
            if (req.IsValid)
            {
                await _accountsService.UpdateAccount(req);
                return Ok();
            }
            return BadRequest("Invalid data or missing required fields");
        }

        [HttpGet]
        [Route("DeleteAccount")]
        public async Task<IActionResult> DeleteAccount(int accno)
        {
            if (accno == 0)
            {
                return BadRequest("Invalid account number");
            }

            // TODO:: Add delete account logic
            await _accountsService.DeleteAccount(accno);

            return Ok();
        }

        [HttpGet]
        [Route("GetAccounts")]
        public async Task<IActionResult> GetAccounts()
        {
            var data = await _accountsService.GetAllAccounts();
            return Ok(data);
        }

        [HttpPost]
        [Route("RegisterAccountWebBooker")]
        public async Task<IActionResult> RegisterAccountWebBooker(RegisterAccountWebBookerDto req)
        {
            if (!req.IsValid)
            {
                return BadRequest("Invalid data or missing required fields");
            }

            //password 
            var password = GenerateRandomString();
           // var password = $"!AccountUser{req.Accno}!";

            var res = await _profileService.CreateAccountUser(new AppUser
            {
                UserName = req.Accno.ToString(),
                Email = req.BookerEmail,
                FullName = req.BookerName,
                PhoneNumber = req.BookerPhone
            }, password, req.Accno);

            if (res.Succeeded)
                return Ok();
            else
            { 
                var errors = string.Join("\r\n", res.Errors.Select(o => o.Description));
                return BadRequest($"Failed to create account user.\r\n{errors}"); 
            }
        }

        #endregion

        #region AVAILABILITY

        [HttpGet]
        [Route("AvailabilityLog")]
        public async Task<IActionResult> AvailabilityLog(int userid, DateTime date)
        {
            if (date != null)
            {
                if (userid > 0)
                {
                    var data = await _availabilityService.GetAuditLog(date, userid);
                    return Ok(data);
                }
                else
                {
                    var data = await _availabilityService.GetAuditLog(date);
                    return Ok(data);
                }
            }

            return BadRequest("Invalid date");
        }

        [HttpGet]
        [Route("GetAvailability")]
        public async Task<IActionResult> GetAvailability(int userid, DateTime date)
        {

            if (userid == 0)
            {
                var ok = await _availabilityService.GetAvailabilities(date); 
                return Ok(ok);
            }
            else
            { 
                var ok = await _availabilityService.GetAvailabilities(userid,date);
                return Ok(ok);
            }

            
        }

        [HttpGet]
        [Route("DeleteAvailability")]
        [Authorize]
        public async Task<IActionResult> DeleteAvailability(int availabilityId)
        {
            var uname = User.Identity.Name;

            if (!string.IsNullOrEmpty(uname))
            {
                var user = await _userManager.FindByNameAsync(uname);
            }

            await _availabilityService.Delete(availabilityId, uname);

            return Ok();
        }

        [HttpPost]
        [Route("SetAvailability")]
        [Authorize]
        public async Task<IActionResult> SetAvailability(CreateAvailabilityRequestDto req)
        {
            if (req.IsValid)
            {
                var uname = User.Identity.Name;

                if (!string.IsNullOrEmpty(uname))
                {
                    var user = await _userManager.FindByNameAsync(uname);

                    if (user != null)
                    {
                        var start = DateTime.Now.ToUKTime().AddMonths(-12);
                        var end = DateTime.Now.ToUKTime();


                        var fhr = Convert.ToInt32(req.From.Split(':')[0]);
                        var fmm = Convert.ToInt32(req.From.Split(':')[1]);

                        var thr = Convert.ToInt32(req.To.Split(':')[0]);
                        var tmm = Convert.ToInt32(req.To.Split(':')[1]);

                        var fromTs = new TimeSpan(fhr, fmm, 0);
                        var toTs = new TimeSpan(thr, tmm, 0);


                        var data = await _availabilityService.Create(req.UserId, req.Date, fromTs, toTs,
                            (bool)req.GiveOrTake, req.Type, req.Note, user.FullName);

                        return Ok(data);
                    }
                    return NotFound("user not found.");
                }

                return NotFound("the username was not found.");
            }

            return BadRequest("the model data was invalid or missing required fields.");
        }

        [HttpPost]
        [Route("AvailabilityReport")]
        [Authorize]
        public async Task<IActionResult> AvailabilityReport(GetAvailabilityReportDto req)
        {
            if(!req.IsValid)
            {
                return BadRequest("Invalid data or missing required fields");
            }

            if (req.UserId > 0)
            {
                var data = await _availabilityService.GetAvailabilityForPeriod(req.StartDate, req.EndDate, req.UserId);
                if (data != null)
                {
                    return Ok(data);
                }

                return NotFound("No data found");
            }
            else
            {
                var data = await _availabilityService.GetAvailabilityForPeriod(req.StartDate, req.EndDate);
                if (data != null)
                {
                    return Ok(data);
                }

                return NotFound("No data found");
            }
        }

        #endregion

        #region POIS
        [HttpPost]
        [Route("AddPOI")]
        public async Task<IActionResult> AddPOI(CreatePOIRequest req)
        {
            if (req.IsValid)
            {
                await _poiService.CreatePOI(req);
                return Ok();
            }
            return BadRequest("Invalid data or missing required fields");
        }

        [HttpPost]
        [Route("UpdatePOI")]
        public async Task<IActionResult> UpdatePOI(UpdatePOIRequest req)
        {
            if (req.IsValid)
            {
                await _poiService.UpdatePOI(req);
                return Ok();
            }
            return BadRequest("Invalid data or missing required fields");
        }

        [HttpGet]
        [Route("DeletePOI")]
        public async Task<IActionResult> DeletePOI(int id)
        {
            if (id == 0)
            {
                return BadRequest("Invalid data or missing required fields");
            }

            var res = await _poiService.DeletePOI(new DeletePOIRequest()
            {
                Id = id
            });

            return Ok(id);
        }

        [HttpGet]
        [Route("GetPOIs")]
        public async Task<IActionResult> GetPOIs()
        {
            var data = await _poiService.GetLocalPOI("");
            return Ok(data);
        }

        #endregion

        #region CONFIG
        [HttpGet]
        [Route("GetMessageConfig")]
        public async Task<IActionResult> GetMessageConfig()
        {
            var data = await _db.MessagingNotifyConfig.AsNoTracking().FirstOrDefaultAsync();
            return Ok(data);
        }

        [HttpPost]
        [Route("UpdateMessageConfig")]
        public async Task<IActionResult> UpdateMessageConfig(MessagingNotifyConfig req)
        {
            var res = _db.MessagingNotifyConfig.AsNoTracking().FirstOrDefault();

            if (res == null)
            {
                await _db.MessagingNotifyConfig.AddAsync(req);
            }
            else
            {
                _db.MessagingNotifyConfig.Update(req);
            }

            await _db.SaveChangesAsync();

            return Ok();
        }

        [HttpGet]
        [Route("GetCompanyConfig")]
        public async Task<IActionResult> GetCompanyConfig()
        {
            var data = await _db.CompanyConfig.AsNoTracking().FirstOrDefaultAsync();
            return Ok(data);
        }

        [HttpPost]
        [Route("UpdateCompanyConfig")]
        public async Task<IActionResult> AddCompanyConfig(CompanyConfig req)
        {
            var res = _db.CompanyConfig.AsNoTracking().FirstOrDefault();

            if (res != null)
            {
                _db.CompanyConfig.Update(req);
            }
            else
            {
                await _db.CompanyConfig.AddAsync(req);
            }

            await _db.SaveChangesAsync();

            return Ok();
        }
        #endregion

        #region TARIFFS
        [HttpGet]
        [Route("GetTariffConfig")]
        public async Task<IActionResult> GetTariffConfig()
        {
            var data = await _tariffService.GetAllTariffs();
            return Ok(data);
        }

        [HttpPost]
        [Route("SetTariffConfig")]
        public async Task<IActionResult> SetTariffConfig(Tariff obj)
        {
            await _tariffService.Update(obj);
            return Ok();
        }

        #endregion

        #region UI NOTIFICATIONS
        [HttpGet]
        [Route("GetNotifications")]
        public async Task<IActionResult> GetNotifications()
        {
            var res = await _adminUIService.GetNotifications();

            return Ok(res);
        }

        [HttpGet]
        [Route("ClearNotification")]
        public async Task<IActionResult> ClearNotification(int id)
        {
            await _adminUIService.ClearNotification(id);

            return Ok();
        }

        [HttpGet]
        [Route("ClearAllNotifications")]
        public async Task<IActionResult> ClearAllNotification()
        {
            await _adminUIService.ClearAllNotifications();

            return Ok();
        }

        [HttpPost]
        [Route("ClearAllNotifications")]
        public async Task<IActionResult> ClearAllNotificationbyType(NotificationEvent type)
        {
            await _adminUIService.ClearAllNotificationByType(type);

            return Ok();
        }

        [Authorize]
        [HttpPost]
        [Route("UpdateBrowserFCM")]
        public async Task<IActionResult> UpdateBrowserFCM(string fcm)
        {
            var uname = User.Identity.Name;

            if (!string.IsNullOrEmpty(uname))
            {
                var user = await _userManager.FindByNameAsync(uname);

                if (user != null)
                {
                    await _db.UserProfiles.Where(o => o.UserId == user.Id)
                        .ExecuteUpdateAsync(o => o.SetProperty(u => u.ChromeFCM, fcm));
                }
                else
                    return NotFound("the user was not found.");
            }

            return Ok();
        }

        [HttpPost]
        [Route("GetBrowserFCMs")]
        public async Task<IActionResult> GetBrowserFCMs()
        {
            var data = await _db.UserProfiles.AsNoTracking().Select(o => o.ChromeFCM).ToListAsync();

            //var conf = await _db.CompanyConfig.AsNoTracking().FirstOrDefaultAsync();
            
            await _messagingService.SendBrowserNotification("test title","test body");
            return Ok(data);
        }

        [Authorize]
        [HttpPost]
        [Route("RemoveBrowserFCM")]
        public async Task<IActionResult> RemoveBrowserFCM()
        {
            var uname = User.Identity.Name;

            if (!string.IsNullOrEmpty(uname))
            {
                var user = await _userManager.FindByNameAsync(uname);

                if (user != null)
                {
                    await _db.UserProfiles.Where(o => o.UserId == user.Id)
                        .ExecuteUpdateAsync(o => o.SetProperty(u => u.ChromeFCM, ""));
                }
                else
                    return NotFound("the user was not found.");
            }

            return Ok();
        }

        #endregion

        #region WEB BOOKING REQUESTS
        [HttpGet]
        [Route("GetWebChangeRequests")]
        public async Task<IActionResult> GetWebChangeRequests()
        {
            var res = new List<ActiveBookingAmendDto>();

            var data = await _db.WebAmendmentRequests.Where(o => o.Processed == false).ToListAsync();

            foreach (var item in data)
            {
                var obj = new ActiveBookingAmendDto();
                var booking = await _db.Bookings.Where(o => o.Id == item.BookingId)
                    .Select(o => new ActiveBookingDataDto
                {
                    Id = item.Id,
                    BookingId = o.Id,
                    DateTime = o.PickupDateTime,
                    PickupAddress = $"{o.PickupAddress}, {o.PickupPostCode}",
                    DestinationAddress = $"{o.DestinationAddress}, {o.DestinationPostCode}",
                    PassengerName = o.PassengerName,
                    RecurranceId = o.RecurrenceID
                    }).OrderBy(o => o.DateTime)
                .FirstOrDefaultAsync();

                obj.Id = item.Id;
                obj.Amendments = item.Amendments;
                obj.CancelBooking = item.CancelBooking;
                obj.RequestedOn = item.RequestedOn;
                obj.BookingId = item.BookingId;
                obj.ApplyToBlock = item.ApplyToBlock;

                obj.DateTime = booking.DateTime;
                obj.PickupAddress = booking.PickupAddress;
                obj.DestinationAddress = booking.DestinationAddress;
                obj.PassengerName = booking.PassengerName;
                obj.RecurranceId = booking.RecurranceId;

                res.Add(obj);
            }

            return Ok(res);
        }

        [HttpGet]
        [Route("UpdateWebChangeRequest")]
        public async Task<IActionResult> UpdateWebChangeRequests(int reqId)
        {
            await _db.WebAmendmentRequests.Where(o => o.Id == reqId).ExecuteUpdateAsync(o => o.SetProperty(u => u.Processed, true));
            return Ok();
        }

        #endregion

        [HttpPost]
        [Route("SubmitTicket")]
        [Consumes("multipart/form-data")] // Explicitly tells the API it expects form data
        public async Task<IActionResult> SubmitTicket([FromBody] SubmitTicketRequest request)
        {
            // You now have access to request.Subject, request.Message, and request.Attachment

            if (request.Attachment != null && request.Attachment.Length > 0)
            {
                // Process the file, e.g., save it to storage or pass it to the service
                // You can access file details like FileName and Length
                var fileName = request.Attachment.FileName;
                // Example: read the file stream
                 using var stream = request.Attachment.OpenReadStream();
                await _messagingService.SendEmailRaiseTicket(request.Subject, request.Message, stream, fileName);
            }
            else
            {
                await _messagingService.SendEmailRaiseTicket(request.Subject, request.Message, null, null);
            }
            return Ok();
        }

        private static string GenerateRandomString(int length = 8)
        {
            const string chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789";
            var random = new Random();
            return new string(Enumerable.Repeat(chars, length)
                .Select(s => s[random.Next(s.Length)]).ToArray());
        }

    }
}
