using RedTaxi.Data;
using RedTaxi.Data.Models;
using RedTaxi.Services;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Twilio.AspNet.Common;
using Twilio.AspNet.Core;
using Twilio.TwiML;

namespace RedTaxi.API.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    [Consumes("application/x-www-form-urlencoded")]
    public class WhatsAppController : TwilioController
    {
        private readonly RedTaxiDbContext _db;
        private readonly AceMessagingService _messaging;
        private readonly UserProfileService _userProfileService;
        private readonly ILogger<WhatsAppController> _logger;
        private readonly UserActionsService _actions;
        private readonly UINotificationService _uiNotificationService;

        public WhatsAppController(RedTaxiDbContext db, 
            AceMessagingService messagingService, UserProfileService userProfileService,
            ILogger<WhatsAppController> logger, UserActionsService actions, UINotificationService uINotificationService) 
        {
            _db = db;
            _messaging = messagingService;
            _userProfileService = userProfileService;
            _actions = actions;
            _logger = logger;
            _uiNotificationService = uINotificationService;
        }

        [HttpPost]
        [Route("RecieveReply")]
        [Consumes("application/x-www-form-urlencoded")]
        public async Task<TwiMLResult> RecieveReply([FromForm]
            SmsRequest request)
        {
            var messagingResponse = new MessagingResponse();
            var tel = request.From.Replace("whatsapp:+44", "0");
            var id = await _userProfileService.GetUserFromPhoneNo(tel);
            var body = request.Body + " - " + request.ButtonPayload.Replace("ACC", "").Replace("REJ", "");

            var exists = await _db.DriverMessages.Where(o => o.Message.Contains(body)).CountAsync();

            if (exists == 0)
            {
                _db.DriverMessages.Add(new DriverMessage
                {
                    UserId = id,
                    DateCreated = DateTime.Now.ToUKTime(),
                    Message = body,
                    Read = false
                });

                await _db.SaveChangesAsync();
            }

            var driverName = await _db.Users.Where(o => o.Id == id).Select(o => o.FullName).FirstOrDefaultAsync();

            if (!string.IsNullOrEmpty(request.ButtonPayload))
            {
                _logger.LogInformation($"WhatsApp reply recieved for driver {id} - Payload: {request.ButtonPayload}");

                try
                {
                    var payload = request.ButtonPayload.Replace("ACC", "").Replace("REJ", "");
                    var jobid = Convert.ToInt32(payload);

                    _logger.LogInformation($"Updating booking status for job no: {jobid} with status {request.Body}");

                    if (request.Body == "ACCEPT")
                    {
                        var allocated = await _db.Bookings.Where(o=>o.Id == jobid).Select(o=>o.UserId).FirstOrDefaultAsync();

                        if (allocated != null && allocated == id)
                        {
                            await _db.Bookings.Where(o => o.Id == jobid).ExecuteUpdateAsync(p =>
                            p.SetProperty(u => u.Status, RedTaxi.Domain.BookingStatus.AcceptedJob));

                            await _actions.LogBookingAccepted(jobid, driverName);
                        }
                    }
                    else // REJECT
                    {
                        await _db.Bookings.Where(o => o.Id == jobid).ExecuteUpdateAsync(p =>
                        p.SetProperty(u => u.Status, RedTaxi.Domain.BookingStatus.RejectedJob)
                        .SetProperty(u=>u.UserId, (int?)null));

                        await _uiNotificationService.AddJobRejectNotification(id, driverName, jobid);

                        await _actions.LogBookingRejected(jobid, driverName);
                    }

                    await _db.DriverAllocations.Where(o => o.BookingId == jobid).ExecuteDeleteAsync();
                }
                catch(Exception ex)
                {
                    _logger.LogError(ex, "Error converting or updating driver recieved status");
                }
            }
            
            _logger.LogInformation($"Message saved to database");
            return TwiML(messagingResponse);
        }



        [HttpGet]
        [Route("Send")]
        //[ValidateTwilioRequest]
        public async Task Send(string number, string message)
        {
            _logger.LogInformation($"Sending {number} - {message}");
            await _messaging.SendWhatsAppMessage(number,message);
        }

        public class SmsRequest : TwilioRequest
        {
            public string SmsMessageSid { get; set; }

            public string SmsSid { get; set; }

            public int NumMedia { get; set; }

            public string ProfileName { get; set; }

            public string WaId { get; set; }

            public string SmsStatus { get; set; }

            public string Body { get; set; }

            public string ButtonPayload { get; set; }

            public string To { get; set; }

            public int NumSegments { get; set; }

            public int ReferralNumMedia { get; set; }

            public string MessageSid { get; set; }

            public string AccountSid { get; set; }

            public string From { get; set; }

            public string ApiVersion { get; set; }
        }
    }
}
