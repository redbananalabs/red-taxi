using Microsoft.Extensions.Options;
using FirebaseAdmin;
using FirebaseAdmin.Messaging;
using Microsoft.Extensions.Logging;
using RedTaxi.Modules.Messaging;

namespace RedTaxi.Modules.Messaging.Services
{
    public interface IPushNotificationService
    {
        Task SendAndroidNotification(PushNotificationRequest request);
    }

    public class PushNotificationService : IPushNotificationService
    {
        private readonly MessagingConfig _config;
        private readonly ILogger<PushNotificationService> _logger;
        // Static logger factory initialized here (not from DI) so logger can be created.
        private static readonly ILoggerFactory _loggerFactory =
            LoggerFactory.Create(builder => builder.AddConsole());

        public PushNotificationService(IOptions<MessagingConfig> config)
        {
            // this is a singleton and the props are static so available anytime
            _config = config.Value;

            // Initialize logger from static factory (NOT from DI)
            _logger = _loggerFactory.CreateLogger<PushNotificationService>();
        }

        public async Task SendAndroidNotification(PushNotificationRequest req)
        {
            var customToken = FirebaseApp.DefaultInstance;

            foreach (var fcm in req.registration_ids)
            {
                var message = new Message()
                {
                    Notification = new Notification
                    {
                        Title = req.notification.title,
                        Body = req.notification.body
                    },
                    Data = req.data,
                    Token = fcm,
                };

                try
                {
                    string response = await FirebaseMessaging.DefaultInstance.SendAsync(message);
                    _logger.LogInformation($"Push Message Sent: {req.notification.title} -> reponse = {response}");
                }
                catch (Exception ex)
                {
                    _logger.LogError(ex, "Error sending message");
                    throw;
                }
            }
        }

        public async Task SendChromeNotification(PushNotificationRequest req)
        {
            var msg = new MulticastMessage();
            msg.Tokens = req.registration_ids;
            msg.Data = req.data;
            msg.Notification = new Notification
            {
                Title = req.notification.title,
                Body = req.notification.body
            };

            await FirebaseMessaging.DefaultInstance.SendEachForMulticastAsync(msg);
        }

    }
}
