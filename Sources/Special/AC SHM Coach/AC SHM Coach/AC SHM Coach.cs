using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Drawing;
using System.IO;
using System.IO.MemoryMappedFiles;
using System.Linq;
using System.Reflection;
using System.Runtime.InteropServices;
using System.Runtime.Remoting.Lifetime;
using System.Text;
using System.Threading;
using System.Threading.Tasks;
using System.Windows.Forms;
using static System.Windows.Forms.VisualStyles.VisualStyleElement.TextBox;

namespace ACSHMCoach {
	enum AC_MEMORY_STATUS { DISCONNECTED, CONNECTING, CONNECTED }

	public class SHMCoach
	{
		bool connected = false;

		private AC_MEMORY_STATUS memoryStatus = AC_MEMORY_STATUS.DISCONNECTED;
		public bool IsRunning { get { return (memoryStatus == AC_MEMORY_STATUS.CONNECTED); } }

		Physics physics;
		Graphics graphics;
		Cars cars;
		StaticInfo staticInfo;

		public SHMCoach()
		{
			connected = ConnectToSharedMemory();
		}

		string GetSession(AC_SESSION_TYPE session)
		{
			switch (session)
			{
				case AC_SESSION_TYPE.AC_PRACTICE:
					return "Practice";
				case AC_SESSION_TYPE.AC_QUALIFY:
					return "Qualification";
				case AC_SESSION_TYPE.AC_RACE:
					return "Race";
				default:
					return "Other";
			}
		}

		private bool ConnectToSharedMemory()
		{
			try
			{
				memoryStatus = AC_MEMORY_STATUS.CONNECTING;

				// Connect to shared memory
				physicsMMF = MemoryMappedFile.OpenExisting("Local\\acpmf_physics");
				graphicsMMF = MemoryMappedFile.OpenExisting("Local\\acpmf_graphics");
				staticInfoMMF = MemoryMappedFile.OpenExisting("Local\\acpmf_static");
				carsInfoMMF = MemoryMappedFile.OpenExisting("Local\\acpmf_cars");

				physics = ReadPhysics();
				graphics = ReadGraphics();
				staticInfo = ReadStaticInfo();
				cars = ReadCars();

				memoryStatus = AC_MEMORY_STATUS.CONNECTED;

				return true;
			}
			catch (FileNotFoundException)
			{
				return false;
			}
		}

		public void Close()
		{
			memoryStatus = AC_MEMORY_STATUS.DISCONNECTED;
		}

		MemoryMappedFile physicsMMF;
		MemoryMappedFile graphicsMMF;
		MemoryMappedFile staticInfoMMF;
		MemoryMappedFile carsInfoMMF;

		public Physics ReadPhysics()
		{
			using (var stream = physicsMMF.CreateViewStream())
			{
				using (var reader = new BinaryReader(stream))
				{
					var size = Marshal.SizeOf(typeof(Physics));
					var bytes = reader.ReadBytes(size);
					var handle = GCHandle.Alloc(bytes, GCHandleType.Pinned);
					var data = (Physics)Marshal.PtrToStructure(handle.AddrOfPinnedObject(), typeof(Physics));
					handle.Free();
					return data;
				}
			}
		}

		public Graphics ReadGraphics()
		{
			using (var stream = graphicsMMF.CreateViewStream())
			{
				using (var reader = new BinaryReader(stream))
				{
					var size = Marshal.SizeOf(typeof(Graphics));
					var bytes = reader.ReadBytes(size);
					var handle = GCHandle.Alloc(bytes, GCHandleType.Pinned);
					var data = (Graphics)Marshal.PtrToStructure(handle.AddrOfPinnedObject(), typeof(Graphics));
					handle.Free();
					return data;
				}
			}
		}

		public StaticInfo ReadStaticInfo()
		{
			using (var stream = staticInfoMMF.CreateViewStream())
			{
				using (var reader = new BinaryReader(stream))
				{
					var size = Marshal.SizeOf(typeof(StaticInfo));
					var bytes = reader.ReadBytes(size);
					var handle = GCHandle.Alloc(bytes, GCHandleType.Pinned);
					var data = (StaticInfo)Marshal.PtrToStructure(handle.AddrOfPinnedObject(), typeof(StaticInfo));
					handle.Free();
					return data;
				}
			}
        }

