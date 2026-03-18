using System.ComponentModel.DataAnnotations;

namespace RedTaxi.Modules.Messaging
{
    public class PushNotificationRequest
    {
        public PushNotificationRequest()
        {
            registration_ids = new List<string>();
        }

        [Required]
        public NotificationMessageBody notification { get; set; }
        [Required]
        public Dictionary<string, string> data { get; set; }
        [Required]
        public List<string> registration_ids { get; set; }
    }

    public class SendTextMessageRequestDto
    {
        [Required]
        public string Message { get; set; }

        [Required]
        [Phone]
        public string Telephone { get; set; }
    }



    public class NotificationMessageBody
    {
        [Required]
        public string title { get; set; } = string.Empty;
        [Required]
        public string body { get; set; } = string.Empty;
    }
}
