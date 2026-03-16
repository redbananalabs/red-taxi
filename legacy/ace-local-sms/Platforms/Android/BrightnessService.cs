using Android.Views;

namespace SmsSenderApp
{
    public partial class BrightnessService
    {
        public partial float SetBrightness(float brightness)
        {
            try
            {
                var window = Microsoft.Maui.ApplicationModel.Platform.CurrentActivity.Window;
                var attributesWindow = new WindowManagerLayoutParams();

                var previousBrightness = window.Attributes.ScreenBrightness;

                attributesWindow.CopyFrom(window.Attributes);
                attributesWindow.ScreenBrightness = brightness;

                window.Attributes = attributesWindow;

                return previousBrightness;
            }
            catch
            {
                return 0;
            }
        }
    }
}