        public Cars ReadCars()
        {
            using (var stream = carsInfoMMF.CreateViewStream())
            {
                using (var reader = new BinaryReader(stream))
                {
                    while (true)
                    {
                        var size = Marshal.SizeOf(typeof(Cars));
                        var bytes = reader.ReadBytes(size);
                        var handle = GCHandle.Alloc(bytes, GCHandleType.Pinned);
                        var data = (Cars)Marshal.PtrToStructure(handle.AddrOfPinnedObject(), typeof(Cars));

                        int packetID = data.packetID;

                        if (packetID == -1)
                        {
                            handle.Free();

                            Thread.Sleep(10);

                            continue;
                        }

                        data = (Cars)Marshal.PtrToStructure(handle.AddrOfPinnedObject(), typeof(Cars));

                        handle.Free();

                        if (packetID == data.packetID)
                            return data;
                        else
                            Thread.Sleep(10);
                    }
                }
            }
        }

        private static string GetStringFromBytes(byte[] bytes)
		{
			if (bytes == null)
				return "";

			var nullIdx = Array.IndexOf(bytes, (byte)0);

			return nullIdx >= 0 ? Encoding.Default.GetString(bytes, 0, nullIdx) : Encoding.Default.GetString(bytes);
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

        void playSound(string wavFile, bool wait = true)
        {
            try
            {
                ProcessStartInfo startInfo = new ProcessStartInfo
                {
                    FileName = player,
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

        public class MovingAverage
        {
            private readonly double[] Window;
            private int Head;
            private int Count;
            private double Sum;

            public MovingAverage(int period)
            {
                if (period <= 0)
                    throw new ArgumentException("Period must be greater than zero.", nameof(period));

                Window = new double[period];

                Head = 0;
                Count = 0;
                Sum = 0;
            }

            public double Add(double newValue)
            {
                if (Count == Window.Length)
                    Sum -= Window[Head];

                Window[Head] = newValue;

                Sum += newValue;
                Head = (Head + 1) % Window.Length;

                if (Count < Window.Length)
                    Count++;

                return Sum / Count;
            }
        }

        class SuspensionDeflections
        {
            public readonly int CompletedLaps;
            public readonly long TimeMS;

            public readonly double FrontLeft;
            public readonly double FrontRight;
            public readonly double RearLeft;
            public readonly double RearRight;

            public SuspensionDeflections(int completedLaps, double suspensionDeflectionFL, double suspensionDeflectionFR,
                                                            double suspensionDeflectionRL, double suspensionDeflectionRR)
            {
                TimeMS = Environment.TickCount;

                CompletedLaps = completedLaps;

                FrontLeft = suspensionDeflectionFL * 1000;
                FrontRight = suspensionDeflectionFR * 1000;
                RearLeft = suspensionDeflectionRL * 1000;
                RearRight = suspensionDeflectionRR * 1000;
            }
        }

        class SuspensionBottomOuts
        {
            public int CompletedLaps;

            public string Severity;
            public string Axle;

            /// <summary>
            /// Start time of the event (milliseconds from data start)
            /// </summary>
            public long StartTimeMs { get; set; }

            /// <summary>
            /// End time of the event (milliseconds from data start)
            /// </summary>
            public long EndTimeMs { get; set; }

            /// <summary>
            /// Duration of the event in milliseconds
            /// </summary>
            public long DurationMs => EndTimeMs - StartTimeMs;

            /// <summary>
            /// Peak acceleration during the event
            /// </summary>
            public double PeakAccelerationMagnitude { get; set; }

            /// <summary>
            /// Average acceleration during the event
            /// </summary>
            public double AvgAccelerationMagnitude { get; set; }

            /// <summary>
            /// Impulse (integral of acceleration over time)
            /// </summary>
            public double ImpulseValue { get; set; }

            public SuspensionBottomOuts(int completedLaps, string severity, string axle)
            {
                CompletedLaps = completedLaps;

                Severity = severity;
                Axle = axle;
            }
        }

        class CornerDynamics
		{
			public double Speed;
			public double Usos;
			public int CompletedLaps;
			public int Phase;

			public CornerDynamics(float speed, float usos, int completedLaps, int phase)
			{
				Speed = speed;
				Usos = usos;
				CompletedLaps = completedLaps;
				Phase = phase;
			}
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
        List<SuspensionDeflections> suspensionDeflectionsList = new List<SuspensionDeflections>();

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

        System.Media.SoundPlayer lastPlayer = null;

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
					if (lastPlayer != null)
					{
						lastPlayer.Stop();

						lastPlayer.Dispose();
					}

                    lastPlayer = new System.Media.SoundPlayer(wavFile);

                    lastPlayer.Play();
                }

            return true;
        }

        bool collectTelemetry(string soundsDirectory, string audioDevice)
		{
			if ((graphics.Status != AC_STATUS.AC_LIVE) || graphics.IsInPit != 0 || graphics.IsInPitLane != 0)
				return true;

            int completedLaps = graphics.CompletedLaps;
            float steerAngle = smoothValue(recentSteerAngles, physics.SteerAngle);
            float acceleration = physics.SpeedKmh - lastSpeed;

            if (physics.SpeedKmh > 60)
                suspensionDeflectionsList.Add(new SuspensionDeflections(completedLaps,
                                                                        physics.SuspensionTravel[0],
                                                                        physics.SuspensionTravel[1],
                                                                        physics.SuspensionTravel[2],
                                                                        physics.SuspensionTravel[3]));

            lastSpeed = physics.SpeedKmh;

			pushValue(recentGLongs, acceleration);

            float angularVelocity = smoothValue(recentRealAngVels, physics.LocalAngularVelocity[1]);
            float steeredAngleDegs = steerAngle * steerLock / 2.0f / steerRatio;
            float steerAngleRadians = -steeredAngleDegs / 57.2958f;
            float wheelBaseMeter = wheelbase / 100f;
            float radius = wheelBaseMeter / steerAngleRadians;
            float perimeter = radius * (float)PI * 2;
            float perimeterSpeed = lastSpeed / 3.6f;
            double idealAngularVelocity = smoothValue(recentIdealAngVels, perimeterSpeed / perimeter * 2 * (float)PI);

            if (Math.Abs(steerAngle) > 0.2 && lastSpeed > 60)
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

                CornerDynamics cd = new CornerDynamics(physics.SpeedKmh, 0, graphics.CompletedLaps, phase);

				if (Math.Abs(angularVelocity * 57.2958) > 0.1)
				{
                    double slip = Math.Abs(idealAngularVelocity - angularVelocity);
			
					if (steerAngle > 0) {
						if (angularVelocity > 0)
						{
							if (calibrate)
								slip *= -1;
							else
								slip = (oversteerHeavyThreshold - 1) / 57.2989;
						}
						else if (angularVelocity < idealAngularVelocity)
							slip *= -1;
					}
					else {
						if (angularVelocity < 0)
						{
							if (calibrate)
								slip *= -1;
							else
								slip = (oversteerHeavyThreshold - 1) / 57.2989;
						}
						else if (angularVelocity > idealAngularVelocity)
							slip *= -1;
					}

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

				cornerDynamicsList.Add(cd);

				if (lastCompletedLaps != completedLaps) {
					lastCompletedLaps = completedLaps;
					
					while (true)
						if (cornerDynamicsList[0].CompletedLaps < completedLaps - 2)
							cornerDynamicsList.RemoveAt(0);
						else
							break;

                    while (suspensionDeflectionsList.Count > 0)
                        if (suspensionDeflectionsList[0].CompletedLaps < completedLaps - 1)
                            suspensionDeflectionsList.RemoveAt(0);
                        else
                            break;
                }
			}

			return true;
        }

        delegate double Deflection(SuspensionDeflections deflectsions);

        IEnumerable<SuspensionBottomOuts> createSuspensionIssues()
        {
            List<double> CalculateAccelerations(List<(long TimeMS, double Deflection)> deflections)
            {
                List<double> accelerations = new List<double>();

                double CalculateAcceleration(long lastTime, double lastDeflection,
                                             long time, double deflection,
                                             long nextTime, double nextDeflection)
                {
                    long dt1 = (time - lastTime);
                    long dt2 = (nextTime - time);

                    if (dt1 <= 0 || dt2 <= 0)
                        return 0;

                    double term1 = (nextDeflection - deflection) / dt2;
                    double term2 = (deflection - lastDeflection) / dt1;

                    return 2.0 * (term1 - term2) / ((double)(dt1 + dt2) / 1000.0);
                }

                for (int i = 1; i < deflections.Count - 1; i++)
                    accelerations.Add(CalculateAcceleration(deflections[i - 1].TimeMS,
                                                            deflections[i - 1].Deflection,
                                                            deflections[i].TimeMS,
                                                            deflections[i].Deflection,
                                                            deflections[i + 1].TimeMS,
                                                            deflections[i + 1].Deflection));

                try
                {
                    accelerations.Add(accelerations[accelerations.Count - 1]);
                }
                catch { }

                try
                {
                    accelerations.Insert(0, accelerations[accelerations.Count - 1]);
                }
                catch { }

                return accelerations;
            }

            List<(long TimeMS, double Deflection)> ExtractDeflections(List<SuspensionDeflections> deflections,
                                                                      Deflection Getter)
            {
                List<(long TimeMS, double Deflection)> smoothedDeflections = new List<(long TimeMS, double Deflection)>();
                MovingAverage Deflection = new MovingAverage(5);

                foreach (var deflection in suspensionDeflectionsList)
                    smoothedDeflections.Add((deflection.TimeMS, Deflection.Add(Getter(deflection))));

                return smoothedDeflections;
            }

            List<SuspensionBottomOuts> CreateBottomOuts(string axle, List<double> leftAccelerations,
                                                                     List<double> rightAccelerations)
            {
                const double accelerationThreshold = 5;
                const int minEventDurationMs = 30;
                const int samplingIntervalMs = 20;
                const int minEventGapMs = 100;

                int minSamplesRequired = Math.Max(1, minEventDurationMs / samplingIntervalMs);

                var events = new List<SuspensionBottomOuts>();

                // Use magnitude (absolute value) of acceleration for detection
                var combinedAccel = new double[leftAccelerations.Count];
                var leftAboveThreshold = new bool[leftAccelerations.Count];
                var rightAboveThreshold = new bool[rightAccelerations.Count];

                string GetSeverity(double acceleration)
                {
                    double gForce = Math.Abs(acceleration);

                    if (gForce > 15)
                        return "Heavy";
                    else if (gForce > 10)
                        return "Medium";
                    else
                        return "Light";
                }

                /// <summary>
                /// Calculates impulse (integral of acceleration) for an event
                /// </summary>
                double CalculateImpulse(long duration, List<double> accelerationValues)
                {
                    if (accelerationValues.Count == 0)
                        return 0f;

                    // Impulse = integral of acceleration over time
                    // Using trapezoidal rule for numerical integration
                    double impulse = 0f;

                    for (int i = 0; i < accelerationValues.Count - 1; i++)
                        // Trapezoidal rule: (a[i] + a[i+1]) / 2 * dt
                        impulse += (accelerationValues[i] + accelerationValues[i + 1]) / 2f * ((double)duration / 1000);

                    return impulse;
                }

                /// <summary>
                /// Merges bottoming out events that are too close together or part of the same peak
                /// </summary>
                List<SuspensionBottomOuts> MergeCloseEvents(List<SuspensionBottomOuts> allEvents)
                {
                    if (allEvents.Count <= 1)
                        return allEvents;

                    var merged = new List<SuspensionBottomOuts>();
                    var currentEvent = new SuspensionBottomOuts(allEvents[0].CompletedLaps, allEvents[0].Severity, allEvents[0].Axle)
                    {
                        StartTimeMs = allEvents[0].StartTimeMs,
                        EndTimeMs = allEvents[0].EndTimeMs,
                        PeakAccelerationMagnitude = allEvents[0].PeakAccelerationMagnitude,
                        AvgAccelerationMagnitude = allEvents[0].AvgAccelerationMagnitude,
                        ImpulseValue = allEvents[0].ImpulseValue
                    };

                    for (int i = 1; i < allEvents.Count; i++)
                    {
                        long gap = allEvents[i].StartTimeMs - currentEvent.EndTimeMs;

                        if (gap < minEventGapMs)
                        {
                            // Merge events that are close together
                            currentEvent.EndTimeMs = allEvents[i].EndTimeMs;
                            currentEvent.PeakAccelerationMagnitude = Math.Max(currentEvent.PeakAccelerationMagnitude,
                                allEvents[i].PeakAccelerationMagnitude);
                            currentEvent.ImpulseValue += allEvents[i].ImpulseValue;

                            // Recalculate average (approximate)
                            currentEvent.AvgAccelerationMagnitude =
                                (currentEvent.AvgAccelerationMagnitude + allEvents[i].AvgAccelerationMagnitude) / 2f;
                        }
                        else
                        {
                            // Add current event and start new one
                            merged.Add(currentEvent);

                            currentEvent = new SuspensionBottomOuts(allEvents[i].CompletedLaps, allEvents[i].Severity, allEvents[i].Axle)
                            {
                                StartTimeMs = allEvents[i].StartTimeMs,
                                EndTimeMs = allEvents[i].EndTimeMs,
                                PeakAccelerationMagnitude = allEvents[i].PeakAccelerationMagnitude,
                                AvgAccelerationMagnitude = allEvents[i].AvgAccelerationMagnitude,
                                ImpulseValue = allEvents[i].ImpulseValue
                            };
                        }
                    }

                    merged.Add(currentEvent);

                    return merged;
                }

                for (int i = 0; i < leftAccelerations.Count; i++)
                {
                    double leftMagnitude = leftAccelerations[i];
                    double rightMagnitude = rightAccelerations[i];

                    if (leftMagnitude < 0 && rightMagnitude < 0)
                    {
                        leftMagnitude = Math.Abs(leftMagnitude);
                        rightMagnitude = Math.Abs(rightMagnitude);

                        // Use maximum magnitude (most severe)
                        combinedAccel[i] = Math.Max(leftMagnitude, rightMagnitude);

                        leftAboveThreshold[i] = leftMagnitude >= accelerationThreshold;
                        rightAboveThreshold[i] = rightMagnitude >= accelerationThreshold;
                    }
                }

                bool inEvent = false;
                int eventStartIndex = 0;
                double peakAccelInEvent = 0;
                var accelValuesInEvent = new List<double>();

                for (int i = 0; i < combinedAccel.Length; i++)
                    if (leftAboveThreshold[i] || rightAboveThreshold[i])
                    {
                        if (!inEvent)
                        {
                            // Start new event
                            inEvent = true;
                            eventStartIndex = i;
                            peakAccelInEvent = 0f;
                            accelValuesInEvent.Clear();
                        }

                        // Track data for this event
                        peakAccelInEvent = Math.Max(peakAccelInEvent, combinedAccel[i]);
                        accelValuesInEvent.Add(combinedAccel[i]);
                    }
                    else
                    {
                        if (inEvent)
                        {
                            // Only create event if it meets minimum duration
                            if (i - eventStartIndex >= minSamplesRequired)
                            {
                                var startTime = suspensionDeflectionsList[eventStartIndex].TimeMS;
                                var endTime = suspensionDeflectionsList[i].TimeMS;
                                var bottomOutEvent = new SuspensionBottomOuts(suspensionDeflectionsList[eventStartIndex].CompletedLaps,
                                                                              GetSeverity(peakAccelInEvent), axle)
                                {
                                    StartTimeMs = startTime,
                                    EndTimeMs = endTime,
                                    PeakAccelerationMagnitude = peakAccelInEvent,
                                    AvgAccelerationMagnitude = accelValuesInEvent.Average(),
                                    ImpulseValue = CalculateImpulse(endTime - startTime, accelValuesInEvent)
                                };

                                events.Add(bottomOutEvent);
                            }

                            inEvent = false;
                        }
                    }

                // Handle event that extends to end of data
                if (inEvent)
                {
                    int eventDurationSamples = combinedAccel.Length - eventStartIndex;
                    if (eventDurationSamples >= minSamplesRequired)
                    {
                        var startTime = suspensionDeflectionsList[eventStartIndex].TimeMS;
                        var endTime = suspensionDeflectionsList[suspensionDeflectionsList.Count - 1].TimeMS;
                        var bottomOutEvent = new SuspensionBottomOuts(suspensionDeflectionsList[eventStartIndex].CompletedLaps,
                                                                      GetSeverity(peakAccelInEvent), axle)
                        {
                            StartTimeMs = startTime,
                            EndTimeMs = endTime,
                            PeakAccelerationMagnitude = peakAccelInEvent,
                            AvgAccelerationMagnitude = accelValuesInEvent.Average(),
                            ImpulseValue = CalculateImpulse(endTime - startTime, accelValuesInEvent)
                        };

                        events.Add(bottomOutEvent);
                    }
                }

                // Merge events that are too close together
                return MergeCloseEvents(events);
            }

            List<double> frontLeftAccels = CalculateAccelerations(ExtractDeflections(suspensionDeflectionsList, d => d.FrontLeft));
            List<double> frontRightAccels = CalculateAccelerations(ExtractDeflections(suspensionDeflectionsList, d => d.FrontRight));
            List<double> rearLeftAccels = CalculateAccelerations(ExtractDeflections(suspensionDeflectionsList, d => d.RearLeft));
            List<double> rearRightAccels = CalculateAccelerations(ExtractDeflections(suspensionDeflectionsList, d => d.RearRight));

            if (false)
            {
                StreamWriter output = new StreamWriter(dataFile + ".deflections", false);

                foreach (var deflections in suspensionDeflectionsList)
                    output.WriteLine(deflections.FrontLeft + "," + deflections.FrontRight + "," +
                                     deflections.RearLeft + "," + deflections.RearRight);

                output.Close();

                output = new StreamWriter(dataFile + ".accelerations", false);

                for (int i = 0; i < frontLeftAccels.Count; i++)
                    output.WriteLine(frontLeftAccels[i] + "," + frontRightAccels[i] + "," +
                                     rearLeftAccels[i] + "," + rearRightAccels[i]);

                output.Close();
            }

            return CreateBottomOuts("Front",
                                    frontLeftAccels,
                                    frontRightAccels).Concat(CreateBottomOuts("Rear",
                                                                              rearLeftAccels,
                                                                              rearRightAccels));
        }

        void writeTelemetry()
		{
			StreamWriter output = new StreamWriter(dataFile + ".tmp", false);

            void writeBottomOut(IEnumerable<SuspensionBottomOuts> suspensionIssues, string severity)
            {
                int count = 0;
                int front = 0;
                int rear = 0;

                foreach (var bottomOut in suspensionIssues)
                    if (bottomOut.Severity == severity)
                    {
                        count += 1;

                        if (bottomOut.Axle == "Front")
                            front += 1;
                        else if (bottomOut.Axle == "Rear")
                            rear += 1;
                    }

                if (count > 0)
                {
                    output.WriteLine("[Suspension.Bottom.Out." + severity + "]");

                    if (front > 0)
                        output.WriteLine("Front=" + front);

                    if (rear > 0)
                        output.WriteLine("Rear=" + rear);
                }
            }

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
                    Task<IEnumerable<SuspensionBottomOuts>> suspensionIssues = Task.Run(createSuspensionIssues);

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

                    IEnumerable<SuspensionBottomOuts> suspensionBottomOuts = suspensionIssues.Result;

                    writeBottomOut(suspensionBottomOuts, "Heavy");
                    writeBottomOut(suspensionBottomOuts, "Medium");
                    writeBottomOut(suspensionBottomOuts, "Light");
                }

				output.Close();

				FileInfo info = new FileInfo(dataFile);

				info.Delete();

				info = new FileInfo(dataFile + ".tmp");

				info.MoveTo(dataFile);
			}
			catch (Exception) {
				try
				{
					output.Close();
				}
				catch (Exception) {
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

        void checkCoordinates()
		{
			if (DateTimeOffset.Now.ToUnixTimeMilliseconds() > nextUpdate)
			{
				double velocityX = physics.LocalVelocity[0];
				double velocityY = physics.LocalVelocity[2];
				double velocityZ = physics.LocalVelocity[1];

				if ((velocityX != 0) || (velocityY != 0) || (velocityZ != 0))
				{
					int carID = 0;

					float coordinateX = cars.cars[carID].worldPosition.x;
					float coordinateY = cars.cars[carID].worldPosition.z;
					
					if ((coordinateX != 0) || (coordinateY != 0))
						if (triggerType == "Trigger") {
							for (int i = 0; i < numCoordinates; i++)
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
                            if (lastLap != graphics.CompletedLaps)
                            {
                                lastLap = graphics.CompletedLaps;

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

                            if ((bestHint > lastHint) && ((lastPhase != Start) || (hintPhases[bestHint] == Intro)))
                            {
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

        public void initializeTrigger(string type, string[] args)
        {
			triggerType = type;

            for (int i = 1; i < (args.Length - 1); i += 3)
            {
                tIndices[numCoordinates] = int.Parse(args[i]);
                xCoordinates[numCoordinates] = float.Parse(args[i + 1]);
                yCoordinates[numCoordinates] = float.Parse(args[i + 2]);

                if (++numCoordinates > 255)
                    break;
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

        string soundsDirectory = "";
        string audioDevice = string.Empty;
        string player = string.Empty;
        string workingDirectory = string.Empty;
        float volume = 0;
        string hintFile = string.Empty;

        public void initializeTrackHints(string type, string[] args)
        {
            triggerType = type;

            hintFile = args[1];

            if (args.Length > 2)
                audioDevice = args[2];

            if (args.Length > 3)
                volume = float.Parse(args[3]);

            if (args.Length > 4)
                player = args[4];

            if (args.Length > 5)
                workingDirectory = args[5];
        }

        public void initializeAnalyzer(bool calibrateTelemetry, string[] args)
        {
            dataFile = args[1];
			
			calibrate = calibrateTelemetry;
			
			if (calibrate) {
				lowspeedThreshold = int.Parse(args[2]);
				steerLock = int.Parse(args[3]);
				steerRatio = int.Parse(args[4]);
				wheelbase = int.Parse(args[5]);
				trackWidth = int.Parse(args[6]);
			}
			else {
				understeerLightThreshold = int.Parse(args[2]);
				understeerMediumThreshold = int.Parse(args[3]);
				understeerHeavyThreshold = int.Parse(args[4]);
				oversteerLightThreshold = int.Parse(args[5]);
				oversteerMediumThreshold = int.Parse(args[6]);
				oversteerHeavyThreshold = int.Parse(args[7]);
				lowspeedThreshold = int.Parse(args[8]);
				steerLock = int.Parse(args[9]);
				steerRatio = int.Parse(args[10]);
				wheelbase = int.Parse(args[11]);
				trackWidth = int.Parse(args[12]);

                if (args.Length > 13) {
                    soundsDirectory = args[13];

					if (args.Length > 14)
						audioDevice = args[14];

                    if (args.Length > 15)
                        volume = float.Parse(args[15]);

                    if (args.Length > 16)
                        player = args[16];

                    if (args.Length > 17)
                        workingDirectory = args[17];
                }
            }
        }

        public void Run(bool positionTrigger, bool trackHints, bool handlingAnalyzer)
		{
			long counter = 0;
			
            while (true)
			{
				counter += 1;
				
				physics = ReadPhysics();
				graphics = ReadGraphics();
				staticInfo = ReadStaticInfo();
                cars = ReadCars();

                if (handlingAnalyzer)
                {
                    if (collectTelemetry(soundsDirectory, audioDevice))
					{
                        if (counter % 20 == 0)
                            writeTelemetry();

						Thread.Sleep(10);
                    }
                    else
                        break;
                }
                else if (positionTrigger)
				{
					checkCoordinates();

					Thread.Sleep(10);
                }
                else if (trackHints)
                {
                    loadTrackHints();

                    checkCoordinates();

                    Thread.Sleep(10);
                }
            }

			Close();
		}
	}
}
