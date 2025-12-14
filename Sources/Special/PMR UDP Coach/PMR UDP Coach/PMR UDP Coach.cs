using PMRUDPSpotter;
using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Diagnostics.Eventing.Reader;
using System.Drawing;
using System.Drawing.Imaging;
using System.IO;
using System.Reflection;
using System.Runtime.InteropServices;
using System.Runtime.InteropServices.ComTypes;
using System.Text;
using System.Threading;

namespace PMRUDPCoach {
	public class UDPCoach
    {
        private PMRUDPReceiver receiver;

        bool connected = false;

        string multiCastGroup;
        int multiCastPort;
        bool useMultiCast;

        public UDPCoach(string multiCastGroup = "224.0.0.150", int multiCastPort = 7576, bool useMultiCast = true) {
            this.multiCastGroup = multiCastGroup;
            this.multiCastPort = multiCastPort;
            this.useMultiCast = useMultiCast;

            if (!this.connected)
				this.Connect();
		}

		private void Connect() {
			if (!this.connected) {
				try {
                    if (receiver != null)
                        receiver.Stop();

                    receiver = new PMRUDPReceiver(multiCastPort, multiCastGroup, useMultiCast);

                    bool started = receiver.Start();

                    if (started)
                    {
                        started = false;

                        for (int i = 0; i <= 3 && !started; i++)
                            if (receiver.HasReceivedData())
                                started = true;
                            else
                                Thread.Sleep(200);
                    }

                    if (!started)
                        receiver = null;
                    else
                        this.connected = true;
                }
				catch (Exception) {
					this.Disconnect();
				}
			}
		}

