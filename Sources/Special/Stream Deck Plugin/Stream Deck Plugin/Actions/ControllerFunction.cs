using System;
using System.Drawing;
using System.Linq;
using System.Runtime.InteropServices;
using System.Text;
using System.Threading.Tasks;
using System.Windows;
using BarRaider.SdTools;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;


namespace SimulatorControllerPlugin
{
    public struct COPYDATASTRUCT {
        public IntPtr dwData;
        public int cbData;
        [MarshalAs(UnmanagedType.LPStr)]
        public string lpData;
    }

    [PluginActionId("simulatorcontrollerplugin.controllerfunction")]
    public class ControllerFunction : PluginBase {
        static string UnicodeToUTF8(string from) {
            var bytes = Encoding.UTF8.GetBytes(from);
            
            return new string(bytes.Select(b => (char)b).ToArray());
        }

        class ControllerFunctionButton : Program.Button {
            ControllerFunction ControllerFunction { get; set; }

            public override async void SetTitle(string title) {
                await this.ControllerFunction.Connection.SetTitleAsync(title);
            }

            public ControllerFunctionButton(ControllerFunction function) : base(function.GetFunction()) {
                this.ControllerFunction = function;
            }
        }

        ControllerFunctionButton Button { get; set; }

        const int WM_COPYDATA = 0x004A;

        [DllImport("user32.dll")]
        public static extern int FindWindowEx(int hwndParent, int hwndChildAfter, string lpszClass, string lpszWindow);

        [DllImport("user32.dll")]
        public static extern int SendMessage(int hWnd, int uMsg, int wParam, ref COPYDATASTRUCT lParam);

        public int SendStringMessage(int hWnd, int wParam, string msg) {
            int result = 0;

            if (hWnd > 0) {
                byte[] sarr = System.Text.Encoding.Default.GetBytes(msg);
                int len = sarr.Length;
                COPYDATASTRUCT cds;

                cds.dwData = (IntPtr)(256 * 'S' + 'D');
                cds.lpData = msg;
                cds.cbData = len + 1;

                result = SendMessage(hWnd, WM_COPYDATA, wParam, ref cds);
            }

            return result;
        }

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

            this.Button = new ControllerFunctionButton(this);

            Program.RegisterButton(this.Button);
        }

        public override void Dispose() {
            Program.UnregisterButton(this.Button);
        }

        public string GetFunction() {
            return this.settings.Function.Split(" ".ToCharArray(), 1)[0];
        }

        public override void KeyPressed(KeyPayload payload) { }

        public override void KeyReleased(KeyPayload payload)
        {
            try
            {
                int winHandle = FindWindowEx(0, 0, null, "Simulator Controller.exe");

                if (winHandle != 0)
                    SendStringMessage(winHandle, 0, "Stream Deck:" + this.settings.Function);
            }
            catch (Exception ex)
            {
                Logger.Instance.LogMessage(TracingLevel.ERROR, "Error during Key processing: " + ex.Message);
            }
        }

        public override void OnTick() { }

        public override void ReceivedSettings(ReceivedSettingsPayload payload)
        {
            Program.UnregisterButton(this.Button);

            Tools.AutoPopulateSettings(settings, payload.Settings);
            SaveSettings();

            this.Button = new ControllerFunctionButton(this);

            Program.RegisterButton(this.Button);
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
