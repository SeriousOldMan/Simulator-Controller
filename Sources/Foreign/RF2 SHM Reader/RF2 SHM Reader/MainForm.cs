/*
rF2SMMonitor is visual debugger for rF2 Shared Memory Plugin.

MainForm implementation, contains main loop and render calls.

Author: The Iron Wolf (vleonavicius@hotmail.com)
Website: thecrewchief.org
*/
using rF2SMMonitor.rFactor2Data;
using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Drawing;
using System.Runtime.InteropServices;
using System.Text;
using System.Threading;
using System.Windows.Forms;
using static rF2SMMonitor.rFactor2Constants;

namespace rF2SMMonitor
{
  public partial class MainForm : Form
  {
    // Connection fields
    private const int CONNECTION_RETRY_INTERVAL_MS = 1000;
    private const int DISCONNECTED_CHECK_INTERVAL_MS = 15000;
    private const float DEGREES_IN_RADIAN = 57.2957795f;
    private const int LIGHT_MODE_REFRESH_MS = 500;

    public static bool useStockCarRulesPlugin = false;

    System.Windows.Forms.Timer connectTimer = new System.Windows.Forms.Timer();
    System.Windows.Forms.Timer disconnectTimer = new System.Windows.Forms.Timer();
    bool connected = false;

    // Read buffers:
    MappedBuffer<rF2Telemetry> telemetryBuffer = new MappedBuffer<rF2Telemetry>(rFactor2Constants.MM_TELEMETRY_FILE_NAME, true /*partial*/, true /*skipUnchanged*/);
    MappedBuffer<rF2Scoring> scoringBuffer = new MappedBuffer<rF2Scoring>(rFactor2Constants.MM_SCORING_FILE_NAME, true /*partial*/, true /*skipUnchanged*/);
    MappedBuffer<rF2Rules> rulesBuffer = new MappedBuffer<rF2Rules>(rFactor2Constants.MM_RULES_FILE_NAME, true /*partial*/, true /*skipUnchanged*/);
    MappedBuffer<rF2ForceFeedback> forceFeedbackBuffer = new MappedBuffer<rF2ForceFeedback>(rFactor2Constants.MM_FORCE_FEEDBACK_FILE_NAME, false /*partial*/, false /*skipUnchanged*/);
    MappedBuffer<rF2Graphics> graphicsBuffer = new MappedBuffer<rF2Graphics>(rFactor2Constants.MM_GRAPHICS_FILE_NAME, false /*partial*/, false /*skipUnchanged*/);
    MappedBuffer<rF2PitInfo> pitInfoBuffer = new MappedBuffer<rF2PitInfo>(rFactor2Constants.MM_PITINFO_FILE_NAME, false /*partial*/, true /*skipUnchanged*/);
    MappedBuffer<rF2Weather> weatherBuffer = new MappedBuffer<rF2Weather>(rFactor2Constants.MM_WEATHER_FILE_NAME, false /*partial*/, true /*skipUnchanged*/);
    MappedBuffer<rF2Extended> extendedBuffer = new MappedBuffer<rF2Extended>(rFactor2Constants.MM_EXTENDED_FILE_NAME, false /*partial*/, true /*skipUnchanged*/);

    // Write buffers:
    MappedBuffer<rF2HWControl> hwControlBuffer = new MappedBuffer<rF2HWControl>(rFactor2Constants.MM_HWCONTROL_FILE_NAME);
    MappedBuffer<rF2WeatherControl> weatherControlBuffer = new MappedBuffer<rF2WeatherControl>(rFactor2Constants.MM_WEATHER_CONTROL_FILE_NAME);
    MappedBuffer<rF2RulesControl> rulesControlBuffer = new MappedBuffer<rF2RulesControl>(rFactor2Constants.MM_RULES_CONTROL_FILE_NAME);
    MappedBuffer<rF2PluginControl> pluginControlBuffer = new MappedBuffer<rF2PluginControl>(rFactor2Constants.MM_PLUGIN_CONTROL_FILE_NAME);

    // Marshalled views:
    rF2Telemetry telemetry;
    rF2Scoring scoring;
    rF2Rules rules;
    rF2ForceFeedback forceFeedback;
    rF2Graphics graphics;
    rF2PitInfo pitInfo;
    rF2Weather weather;
    rF2Extended extended;

    // Marashalled output views:
    rF2HWControl hwControl;
    rF2WeatherControl weatherControl;
    rF2RulesControl rulesControl;
    rF2PluginControl pluginControl;

    // Track rF2 transitions.
    TransitionTracker tracker = new TransitionTracker();

    // Config
    IniFile config = new IniFile();
    float scale = 2.0f;
    float xOffset = 0.0f;
    float yOffset = 0.0f;
    int focusVehicle = 0;
    bool centerOnVehicle = true;
    bool rotateAroundVehicle = true;
    bool logPhaseAndState = true;
    bool logDamage = true;
    bool logTiming = true;
    bool logRules = true;
    bool logLightMode = false;
    bool enablePitInputs = false;

    // Capture of the max FFB force.
    double maxFFBValue = 0.0;

    // Last applied value for the rain intensity.
    double rainIntensityRequested = 0.0;

    [StructLayout(LayoutKind.Sequential)]
    public struct NativeMessage
    {
      public IntPtr Handle;
      public uint Message;
      public IntPtr WParameter;
      public IntPtr LParameter;
      public uint Time;
      public Point Location;
    }

    [DllImport("user32.dll")]
    public static extern int PeekMessage(out NativeMessage message, IntPtr window, uint filterMin, uint filterMax, uint remove);

