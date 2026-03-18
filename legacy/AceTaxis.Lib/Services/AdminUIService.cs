using AceTaxis.Data;
using AceTaxis.Data.Models;
using AceTaxis.Domain;
using AceTaxis.DTOs.Admin;
using EllipticCurve.Utils;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;
using OSS.Messaging;
using OSS.Messaging.Services;

namespace AceTaxis.Services
{
    public class AdminUIService : BaseService<AdminUIService>
    {
        private readonly AvailabilityService _availabilityService;
        private readonly ReportingService _reportingService;
        private readonly IPushNotificationService _pushNotificationService;
        private readonly UserProfileService _usersService;
        private readonly AceMessagingService _messageService;

        public AdminUIService(
            IDbContextFactory<AceDbContext> factory,
            AvailabilityService availabilityService, 
            UserProfileService usersService,
            IPushNotificationService pushNotificationService,
            AceMessagingService messageService,
            ReportingService reportingService, ILogger<AdminUIService> logger) : base(factory, logger)
        {
            _availabilityService = availabilityService;
            _reportingService = reportingService;
            _pushNotificationService = pushNotificationService;
            _usersService = usersService;
            _messageService = messageService;
        }

        public async Task SendAllDriversMessage(string message, string sentBy)
        {
            // get drivers on shift
            var drivers = await _availabilityService.GetOnShiftDrivers();

            var lst = new List<(SendMessageOfType comms, string userid, string fcm, string telephone)>();

            foreach (var driver in drivers)
            {
                var fcm = await _usersService.GetFCMToken(driver.UserId);
                var tel = await _usersService.GetPhoneNumber(driver.UserId);
                var del = await _usersService.GetCommsPlatform(driver.UserId);

                lst.Add((del,driver.UserId.ToString(), fcm, tel));
            }

            foreach (var entry in lst)
            {
                var uid = Convert.ToInt32(entry.userid);
                var online = await IsPushOnline(uid);

                if (entry.comms == SendMessageOfType.Push && !string.IsNullOrEmpty(entry.fcm))
                {
                    _logger.LogInformation($"UserId {entry.userid} has FCM token - .");

                    var date = DateTime.Now.ToUKTime();

                    var navObj = new Dictionary<string, string>
                            {
                               { "NavId", $"{(int)PushNotificationNavId.GlobalMessage}" },
                               { "message", message },
                               { "datetime", date.ToString("dd/MM/yyyy HH:mm") },
                               { "sentBy", sentBy }
                            };

                     var pushn = new PushNotificationRequest
                     {
                        notification = new NotificationMessageBody
                        {
                            title = "GLOBAL MESSAGE",
                            body = message
                        },
                        data = navObj,
                        registration_ids = new List<string> { entry.fcm }
                     };

                     // send
                     try
                     {
                         await _pushNotificationService.SendAndroidNotification(pushn);

                         _logger.LogInformation($"Push notification sent to userId {entry.userid} with FCM token {entry.fcm}.");
                     }
                     catch (Exception ex)
                     {
                         _logger.LogError(ex, $"Push notification sent to userId {entry.userid} with FCM token {entry.fcm} failed");
                     }
                }
                else // text or whatsapp
                {
                    _messageService.SendSmsMessage(entry.telephone, message);
                }
            }
        }

