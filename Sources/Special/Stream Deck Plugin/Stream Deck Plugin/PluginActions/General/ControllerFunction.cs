using System;
using System.Diagnostics;
using System.Drawing;
using System.Runtime.InteropServices;
using System.ServiceModel;
using System.Threading.Tasks;
using BarRaider.SdTools;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;


namespace SimulatorControllerStreamDeckPlugin.PluginActions
{
   [PluginActionId("SimulatorControllerStreamDeckPlugin.ControllerFunction")]
    public class ControllerFunction : PluginBase
    {
        [DllImport("user32.dll")]
        public static extern IntPtr FindWindowEx(IntPtr hwndParent, IntPtr hwndChildAfter, string lpszClass, string lpszWindow);

        [DllImport("user32.dll")]
        public static extern int SendMessage(IntPtr hWnd, int uMsg, int wParam, string lParam);

        const int WM_COPYDATA = 0x004A;

        private class PluginSettings
        {
            public static PluginSettings CreateDefaultSettings()
            {
                PluginSettings instance = new PluginSettings();
                instance.Function = "Button.1";
                return instance;
            }

            [JsonProperty(PropertyName = "Function")]
            public string Function { get; set; }
        }

        #region Private Members

        private PluginSettings settings;
        private bool _valueShown;
        private int _valueShownTimeout = 1;
        private DateTime _valueShownDateTime = DateTime.Now;

        #endregion
        public ControllerFunction(SDConnection connection, InitialPayload payload) : base(connection, payload)
        {
            if (payload.Settings == null || payload.Settings.Count == 0)
            {
                settings = PluginSettings.CreateDefaultSettings();
                SaveSettings();
            }
            else
            {
                settings = payload.Settings.ToObject<PluginSettings>();
            }
        }

        public override void Dispose() { }

        public override void KeyPressed(KeyPayload payload) { }

        public override void KeyReleased(KeyPayload payload)
        {
            var returnVal = -1;
            try
            {
                Process proccess = Process.GetProcessesByName("Simulator Controller.exe")[0];

                SendMessage(proccess.Handle, WM_COPYDATA, 0, "External:" + this.settings.Function);
            }
            catch (Exception ex)
            {
                Logger.Instance.LogMessage(TracingLevel.ERROR, "Error during Key processing: " + ex.Message);
            }
        }

        public override void OnTick() { }

        public override void ReceivedSettings(ReceivedSettingsPayload payload)
        {
            Tools.AutoPopulateSettings(settings, payload.Settings);
            SaveSettings();
        }

        public override void ReceivedGlobalSettings(ReceivedGlobalSettingsPayload payload) { }

        #region Private Methods
        private async Task DrawValueData(int value)
        {

            try
            {
                var ForegroundColor = "#ffffff";
                var BackgroundColor = "#000000";

                Bitmap bmp = Tools.GenerateGenericKeyImage(out Graphics graphics);
                int height = bmp.Height;
                int width = bmp.Width;

                SizeF stringSize;
                float stringPos;
                var fontDefault = new Font("Verdana", 30, FontStyle.Bold);

                // Background
                var bgBrush = new SolidBrush(ColorTranslator.FromHtml(BackgroundColor));
                var fgBrush = new SolidBrush(ColorTranslator.FromHtml(ForegroundColor));
                graphics.FillRectangle(bgBrush, 0, 0, width, height);

                // Top title
                string title = "";
                stringSize = graphics.MeasureString(title, fontDefault);
                stringPos = Math.Abs((width - stringSize.Width)) / 2;
                graphics.DrawString(title, fontDefault, fgBrush, new PointF(stringPos, 5));

                string currStr = value.ToString();
                int buffer = 0;

                stringSize = graphics.MeasureString(currStr, fontDefault);
                stringPos = Math.Abs((width - stringSize.Width)) / 2;
                graphics.DrawString(currStr, fontDefault, fgBrush, new PointF(stringPos, 50));
                Connection.SetImageAsync(bmp);
                graphics.Dispose();
                _valueShown = true;
                _valueShownDateTime = DateTime.Now;
            }
            catch (Exception ex)
            {
                Logger.Instance.LogMessage(TracingLevel.ERROR, $"Error drawing image data {ex}");
            }
        }
        private async Task RestoreImage()
        {
            await Connection.SetDefaultImageAsync();
        }
        private Task SaveSettings()
        {
            return Connection.SetSettingsAsync(JObject.FromObject(settings));
        }

        #endregion
    }
}