    public MainForm()
    {
      this.InitializeComponent();

      this.DoubleBuffered = true;
      this.StartPosition = FormStartPosition.Manual;
      this.Location = new Point(0, 0);

      this.EnableControls(false);
      this.scaleTextBox.KeyDown += this.TextBox_KeyDown;
      this.scaleTextBox.LostFocus += this.ScaleTextBox_LostFocus;
      this.xOffsetTextBox.KeyDown += this.TextBox_KeyDown;
      this.xOffsetTextBox.LostFocus += this.XOffsetTextBox_LostFocus;
      this.yOffsetTextBox.KeyDown += this.TextBox_KeyDown;
      this.yOffsetTextBox.LostFocus += this.YOffsetTextBox_LostFocus;
      this.focusVehTextBox.KeyDown += this.TextBox_KeyDown;
      this.focusVehTextBox.LostFocus += this.FocusVehTextBox_LostFocus;
      this.setAsOriginCheckBox.CheckedChanged += this.SetAsOriginCheckBox_CheckedChanged;
      this.rotateAroundCheckBox.CheckedChanged += this.RotateAroundCheckBox_CheckedChanged;
      this.logPhaseAndStateCheckBox.CheckedChanged += this.CheckBoxLogPhaseAndState_CheckedChanged;
      this.logDamageCheckBox.CheckedChanged += this.CheckBoxLogDamage_CheckedChanged;
      this.logTimingCheckBox.CheckedChanged += this.CheckBoxLogTiming_CheckedChanged;
      this.logRulesCheckBox.CheckedChanged += this.CheckBoxLogRules_CheckedChanged;
      this.lightModeCheckBox.CheckedChanged += this.CheckBoxLightMode_CheckedChanged;
      this.enablePitInputsCheckBox.CheckedChanged += this.CheckBoxEnablePitInputs_CheckedChanged;
      this.MouseWheel += this.MainForm_MouseWheel;

      this.rainIntensityTextBox.LostFocus += this.RainIntensityTextBox_LostFocus;
      this.rainIntensityTextBox.Text = "0.0";
      this.applyRainIntensityButton.Click += this.ApplyRainIntensityButton_Click;

      this.LoadConfig();
      this.connectTimer.Interval = MainForm.CONNECTION_RETRY_INTERVAL_MS;
      this.connectTimer.Tick += this.ConnectTimer_Tick;
      this.disconnectTimer.Interval = MainForm.DISCONNECTED_CHECK_INTERVAL_MS;
      this.disconnectTimer.Tick += this.DisconnectTimer_Tick;
      this.connectTimer.Start();
      this.disconnectTimer.Start();

      this.view.BorderStyle = BorderStyle.Fixed3D;
      this.view.Paint += this.View_Paint;
      this.MouseClick += this.MainForm_MouseClick;
      this.view.MouseClick += this.MainForm_MouseClick;

      Application.Idle += this.HandleApplicationIdle;
    }

    private void ApplyRainIntensityButton_Click(object sender, EventArgs e)
    {
      if (!this.connected
        || this.extended.mWeatherControlInputEnabled == 0)
        return;

      this.weatherControl.mVersionUpdateBegin = this.weatherControl.mVersionUpdateEnd = this.weatherControl.mVersionUpdateBegin + 1;

      // First, copy current state into control buffer.
      // This is not a deep copy. Values in weather buffer wwill change.  If that is not desired, deep copy needs to be performed.
      this.weatherControl.mWeatherInfo = this.weather.mWeatherInfo;

      this.weatherControl.mWeatherInfo.mET += 5.0;  // Apply in 5 seconds.
      // Apply requested rain intensity.
      this.weatherControl.mWeatherInfo.mRaining[4] = this.rainIntensityRequested;

      this.weatherControlBuffer.PutMappedData(ref this.weatherControl);
      this.applyRainIntensityButton.Enabled = false;
    }

    private void CheckBoxEnablePitInputs_CheckedChanged(object sender, EventArgs e)
    {
      this.enablePitInputs = this.enablePitInputsCheckBox.Checked;
      this.config.Write("enablePitInputs", this.enablePitInputs ? "1" : "0");
    }

    [DllImport("user32.dll")]
    static extern short GetAsyncKeyState(System.Windows.Forms.Keys vKey);

    private DateTime nextKeyHandlingTime = DateTime.MinValue;
    private void ProcessKeys()
    {
      if (!this.connected 
        || !this.enablePitInputs
        || this.extended.mHWControlInputEnabled == 0)
        return;

      var now = DateTime.Now;
      if (now < this.nextKeyHandlingTime)
        return;

      this.nextKeyHandlingTime = now + TimeSpan.FromMilliseconds(100);

      byte[] commandStr = null;
      var fRetVal = 1.0;

      if (MainForm.GetAsyncKeyState(Keys.U) != 0)
        commandStr = Encoding.Default.GetBytes("PitMenuIncrementValue");
      else if (MainForm.GetAsyncKeyState(Keys.Y) != 0)
        commandStr = Encoding.Default.GetBytes("PitMenuDecrementValue");
      else if (MainForm.GetAsyncKeyState(Keys.P) != 0)
        commandStr = Encoding.Default.GetBytes("PitMenuUp");
      else if (MainForm.GetAsyncKeyState(Keys.O) != 0)
        commandStr = Encoding.Default.GetBytes("PitMenuDown");
      // rough sample for rule input buffer.
      /*else if (MainForm.GetAsyncKeyState(Keys.T) != 0)
      {
        if (this.extended.mRulesControlInputEnabled == 0)
          return;

        this.rulesControl.mVersionUpdateBegin = this.rulesControl.mVersionUpdateEnd = this.rulesControl.mVersionUpdateBegin + 1;

        // First, copy current state into control buffer.
        // This is not a deep copy. Values in rules buffer wwill change.  If that is not desired, deep copy needs to be performed.
        this.rulesControl.mTrackRules = this.rules.mTrackRules;
        this.rulesControl.mActions = this.rules.mActions;
        this.rulesControl.mParticipants = this.rules.mParticipants;

        this.rulesControl.mTrackRules.mMessage = new byte[96];
        var msg = Encoding.Default.GetBytes("Hello!");  // should be visible in LSI during FCY?
        for (int i = 0; i < msg.Length; ++i)
          this.rulesControl.mTrackRules.mMessage[i] = msg[i];

        this.rulesControlBuffer.PutMappedData(ref this.rulesControl);
      }*/

      this.SendPitMenuCmd(commandStr, fRetVal);
    }

    private void SendPitMenuCmd(byte[] commandStr, double fRetVal)
    {
      if (commandStr != null)
      {
        this.hwControl.mVersionUpdateBegin = this.hwControl.mVersionUpdateEnd = this.hwControl.mVersionUpdateBegin + 1;

        this.hwControl.mControlName = new byte[rFactor2Constants.MAX_HWCONTROL_NAME_LEN];
        for (int i = 0; i < commandStr.Length; ++i)
          this.hwControl.mControlName[i] = commandStr[i];

        this.hwControl.mfRetVal = fRetVal;

        this.hwControlBuffer.PutMappedData(ref this.hwControl);
      }
    }
    private void CheckBoxLogRules_CheckedChanged(object sender, EventArgs e)
    {
      this.logRules = this.logRulesCheckBox.Checked;
      this.config.Write("logRules", this.logRules ? "1" : "0");
    }