        public async Task SendDriverMessage(int userid, string message, string sentBy)
        {
            var fcm = "";
            var tel = "";
            var del = SendMessageOfType.WhatsApp;

            // get user fcm token
            if (userid != null)
            {
                fcm = await _usersService.GetFCMToken(userid);
                tel = await _usersService.GetPhoneNumber(userid);
                del = await _usersService.GetCommsPlatform(userid);
            }

            var online = await IsPushOnline(userid);

            if (del == SendMessageOfType.Push && !string.IsNullOrEmpty(fcm) && online.Alive)
            {
                _logger.LogInformation($"UserId {userid} has FCM token - .");

                var date = DateTime.Now.ToUKTime();

                var navObj = new Dictionary<string, string>
                        {
                            { "NavId", $"{(int)PushNotificationNavId.DirectMessage}" },
                            { "message", message },
                            { "datetime", date.ToString("dd/MM/yyyy HH:mm") },
                            { "sentBy", sentBy }
                         };

                 var pushn = new PushNotificationRequest
                 {
                    notification = new NotificationMessageBody
                    {
                        title = "DIRECT MESSAGE",
                        body = message
                    },
                    data = navObj,
                    registration_ids = new List<string> { fcm }
                 };

                // send
                try
                {
                    await _pushNotificationService.SendAndroidNotification(pushn);

                    _logger.LogInformation($"Push notification sent to userId {userid} with FCM token {fcm}.");
                }
                catch (Exception ex)
                {
                   _logger.LogError(ex, $"Push notification sent to userId {userid} with FCM token {fcm} failed");
                }
            }
            else
            {
                _messageService.SendSmsMessage(tel, message);
            }
        }

        private async Task<(bool Alive, int Minutes)> IsPushOnline(int userId)
        {
            var time = await _dB.UserProfiles
                .Where(o => o.UserId == userId)
                .Select(o => o.GpsLastUpdated)
                .FirstOrDefaultAsync();

            if (time == null)
                return (false, 99);

            // Calculate the time difference
            TimeSpan difference = DateTime.Now.ToUKTime() - time.Value;

            // If you want whole minutes only:
            int diff = (int)difference.TotalMinutes;
            var off = diff <= 3;

            return (off, diff);
        }

        public async Task<DashboardDataDto> GetDashData(int userId)
        {
            var obj = new DashboardDataDto();

            var cnts = await _reportingService.GetDashCounts();
            obj.BookingsTodayCount = cnts.BookingsCount;
            obj.DriversCount = cnts.DriversCount;
            obj.PoisCount = cnts.POIsCount;
            obj.UnallocatedTodayCount = cnts.UnallocatedTodayCount;

            var from = DateTime.Now.StartOfWeek(DayOfWeek.Monday).Date;
            var to = from.AddDays(6).To2359();

            var all = await _reportingService.GetDriversTotals(from, to, userId);

            // remove driver 1
            all.RemoveAll(x => x.Id == 1);
            obj.DriverWeeksEarnings = all;

            var data = await _reportingService.GetDriversTotals(DateTime.Today.Date, DateTime.Now.ToUKTime().To2359(), userId);
            // remove driver 1
            data.RemoveAll(x => x.Id == 1);
            obj.DriverDaysEarnings = data;

            obj.JobsBookedToday = await _reportingService.JobsBookedToday();
            obj.JobsBookedTodayCount = obj.JobsBookedToday.Sum(o => o.Total);

            var counts = await _reportingService.GetCustomerCounts();
            obj.CustomerAquireCounts = counts;

            obj.AllocationReplys = await _reportingService.GetAllocationReplys();

            obj.SmsHeartBeat = await _reportingService.GetSmsHeartBeat();

            return obj;
        }

        public async Task<DateTime?> GetSMSHeartBeat()
        {
            return await _reportingService.GetSmsHeartBeat();
        }

        public async Task<List<UINotification>> GetNotifications()
        { 
            var data = await _dB.UINotifications.Where(o=>o.Status == NotificationStatus.Default)
                .OrderBy(o=>o.DateTimeStamp)
                .ToListAsync();

            return data;
        }

        public async Task ClearNotification(int id)
        {
            await _dB.UINotifications.Where(o => o.Id == id)
                .ExecuteUpdateAsync(o => o.SetProperty(p => p.Status, NotificationStatus.Read));
        }

        public async Task ClearAllNotificationByType(NotificationEvent eventType)
        {
            await _dB.UINotifications.Where(o => o.Event == eventType)
                .ExecuteUpdateAsync(o => o.SetProperty(p => p.Status, NotificationStatus.Read));
        }

        public async Task ClearAllNotifications()
        {
            await _dB.UINotifications
                .ExecuteUpdateAsync(o => o.SetProperty(p => p.Status, NotificationStatus.Read));
        }
    }
}
