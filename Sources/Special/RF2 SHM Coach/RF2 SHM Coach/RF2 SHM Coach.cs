/*
RF2 SHM Coach main class.

Small parts original by: The Iron Wolf (vleonavicius@hotmail.com; thecrewchief.org)
*/
using RF2SHMCoach.rFactor2Data;
using System;
using System.Collections.Generic;
using System.Diagnostics.Eventing.Reader;
using System.Drawing;
using System.Drawing.Imaging;
using System.IO;
using System.Reflection;
using System.Runtime.InteropServices;
using System.Runtime.InteropServices.ComTypes;
using System.Text;
using System.Threading;
using System.Windows.Forms;
using static RF2SHMCoach.rFactor2Constants;
using static RF2SHMCoach.rFactor2Constants.rF2GamePhase;
using static RF2SHMCoach.rFactor2Constants.rF2PitState;
using static System.Net.WebRequestMethods;
using static System.Windows.Forms.VisualStyles.VisualStyleElement.TextBox;

namespace RF2SHMCoach {
	public class SHMCoach {
		bool connected = false;

		// Read buffers:
		MappedBuffer<rF2Scoring> scoringBuffer = new MappedBuffer<rF2Scoring>(rFactor2Constants.MM_SCORING_FILE_NAME, true /*partial*/, true /*skipUnchanged*/);
        MappedBuffer<rF2Extended> extendedBuffer = new MappedBuffer<rF2Extended>(rFactor2Constants.MM_EXTENDED_FILE_NAME, false /*partial*/, true /*skipUnchanged*/);
        MappedBuffer<rF2Telemetry> telemetryBuffer = new MappedBuffer<rF2Telemetry>(rFactor2Constants.MM_TELEMETRY_FILE_NAME, true /*partial*/, true /*skipUnchanged*/);

        // Marshalled views:
        rF2Scoring scoring;
        rF2Extended extended;
        rF2Telemetry telemetry;

        public SHMCoach() {
			if (!this.connected)
				this.Connect();
		}

		private static string GetStringFromBytes(byte[] bytes) {
			if (bytes == null)
				return "";

			var nullIdx = Array.IndexOf(bytes, (byte)0);

			return nullIdx >= 0 ? Encoding.Default.GetString(bytes, 0, nullIdx) : Encoding.Default.GetString(bytes);
		}

		static rF2VehicleTelemetry noTelemetry = new rF2VehicleTelemetry();

        public static ref rF2VehicleTelemetry GetPlayerTelemetry(int id, ref rF2Telemetry telemetry) {
			for (int i = 0; i < telemetry.mNumVehicles; ++i) {
				if (telemetry.mVehicles[i].mID == id)
					return ref telemetry.mVehicles[i];
			}

			return ref noTelemetry;
		}

		private void Connect() {
			if (!this.connected) {
				try {
					// Extended buffer is the last one constructed, so it is an indicator RF2SM is ready.
					this.extendedBuffer.Connect();
                    this.scoringBuffer.Connect();
                    this.telemetryBuffer.Connect();

                    this.connected = true;
				}
				catch (Exception) {
					this.Disconnect();
				}
			}
		}

		private void Disconnect() {
			this.extendedBuffer.Disconnect();
            this.scoringBuffer.Disconnect();
            this.telemetryBuffer.Disconnect();

            this.connected = false;
        }

        static rF2VehicleScoring noPlayer = new rF2VehicleScoring();

        public static ref rF2VehicleScoring GetPlayerScoring(ref rF2Scoring scoring)
        {
            for (int i = 0; i < scoring.mScoringInfo.mNumVehicles; ++i)
            {
                if (scoring.mVehicles[i].mIsPlayer == 1)
                    return ref scoring.mVehicles[i];
            }

            return ref noPlayer;
        }

        const int WM_COPYDATA = 0x004A;

		public struct COPYDATASTRUCT
		{
			public IntPtr dwData;
			public int cbData;
			[MarshalAs(UnmanagedType.LPStr)]
			public string lpData;
		}

		[DllImport("user32.dll")]
		public static extern int FindWindowEx(int hwndParent, int hwndChildAfter, string lpszClass, string lpszWindow);

		[DllImport("user32.dll")]
		public static extern int SendMessage(int hWnd, int uMsg, int wParam, ref COPYDATASTRUCT lParam);

		public int SendStringMessage(int hWnd, int wParam, string msg)
		{
			int result = 0;

			if (hWnd > 0)
			{
				byte[] sarr = System.Text.Encoding.Default.GetBytes(msg);
				int len = sarr.Length;
				COPYDATASTRUCT cds;

				cds.dwData = (IntPtr)(256 * 'D' + 'C');
				cds.lpData = msg;
				cds.cbData = len + 1;

				result = SendMessage(hWnd, WM_COPYDATA, wParam, ref cds);
			}

			return result;
		}