    private void CheckBoxLightMode_CheckedChanged(object sender, EventArgs e)
    {
      this.logLightMode = this.lightModeCheckBox.Checked;

      // Disable/enable rendering options
      this.globalGroupBox.Enabled = !this.logLightMode;
      this.groupBoxFocus.Enabled = !this.logLightMode;

      this.config.Write("logLightMode", this.logLightMode ? "1" : "0");
    }

    private void CheckBoxLogDamage_CheckedChanged(object sender, EventArgs e)
    {
      this.logDamage = this.logDamageCheckBox.Checked;
      this.config.Write("logDamage", this.logDamage ? "1" : "0");
    }

    private void CheckBoxLogTiming_CheckedChanged(object sender, EventArgs e)
    {
      this.logTiming = this.logTimingCheckBox.Checked;
      this.config.Write("logTiming", this.logTiming ? "1" : "0");
    }

    private void CheckBoxLogPhaseAndState_CheckedChanged(object sender, EventArgs e)
    {
      this.logPhaseAndState = this.logPhaseAndStateCheckBox.Checked;
      this.config.Write("logPhaseAndState", this.logPhaseAndState ? "1" : "0");
    }

    private void MainForm_MouseClick(object sender, MouseEventArgs e)
    {
      if (e.Button == MouseButtons.Right)
      {
        this.delayAccMicroseconds = 0;
        this.numDelayUpdates = 0;

        this.telemetryBuffer.ClearStats();
        this.scoringBuffer.ClearStats();
        this.extendedBuffer.ClearStats();
        this.rulesBuffer.ClearStats();

        // No stats for FFB buffer (single value buffer).

        this.maxFFBValue = 0.0;
      }
    }

    private void RainIntensityTextBox_LostFocus(object sender, EventArgs e)
    {
      var result = 0.0;
      if (double.TryParse(this.rainIntensityTextBox.Text, out result)
        && result >= 0.0 && result <= 1.0)
      {
        if (this.rainIntensityRequested != result)
          this.applyRainIntensityButton.Enabled = true;

        this.rainIntensityRequested = result;
      }

      this.rainIntensityTextBox.Text = this.rainIntensityRequested.ToString("0.0");
    }

    private void YOffsetTextBox_LostFocus(object sender, EventArgs e)
    {
      float result = 0.0f;
      if (float.TryParse(this.yOffsetTextBox.Text, out result))
      {
        this.yOffset = result;
        this.config.Write("yOffset", this.yOffset.ToString());
      }
      else
        this.yOffsetTextBox.Text = this.yOffset.ToString();
    }

    private void XOffsetTextBox_LostFocus(object sender, EventArgs e)
    {
      float result = 0.0f;
      if (float.TryParse(this.xOffsetTextBox.Text, out result))
      {
        this.xOffset = result;
        this.config.Write("xOffset", this.xOffset.ToString());
      }
      else
        this.xOffsetTextBox.Text = this.xOffset.ToString();

    }

    private void MainForm_MouseWheel(object sender, MouseEventArgs e)
    {
      float step = 0.5f;
      if (this.scale < 5.0f)
        step = 0.25f;
      else if (this.scale < 2.0f)
        step = 0.1f;
      else if (this.scale < 1.0f)
        step = 0.05f;

      if (e.Delta > 0)
        this.scale += step;
      else if (e.Delta < 0)
        this.scale -= step;

      if (this.scale <= 0.0f)
        this.scale = 0.05f;

      this.config.Write("scale", this.scale.ToString());
      this.scaleTextBox.Text = this.scale.ToString();
    }

    private void RotateAroundCheckBox_CheckedChanged(object sender, EventArgs e)
    {
      this.rotateAroundVehicle = this.rotateAroundCheckBox.Checked;
      this.config.Write("rotateAroundVehicle", this.rotateAroundVehicle ? "1" : "0");
    }

    private void SetAsOriginCheckBox_CheckedChanged(object sender, EventArgs e)
    {
      this.centerOnVehicle = this.setAsOriginCheckBox.Checked;
      this.rotateAroundCheckBox.Enabled = this.setAsOriginCheckBox.Checked;
      this.config.Write("centerOnVehicle", this.centerOnVehicle ? "1" : "0");
    }

    private void FocusVehTextBox_LostFocus(object sender, EventArgs e)
    {
      int result = 0;
      if (int.TryParse(this.focusVehTextBox.Text, out result) && result >= 0)
      {
        this.focusVehicle = result;
        this.config.Write("focusVehicle", this.focusVehicle.ToString());
      }
      else
        this.focusVehTextBox.Text = this.focusVehTextBox.ToString();
    }

    private void ScaleTextBox_LostFocus(object sender, EventArgs e)
    {
      float result = 0.0f;
      if (float.TryParse(this.scaleTextBox.Text, out result))
      {
        this.scale = Math.Max(result, 0.05f);
        this.config.Write("scale", this.scale.ToString());
      }
      else
        this.scaleTextBox.Text = this.scale.ToString();
    }

    private void TextBox_KeyDown(object sender, KeyEventArgs e)
    {
      if (e.KeyCode == Keys.Enter)
        this.view.Focus();
    }
    protected override void Dispose(bool disposing)
    {
      if (disposing && (components != null))
        components.Dispose();

      if (disposing)
        Disconnect();

      base.Dispose(disposing);
    }

    // Amazing loop implementation by Josh Petrie from:
    // http://gamedev.stackexchange.com/questions/67651/what-is-the-standard-c-windows-forms-game-loop
    bool IsApplicationIdle()
    {
      NativeMessage result;
      return PeekMessage(out result, IntPtr.Zero, (uint)0, (uint)0, (uint)0) == 0;
    }

