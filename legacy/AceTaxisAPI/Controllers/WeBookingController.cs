using AceTaxis;
using AceTaxis.Data;
using AceTaxis.Data.Models;
using AceTaxis.Domain;
using AceTaxis.DTOs;
using AceTaxis.DTOs.Admin;
using AceTaxis.DTOs.Booking;
using AceTaxis.DTOs.MessageTemplates;
using AceTaxis.Migrations;
using AceTaxis.Services;
using AutoMapper;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Newtonsoft.Json;
using System.Net;
using System.Net.Http.Headers;
using System.Text.Encodings.Web;
using System.Text.Json.Serialization;

namespace AceTaxisAPI.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class WeBookingController : ControllerBase
    {
        private readonly AceDbContext _db;
        private readonly IMapper _mapper;
        private readonly BookingService _bookingService;
        private readonly AceMessagingService _aceMessagingService;
        private readonly UserManager<AppUser> _userManager;
        private readonly UserProfileService _userProfileService;
        private readonly TariffService _tariff;
        private readonly UINotificationService _notification;
        private readonly HttpClient _httpClient = new HttpClient();

        public WeBookingController(AceDbContext db, 
            IMapper mapper, 
            BookingService bookingService, 
            AceMessagingService messagingService,
            UserManager<AppUser> userManager,
            TariffService tariff,
            UserProfileService userProfileService,
            UINotificationService notificationService)
        {
            _db = db;
            _mapper = mapper;
            _bookingService = bookingService;
            _aceMessagingService = messagingService;
            _userManager = userManager;
            _userProfileService = userProfileService;
            _tariff = tariff;
            _notification = notificationService;
        }

        //private string[] AirportsSeaPorts = new string[] 
        //{
        //    "Bristol Airport",
        //    "Bristol Seaport",
        //    "Bristol Cruise Terminal",
        //    "Bristol Ferry Terminal",
        //    "Bristol Docks",
        //    "Heathrow Airport Terminal 1",
        //    "Heathrow Airport Terminal 2",
        //    "Heathrow Airport Terminal 3",
        //    "Heathrow Airport Terminal 4",
        //    "Heathrow Airport Terminal 5",
        //    "Gatwick Airport South Terminal",
        //    "Gatwick Airport North Terminal",
        //    "Bournemouth Airport",
        //    "Luton Airport",
        //    "Stanstead Airport",
        //    "London City Aiport",
        //    "City Airport",
        //    "Exeter Airport",
        //    "Poole Docks",
        //    "Southampton Docks"
        //};

        [HttpPost]
        [Route("CreatePolygon")]
        public async Task<IActionResult> CreatePolygon([FromBody] CreateGeoFenceDto dto)
        {
            if (dto.IsValid)
            {
                // check duplcate name
                var cnt = await _db.GeoFences.CountAsync(o => o.Name == dto.Name);

                if (cnt == 0)
                {
                    var obj = new GeoFence
                    {
                        Name = dto.Name,
                        PolygonData = dto.Data,
                        Area = dto.Area,
                        Points = dto.Points,
                        CreatedOn = DateTime.Now.ToUKTime()
                    };
                    await _db.GeoFences.AddAsync(obj);
                    await _db.SaveChangesAsync();
                    return Ok(obj);
                }
                else
                { 
                     return BadRequest("a polygon with the same name already exists");
                }
            }

            return BadRequest("the data is invalid or missing required fields");
        }

        [HttpPost]
        [Route("UpdatePolygon")]
        public async Task<IActionResult> UpdatePolygon([FromBody] CreateGeoFenceDto dto)
        {
            if (dto.IsValid)
            {
                await _db.GeoFences.Where(o => o.Name == dto.Name).ExecuteDeleteAsync();

                // check duplcate name
                var cnt = await _db.GeoFences.CountAsync(o => o.Name == dto.Name);

                if (cnt == 0)
                {
                    var obj = new GeoFence
                    {
                        Name = dto.Name,
                        PolygonData = dto.Data,
                        Area = dto.Area,
                        Points = dto.Points,
                        CreatedOn = DateTime.Now.ToUKTime()
                    };
                    await _db.GeoFences.AddAsync(obj);
                    await _db.SaveChangesAsync();
                    return Ok(obj);
                }
                else
                {
                    return BadRequest("a polygon with the same name already exists");
                }
            }

            return BadRequest("the data is invalid or missing required fields");
        }

        [HttpDelete]
        [Route("DeletePolygon")]
        public async Task<IActionResult> DeletePolygon(string polygonName)
        {
            await _db.ZoneToZonePrices.Where(o => o.StartZoneName == polygonName || o.EndZoneName == polygonName).ExecuteDeleteAsync();

            {
                await _db.GeoFences.Where(o=>o.Name == polygonName).ExecuteDeleteAsync();
                return Ok();
            }
        }

        [HttpGet]
        [Route("GetAllPolygons")]
        public async Task<IActionResult> GetAllPolygons()
        {
            {
                var data = await _db.GeoFences.ToListAsync();
                return Ok(data);
            }
        }

        [HttpPost]
        [Route("GetAdressSuggestions")]
        public async Task<IActionResult> GetAdressSuggestions(string search)
        {
            if (string.IsNullOrEmpty(search))
                return BadRequest("the search string is empty");

            // get pois
            var pois = await _db.LocalPOIs
                .Where(o => (o.Type != LocalPOIType.House && o.Type != LocalPOIType.Airport && o.Type != LocalPOIType.Ferry_Port)  && o.Address.StartsWith(search) || o.Postcode.StartsWith(search))
                .Select(o => new { o.Address, o.Postcode })
                .ToListAsync();

            // Create the client
         //   var result = new PostcodeLookup().LookupAddress(search); 

            //if (true)
            //{
            //    var res = new Dictionary<string,string>();

            //    // Add POIs to the result
            //    foreach (var poi in pois)
            //    {
            //        var address = $"{poi.Address}, {poi.Postcode}";
            //        res.Add(address,"");
            //    }

            //    // Add suggestions from the API
            //    var reply = JsonConvert.DeserializeObject<GetAddressResponseDto>(result.Json);

            //    foreach (var suggestion in reply.suggestions)
            //    {
            //        res.Add(suggestion.address,suggestion.id);
            //    }

            //    return Ok(res);
            //}
            //else
            //{
            //    return BadRequest($"Error fetching address suggestions: {result.Failed.Message}");
            //}

            return Ok(pois);
        }

        [HttpPost]
        [Route("AddNewPassenger")]
        public async Task<IActionResult> AddNewPassenger([FromBody] AccountPassengerDto dto)
        {
            if (dto.IsValid) 
            {
                var obj = _mapper.Map<AccountPassengerDto, AccountPassenger>(dto);
                
                await _db.AccountPassengers.AddAsync(obj);
                await _db.SaveChangesAsync();

                return Ok(obj);
            }

            return BadRequest("the data is invalid or missing required fields");
            
        }

        [HttpDelete]
        [Route("DeletePassenger")]
        public async Task<IActionResult> DeletePassenger(int passengerId)
        {
            if (passengerId > 0)
            {
                var cnt = await _db.AccountPassengers.Where(o => o.Id == passengerId).CountAsync();

                if (cnt == 1)
                {
                    await _db.AccountPassengers.Where(o=>o.Id == passengerId).ExecuteDeleteAsync();
                    return Ok(passengerId);
                }

                return NotFound("the passenger id was not found");
            }

            return BadRequest("the passenger id is invalid");
        }

        [HttpGet]
        [Route("GetPassengers")]
        public async Task<IActionResult> GetPassengerList(int accountNo)
        {
            if(accountNo == 0)
                return BadRequest("Invalid account number.");

            var data = await _db.AccountPassengers.Where(o => o.AccNo == accountNo).ToListAsync();

            if (data != null)
            {
                var res = new List<AccountPassengerDto>();

                foreach (var item in data) 
                {
                    var i = _mapper.Map<AccountPassenger,AccountPassengerDto>(item);
                    res.Add(i);
                }
                 
                return Ok(res);
            }

            return Ok(new List<AccountPassengerDto>());
        }

        [HttpPost]
        [Route("CreateWebBooking")]
        public async Task<IActionResult> CreateWebBooking(WebBookingDto dto)
        {
            if (dto.IsValid)
            {
                var job = _mapper.Map<WebBookingDto, WebBooking>(dto);

                job.Passengers = dto.Passengers;

                var date = DateTime.Now.ToUKTime();

                job.CreatedOn = date;
                job.Scope = BookingScope.Account;

                await _db.WebBookings.AddAsync(job);
                await _db.SaveChangesAsync();

                // create notfication
                await _notification.WebBookingCreated(dto.AccNo);
                await _aceMessagingService.SendBrowserNotification("ACCOUNT BOOKING REQUEST", $"Account {dto.AccNo} has requested a booking for {dto.PickupDateTime}.");
                return Ok();
            }

            return BadRequest("the data is invalid or missing required fields");
        }

        [HttpPost]
        [Route("CreateCashBooking")]
        public async Task<IActionResult> CreateCashBooking(CashWebBookingDto dto)
        {
            if (dto.IsValid)
            {
                var job = _mapper.Map<CashWebBookingDto, WebBooking>(dto);

                job.DestinationAddress = dto.DestinationAddress;

                var date = DateTime.Now.ToUKTime();
                job.AccNo = 9999;
                job.CreatedOn = date;
                job.Scope = dto.Scope.Value;
                
                job.PickupAddress = dto.PickupAddress.Replace(dto.PickupPostCode,"").Replace(",,",",").Trim().TrimEnd(',');
                job.DestinationAddress = dto.DestinationAddress.Replace(dto.DestinationPostCode, "").Replace(",,", ",").Trim().TrimEnd(',');

                job.PickupAddress =  WebUtility.UrlDecode(job.PickupAddress);
                job.DestinationAddress = WebUtility.UrlDecode(job.DestinationAddress);

                // Ensure the passenger name is in Title Case
                if (!string.IsNullOrWhiteSpace(job.PassengerName))
                {
                    var textInfo = System.Globalization.CultureInfo.CurrentCulture.TextInfo;
                    job.PassengerName = textInfo.ToTitleCase(job.PassengerName.ToLower());
                }

                job.Mileage = dto.Mileage;
                job.MileageText = dto.MileageText;
                job.DurationMinutes = dto.DurationMinutes;
                job.DurationText = dto.DurationText;
                job.Price = dto.Price;
                job.ArriveBy = false;
                job.Luggage = dto.Luggage;
                job.Passengers = dto.Passengers;
                
                job.Details = WebUtility.UrlDecode(dto.Details);

                await _db.WebBookings.AddAsync(job);
                await _db.SaveChangesAsync();

                // create notfication
                await _notification.WebBookingCreated(dto.AccNo);
                await _aceMessagingService.SendBrowserNotification("CASH BOOKING REQUEST", $"Account {dto.AccNo} has requested a booking for {dto.PickupDateTime}.");

                // send booking sms
                var email = job.Email;
                var name = job.PassengerName;

                _aceMessagingService.SendSmsMessage("07870545494", "You have received a new cash booking on ace taxis website, take a look ;-)");
                _aceMessagingService.SendSmsMessage("07572382366", "You have received a new cash booking on ace taxis website, take a look ;-)");

                return Ok();
            }

            return BadRequest("the data is invalid or missing required fields");
        }

        [Authorize]
        [HttpPost]
        [Route("GetWebBookings")]
        public async Task<IActionResult> GetWebBookings(GetWebBookingsRequestDto dto)
        {
            IQueryable<WebBooking> query;

            if(dto.AccNo.HasValue && dto.AccNo.Value != 0)
                query = _db.WebBookings.Where(o => o.AccNo == dto.AccNo).AsQueryable();
            else
                query = _db.WebBookings.AsQueryable();

            query.Where(o => o.Processed == dto.Processed);

            if (dto.Accepted)
                query = query.Where(o => o.Status == WebBookingStatus.Accepted);
            if (dto.Rejected)
                query = query.Where(o => o.Status == WebBookingStatus.Rejected);

            var data = await query.ToListAsync();

            foreach (var item in data)
            {
                if (!string.IsNullOrEmpty(item.RecurrenceRule))
                {
                    var rule = new BookingRule(item.RecurrenceRule);

                    var str = string.Empty;

                    if (rule.Mon)
                        str += "Mon,";
                    if (rule.Tue)
                        str += "Tue,";
                    if (rule.Wed)
                        str += "Wed,";
                    if (rule.Thu)
                        str += "Thu,";
                    if (rule.Fri)
                        str += "Fri,";
                    if (rule.Sat)
                        str += "Sat,";
                    if (rule.Sun)
                        str += "Sun";

                    if (rule.UntilEnd.HasValue)
                    {
                        var eo = rule.UntilEnd.Value;
                        str += $"\r\nEnds On: {eo.ToString("dd/MM/yy")}";
                    }

                    item.RepeatText = str;
                }
            }

            return Ok(data);
        }

        [Authorize]
        [HttpPost]
        [Route("Accept")]
        public async Task<IActionResult> AcceptWebBooking(WebBookingAcceptDto dto)
        {
            if (dto.IsValid)
            { 
                var obj = _db.WebBookings.FirstOrDefault(x => x.Id == dto.Id);

                if (obj == null)
                {
                    return NotFound("the web booking was not found");
                }

                var uname = User.Identity.Name;
                var fullname = string.Empty;

                if (!string.IsNullOrEmpty(uname))
                {
                    var user = await _userManager.FindByNameAsync(uname);

                    if (user != null)
                    {
                        fullname = user.FullName;
                    }
                }

                // validate recurrance rule
                if (!string.IsNullOrEmpty(obj.RecurrenceRule))
                {
                    try
                    {
                        var rule = new BookingRule(obj.RecurrenceRule);
                    }
                    catch (Exception ex)
                    {

                        return BadRequest($"The recurrance rule is invalid\r\n{ex.Message}");
                    }
                }

                // create booking
                var hh = Convert.ToInt32(dto.RequiredTime.Split(':')[0]);
                var mm = Convert.ToInt32(dto.RequiredTime.Split(':')[1]);

                var dt = new DateTime(obj.PickupDateTime.Year, 
                    obj.PickupDateTime.Month, 
                    obj.PickupDateTime.Day, 
                    hh, mm, 0);

                GetPriceResponseDto journey = null;

                if (obj.AccNo != 9999)
                {
                    if (obj.AccNo != 9014 || obj.AccNo != 10026)
                    {
                        try
                        {
                            // get time and miles - get price
                            journey = await _tariff.GetOnInvoicePrices(obj.PickupPostCode,
                                   obj.DestinationPostCode, null, obj.AccNo);
                        }
                        catch (Exception)
                        {
                            // expected error if postcodes are invalid
                            journey = new GetPriceResponseDto();
                        }
                    }
                    else
                    {
                        try
                        {
                            // get time and miles - get price
                            journey = await _tariff.GetPriceHVS(obj.PickupPostCode,
                                   obj.DestinationPostCode, null);
                        }
                        catch (Exception)
                        {
                            // expected error if postcodes are invalid
                            journey = new GetPriceResponseDto();
                        }
                    }
                }

                var scope = obj.AccNo == 9999 ? obj.Scope : BookingScope.Account;

                //var price = (obj.AccNo == 9999 && dto.Price > 0) ? dto.Price : journey.PriceAccount;

                var req = new CreateBookingRequestDto
                {
                    PickupDateTime = dt,
                    PickupAddress = obj.PickupAddress,
                    PickupPostCode = obj.PickupPostCode,
                    DestinationAddress = obj.DestinationAddress,
                    DestinationPostCode = obj.DestinationPostCode,
                    PassengerName = obj.PassengerName,
                    AccountNumber = obj.AccNo,
                    RecurrenceRule = obj.RecurrenceRule,
                    Email = obj.Email,
                    PhoneNumber = obj.PhoneNumber,
                    Scope = scope,
                    BookedByName = "[WEB] - " + fullname,
                    Passengers = obj.Passengers
                };

                // set price and mileage and details
                req.DurationMinutes = obj.AccNo == 9999 ? obj.DurationMinutes.Value : journey.TotalMinutes;
                req.Mileage = obj.AccNo == 9999 ? obj.Mileage : (decimal)journey.TotalMileage;
                req.MileageText = obj.AccNo == 9999 ? obj.MileageText : journey.MileageText;
                req.DurationMinutes = obj.AccNo == 9999 ? obj.DurationMinutes.Value : journey.TotalMinutes;
                req.Passengers = obj.Passengers;

                if (dto.Price > 0)
                {
                    if (obj.AccNo == 9999)
                    {
                        req.Price = (decimal)dto.Price;
                        req.PriceAccount = 0;
                    }
                    else
                    {
                        req.Price = (decimal)dto.Price;
                        req.PriceAccount = (decimal)journey.PriceAccount;
                    }

                }
                else 
                {
                    req.Price = obj.AccNo == 9999 ? (decimal)obj.Price : (decimal)journey.PriceDriver;
                    req.PriceAccount = obj.AccNo == 9999 ? 0 : (decimal)journey.PriceAccount;
                }

                if (obj.AccNo == 9999)
                {
                    req.Details += $"[Web Booking]\r\n\r\nLuggage: {obj.Luggage}\r\n\r\n{obj.Details}";
                    req.Scope = BookingScope.Card;
                }
                else
                { 
                    req.Details += $"[Web Booking]\r\n\r\n{obj.Details}";
                }
                    var obj2 = await _bookingService.CreateBooking(req);

                var email = string.Empty;
                var name = string.Empty;

                if (obj.AccNo == 9999)
                {
                    email = obj.Email;
                    name = obj.PassengerName;
                }
                else
                {
                    var detail = await _db.Accounts
                         .Where(o => o.AccNo == obj.AccNo)
                         .Select(o => new { o.BookerName, o.BookerEmail })
                         .FirstOrDefaultAsync();

                    email = detail.BookerEmail;
                    name = detail.BookerName;
                }

                if (!string.IsNullOrEmpty(email))
                {
                    if (obj.AccNo == 9999)
                    {
                        await _aceMessagingService.SendCashBookingAcceptedEmail(email, name,
                            new BookingAcceptedEmail
                            {
                                accno = obj.AccNo,
                                pickupaddress = $"{obj.PickupAddress}, {obj.PickupPostCode}",
                                destinationaddress = $"{obj.DestinationAddress}, {obj.DestinationPostCode}",
                                passengername = obj.PassengerName,
                                bookingId = obj2.First().BookingId,
                                price = (double)obj.Price,
                                datetime = obj.PickupDateTime.ToString("dd/MM/yy HH:mm")
                            });

                        // send payment link - this will update the booking to card & pending

                        // Forward the JWT token from the incoming request
                        var authHeader = Request.Headers["Authorization"].ToString();

                        // create url
                        var url = $"https://ace-server.1soft.co.uk/api/bookings/paymentlink" +
                             $"?bookingId={obj2.First().BookingId}" +
                             $"&telephone={Uri.EscapeDataString(obj.PhoneNumber)}" +
                             $"&email={Uri.EscapeDataString(obj.Email)}" +
                             $"&name={Uri.EscapeDataString(obj.PassengerName)}" +
                             $"&price={obj.Price}" +
                             $"&pickup={Uri.EscapeDataString(obj.PickupAddress)}";

                        // Create downstream request
                        var request = new HttpRequestMessage(
                            HttpMethod.Get,
                            url);

                        if (!string.IsNullOrEmpty(authHeader) && AuthenticationHeaderValue.TryParse(authHeader, out var parsed))
                        {
                            request.Headers.Authorization = parsed;
                        }

                        // Send request
                        var response = await _httpClient.SendAsync(request, HttpContext.RequestAborted);

                        // Handle response
                        var body = await response.Content.ReadAsStringAsync();
                    }
                    else
                    { 
                        await _aceMessagingService.SendAccountBookingAcceptedEmail(email, name,
                            new BookingAcceptedEmail
                            {
                                accno = obj.AccNo,
                                pickupaddress = $"{obj.PickupAddress}, {obj.PickupPostCode}",
                                destinationaddress = $"{obj.DestinationAddress}, {obj.DestinationPostCode}",
                                passengername = obj.PassengerName,
                                bookingId = obj2.First().BookingId,
                                price = dto.Price,
                                datetime = obj.PickupDateTime.ToString("dd/MM/yy HH:mm")
                            });
                    }
                }

                // update web booking request
                var date = DateTime.Now.ToUKTime();
                
                obj.Processed = true;
                obj.AcceptedRejectedBy = fullname;
                obj.AcceptedRejectedOn = date;
                obj.Status = WebBookingStatus.Accepted;

                _db.WebBookings.Update(obj);
                await _db.SaveChangesAsync();

                return Ok();
            }

            return BadRequest("the data is invalid or missing required fields");
        }

        [Authorize]
        [HttpPost]
        [Route("Reject")]
        public async Task<IActionResult> RejectWebBooking(WebBookingRejectDto dto)
        {
            if (dto.IsValid)
            {
                var obj = await _db.WebBookings.FirstOrDefaultAsync(x => x.Id == dto.Id);

                if (obj == null)
                {
                    return NotFound("the web booking was not found");
                }

                var uname = User.Identity.Name;
                var fullname = string.Empty;

                if (!string.IsNullOrEmpty(uname))
                {
                    var user = await _userManager.FindByNameAsync(uname);

                    if (user != null)
                    {
                        fullname = user.FullName;
                    }
                }

                // send confirmation email
                var email = string.Empty;
                var name = string.Empty;

                if (obj.AccNo == 9999)
                {
                    email = obj.Email;
                    name = obj.PassengerName;
                }
                else
                {
                    var detail = await _db.Accounts
                         .Where(o => o.AccNo == obj.AccNo)
                         .Select(o => new { o.BookerName, o.BookerEmail })
                         .FirstOrDefaultAsync();

                    email = detail.BookerEmail;
                    name = detail.BookerName;
                }

                if (!string.IsNullOrEmpty(email))
                {
                    if (obj.AccNo == 9999)
                    {
                        await _aceMessagingService.SendCashBookingRejectedEmail(email, name,
                           new BookingRejectedEmail
                           {
                               accno = obj.AccNo,
                               pickupaddress = $"{obj.PickupAddress}, {obj.PickupPostCode}",
                               destinationaddress = $"{obj.DestinationAddress}, {obj.DestinationPostCode}",
                               passengername = obj.PassengerName,
                               reason = dto.Reason,
                               datetime = obj.PickupDateTime.ToString("dd/MM/yy HH:mm")
                           });
                    }
                    else
                    {
                        await _aceMessagingService.SendAccountBookingRejectedEmail(email, name,
                            new BookingRejectedEmail
                            {
                                accno = obj.AccNo,
                                pickupaddress = $"{obj.PickupAddress}, {obj.PickupPostCode}",
                                destinationaddress = $"{obj.DestinationAddress}, {obj.DestinationPostCode}",
                                passengername = obj.PassengerName,
                                reason = dto.Reason,
                                datetime = obj.PickupDateTime.ToString("dd/MM/yy HH:mm")
                            });
                    }
                }

                // update web booking request
                var date = DateTime.Now.ToUKTime();
                
                obj.Processed = true;
                obj.AcceptedRejectedBy = fullname;
                obj.AcceptedRejectedOn = date;
                obj.RejectedReason = UrlEncoder.Create().Encode(dto.Reason);
                obj.Status = AceTaxis.Domain.WebBookingStatus.Rejected;

                _db.WebBookings.Update(obj);
                await _db.SaveChangesAsync();

                return Ok();
            }

            return BadRequest("the data is invalid or missing required fields");
        }

        [Authorize]
        [HttpPost]
        [Route("AmendAccept")]
        public async Task<IActionResult> AmendAcceptWebBooking(WebBookingAmendAcceptDto dto)
        {
            if (dto.IsValid)
            {
                var obj = await _db.WebBookings.FirstOrDefaultAsync(x => x.Id == dto.Id);

                if (obj == null)
                {
                    return NotFound("the web booking was not found");
                }

                var uname = User.Identity.Name;
                var fullname = string.Empty;

                if (!string.IsNullOrEmpty(uname))
                {
                    var user = await _userManager.FindByNameAsync(uname);

                    if (user != null)
                    {
                        fullname = user.FullName;
                    }
                }

                obj.PickupDateTime = dto.PickupDateTime;
                obj.Passengers = dto.Passengers;
                obj.Status = WebBookingStatus.Default;
                obj.Processed = false;
                obj.RejectedReason = string.Empty;
                
                _db.WebBookings.Update(obj);
                await _db.SaveChangesAsync();

                if (dto.Vehicles > 1)
                { 
                    foreach (var i in Enumerable.Range(1, dto.Vehicles - 1))
                    {
                        // clone job
                        var newJob = (WebBooking)obj.Clone();
                        newJob.Id = 0;
                        await _db.WebBookings.AddAsync(newJob);
                        await _db.SaveChangesAsync();
                    }
                }

                return Ok();

            }
         
            return BadRequest("the data is invalid or missing required fields");
        }



        [HttpGet]
        [Route("ShortenUrl")]
        public async Task<IActionResult> ShortenUrl(string longUrl)
        {
            if (string.IsNullOrEmpty(longUrl))
                return BadRequest("the url is empty");
            var shortUrl = await _aceMessagingService.ShorternUrl(longUrl);
            if (!string.IsNullOrEmpty(shortUrl))
                return Ok(shortUrl);
            else
                return BadRequest("an error occurred while shortening the url");
        }

        [Authorize]
        [HttpGet]
        [Route("GetDuration")]
        public async Task<IActionResult> GetDuration(int wid)
        {
            var obj = await _db.WebBookings.Where(o=>o.Id == wid)
                .Select(o => new { 
                    o.PickupDateTime, 
                    o.PickupPostCode, 
                    o.DestinationPostCode 
                })
                .FirstOrDefaultAsync();


            // get time and miles - get price
            var journey = await _tariff.Get9999CashPrice(obj.PickupDateTime, 1, obj.PickupPostCode,
                   obj.DestinationPostCode, null, true);

            if (journey != null)
            {
                return Ok(journey.JourneyMinutes + 5);
            }

            return BadRequest("Possible postcode error, please check they are valid postcodes.");
        }

       // [Authorize]
        [HttpGet]
        [Route("GetAccountActiveBookings")]
        public async Task<IActionResult> GetAccountActiveBookings(int accno)
        {
            var active = await _bookingService.GetAccountActiveBookings(accno);

            var lst = active.Select(o => o.BookingId).ToList();

            var pending = await _db.WebAmendmentRequests
                .Where(o => o.Processed == false && lst.Contains(o.BookingId))
                .Select(o => new { o.BookingId, o.ApplyToBlock })
                .FirstOrDefaultAsync();

            if (pending != null)
            {
                // display pending for actual booking
                active.Where(o => o.BookingId == pending.BookingId).First().ChangesPending = true;

                // check if actual booking is cancelBlock then apply to any Dates > than booking date
                if (pending.ApplyToBlock)
                {
                    // get bookings going forward
                    var firstDate = active.FirstOrDefault(o => o.BookingId == pending.BookingId).DateTime;
                    var recurId = active.FirstOrDefault(o => o.BookingId == pending.BookingId).RecurranceId;

                    var block = active.Where(o => o.DateTime.Date > firstDate.Date && o.RecurranceId == recurId)
                        .Select(o => o.BookingId)
                        .ToList();

                    foreach (var item in block)
                    {
                        active.Where(o => o.BookingId == item).First().ChangesPending = true;
                    }
                }
            }

            return Ok(active);
        }

        [Authorize]
        [HttpGet]
        [Route("RequestAmendment")]
        public async Task<IActionResult> RequestAmendment(int bookingId, string message, bool block)
        {
            var date = DateTime.Now.ToUKTime();

            var obj = new WebAmendmentRequest
            {
                BookingId = bookingId,
                Amendments = message,
                Processed = false,
                CancelBooking = false,
                ApplyToBlock = block,
            };

            var uname = User.Identity.Name;

            // create notfication
            await _notification.BookingAmendmentRequest(uname, bookingId, message);
            await _db.WebAmendmentRequests.AddAsync(obj);
            await _db.SaveChangesAsync();

            _aceMessagingService.SendSmsMessage("07870545494", "You have received a amendment request from an account customer, take a look ;-)");

            return Ok();
        }

        [Authorize]
        [HttpGet]
        [Route("RequestCancellation")]
        public async Task<IActionResult> RequestCancellation(int bookingId, bool block)
        {
            var date = DateTime.Now.ToUKTime();

            var obj = new WebAmendmentRequest
            {
                BookingId = bookingId,
                Amendments = "Cancel Booking",
                Processed = false,
                CancelBooking = true,
                RequestedOn = date,
                ApplyToBlock = block
            };

            var uname = User.Identity.Name;

            // create notfication
            await _notification.BookingCancelationRequest(uname, bookingId);
            await _aceMessagingService.SendBrowserNotification("BOOKING CANCELLATION REQUEST", $"Account {uname} has requested a cancellation.");
            await _db.WebAmendmentRequests.AddAsync(obj);
            await _db.SaveChangesAsync();

            return Ok();
        }

    }
}