        void SendTriggerMessage(string message)
        {
            int winHandle = FindWindowEx(0, 0, null, "Driving Coach.exe");

            if (winHandle == 0)
                winHandle = FindWindowEx(0, 0, null, "Driving Coach.ahk");

            if (winHandle != 0)
                SendStringMessage(winHandle, 0, "Driving Coach:" + message);
        }

		float[] xCoordinates = new float[256];
        float[] yCoordinates = new float[256];
        int numCoordinates = 0;
		long lastUpdate = 0;
		string triggerType = "Trigger";

		void checkCoordinates(ref rF2VehicleScoring playerScoring)
		{
			if (DateTimeOffset.Now.ToUnixTimeMilliseconds() > (lastUpdate + (triggerType == "BrakeHints" ? 200 : 2000)))
			{
				double lVelocityX = playerScoring.mLocalVel.x;
				double lVelocityY = playerScoring.mLocalVel.y;
				double lVelocityZ = playerScoring.mLocalVel.z;

				int carID = 0;

				for (int i = 0; i < scoring.mScoringInfo.mNumVehicles; ++i)
					if (scoring.mVehicles[i].mIsPlayer != 0)
					{
						carID = i;

						break;
					}

				var ori = playerScoring.mOri;

				double velocityX = ori[RowX].x * lVelocityX + ori[RowX].y * lVelocityY + ori[RowX].z * lVelocityZ;
				double velocityY = ori[RowY].x * lVelocityX + ori[RowY].y * lVelocityY + ori[RowY].z * lVelocityZ;
				double velocityZ = (ori[RowZ].x * lVelocityX + ori[RowZ].y * lVelocityY + ori[RowZ].z * lVelocityZ) * -1;

				if ((velocityX != 0) || (velocityY != 0) || (velocityZ != 0))
				{
					double coordinateX = playerScoring.mPos.x;
					double coordinateY = (- playerScoring.mPos.z);

					for (int i = 0; i < numCoordinates; i += 1)
					{
						if (Math.Abs(xCoordinates[i] - coordinateX) < 20 && Math.Abs(yCoordinates[i] - coordinateY) < 20)
						{
							if (triggerType == "Trigger")
								SendTriggerMessage("positionTrigger:" + (i + 1) + ";" + xCoordinates[i] + ";" + yCoordinates[i]);
							else if (triggerType == "BrakeHints")
								if (audioDevice != "")
									SendTriggerMessage("acousticFeedback:" + hintSounds[i]);
								else
									new System.Media.SoundPlayer(hintSounds[i]).Play();

                            lastUpdate = DateTimeOffset.Now.ToUnixTimeMilliseconds();

							break;
						}
					}
				}
			}
        }

        string[] hintSounds = new string[256];
		DateTime lastHintsUpdate = DateTime.Now;

		public void loadBrakeHints()
		{
			if ((hintFile != "") && System.IO.File.Exists(hintFile))
			{
				if (hintSounds.Length == 0 || (System.IO.File.GetLastWriteTime(hintFile) > lastHintsUpdate))
				{
                    var linesRead = System.IO.File.ReadLines(hintFile);

                    numCoordinates = 0;

                    foreach (var line in linesRead)
                    {
						var parts = line.Split(new char[] { ' ' }, 3);

                        xCoordinates[numCoordinates] = float.Parse(parts[0]);
                        yCoordinates[numCoordinates] = float.Parse(parts[1]);
                        hintSounds[numCoordinates] = parts[2];

                        if (++numCoordinates > 255)
							break;
                    }
                }
			} 
		}

        public void initializeTrigger(string type, string[] args)
        {
			triggerType = type;

			for (int i = 1; i < (args.Length - 1); i += 2)
			{
				xCoordinates[numCoordinates] = float.Parse(args[i]);
				yCoordinates[numCoordinates] = float.Parse(args[i + 1]);

                if (++numCoordinates > 59)
                    break;
            }
        }

		string audioDevice = string.Empty;
		string hintFile = string.Empty;

        public void initializeBrakeHints(string type, string[] args)
        {
            triggerType = type;

            hintFile = args[1];
            
			if (args.Length > 2)
				audioDevice = args[2];
        }

        public void Run(bool positionTrigger, bool brakeHints) {
            while (true) {
				if (!connected)
					Connect();

				if (connected)
				{
					try
					{
						if (!extendedBuffer.GetMappedData(ref extended) || !scoringBuffer.GetMappedData(ref scoring)
																	    || !telemetryBuffer.GetMappedData(ref telemetry))
							continue;
                    }
					catch (Exception)
					{
						this.Disconnect();
					}

					if (connected) {
						ref rF2VehicleScoring playerScoring = ref GetPlayerScoring(ref scoring);

						if (positionTrigger)
						{
							checkCoordinates(ref playerScoring);

							Thread.Sleep(10);
						}
						else if (brakeHints)
						{
							loadBrakeHints();

                            checkCoordinates(ref playerScoring);

                            Thread.Sleep(10);
                        }
					}
					else
						Thread.Sleep(1000);
				}
				else
					Thread.Sleep(1000);
            }
		}
    }
}