    void HandleApplicationIdle(object sender, EventArgs e)
    {
      while (this.IsApplicationIdle())
      {
        try
        {
          this.MainUpdate();

          if (base.WindowState == FormWindowState.Minimized)
          {
            // being lazy lazy lazy.
            this.tracker.TrackPhase(ref this.scoring, ref this.telemetry, ref this.extended, null, this.logPhaseAndState);
            this.tracker.TrackDamage(ref this.scoring, ref this.telemetry, ref this.extended, null, this.logDamage);
            this.tracker.TrackTimings(ref this.scoring, ref this.telemetry, ref this.rules, ref this.extended, null, this.logTiming);
            this.tracker.TrackRules(ref this.scoring, ref this.telemetry, ref this.rules, ref this.extended, null, this.logRules);
          }
          else
          {
            this.MainRender();
          }

          this.ProcessKeys();

          if (this.logLightMode)
            Thread.Sleep(LIGHT_MODE_REFRESH_MS);
        }
        catch (Exception)
        {
          this.Disconnect();
        }
      }
    }

    long delayAccMicroseconds = 0;
    long numDelayUpdates = 0;
    float avgDelayMicroseconds = 0.0f;
    void MainUpdate()
    {
      if (!this.connected)
        return;

      try
      {
        var watch = System.Diagnostics.Stopwatch.StartNew();

        extendedBuffer.GetMappedData(ref extended);
        scoringBuffer.GetMappedData(ref scoring);
        telemetryBuffer.GetMappedData(ref telemetry);
        rulesBuffer.GetMappedData(ref rules);
        forceFeedbackBuffer.GetMappedDataUnsynchronized(ref forceFeedback);
        graphicsBuffer.GetMappedDataUnsynchronized(ref graphics);
        pitInfoBuffer.GetMappedData(ref pitInfo);
        weatherBuffer.GetMappedData(ref weather);

        watch.Stop();
        var microseconds = watch.ElapsedTicks * 1000000 / System.Diagnostics.Stopwatch.Frequency;
        this.delayAccMicroseconds += microseconds;
        ++this.numDelayUpdates;

        if (this.numDelayUpdates == 0)
        {
          this.numDelayUpdates = 1;
          this.delayAccMicroseconds = microseconds;
        }

        this.avgDelayMicroseconds = (float)this.delayAccMicroseconds / this.numDelayUpdates;
      }
      catch (Exception)
      {
        this.Disconnect();
      }
    }

    void MainRender()
    {
      this.view.Refresh();
    }

    int framesAvg = 20;
    int frame = 0;
    int fps = 0;
    Stopwatch fpsStopWatch = new Stopwatch();
    private void UpdateFPS()
    {
      if (this.frame > this.framesAvg)
      {
        this.fpsStopWatch.Stop();
        var tsSinceLastRender = this.fpsStopWatch.Elapsed;
        this.fps = tsSinceLastRender.Milliseconds > 0 ? (1000 * this.framesAvg) / tsSinceLastRender.Milliseconds : 0;
        this.fpsStopWatch.Restart();
        this.frame = 0;
      }
      else
        ++this.frame;
    }

    private static string GetStringFromBytes(byte[] bytes)
    {
      if (bytes == null)
        return "";

      var nullIdx = Array.IndexOf(bytes, (byte)0);

      return nullIdx >= 0
        ? Encoding.Default.GetString(bytes, 0, nullIdx)
        : Encoding.Default.GetString(bytes);
    }