		private void Disconnect() {
            receiver?.Stop();
            receiver = null;

            this.connected = false;
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

        void SendAnalyzerMessage(string message)
        {
            int winHandle = FindWindowEx(0, 0, null, "Setup Workbench.exe");

            if (winHandle == 0)
                winHandle = FindWindowEx(0, 0, null, "Setup Workbench.ahk");

            if (winHandle != 0)
                SendStringMessage(winHandle, 0, "Analyzer:" + message);
        }

		double vectorLength(double x, double y)
		{
			return Math.Sqrt((x * x) + (y * y));
		}

		void playSound(string wavFile, bool wait = true) {
            try
            {
                ProcessStartInfo startInfo = new ProcessStartInfo
                {
                    FileName = player,
					WorkingDirectory = workingDirectory,
                    Arguments = $"\"{wavFile}\" -t waveaudio \"{audioDevice}\" vol {volume}",
                    UseShellExecute = false,
                    RedirectStandardOutput = false,
                    RedirectStandardError = false,
                    CreateNoWindow = true
                };

                using (Process process = new Process())
                {
                    process.StartInfo = startInfo;

                    process.Start();

					if (wait)
						process.WaitForExit();
                }
            }
            catch (Exception ex)
            {
				return;
            }
        }

		class CornerDynamics
        {
            public double Speed;
            public double Usos;
            public int CompletedLaps;
            public int Phase;

            public CornerDynamics(double speed, double usos, int completedLaps, int phase)
            {
                Speed = speed;
                Usos = usos;
                CompletedLaps = completedLaps;
                Phase = phase;
            }
        }

        double vehicleSpeed(ref UDPVehicleTelemetry telemetry)
        {
            var chassis = telemetry.Chassis;

            return Math.Sqrt(chassis.VelocityLS[0] * chassis.VelocityLS[0] +
                             chassis.VelocityLS[1] * chassis.VelocityLS[1] +
                             chassis.VelocityLS[2] * chassis.VelocityLS[2]) * 3.6;
        }

        const int MAXVALUES = 6;
		const double PI = 3.14159265;

        List<float> recentSteerAngles = new List<float>();
        List<float> recentGLongs = new List<float>();
        List<float> recentIdealAngVels = new List<float>();
        List<float> recentRealAngVels = new List<float>();

        void pushValue(List<float> values, float value)
        {
            values.Add(value);

            if ((int)values.Count > MAXVALUES)
                values.RemoveAt(0);
        }

        float averageValue(List<float> values, ref int num)
        {
            float sum = 0.0f;

            foreach (float value in values)
                sum += value;

            num = values.Count;

            return (num > 0) ? sum / num : 0.0f;
        }

        float smoothValue(List<float> values, float value)
        {
            int ignore = 0;

			if (false) {
				pushValue(values, value);

				return averageValue(values, ref ignore);
			}
			else
				return value;
        }

        List<CornerDynamics> cornerDynamicsList = new List<CornerDynamics>();

        string dataFile = "";
        int understeerLightThreshold = 12;
        int understeerMediumThreshold = 20;
        int understeerHeavyThreshold = 35;
        int oversteerLightThreshold = 2;
        int oversteerMediumThreshold = -6;
        int oversteerHeavyThreshold = -10;
        int lowspeedThreshold = 100;
        int steerLock = 900;
        int steerRatio = 14;
        int wheelbase = 270;
        int trackWidth = 150;

        int lastCompletedLaps = 0;
        float lastSpeed = 0.0f;
		
		bool calibrate = false;
        long lastSound = 0;

		bool triggerUSOSBeep(string soundsDirectory, string audioDevice, double usos)
		{
			string wavFile;

			if (usos < oversteerHeavyThreshold)
				wavFile = soundsDirectory + "\\Oversteer Heavy.wav";
			else if (usos < oversteerMediumThreshold)
				wavFile = soundsDirectory + "\\Oversteer Medium.wav";
			else if (usos < oversteerLightThreshold)
				wavFile = soundsDirectory + "\\Oversteer Light.wav";
			else if (usos > understeerHeavyThreshold)
				wavFile = soundsDirectory + "\\Understeer Heavy.wav";
			else if (usos > understeerMediumThreshold)
				wavFile = soundsDirectory + "\\Understeer Medium.wav";
			else if (usos > understeerLightThreshold)
				wavFile = soundsDirectory + "\\Understeer Light.wav";
			else
				return false;

			if (wavFile != "")
				if (audioDevice != "")
				{
					if (player != "")
						playSound(wavFile, false);
					else
						SendAnalyzerMessage("acousticFeedback:" + wavFile);
				}
				else
				{
					if (lastPlayer != null) {
						lastPlayer.Stop();

						lastPlayer.Dispose();
					}

                    lastPlayer = new System.Media.SoundPlayer(wavFile);

                    lastPlayer.Play();
                }
			
            return true;
		}

		bool collectTelemetry(ref UDPParticipantRaceState playerVehicle,
                              ref UDPVehicleTelemetry playerTelemetry,
                              string soundsDirectory, string audioDevice)
        {
            if (playerVehicle.InPits || playerVehicle.InPitLane)
                return true;

			float steerAngle = smoothValue(recentSteerAngles, playerTelemetry.Input.Steering);

            float speed = (float)vehicleSpeed(ref playerTelemetry);
            float acceleration = (float)speed - lastSpeed;

			lastSpeed = speed;

            pushValue(recentGLongs, acceleration);

            double angularVelocity = smoothValue(recentRealAngVels, playerTelemetry.Chassis.AngularVelocityLS[2]);
            double steeredAngleDegs = steerAngle * steerLock / 2.0f / steerRatio;
            double steerAngleRadians = -steeredAngleDegs / 57.2958;
            double wheelBaseMeter = (float)wheelbase / 100;
            double radius = wheelBaseMeter / steerAngleRadians;
            double perimeter = radius * PI * 2;
            double perimeterSpeed = lastSpeed / 3.6;
            double idealAngularVelocity = smoothValue(recentIdealAngVels, (float)(perimeterSpeed / perimeter * 2 * PI));
            
			if (Math.Abs(steerAngle) > 0.1 && lastSpeed > 60)
			{
                // Get the average recent GLong
                int numGLong = 0;
                float glongAverage = averageValue(recentGLongs, ref numGLong);

                int phase = 0;
                if (numGLong > 0)
                    if (glongAverage < -0.2)
                    {
                        // Braking
                        phase = -1;
                    }
                    else if (glongAverage > 0.1)
                    {
                        // Accelerating
                        phase = 1;
                    }

                CornerDynamics cd = new CornerDynamics(speed, 0, Math.Max(0, playerVehicle.CurrentLap - 1), phase);

				if (Math.Abs(angularVelocity * 57.2958) > 0.1)
				{
					double slip = Math.Abs(idealAngularVelocity - angularVelocity);

					if (steerAngle > 0) {
						if (angularVelocity > 0)
                        {
							/*
							if (calibrate)
								slip *= -1;
							else
								slip = (oversteerHeavyThreshold - 1) / 57.2989;
							*/

							slip *= -1;
                        }
                        else if (angularVelocity < idealAngularVelocity)
							slip *= -1;
					}
					else {
						if (angularVelocity < 0)
                        {
							/*
							if (calibrate)
								slip *= -1;
                            else
								slip = (oversteerHeavyThreshold - 1) / 57.2989;
							*/
							
							slip *= -1;
                        }
                        else if (angularVelocity > idealAngularVelocity)
							slip *= -1;
					}

					if (slip != 0)
					{
						cd.Usos = slip * 57.2989 * 1;

						if ((soundsDirectory != "") && Environment.TickCount > (lastSound + 300))
							if (triggerUSOSBeep(soundsDirectory, audioDevice, cd.Usos))
								lastSound = Environment.TickCount;

						if (false)
						{
							StreamWriter output = new StreamWriter(dataFile + ".trace", true);

							output.Write(steerAngle + "  ");
							output.Write(steeredAngleDegs + "  ");
							output.Write(steerAngleRadians + "  ");
							output.Write(lastSpeed + "  ");
							output.Write(idealAngularVelocity + "  ");
							output.Write(angularVelocity + "  ");
							output.Write(slip + "  ");
							output.WriteLine(cd.Usos);

							output.Close();

							Thread.Sleep(200);
						}
					}
                    else
						cd = null;
                }

				if (cd != null)
					cornerDynamicsList.Add(cd);

				int completedLaps = Math.Max(0, playerVehicle.CurrentLap - 1);

				if (lastCompletedLaps != completedLaps) {
					lastCompletedLaps = completedLaps;
					
					while (true)
						if (cornerDynamicsList[0].CompletedLaps < completedLaps - 1)
							cornerDynamicsList.RemoveAt(0);
						else
							break;
				}
			}

            return true;
        }

        void writeTelemetry()
        {
            StreamWriter output = new StreamWriter(dataFile + ".tmp", false);

            try
            {
                int[] slowLightUSNum = { 0, 0, 0 };
                int[] slowMediumUSNum = { 0, 0, 0 };
                int[] slowHeavyUSNum = { 0, 0, 0 };
                int[] slowLightOSNum = { 0, 0, 0 };
                int[] slowMediumOSNum = { 0, 0, 0 };
                int[] slowHeavyOSNum = { 0, 0, 0 };
                int slowTotalNum = 0;
                int[] fastLightUSNum = { 0, 0, 0 };
                int[] fastMediumUSNum = { 0, 0, 0 };
                int[] fastHeavyUSNum = { 0, 0, 0 };
                int[] fastLightOSNum = { 0, 0, 0 };
                int[] fastMediumOSNum = { 0, 0, 0 };
                int[] fastHeavyOSNum = { 0, 0, 0 };
                int fastTotalNum = 0;
		
				int[] slowOSMin = { 0, 0, 0 };
				int[] fastOSMin = { 0, 0, 0 };
				int[] slowUSMax = { 0, 0, 0 };
				int[] fastUSMax = { 0, 0, 0 };

                foreach (CornerDynamics corner in cornerDynamicsList)
                {
                    int phase = corner.Phase + 1;

                    if (calibrate) {
						if (corner.Speed < lowspeedThreshold) {
							slowOSMin[phase] = Math.Min(slowOSMin[phase], (int)corner.Usos);
							slowUSMax[phase] = Math.Max(slowUSMax[phase], (int)corner.Usos);
						}
						else {
							fastOSMin[phase] = Math.Min(fastOSMin[phase], (int)corner.Usos);
							fastUSMax[phase] = Math.Max(fastUSMax[phase], (int)corner.Usos);
						}
					}
					else {
						if (corner.Speed < lowspeedThreshold)
						{
							slowTotalNum++;
							if (corner.Usos < oversteerHeavyThreshold)
							{
								slowHeavyOSNum[phase]++;
							}
							else if (corner.Usos < oversteerMediumThreshold)
							{
								slowMediumOSNum[phase]++;
							}
							else if (corner.Usos < oversteerLightThreshold)
							{
								slowLightOSNum[phase]++;
							}
							else if (corner.Usos > understeerHeavyThreshold)
							{
								slowHeavyUSNum[phase]++;
							}
							else if (corner.Usos > understeerMediumThreshold)
							{
								slowMediumUSNum[phase]++;
							}
							else if (corner.Usos > understeerLightThreshold)
							{
								slowLightUSNum[phase]++;
							}
						}
						else
						{
							fastTotalNum++;
							if (corner.Usos < oversteerHeavyThreshold)
							{
								fastHeavyOSNum[phase]++;
							}
							else if (corner.Usos < oversteerMediumThreshold)
							{
								fastMediumOSNum[phase]++;
							}
							else if (corner.Usos < oversteerLightThreshold)
							{
								fastLightOSNum[phase]++;
							}
							else if (corner.Usos > understeerHeavyThreshold)
							{
								fastHeavyUSNum[phase]++;
							}
							else if (corner.Usos > understeerMediumThreshold)
							{
								fastMediumUSNum[phase]++;
							}
							else if (corner.Usos > understeerLightThreshold)
							{
								fastLightUSNum[phase]++;
							}
						}
					}
                }

                if (calibrate) {
					output.WriteLine("[Understeer.Slow]");

					output.WriteLine("Entry=" + slowUSMax[0]);
					output.WriteLine("Apex=" + slowUSMax[1]);
					output.WriteLine("Exit=" + slowUSMax[2]);
					
					output.WriteLine("[Understeer.Fast]");

					output.WriteLine("Entry=" + fastUSMax[0]);
					output.WriteLine("Apex=" + fastUSMax[1]);
					output.WriteLine("Exit=" + fastUSMax[2]);
					
					output.WriteLine("[Oversteer.Slow]");

					output.WriteLine("Entry=" + slowOSMin[0]);
					output.WriteLine("Apex=" + slowOSMin[1]);
					output.WriteLine("Exit=" + slowOSMin[2]);
					
					output.WriteLine("[Oversteer.Fast]");

					output.WriteLine("Entry=" + fastOSMin[0]);
					output.WriteLine("Apex=" + fastOSMin[1]);
					output.WriteLine("Exit=" + fastOSMin[2]);
				}
				else {
					output.WriteLine("[Understeer.Slow.Light]");

					if (slowTotalNum > 0)
					{
						output.WriteLine("Entry=" + (int)(100.0f * slowLightUSNum[0] / slowTotalNum));
						output.WriteLine("Apex=" + (int)(100.0f * slowLightUSNum[1] / slowTotalNum));
						output.WriteLine("Exit=" + (int)(100.0f * slowLightUSNum[2] / slowTotalNum));
					}

					output.WriteLine("[Understeer.Slow.Medium]");

					if (slowTotalNum > 0)
					{
						output.WriteLine("Entry=" + (int)(100.0f * slowMediumUSNum[0] / slowTotalNum));
						output.WriteLine("Apex=" + (int)(100.0f * slowMediumUSNum[1] / slowTotalNum));
						output.WriteLine("Exit=" + (int)(100.0f * slowMediumUSNum[2] / slowTotalNum));
					}

					output.WriteLine("[Understeer.Slow.Heavy]");

					if (slowTotalNum > 0)
					{
						output.WriteLine("Entry=" + (int)(100.0f * slowHeavyUSNum[0] / slowTotalNum));
						output.WriteLine("Apex=" + (int)(100.0f * slowHeavyUSNum[1] / slowTotalNum));
						output.WriteLine("Exit=" + (int)(100.0f * slowHeavyUSNum[2] / slowTotalNum));
					}

					output.WriteLine("[Understeer.Fast.Light]");

					if (fastTotalNum > 0)
					{
						output.WriteLine("Entry=" + (int)(100.0f * fastLightUSNum[0] / fastTotalNum));
						output.WriteLine("Apex=" + (int)(100.0f * fastLightUSNum[1] / fastTotalNum));
						output.WriteLine("Exit=" + (int)(100.0f * fastLightUSNum[2] / fastTotalNum));
					}

					output.WriteLine("[Understeer.Fast.Medium]");

					if (fastTotalNum > 0)
					{
						output.WriteLine("Entry=" + (int)(100.0f * fastMediumUSNum[0] / fastTotalNum));
						output.WriteLine("Apex=" + (int)(100.0f * fastMediumUSNum[1] / fastTotalNum));
						output.WriteLine("Exit=" + (int)(100.0f * fastMediumUSNum[2] / fastTotalNum));
					}

					output.WriteLine("[Understeer.Fast.Heavy]");

					if (fastTotalNum > 0)
					{
						output.WriteLine("Entry=" + (int)(100.0f * fastHeavyUSNum[0] / fastTotalNum));
						output.WriteLine("Apex=" + (int)(100.0f * fastHeavyUSNum[1] / fastTotalNum));
						output.WriteLine("Exit=" + (int)(100.0f * fastHeavyUSNum[2] / fastTotalNum));
					}

					output.WriteLine("[Oversteer.Slow.Light]");

					if (slowTotalNum > 0)
					{
						output.WriteLine("Entry=" + (int)(100.0f * slowLightOSNum[0] / slowTotalNum));
						output.WriteLine("Apex=" + (int)(100.0f * slowLightOSNum[1] / slowTotalNum));
						output.WriteLine("Exit=" + (int)(100.0f * slowLightOSNum[2] / slowTotalNum));
					}

					output.WriteLine("[Oversteer.Slow.Medium]");

					if (slowTotalNum > 0)
					{
						output.WriteLine("Entry=" + (int)(100.0f * slowMediumOSNum[0] / slowTotalNum));
						output.WriteLine("Apex=" + (int)(100.0f * slowMediumOSNum[1] / slowTotalNum));
						output.WriteLine("Exit=" + (int)(100.0f * slowMediumOSNum[2] / slowTotalNum));
					}

					output.WriteLine("[Oversteer.Slow.Heavy]");

					if (slowTotalNum > 0)
					{
						output.WriteLine("Entry=" + (int)(100.0f * slowHeavyOSNum[0] / slowTotalNum));
						output.WriteLine("Apex=" + (int)(100.0f * slowHeavyOSNum[1] / slowTotalNum));
						output.WriteLine("Exit=" + (int)(100.0f * slowHeavyOSNum[2] / slowTotalNum));
					}

					output.WriteLine("[Oversteer.Fast.Light]");

					if (fastTotalNum > 0)
					{
						output.WriteLine("Entry=" + (int)(100.0f * fastLightOSNum[0] / fastTotalNum));
						output.WriteLine("Apex=" + (int)(100.0f * fastLightOSNum[1] / fastTotalNum));
						output.WriteLine("Exit=" + (int)(100.0f * fastLightOSNum[2] / fastTotalNum));
					}

					output.WriteLine("[Oversteer.Fast.Medium]");

					if (fastTotalNum > 0)
					{
						output.WriteLine("Entry=" + (int)(100.0f * fastMediumOSNum[0] / fastTotalNum));
						output.WriteLine("Apex=" + (int)(100.0f * fastMediumOSNum[1] / fastTotalNum));
						output.WriteLine("Exit=" + (int)(100.0f * fastMediumOSNum[2] / fastTotalNum));
					}

					output.WriteLine("[Oversteer.Fast.Heavy]");

					if (fastTotalNum > 0)
					{
						output.WriteLine("Entry=" + (int)(100.0f * fastHeavyOSNum[0] / fastTotalNum));
						output.WriteLine("Apex=" + (int)(100.0f * fastHeavyOSNum[1] / fastTotalNum));
						output.WriteLine("Exit=" + (int)(100.0f * fastHeavyOSNum[2] / fastTotalNum));
					}
				}

                output.Close();

                FileInfo info = new FileInfo(dataFile);

                info.Delete();

                info = new FileInfo(dataFile + ".tmp");

                info.MoveTo(dataFile);
            }
            catch (Exception)
            {
                try
                {
                    output.Close();
                }
                catch (Exception)
                {
                }

                // retry next round...
            }
        }

        const int Start = 0;
        const int Intro = 1;
        const int Ready = 2;
        const int Set = 3;
        const int Brake = 4;
        const int Release = 5;

        int[] tIndices = new int[256];
        float[] xCoordinates = new float[256];
        float[] yCoordinates = new float[256];
        int numCoordinates = 0;
		long nextUpdate = 0;
		string triggerType = "Trigger";
		int lastLap = 0;
		int lastHint = -1;
		int lastGroup = 0;
		int lastPhase = Start;

		System.Media.SoundPlayer lastPlayer = null;

        void checkCoordinates(ref UDPParticipantRaceState playerVehicle,
							  ref UDPVehicleTelemetry playerTelemetry)
		{
            if (DateTimeOffset.Now.ToUnixTimeMilliseconds() > nextUpdate)
            {
                double velocityX = playerTelemetry.Chassis.VelocityLS[0];
				double velocityY = playerTelemetry.Chassis.VelocityLS[1];
                double velocityZ = playerTelemetry.Chassis.VelocityLS[2];

				if ((velocityX != 0) || (velocityY != 0) || (velocityZ != 0))
				{
					double coordinateX = playerTelemetry.Chassis.PosWS[0];
					double coordinateY = playerTelemetry.Chassis.PosWS[2];

                    if (triggerType == "Trigger") {
						for (int i = 0; i < numCoordinates; i += 1)
						{
							if (Math.Abs(xCoordinates[i] - coordinateX) < 20 && Math.Abs(yCoordinates[i] - coordinateY) < 20)
							{
								SendTriggerMessage("positionTrigger:" + tIndices[i] + ";" + xCoordinates[i] + ";" + yCoordinates[i]);

								nextUpdate = DateTimeOffset.Now.ToUnixTimeMilliseconds() + 2000;

								break;
							}
						}
					}
					else {
						if (lastLap != Math.Max(0, playerVehicle.CurrentLap - 1))
						{
							lastLap = Math.Max(0, playerVehicle.CurrentLap - 1);

							lastHint = -1;
						}

						int bestHint = -1;
						float bestDistance = 99999;

						for (int i = lastHint + 1; i < numCoordinates; i += 1)
						{
							float curDistance = (float)vectorLength(xCoordinates[i] - coordinateX, yCoordinates[i] - coordinateY);

							if ((curDistance < hintDistances[i]) && (curDistance < bestDistance))
							{
								bestHint = i;
								bestDistance = curDistance;
							}
						}

						if ((bestHint > lastHint) && ((lastPhase != Start) || (hintPhases[bestHint] == Intro))) {
							if ((lastGroup != hintGroups[bestHint]) && (hintPhases[bestHint] != Intro))
								return;
							else if ((hintPhases[bestHint] <= lastPhase) && (hintPhases[bestHint] != Intro))
								return;

							lastHint = bestHint;
							lastGroup = hintGroups[bestHint];
							lastPhase = hintPhases[bestHint];

							if (audioDevice != "")
							{
								if (player != "")
									playSound(hintSounds[bestHint], false);
								else
									SendTriggerMessage("acousticFeedback:" + hintSounds[bestHint]);
							}
							else
							{
								if (lastPlayer != null)
								{
									lastPlayer.Stop();

									lastPlayer.Dispose();
								}

								lastPlayer = new System.Media.SoundPlayer(hintSounds[bestHint]);

								lastPlayer.Play();
							}
						}
					}
				}
			}
        }

        int[] hintGroups = new int[256];
        int[] hintPhases = new int[256];
        float[] hintDistances = new float[256];
        string[] hintSounds = new string[256];
        DateTime lastHintsUpdate = DateTime.Now;

        public void loadTrackHints()
		{
			if ((hintFile != "") && System.IO.File.Exists(hintFile))
			{
				if (numCoordinates == 0 || (System.IO.File.GetLastWriteTime(hintFile) > lastHintsUpdate))
				{
                    numCoordinates = 0;
                    lastHintsUpdate = System.IO.File.GetLastWriteTime(hintFile);

                    foreach (var line in System.IO.File.ReadAllLines(hintFile))
                    {
						var parts = line.Split(new char[] { ' ' }, 6);

                        hintGroups[numCoordinates] = int.Parse(parts[0]);
                        switch (parts[1].ToLower())
                        {
                            case "intro":
                                hintPhases[numCoordinates] = Intro;

								break;
                            case "ready":
                                hintPhases[numCoordinates] = Ready;

								break;
                            case "set":
                                hintPhases[numCoordinates] = Set;

								break;
                            case "brake":
                                hintPhases[numCoordinates] = Brake;

                                break;
                            case "release":
                                hintPhases[numCoordinates] = Release;

                                break;
                        }
                        xCoordinates[numCoordinates] = float.Parse(parts[2]);
                        yCoordinates[numCoordinates] = float.Parse(parts[3]);
                        hintDistances[numCoordinates] = float.Parse(parts[4]);
                        hintSounds[numCoordinates] = parts[5];

                        if (++numCoordinates > 255)
							break;
                    }

					lastHint = -1;
					lastGroup = 0;
					lastPhase = Start;
                }
			} 
		}

        public void initializeTrigger(string type, string[] args, int index)
        {
			triggerType = type;

			for (int i = index; i < (args.Length - 1); i += 3)
			{
				tIndices[numCoordinates] = int.Parse(args[i]);
				xCoordinates[numCoordinates] = float.Parse(args[i + 1]);
				yCoordinates[numCoordinates] = float.Parse(args[i + 2]);

                if (++numCoordinates > 255)
                    break;
            }

            Thread.Sleep(10000);
        }

		string soundsDirectory = string.Empty;
		string audioDevice = string.Empty;
        string player = string.Empty;
        string workingDirectory = string.Empty;
        float volume = 0;
		string hintFile = string.Empty;

        public void initializeTrackHints(string type, string[] args, int index)
        {
            triggerType = type;

            hintFile = args[index++];

            if (args.Length > index)
                audioDevice = args[index++];

            if (args.Length > index)
                volume = float.Parse(args[index++]);

            if (args.Length > index)
                player = args[index++];

            if (args.Length > index)
                workingDirectory = args[index++];

            Thread.Sleep(10000);
        }

        public void initializeAnalyzer(bool calibrateTelemetry, string[] args, int index)
        {
            dataFile = args[index++];
			
			calibrate = calibrateTelemetry;
			
			if (calibrate) {
				lowspeedThreshold = int.Parse(args[index++]);
				steerLock = int.Parse(args[index++]);
				steerRatio = int.Parse(args[index++]);
				wheelbase = int.Parse(args[index++]);
				trackWidth = int.Parse(args[index++]);
			}
			else {
				understeerLightThreshold = int.Parse(args[index++]);
				understeerMediumThreshold = int.Parse(args[index++]);
				understeerHeavyThreshold = int.Parse(args[index++]);
				oversteerLightThreshold = int.Parse(args[index++]);
				oversteerMediumThreshold = int.Parse(args[index++]);
				oversteerHeavyThreshold = int.Parse(args[index++]);
				lowspeedThreshold = int.Parse(args[index++]);
				steerLock = int.Parse(args[index++]);
				steerRatio = int.Parse(args[index++]);
				wheelbase = int.Parse(args[index++]);
				trackWidth = int.Parse(args[index++]);

                if (args.Length > index) {
                    soundsDirectory = args[index++];

                    if (args.Length > index)
                        audioDevice = args[index++];

                    if (args.Length > index)
                        volume = float.Parse(args[index++]);

                    if (args.Length > index)
                        player = args[index++];

                    if (args.Length > index)
                        workingDirectory = args[index++];
                }
            }
        }

        public bool active(ref UDPRaceInfo raceInfo)
        {
            return (raceInfo != null) && (raceInfo.State == UDPRaceSessionState.Active) && receiver.HasReceivedData();
        }

        public void Run(bool positionTrigger, bool trackHints, bool handlingAnalyzer) {
            long counter = 0;
			
			while (true) {
				counter += 1;
				
				if (!connected)
					Connect();

				if (connected)
                {
                    var raceInfo = receiver.GetRaceInfo();
                    var playerVehicle = receiver.GetPlayerState();
                    var playerTelemetry = receiver.GetPlayerTelemetry();

					if (active(ref raceInfo)) {
						if (positionTrigger)
						{
							checkCoordinates(ref playerVehicle, ref playerTelemetry);

							Thread.Sleep(10);
						}
						else if (handlingAnalyzer)
						{
							if (collectTelemetry(ref playerVehicle, ref playerTelemetry,
												 soundsDirectory, audioDevice))
							{
								if (counter % 20 == 0)
									writeTelemetry();

								Thread.Sleep(10);
							}
							else
								break;
						}
						else if (trackHints)
						{
							loadTrackHints();

							checkCoordinates(ref playerVehicle, ref playerTelemetry);

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
