using System;
using System.Drawing;
using System.Drawing.Imaging;
using System.IO;
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
                this.ControllerFunction.SwitchProfile();

                await this.ControllerFunction.Connection.SetTitleAsync(title);
            }

            public override async void SetImage(string path) {
                this.ControllerFunction.SwitchProfile();

                if (path.CompareTo("clear") == 0)
                    await this.ControllerFunction.Connection.SetImageAsync((String)null, null, true);
                else
                    using (MemoryStream m = new MemoryStream()) {
                        var image = Image.FromFile(path);
                        var raw = image.RawFormat;
                        string mimeType = ImageCodecInfo.GetImageDecoders().First(c => c.FormatID == raw.Guid).MimeType;

                        image.Save(m, raw);

                        byte[] imageBytes = m.ToArray();

                        string base64String = Convert.ToBase64String(imageBytes);

                        await this.ControllerFunction.Connection.SetImageAsync("data:" + mimeType + ";base64," + base64String);
                    }
            }

            public ControllerFunctionButton(ControllerFunction function) : base(function.GetFunction()) {
                this.ControllerFunction = function;
            }
        }

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

        #region Private Members

        private class PluginSettings {
            public static PluginSettings CreateDefaultSettings() {
                PluginSettings instance = new PluginSettings();
                instance.Function = "Button.1";
                return instance;
            }

            [JsonProperty(PropertyName = "Function")]
            public string Function { get; set; }
        }

        private PluginSettings settings;

        ControllerFunctionButton Button { get; set; }

        const int WM_COPYDATA = 0x004A;

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

            Connection.OnApplicationDidLaunch += OnApplicationDidLaunch;

            Connection.OnApplicationDidTerminate += OnApplicationDidTerminate;
        }

        public override void Dispose() {
            Program.UnregisterButton(Button);
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

        private bool switched = false;

        public void SwitchProfile() {
            if (!switched) {
                switched = true;

                Connection.SwitchProfileAsync("Simulator Controller");
            }
        }

        private void OnApplicationDidTerminate(object sender, BarRaider.SdTools.Wrappers.SDEventReceivedEventArgs<BarRaider.SdTools.Events.ApplicationDidTerminate> e) {
            switched = false;

            Button.SetTitle("");
            Button.SetImage("clear");
        }

        private void OnApplicationDidLaunch(object sender, BarRaider.SdTools.Wrappers.SDEventReceivedEventArgs<BarRaider.SdTools.Events.ApplicationDidLaunch> e) {
            SwitchProfile();
        }

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
        private Task SaveSettings()
        {
            return Connection.SetSettingsAsync(JObject.FromObject(settings));
        }

        #endregion
    }
}