    // Corrdinate conversion:
    // rF2 +x = screen +x
    // rF2 +z = screen -z
    // rF2 +yaw = screen -yaw
    // If I don't flip z, the projection will look from below.
    void View_Paint(object sender, PaintEventArgs e)
    {
      var g = e.Graphics;

      this.tracker.TrackPhase(ref this.scoring, ref this.telemetry, ref this.extended, g, this.logPhaseAndState);
      this.tracker.TrackDamage(ref this.scoring, ref this.telemetry, ref this.extended, g, this.logDamage);
      this.tracker.TrackTimings(ref this.scoring, ref this.telemetry, ref this.rules, ref this.extended, g, this.logTiming);
      this.tracker.TrackRules(ref this.scoring, ref this.telemetry, ref this.rules, ref this.extended, g, this.logRules);

      this.UpdateFPS();

      if (!this.connected)
      {
        var brush = new SolidBrush(System.Drawing.Color.Black);
        g.DrawString("Not connected.", SystemFonts.DefaultFont, brush, 3.0f, 3.0f);

        if (this.logLightMode)
          return;
      }
      else
      {
        var brush = new SolidBrush(System.Drawing.Color.Green);

        var currX = 3.0f;
        var currY = 3.0f;
        float yStep = SystemFonts.DefaultFont.Height;
        var gameStateText = new StringBuilder();

        // Capture FFB stats:
        this.maxFFBValue = Math.Max(Math.Abs(this.forceFeedback.mForceValue), this.maxFFBValue);

        gameStateText.Append(
          $"Plugin Version:    Expected: 3.7.14.2 64bit   Actual: {MainForm.GetStringFromBytes(this.extended.mVersion)}"
          + $"{(this.extended.is64bit == 1 ? " 64bit" : " 32bit")}"
          + $"{(this.extended.mSCRPluginEnabled == 1 ? "    SCR Plugin enabled" : "")}"
          + $"{(this.extended.mDirectMemoryAccessEnabled == 1 ? "    DMA enabled" : "")}"
          + $"{(this.extended.mHWControlInputEnabled == 1 ? "    HWCI enabled" : "")}"
          + $"{(this.extended.mWeatherControlInputEnabled == 1 ? "    WCI enabled" : "")}"
          + $"{(this.extended.mRulesControlInputEnabled == 1 ? "    RCI enabled" : "")}"
          + $"{(this.extended.mPluginControlInputEnabled == 1 ? "    PCI enabled" : "")}"
          + $"    UBM: {this.extended.mUnsubscribedBuffersMask}"
          + $"    FPS: {this.fps}"
          + $"    FFB Curr: {this.forceFeedback.mForceValue:N3} Max: {this.maxFFBValue:N3}");

        // Draw header
        g.DrawString(gameStateText.ToString(), SystemFonts.DefaultFont, brush, currX, currY);

        gameStateText.Clear();

        // Build map of mID -> telemetry.mVehicles[i].
        // They are typically matching values, however, we need to handle online cases and dropped vehicles (mID can be reused).
        var idsToTelIndices = new Dictionary<long, int>();
        for (int i = 0; i < this.telemetry.mNumVehicles; ++i)
        {
          if (!idsToTelIndices.ContainsKey(this.telemetry.mVehicles[i].mID))
            idsToTelIndices.Add(this.telemetry.mVehicles[i].mID, i);
        }

        var playerVehScoring = GetPlayerScoring(ref this.scoring);

        var scoringPlrId = playerVehScoring.mID;
        var playerVeh = new rF2VehicleTelemetry();
        int resolvedPlayerIdx = -1;  // We're fine here with unitialized vehicle telemetry..
        if (idsToTelIndices.ContainsKey(scoringPlrId))
        {
          resolvedPlayerIdx = idsToTelIndices[scoringPlrId];
          playerVeh = this.telemetry.mVehicles[resolvedPlayerIdx];
        }

        // Figure out prev session end player mID
        var playerSessionEndInfo = new rF2VehScoringCapture();
        for (int i = 0; i < this.extended.mSessionTransitionCapture.mNumScoringVehicles; ++i)
        {
          var veh = this.extended.mSessionTransitionCapture.mScoringVehicles[i];
          if (veh.mIsPlayer == 1)
            playerSessionEndInfo = veh;
        }

        gameStateText.Append(
          "mElapsedTime:\n"
          + "mCurrentET:\n"
          + "mElapsedTime-mCurrentET:\n"
          + "mDetlaTime:\n"
          + "mInvulnerable:\n"
          + "mVehicleName:\n"
          + "mTrackName:\n"
          + "mLapStartET:\n"
          + "mLapDist:\n"
          + "mEndET:\n"
          + "mPlayerName:\n"
          + "mPlrFileName:\n\n"
          + "Session Started:\n"
          + "Sess. End Session:\n"
          + "Sess. End Phase:\n"
          + "Sess. End Place:\n"
          + "Sess. End Finish:\n"
          + "Display msg capture:\n"
          );

        // Col 1 labels
        g.DrawString(gameStateText.ToString(), SystemFonts.DefaultFont, brush, currX, currY += yStep);

        gameStateText.Clear();

        gameStateText.Append(
                $"{playerVeh.mElapsedTime:N3}\n"
                + $"{this.scoring.mScoringInfo.mCurrentET:N3}\n"
                + $"{(playerVeh.mElapsedTime - this.scoring.mScoringInfo.mCurrentET):N3}\n"
                + $"{playerVeh.mDeltaTime:N3}\n"
                + (this.extended.mPhysics.mInvulnerable == 0 ? "off" : "on") + "\n"
                + $"{MainForm.GetStringFromBytes(playerVeh.mVehicleName)}\n"
                + $"{MainForm.GetStringFromBytes(playerVeh.mTrackName)}\n"
                + $"{playerVeh.mLapStartET:N3}\n"
                + $"{this.scoring.mScoringInfo.mLapDist:N3}\n"
                + (this.scoring.mScoringInfo.mEndET < 0.0 ? "Unknown" : this.scoring.mScoringInfo.mEndET.ToString("N3")) + "\n"
                + $"{MainForm.GetStringFromBytes(this.scoring.mScoringInfo.mPlayerName)}\n"
                + $"{MainForm.GetStringFromBytes(this.scoring.mScoringInfo.mPlrFileName)}\n\n"
                + $"{this.extended.mSessionStarted != 0}\n"
                + $"{TransitionTracker.GetSessionString(this.extended.mSessionTransitionCapture.mSession)}\n"
                + $"{(rFactor2Constants.rF2GamePhase)this.extended.mSessionTransitionCapture.mGamePhase}\n"
                + $"{playerSessionEndInfo.mPlace}\n"
                + $"{(rFactor2Constants.rF2FinishStatus)playerSessionEndInfo.mFinishStatus}\n"
                + $"{MainForm.GetStringFromBytes(this.extended.mDisplayedMessageUpdateCapture)}\n"
                );

        // Col1 values
        g.DrawString(gameStateText.ToString(), SystemFonts.DefaultFont, Brushes.Purple, currX + 145, currY);

        // Print buffer stats.
        gameStateText.Clear();
        gameStateText.Append(
          "Telemetry:\n"
          + "Scoring:\n"
          + "Rules:\n"
          + "Extended:\n"
          + "Pit Info:\n"
          + "Weather:\n"
          + "Avg read:");

        g.DrawString(gameStateText.ToString(), SystemFonts.DefaultFont, Brushes.Black, 1500, 570);

        gameStateText.Clear();
        gameStateText.Append(
          this.telemetryBuffer.GetStats() + '\n'
          + this.scoringBuffer.GetStats() + '\n'
          + this.rulesBuffer.GetStats() + '\n'
          + this.pitInfoBuffer.GetStats() + '\n'
          + this.weatherBuffer.GetStats() + '\n'
          + this.extendedBuffer.GetStats() + '\n'
          + this.avgDelayMicroseconds.ToString("0.000") + " microseconds");

        g.DrawString(gameStateText.ToString(), SystemFonts.DefaultFont, Brushes.Black, 1560, 570);

        if (this.extended.mDirectMemoryAccessEnabled == 1)
        {
          gameStateText.Clear();
          gameStateText.Append(
            "Status:\n"
            + "Last MC msg:\n"
            + "Pit Speed Limit:\n"
            + "Last LSI Phase:\n"
            + "Last LSI Pit:\n"
            + "Last LSI Order:\n"
            + "Last SCR Instr.:\n"
            );

          g.DrawString(gameStateText.ToString(), SystemFonts.DefaultFont, Brushes.Purple, 1500, 660);

          gameStateText.Clear();
          gameStateText.Append(
            MainForm.GetStringFromBytes(this.extended.mStatusMessage) + '\n'
            + MainForm.GetStringFromBytes(this.extended.mLastHistoryMessage) + '\n'
            + (int)(this.extended.mCurrentPitSpeedLimit * 3.6f + 0.5f) + "kph\n"
            + MainForm.GetStringFromBytes(this.extended.mLSIPhaseMessage) + '\n'
            + MainForm.GetStringFromBytes(this.extended.mLSIPitStateMessage) + '\n'
            + MainForm.GetStringFromBytes(this.extended.mLSIOrderInstructionMessage) + '\n'
            + MainForm.GetStringFromBytes(this.extended.mLSIRulesInstructionMessage) + '\n'
            );

          g.DrawString(gameStateText.ToString(), SystemFonts.DefaultFont, Brushes.Purple, 1580, 660);

          gameStateText.Clear();
          gameStateText.Append(
            "updated: " + this.extended.mTicksStatusMessageUpdated + '\n'
            + "updated: " + this.extended.mTicksLastHistoryMessageUpdated + '\n'
            + '\n'
            + "updated: " + this.extended.mTicksLSIPhaseMessageUpdated + '\n'
            + "updated: " + this.extended.mTicksLSIPitStateMessageUpdated + '\n'
            + "updated: " + this.extended.mTicksLSIOrderInstructionMessageUpdated + '\n'
            + "updated: " + this.extended.mTicksLSIRulesInstructionMessageUpdated + '\n');

          g.DrawString(gameStateText.ToString(), SystemFonts.DefaultFont, Brushes.Purple, 1800, 660);
        }

        if ((this.extended.mUnsubscribedBuffersMask & (long)SubscribedBuffer.PitInfo) == 0)
        {
          // Print pit info:
          gameStateText.Clear();

          gameStateText.Append(
            "PI Cat Index:\n"
            + "PI Cat Name:\n"
            + "PI Choice Index:\n"
            + "PI Choice String:\n"
            + "PI Num Choices:\n"
            );

          g.DrawString(gameStateText.ToString(), SystemFonts.DefaultFont, Brushes.Orange, 1500, 750);

          gameStateText.Clear();
          var catName = MainForm.GetStringFromBytes(this.pitInfo.mPitMneu.mCategoryName);
          var choiceStr = MainForm.GetStringFromBytes(this.pitInfo.mPitMneu.mChoiceString);

          gameStateText.Append(
            this.pitInfo.mPitMneu.mCategoryIndex + "\n"
            + (string.IsNullOrWhiteSpace(catName) ? "<empty>" : catName) + "\n"
            + this.pitInfo.mPitMneu.mChoiceIndex + "\n"
            + (string.IsNullOrWhiteSpace(choiceStr) ? "<empty>" : choiceStr) + "\n"
            + this.pitInfo.mPitMneu.mNumChoices + "\n"
            );

          g.DrawString(gameStateText.ToString(), SystemFonts.DefaultFont, Brushes.Orange, 1600, 750);
        }

        if (this.scoring.mScoringInfo.mNumVehicles == 0
          || resolvedPlayerIdx == -1)  // We need telemetry for stats below.
          return;

        gameStateText.Clear();

        gameStateText.Append(
          "mTimeIntoLap:\n"
          + "mEstimatedLapTime:\n"
          + "mTimeBehindNext:\n"
          + "mTimeBehindLeader:\n"
          + "mPitGroup:\n"
          + "mLapDist(Plr):\n"
          + "mLapDist(Est):\n"
          + "yaw:\n"
          + "pitch:\n"
          + "roll:\n"
          + "speed:\n");

        // Col 2 labels
        g.DrawString(gameStateText.ToString(), SystemFonts.DefaultFont, brush, currX += 275, currY);
        gameStateText.Clear();


        // Calculate derivatives:
        var yaw = Math.Atan2(playerVeh.mOri[RowZ].x, playerVeh.mOri[RowZ].z);

        var pitch = Math.Atan2(-playerVeh.mOri[RowY].z,
          Math.Sqrt(playerVeh.mOri[RowX].z * playerVeh.mOri[RowX].z + playerVeh.mOri[RowZ].z * playerVeh.mOri[RowZ].z));

        var roll = Math.Atan2(playerVeh.mOri[RowY].x,
          Math.Sqrt(playerVeh.mOri[RowX].x * playerVeh.mOri[RowX].x + playerVeh.mOri[RowZ].x * playerVeh.mOri[RowZ].x));

        var speed = Math.Sqrt((playerVeh.mLocalVel.x * playerVeh.mLocalVel.x)
          + (playerVeh.mLocalVel.y * playerVeh.mLocalVel.y)
          + (playerVeh.mLocalVel.z * playerVeh.mLocalVel.z));

        // Estimate lapdist
        // See how much ahead telemetry is ahead of scoring update
        var delta = playerVeh.mElapsedTime - scoring.mScoringInfo.mCurrentET;
        var lapDistEstimated = playerVehScoring.mLapDist;
        if (delta > 0.0)
        {
          var localZAccelEstimated = playerVehScoring.mLocalAccel.z * delta;
          var localZVelEstimated = playerVehScoring.mLocalVel.z + localZAccelEstimated;

          lapDistEstimated = playerVehScoring.mLapDist - localZVelEstimated * delta;
        }

        gameStateText.Append(
          $"{playerVehScoring.mTimeIntoLap:N3}\n"
          + $"{playerVehScoring.mEstimatedLapTime:N3}\n"
          + $"{playerVehScoring.mTimeBehindNext:N3}\n"
          + $"{playerVehScoring.mTimeBehindLeader:N3}\n"
          + $"{MainForm.GetStringFromBytes(playerVehScoring.mPitGroup)}\n"
          + $"{playerVehScoring.mLapDist:N3}\n"
          + $"{lapDistEstimated:N3}\n"
          + $"{yaw:N3}\n"
          + $"{pitch:N3}\n"
          + $"{roll:N3}\n"
          + string.Format("{0:n3} m/s {1:n4} km/h\n", speed, speed * 3.6));

        // Col2 values
        g.DrawString(gameStateText.ToString(), SystemFonts.DefaultFont, Brushes.Purple, currX + 120, currY);

        if (this.logLightMode)
            return;

        // Branch of UI choice: origin center or car# center
        // Fix rotation on car of choice or no.
        // Draw axes
        // Scale will be parameter, scale applied last on render to zoom.
        float scale = this.scale;

        var xVeh = (float)playerVeh.mPos.x;
        var zVeh = (float)playerVeh.mPos.z;
        var yawVeh = yaw;

        // View center
        var xScrOrigin = this.view.Width / 2.0f;
        var yScrOrigin = this.view.Height / 2.0f;
        if (!this.centerOnVehicle)
        {
          // Set world origin.
          g.TranslateTransform(xScrOrigin, yScrOrigin);
          this.RenderOrientationAxis(g);
          g.ScaleTransform(scale, scale);

          RenderCar(g, xVeh, -zVeh, -(float)yawVeh, Brushes.Green);

          for (int i = 0; i < this.telemetry.mNumVehicles; ++i)
          {
            if (i == resolvedPlayerIdx)
              continue;

            var veh = this.telemetry.mVehicles[i];
            var thisYaw = Math.Atan2(veh.mOri[2].x, veh.mOri[2].z);
            this.RenderCar(g,
              (float)veh.mPos.x,
              -(float)veh.mPos.z,
              -(float)thisYaw, Brushes.Red);
          }
        }
        else
        {
          g.TranslateTransform(xScrOrigin, yScrOrigin);

          if (this.rotateAroundVehicle)
            g.RotateTransform(180.0f + (float)yawVeh * DEGREES_IN_RADIAN);

          this.RenderOrientationAxis(g);
          g.ScaleTransform(scale, scale);
          g.TranslateTransform(-xVeh, zVeh);

          RenderCar(g, xVeh, -zVeh, -(float)yawVeh, Brushes.Green);

          for (int i = 0; i < this.telemetry.mNumVehicles; ++i)
          {
            if (i == resolvedPlayerIdx)
              continue;

            var veh = this.telemetry.mVehicles[i];
            var thisYaw = Math.Atan2(veh.mOri[2].x, veh.mOri[2].z);
            this.RenderCar(g,
              (float)veh.mPos.x,
              -(float)veh.mPos.z,
              -(float)thisYaw, Brushes.Red);
          }
        }
      }
    }

