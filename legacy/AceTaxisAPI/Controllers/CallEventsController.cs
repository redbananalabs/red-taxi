using AceTaxis.Data;
using AceTaxis.Domain;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Newtonsoft.Json;
using Newtonsoft.Json.Serialization;
using PusherServer;
using System.Text;

namespace AceTaxisAPI.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class CallEventsController : ControllerBase
    {
        private readonly AceDbContext _db;

        public CallEventsController(AceDbContext db)
        {
            _db = db;
        }

        [HttpGet]
        [Route("CallNotification")]
        public async Task<IActionResult> CallNotification(string caller_id, string recipient_id) //[FromQuery] CallNotificationDto dto)
        {
            if (caller_id == "(anonymous)" || recipient_id == "(anonymous)")
                return Ok();

            var options = new PusherOptions
            {
                Cluster = "eu", Encrypted = true
            };

            var pusher = new Pusher(
              "1817260", "8d1879146140a01d73cf", "bad72d5c78f97de38ad1", options);

            var now = DateTime.Now.ToUKTime();
            // get previous
            var query = @" SELECT * FROM (SELECT *, ROW_NUMBER() OVER (PARTITION BY PickupAddress ORDER BY PickupDateTime DESC) AS RowNum
                            FROM Bookings 
                            WHERE PhoneNumber = {0} AND PickupDateTime < {1}) AS DistinctBookings
                            WHERE RowNum = 1
                            ORDER BY PickupDateTime DESC OFFSET 0 ROWS FETCH NEXT 10 ROWS ONLY ";

            var prev = await _db.Bookings
                .FromSqlRaw(query, caller_id, now)
                .AsNoTracking()
                .Select(o => new
                {
                    o.PickupDateTime,
                    o.PickupAddress,
                    o.PickupPostCode,
                    o.DestinationAddress,
                    o.DestinationPostCode,
                    o.Details,
                    o.PassengerName,
                    o.PhoneNumber,
                    o.Email,
                    o.ChargeFromBase,
                    o.Price,
                    o.DurationMinutes,
                    Scope = BookingScope.Cash,
                    o.AccountNumber,
                    o.Cancelled
                })
                .ToListAsync();

            var time = DateTime.Now.ToUKTime();

            // get current
            var curr = await _db.Bookings
                .Where(o => o.PhoneNumber == caller_id && o.PickupDateTime >= time && o.Cancelled == false)
                .Take(10)
                .AsNoTracking()
                .OrderBy(o => o.PickupDateTime)
                .Include(o=>o.Vias)
                .ToListAsync();

            foreach (var item in curr)
            {
                item.UserId = null;
                item.Status = AceTaxis.Domain.BookingStatus.None;
                item.BookedByName = string.Empty;

                //var date = DateTime.Now.ToUKTime();

                //item.DateCreated = date;
                //item.AllocatedAt = null;
                //item.ActionByUserId = 0;
                //item.CancelledByName = string.Empty;
                //item.CancelledOnArrival = false;
                //item.DateUpdated = null;
                //item.ConfirmationStatus = AceTaxis.Domain.ConfirmationStatus.Select;
                //item.InvoiceNumber = null;
                //item.PostedForStatement = false;
                //item.StatementId = null;
            }

            var currCancelled = await _db.Bookings
                .Where(o => o.PhoneNumber == caller_id && o.PickupDateTime.Date >= time && o.Cancelled == true)
                .Take(3)
                .AsNoTracking()
                .OrderBy(o => o.PickupDateTime)
                .Include(o => o.Vias)
                .ToListAsync();
            
            //currCancelled.Where(o => o.PickupDateTime.Hour < time.Hour);

            foreach (var c in currCancelled)
            {
                prev.Add(new
                {
                    c.PickupDateTime,
                    c.PickupAddress,
                    c.PickupPostCode,
                    c.DestinationAddress,
                    c.DestinationPostCode,
                    c.Details,
                    c.PassengerName,
                    c.PhoneNumber,
                    c.Email,
                    c.ChargeFromBase,
                    c.Price,
                    c.DurationMinutes,
                    Scope = BookingScope.Cash,
                    c.AccountNumber,
                    c.Cancelled
                });
            }

            if (caller_id.StartsWith("044"))
            {
                caller_id = "0" + caller_id.Substring(2);
            }

            if (caller_id.StartsWith("+44"))
            {
                caller_id = "0" + caller_id.Substring(2);
            }

            var obj = new { 
                Current = curr.DistinctBy(o => o.PickupAddress).OrderByDescending(o => o.PickupDateTime).ToList(),
                Previous = prev.DistinctBy(o => o.PickupAddress).OrderByDescending(o => o.PickupDateTime).ToList(), 
                Telephone = caller_id 
            };

            var json = JsonConvert.SerializeObject(obj);
            var result = await pusher.TriggerAsync("my-channel", "my-event", new { message = json });

            return Ok(obj);
        }


        [HttpGet]
        [Route("LookupNumber")]
        public async Task<IActionResult> LookupByNumber(string number)
        {
            if (number.StartsWith("044"))
            {
                number = "0" + number.Substring(3);
            }

            await CallNotification(number, number);
            return Ok(null);
        }

        [HttpGet]
        [Route("LookupEmail")]
        public async Task<IActionResult> LookupByEmail(string email)
        {
            return Ok(email);
        }

        /// <summary>
        /// Used for Booking Form Lookup
        /// </summary>
        /// <param name="caller_id"></param>
        /// <returns></returns>
        [HttpGet]
        [Route("CallerLookup")]
        public async Task<IActionResult> CallNotificationLookup(string caller_id)
        {
            var now = DateTime.Now.ToUKTime();

            // get previous
            var query = @"SELECT * FROM (SELECT *, ROW_NUMBER() OVER (PARTITION BY PickupAddress ORDER BY PickupDateTime DESC) AS RowNum 
FROM Bookings WHERE PhoneNumber = {0} AND PickupDateTime < {1}) AS DistinctBookings WHERE RowNum = 1 ORDER BY PickupDateTime DESC OFFSET 0 ROWS FETCH NEXT 10 ROWS ONLY ";

            var prev = await _db.Bookings
                .FromSqlRaw(query, caller_id, now)
                .AsNoTracking()
                .Select(o => new
                {
                    o.PickupDateTime,
                    o.PickupAddress,
                    o.PickupPostCode,
                    o.DestinationAddress,
                    o.DestinationPostCode,
                    o.Details,
                    o.PassengerName,
                    o.PhoneNumber,
                    o.Email,
                    o.ChargeFromBase,
                    o.Price,
                    o.DurationMinutes,
                    //Scope = (o.Scope == AceTaxis.Domain.BookingScope.Rank || o.Scope == AceTaxis.Domain.BookingScope.Card)
                    //    ? AceTaxis.Domain.BookingScope.Cash
                    //    : o.Scope,
                    Scope = BookingScope.Cash,
                    AccountNumber = o.AccountNumber == null ? 9999 : o.AccountNumber,
                    o.Cancelled
                })
                .ToListAsync();


            // get current
            var curr = await _db.Bookings
                .Where(o => o.PhoneNumber == caller_id && o.PickupDateTime >= now && o.Cancelled == false)
                .Take(10)
                .AsNoTracking()
                .OrderBy(o => o.PickupDateTime)
                .Include(o => o.Vias)
                .ToListAsync();

            var currCancelled = await _db.Bookings
                .Where(o => o.PhoneNumber == caller_id && o.PickupDateTime >= now && o.Cancelled == true)
                .Take(3)
                .AsNoTracking()
                .OrderBy(o => o.PickupDateTime)
                .Include(o => o.Vias)
                .ToListAsync();

            foreach (var c in currCancelled)
            {
                prev.Add(new
                {
                    c.PickupDateTime,
                    c.PickupAddress,
                    c.PickupPostCode,
                    c.DestinationAddress,
                    c.DestinationPostCode,
                    c.Details,
                    c.PassengerName,
                    c.PhoneNumber,
                    c.Email,
                    c.ChargeFromBase,
                    c.Price,
                    c.DurationMinutes,
                    Scope = (c.Scope == BookingScope.Rank || c.Scope == BookingScope.Card) ? BookingScope.Cash : BookingScope.Cash,
                    c.AccountNumber,
                    c.Cancelled
                });
            }

            var obj = new
            {
                Current = curr.DistinctBy(o => o.PickupAddress).OrderByDescending(o => o.PickupDateTime).ToList(),
                Previous = prev.DistinctBy(o => o.PickupAddress).OrderByDescending(o => o.PickupDateTime).ToList(),
                Telephone = caller_id
            };

            var settings = new JsonSerializerSettings
            {
                ContractResolver = new CamelCasePropertyNamesContractResolver(),
                Formatting = Formatting.Indented,
                ReferenceLoopHandling = ReferenceLoopHandling.Ignore,
                PreserveReferencesHandling = PreserveReferencesHandling.None    /*prevent $id/$ref at client end*/
            };

            return new ContentResult
            {
                ContentType = "application/json",
                Content = JsonConvert.SerializeObject(obj, settings),
                StatusCode = 200
            };
        }

        [HttpPost]
        [Route("Create")]
        public async Task<IActionResult> Create(string firstname,string phone)
        {
            var data = await CallNotification(phone, phone);

            var obj = new { Contact = 
                new { 
                    id = 1,
                    firstname = "John",
                    lastname = "Frost",
                    company = "",
                    email = "",
                    businessphone = "",
                    businessphone2 = "",
                    mobilephone = "07572382366",
                    mobilephone2 = "",
                    url = "",
                    customvalue = ""
                } };

            return Ok(obj);
        }

        [HttpGet]
        [Route("GetCustomerByEmail")]
        public async Task<IActionResult> GetCustomerByEmail(string email)
        {
         //   var data = await CallNotification(number, number);

            var obj = new
            {
                Contact =
                new
                {
                    id = 1,
                    firstname = "John",
                    lastname = "Frost",
                    company = "",
                    email = email,
                    businessphone = "",
                    businessphone2 = "",
                    mobilephone = "",
                    mobilephone2 = "",
                    url = "",
                    customvalue = ""
                }
            };

            return Ok();
        }

        
    }
}
