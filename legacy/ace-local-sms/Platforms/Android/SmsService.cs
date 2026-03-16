using Android.App;
using Android.Content;
using Android.Telephony;
using Android.Util;

namespace SmsSenderApp
{
    public partial class SmsService 
    {
        public partial bool Send(string phone, string message)
        {
            try
            {
                var currentActivity = Platform.CurrentActivity;
                PendingIntent pendingIntent = PendingIntent.GetActivity(currentActivity, 0, new Intent(currentActivity, typeof(MainActivity)), 0);
                
                SmsManager.Default.SendTextMessage(phone, null, message, pendingIntent, null);

                return true;
            }
            catch(Java.Lang.Exception ex)
            {
                Log.Debug("INFO", "error sending sms", ex);
                return false;
            }
        }
    }
}