    public static rF2VehicleScoring GetPlayerScoring(ref rF2Scoring scoring)
    {
      var playerVehScoring = new rF2VehicleScoring();
      for (int i = 0; i < scoring.mScoringInfo.mNumVehicles; ++i)
      {
        var vehicle = scoring.mVehicles[i];
        switch ((rFactor2Constants.rF2Control)vehicle.mControl)
        {
          case rFactor2Constants.rF2Control.AI:
          case rFactor2Constants.rF2Control.Player:
          case rFactor2Constants.rF2Control.Remote:
            if (vehicle.mIsPlayer == 1)
              playerVehScoring = vehicle;

            break;

          default:
            continue;
        }

        if (playerVehScoring.mIsPlayer == 1)
          break;
      }

      return playerVehScoring;
    }


    // Length
    // 174.6in (4,435mm)
    // 175.6in (4,460mm) (Z06, ZR1)
    // Width
    // 72.6in (1,844mm)
    // 75.9in (1,928mm) (Z06, ZR1)
    /*PointF[] carPoly =
    {
        new PointF(0.922f, 2.217f),
        new PointF(0.922f, -1.4f),
        new PointF(1.3f, -1.4f),
        new PointF(0.0f, -2.217f),
        new PointF(-1.3f, -1.4f),
        new PointF(-0.922f, -1.4f),
        new PointF(-0.922f, 2.217f),
      };*/

    PointF[] carPoly =
    {
      new PointF(-0.922f, -2.217f),
      new PointF(-0.922f, 1.4f),
      new PointF(-1.3f, 1.4f),
      new PointF(0.0f, 2.217f),
      new PointF(1.3f, 1.4f),
      new PointF(0.922f, 1.4f),
      new PointF(0.922f, -2.217f),
    };

    private void RenderCar(Graphics g, float x, float y, float yaw, Brush brush)
    {
      var state = g.Save();

      g.TranslateTransform(x, y);

      g.RotateTransform(yaw * DEGREES_IN_RADIAN);

      g.FillPolygon(brush, this.carPoly);

      g.Restore(state);
    }

    static float arrowSide = 10.0f;
    PointF[] arrowHead =
    {
      new PointF(-arrowSide / 2.0f, -arrowSide / 2.0f),
      new PointF(0.0f, arrowSide / 2.0f),
      new PointF(arrowSide / 2.0f, -arrowSide / 2.0f)
    };

    private void RenderOrientationAxis(Graphics g)
    {

      float length = 1000.0f;
      float arrowDistX = this.view.Width / 2.0f - 10.0f;
      float arrowDistY = this.view.Height / 2.0f - 10.0f;

      // X (x screen) axis
      g.DrawLine(Pens.Red, -length, 0.0f, length, 0.0f);
      var state = g.Save();
      g.TranslateTransform(this.rotateAroundVehicle ? arrowDistY : arrowDistX, 0.0f);
      g.RotateTransform(-90.0f);
      g.FillPolygon(Brushes.Red, this.arrowHead);
      g.RotateTransform(90.0f);
      g.DrawString("x+", SystemFonts.DefaultFont, Brushes.Red, -10.0f, 10.0f);
      g.Restore(state);

      state = g.Save();
      // Z (y screen) axis
      g.DrawLine(Pens.Blue, 0.0f, -length, 0.0f, length);
      g.TranslateTransform(0.0f, -arrowDistY);
      g.RotateTransform(180.0f);
      g.FillPolygon(Brushes.Blue, this.arrowHead);
      g.DrawString("z+", SystemFonts.DefaultFont, Brushes.Blue, 10.0f, -10.0f);

      g.Restore(state);
    }

    private void ConnectTimer_Tick(object sender, EventArgs e)
    {
      if (!this.connected)
      {
        try
        {
          // Extended buffer is the last one constructed, so it is an indicator RF2SM is ready.
          this.extendedBuffer.Connect();

          this.telemetryBuffer.Connect();
          this.scoringBuffer.Connect();
          this.rulesBuffer.Connect();
          this.forceFeedbackBuffer.Connect();
          this.graphicsBuffer.Connect();
          this.pitInfoBuffer.Connect();
          this.weatherBuffer.Connect();

          this.hwControlBuffer.Connect();
          this.hwControlBuffer.GetMappedData(ref this.hwControl);
          this.hwControl.mLayoutVersion = rFactor2Constants.MM_HWCONTROL_LAYOUT_VERSION;

          this.weatherControlBuffer.Connect();
          this.weatherControlBuffer.GetMappedData(ref this.weatherControl);
          this.weatherControl.mLayoutVersion = rFactor2Constants.MM_WEATHER_CONTROL_LAYOUT_VERSION;

          this.rulesControlBuffer.Connect();
          this.rulesControlBuffer.GetMappedData(ref this.rulesControl);
          this.rulesControl.mLayoutVersion = rFactor2Constants.MM_RULES_CONTROL_LAYOUT_VERSION;

          this.pluginControlBuffer.Connect();
          this.pluginControlBuffer.GetMappedData(ref this.pluginControl);
          this.pluginControl.mLayoutVersion = rFactor2Constants.MM_PLUGIN_CONTROL_LAYOUT_VERSION;

          // Scoring cannot be enabled on demand.
          this.pluginControl.mRequestEnableBuffersMask = /*(int)SubscribedBuffer.Scoring | */(int)SubscribedBuffer.Telemetry | (int)SubscribedBuffer.Rules
            | (int)SubscribedBuffer.ForceFeedback | (int)SubscribedBuffer.Graphics | (int)SubscribedBuffer.Weather | (int)SubscribedBuffer.PitInfo;
          this.pluginControl.mRequestHWControlInput = 1;
          this.pluginControl.mRequestRulesControlInput = 1;
          this.pluginControl.mRequestWeatherControlInput = 1;
          this.pluginControl.mVersionUpdateBegin = this.pluginControl.mVersionUpdateEnd = this.pluginControl.mVersionUpdateBegin + 1;
          this.pluginControlBuffer.PutMappedData(ref this.pluginControl);

          this.connected = true;

          this.EnableControls(true);
        }
        catch (Exception)
        {
          this.Disconnect();
        }
      }
    }

    private void DisconnectTimer_Tick(object sender, EventArgs e)
    {
      if (!this.connected)
        return;

      try
      {
        // Alternatively, I could release resources and try re-acquiring them immidiately.
        var processes = Process.GetProcessesByName(rF2SMMonitor.rFactor2Constants.RFACTOR2_PROCESS_NAME);
        if (processes.Length == 0)
          Disconnect();
      }
      catch (Exception)
      {
        Disconnect();
      }
    }

    private void Disconnect()
    {
      this.extendedBuffer.Disconnect();
      this.scoringBuffer.Disconnect();
      this.rulesBuffer.Disconnect();
      this.telemetryBuffer.Disconnect();
      this.forceFeedbackBuffer.Disconnect();
      this.pitInfoBuffer.Disconnect();
      this.weatherBuffer.Disconnect();
      this.graphicsBuffer.Disconnect();

      this.hwControlBuffer.Disconnect();
      this.weatherControlBuffer.Disconnect();
      this.rulesControlBuffer.Disconnect();
      this.pluginControlBuffer.Disconnect();

      this.connected = false;

      this.EnableControls(false);
    }

    void EnableControls(bool enable)
    {
      this.globalGroupBox.Enabled = enable;
      this.groupBoxFocus.Enabled = enable;
      this.loggingGroupBox.Enabled = enable;
      this.inputsGroupBox.Enabled = enable;

      this.focusVehLabel.Enabled = false;
      this.focusVehTextBox.Enabled = false;
      this.xOffsetLabel.Enabled = false;
      this.xOffsetTextBox.Enabled = false;
      this.yOffsetLabel.Enabled = false;
      this.yOffsetTextBox.Enabled = false;

      if (enable)
      {
        this.rotateAroundCheckBox.Enabled = this.setAsOriginCheckBox.Checked;
        this.globalGroupBox.Enabled = !this.logLightMode;
        this.groupBoxFocus.Enabled = !this.logLightMode;
      }
    }

    void LoadConfig()
    {
      float result = 0.0f;
      this.scale = 2.0f;
      if (float.TryParse(this.config.Read("scale"), out result))
        this.scale = result;

      if (this.scale <= 0.0f)
        this.scale = 0.1f;

      this.scaleTextBox.Text = this.scale.ToString();

      result = 0.0f;
      this.xOffset = 0.0f;
      if (float.TryParse(this.config.Read("xOffset"), out result))
        this.xOffset = result;

      this.xOffsetTextBox.Text = this.xOffset.ToString();

      result = 0.0f;
      this.yOffset = 0.0f;
      if (float.TryParse(this.config.Read("yOffset"), out result))
        this.yOffset = result;

      this.yOffsetTextBox.Text = this.yOffset.ToString();

      int intResult = 0;
      this.focusVehicle = 0;
      if (int.TryParse(this.config.Read("focusVehicle"), out intResult) && intResult >= 0)
        this.focusVehicle = intResult;

      this.focusVehTextBox.Text = this.focusVehicle.ToString();

      intResult = 0;
      this.centerOnVehicle = true;
      if (int.TryParse(this.config.Read("centerOnVehicle"), out intResult) && intResult == 0)
        this.centerOnVehicle = false;

      this.setAsOriginCheckBox.Checked = this.centerOnVehicle;

      intResult = 0;
      this.rotateAroundVehicle = true;
      if (int.TryParse(this.config.Read("rotateAroundVehicle"), out intResult) && intResult == 0)
        this.rotateAroundVehicle = false;

      this.rotateAroundCheckBox.Checked = this.rotateAroundVehicle;

      intResult = 0;
      this.logLightMode = false;
      if (int.TryParse(this.config.Read("logLightMode"), out intResult) && intResult == 1)
        this.logLightMode = true;

      this.lightModeCheckBox.Checked = this.logLightMode;

      intResult = 0;
      this.logPhaseAndState = true;
      if (int.TryParse(this.config.Read("logPhaseAndState"), out intResult) && intResult == 0)
        this.logPhaseAndState = false;

      this.logPhaseAndStateCheckBox.Checked = this.logPhaseAndState;

      intResult = 0;
      this.logDamage = true;
      if (int.TryParse(this.config.Read("logDamage"), out intResult) && intResult == 0)
        this.logDamage = false;

      this.logDamageCheckBox.Checked = this.logDamage;

      intResult = 0;
      this.logTiming = true;
      if (int.TryParse(this.config.Read("logTiming"), out intResult) && intResult == 0)
        this.logTiming = false;

      this.logTimingCheckBox.Checked = this.logTiming;

      intResult = 0;
      this.logRules = true;
      if (int.TryParse(this.config.Read("logRules"), out intResult) && intResult == 0)
        this.logRules = false;

      this.logRulesCheckBox.Checked = this.logRules;

      intResult = 0;
      this.enablePitInputs = true;
      if (int.TryParse(this.config.Read("enablePitInputs"), out intResult) && intResult == 0)
        this.enablePitInputs = false;

      this.enablePitInputsCheckBox.Checked = this.enablePitInputs;

      MainForm.useStockCarRulesPlugin = false;
    }
  }
}
