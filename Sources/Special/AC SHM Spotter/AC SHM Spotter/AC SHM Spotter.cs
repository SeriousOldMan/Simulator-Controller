using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.IO;
using System.IO.MemoryMappedFiles;
using System.Reflection;
using System.Runtime.InteropServices;
using System.Text;
using System.Threading;

namespace ACSHMSpotter {
	enum AC_MEMORY_STATUS { DISCONNECTED, CONNECTING, CONNECTED }

	public class SHMSpotter
	{
		bool connected = false;

		private AC_MEMORY_STATUS memoryStatus = AC_MEMORY_STATUS.DISCONNECTED;
		public bool IsRunning { get { return (memoryStatus == AC_MEMORY_STATUS.CONNECTED); } }

		Physics physics;
		Graphics graphics;
		Cars cars;
		StaticInfo staticInfo;

		public SHMSpotter()
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

		string GetGrip(float surfaceGrip)
		{
			return "Optimum";
		}

		private long GetRemainingLaps(long timeLeft)
		{
			if (staticInfo.IsTimedRace == 0)
				return (graphics.NumberOfLaps - graphics.CompletedLaps);
			else
			{
				if (graphics.iLastTime > 0)
					return ((GetRemainingTime(timeLeft) / graphics.iLastTime) + 1);
				else
					return 0;
			}
		}

		private long GetRemainingTime(long timeLeft)
		{
			if (staticInfo.IsTimedRace != 0)
				return (timeLeft - (graphics.iLastTime * graphics.NumberOfLaps));
			else
				return (GetRemainingLaps(timeLeft) * graphics.iLastTime);
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

				cds.dwData = (IntPtr)(256 * 'R' + 'S');
				cds.lpData = msg;
				cds.cbData = len + 1;

				result = SendMessage(hWnd, WM_COPYDATA, wParam, ref cds);
			}

			return result;
		}

		void SendSpotterMessage(string message)
		{
			int winHandle = FindWindowEx(0, 0, null, "Race Spotter.exe");

			if (winHandle == 0)
				winHandle = FindWindowEx(0, 0, null, "Race Spotter.ahk");

			if (winHandle != 0)
				SendStringMessage(winHandle, 0, "Race Spotter:" + message);
		}

		void SendAutomationMessage(string message)
		{
			int winHandle = FindWindowEx(0, 0, null, "Simulator Controller.exe");

			if (winHandle == 0)
				winHandle = FindWindowEx(0, 0, null, "Simulator Controller.ahk");

			if (winHandle != 0)
				SendStringMessage(winHandle, 0, "Race Spotter:" + message);
		}

		const double PI = 3.14159265;

		const double nearByXYDistance = 10.0;
		const double nearByZDistance = 6.0;
		double longitudinalFrontDistance = 4;
		double longitudinalRearDistance = 5;
		const double lateralDistance = 6;
		const double verticalDistance = 2;

		const int CLEAR = 0;
		const int LEFT = 1;
		const int RIGHT = 2;
		const int THREE = 3;

		const int situationRepeat = 50;

		const string noAlert = "NoAlert";

		int lastSituation = CLEAR;
		int situationCount = 0;

		bool carBehind = false;
		bool carBehindLeft = false;
		bool carBehindRight = false;
		bool carBehindReported = false;
		int carBehindCount = 0;

		const int YELLOW = 1;

		const int BLUE = 16;

		int blueCount = 0;
		int yellowCount = 0;

		int lastFlagState = 0;
		int waitYellowFlagState = 0;

		string computeAlert(int newSituation)
		{
			string alert = noAlert;

			if (lastSituation == newSituation)
			{
				if (lastSituation > CLEAR)
				{
					if (situationCount++ > situationRepeat)
					{
						situationCount = 0;

						alert = "Hold";
					}
				}
				else
					situationCount = 0;
			}
			else
			{
				situationCount = 0;

				if (lastSituation == CLEAR)
				{
					switch (newSituation)
					{
						case LEFT:
							alert = "Left";
							break;
						case RIGHT:
							alert = "Right";
							break;
						case THREE:
							alert = "Three";
							break;
					}
				}
				else
				{
					switch (newSituation)
					{
						case CLEAR:
							if (lastSituation == THREE)
								alert = "ClearAll";
							else
								alert = (lastSituation == RIGHT) ? "ClearRight" : "ClearLeft";

							carBehindReported = true;
							carBehindCount = 21;

							break;
						case LEFT:
							if (lastSituation == THREE)
								alert = "ClearRight";
							else
								alert = "Three";
							break;
						case RIGHT:
							if (lastSituation == THREE)
								alert = "ClearLeft";
							else
								alert = "Three";
							break;
						case THREE:
							alert = "Three";
							break;
					}
				}
			}

			lastSituation = newSituation;

			return alert;
		}

		double vectorLength(double x, double y)
		{
			return Math.Sqrt((x * x) + (y * y));
		}

		double vectorAngle(double x, double y)
		{
			double scalar = (x * 0) + (y * 1);
			double length = vectorLength(x, y);

			double angle = (length > 0) ? Math.Acos(scalar / length) * 180 / PI : 0;

			if (x < 0)
				angle = 360 - angle;

			return angle;
		}

		bool nearBy(double car1X, double car1Y, double car1Z,
					double car2X, double car2Y, double car2Z)
		{
			return (Math.Abs(car1X - car2X) < nearByXYDistance) &&
				   (Math.Abs(car1Y - car2Y) < nearByXYDistance) &&
				   (Math.Abs(car1Z - car2Z) < nearByZDistance);
		}

		void rotateBy(ref double x, ref double y, double angle)
		{
			double sinus = Math.Sin(angle * PI / 180);
			double cosinus = Math.Cos(angle * PI / 180);

			double newX = (x * cosinus) - (y * sinus);
			double newY = (x * sinus) + (y * cosinus);

			x = newX;
			y = newY;
		}

		int checkCarPosition(double carX, double carY, double carZ, double angle, bool faster,
							 double otherX, double otherY, double otherZ)
		{
			if (nearBy(carX, carY, carZ, otherX, otherY, otherZ))
			{
				double transX = (otherX - carX);
				double transY = (otherY - carY);

				rotateBy(ref transX, ref transY, angle);

				if ((Math.Abs(transY) < ((transY > 0) ? longitudinalFrontDistance : longitudinalRearDistance)) && (Math.Abs(transX) < lateralDistance) && (Math.Abs(otherZ - carZ) < verticalDistance))
					return (transX < 0) ? RIGHT : LEFT;
				else
				{
					if (transY < 0)
					{
						carBehind = true;

						if ((faster && Math.Abs(transY) < longitudinalFrontDistance * 1.5) ||
							(Math.Abs(transY) < longitudinalFrontDistance * 2 && Math.Abs(transX) > lateralDistance / 2))
							if (transX < 0)
								carBehindRight = true;
							else
								carBehindLeft = true;
					}

					return CLEAR;
				}
			}
			else
				return CLEAR;
		}

		double[,] lastCoordinates;
		bool hasLastCoordinates = false;

		bool checkPositions()
		{
			if (!hasLastCoordinates)
				lastCoordinates = new double[cars.numVehicles, 3];

			double velocityX = physics.LocalVelocity[0];
			double velocityY = physics.LocalVelocity[2];
			double velocityZ = physics.LocalVelocity[1];

			if ((velocityX != 0) || (velocityY != 0) || (velocityZ != 0))
			{
				// double angle = vectorAngle(velocityX, velocityY);
				float playerRotation = physics.Heading;
				if (playerRotation < 0)
				{
					playerRotation = (float)(2 * Math.PI) + playerRotation;
				}
				double angle = 360 * ((2 * Math.PI) - playerRotation) / (2 * Math.PI);

				int carID = 0;

				float coordinateX = cars.cars[carID].worldPosition.x;
				float coordinateY = cars.cars[carID].worldPosition.z;
				float coordinateZ = cars.cars[carID].worldPosition.y;
				double speed = 0.0;

				if (hasLastCoordinates)
					speed = vectorLength(lastCoordinates[carID, 0] - coordinateX, lastCoordinates[carID, 2] - coordinateY);

				int newSituation = CLEAR;

				carBehind = false;
				carBehindLeft = false;
				carBehindRight = false;

				for (int id = 0; id < cars.numVehicles; id++)
				{
					if ((id != carID) && (cars.cars[id].isCarInPitline == 0) && (cars.cars[id].isCarInPit == 0))
					{
						bool faster = false;

						if (hasLastCoordinates)
							faster = vectorLength(lastCoordinates[id, 0] - cars.cars[id].worldPosition.x,
												  lastCoordinates[id, 2] - cars.cars[carID].worldPosition.y) > speed * 1.05;

						newSituation |= checkCarPosition(coordinateX, coordinateY, coordinateZ, angle, faster,
														 cars.cars[id].worldPosition.x, cars.cars[id].worldPosition.z, cars.cars[id].worldPosition.y);

						if ((newSituation == THREE) && carBehind)
							break;
					}
				}

				for (int id = 0; id < cars.numVehicles; id++)
				{
					lastCoordinates[id, 0] = cars.cars[id].worldPosition.x;
					lastCoordinates[id, 1] = cars.cars[id].worldPosition.y;
					lastCoordinates[id, 2] = cars.cars[id].worldPosition.z;
				}

				hasLastCoordinates = true;

				if (newSituation != CLEAR)
				{
					carBehind = false;
					carBehindLeft = false;
					carBehindRight = false;
					carBehindReported = false;
				}

				if (carBehindCount++ > 200)
					carBehindCount = 0;

				string alert = computeAlert(newSituation);

				if (alert != noAlert)
				{
					longitudinalRearDistance = 4;

					SendSpotterMessage("proximityAlert:" + alert);

					return true;
				}
				else {
					longitudinalRearDistance = 5;

					if (carBehind)
					{
						if (!carBehindReported)
						{
							if (carBehindLeft || carBehindRight || (carBehindCount < 20))
							{
								carBehindReported = true;

								SendSpotterMessage(carBehindLeft ? "proximityAlert:BehindLeft" :
																   (carBehindRight ? "proximityAlert:BehindRight" : "proximityAlert:Behind"));

								return true;
							}
						}
					}
					else
						carBehindReported = false;
				}
			}
			else
			{
				longitudinalRearDistance = 5;

				lastSituation = CLEAR;
				carBehind = false;
				carBehindLeft = false;
				carBehindRight = false;
				carBehindReported = false;
			}

			return false;
		}

		bool checkFlagState()
		{
			if ((waitYellowFlagState & YELLOW) != 0)
			{
				if (yellowCount++ > 50)
				{
					if (graphics.Flag != AC_FLAG_TYPE.AC_YELLOW_FLAG)
						waitYellowFlagState &= ~YELLOW;

					yellowCount = 0;

					if ((waitYellowFlagState & YELLOW) != 0)
					{
						SendSpotterMessage("yellowFlag:Ahead");

						waitYellowFlagState &= ~YELLOW;

						return true;
					}
				}
			}
			else
				yellowCount = 0;

			if (graphics.Flag == AC_FLAG_TYPE.AC_BLUE_FLAG)
			{
				if ((lastFlagState & BLUE) == 0)
				{
					SendSpotterMessage("blueFlag");

					lastFlagState |= BLUE;

					return true;
				}
				else if (blueCount++ > 1000)
				{
					lastFlagState &= ~BLUE;

					blueCount = 0;
				}
			}
			else
			{
				lastFlagState &= ~BLUE;

				blueCount = 0;
			}

			if (graphics.Flag == AC_FLAG_TYPE.AC_YELLOW_FLAG)
			{
				if ((lastFlagState & YELLOW) == 0)
				{
					/*
					SendSpotterMessage("yellowFlag:Sector;1");

					lastFlagState |= YELLOW_SECTOR_1;

					return true;
					*/

					lastFlagState |= YELLOW;
					waitYellowFlagState |= YELLOW;
					yellowCount = 0;
				}
			}
			else
			{
				if ((lastFlagState & YELLOW) != 0)
				{
					if (waitYellowFlagState != lastFlagState)
						SendSpotterMessage("yellowFlag:Clear");

					lastFlagState &= ~YELLOW;
					waitYellowFlagState &= ~YELLOW;
					yellowCount = 0;

					return true;
				}
			}

			return false;
		}

		bool checkPitWindow()
		{
			// No support by Assetto Corsa

			return false;
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

		List<float> recentSteerAngles = new List<float>();
		const int numRecentSteerAngles = 6;

		List<float> recentGLongs = new List<float>();
		const int numRecentGLongs = 6;

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

		bool collectTelemetry()
		{
			if ((graphics.Status != AC_STATUS.AC_LIVE) || graphics.IsInPit != 0 || graphics.IsInPitLane != 0)
				return true;

			float steerAngle = physics.SteerAngle;

            recentSteerAngles.Add(steerAngle);
			if (recentSteerAngles.Count > numRecentSteerAngles)
				recentSteerAngles.RemoveAt(0);

            float acceleration = physics.SpeedKmh - lastSpeed;

            lastSpeed = physics.SpeedKmh;

            recentGLongs.Add(acceleration);
			if (recentGLongs.Count > numRecentGLongs)
				recentGLongs.RemoveAt(0);


            // Get the average recent GLong
            float sumGLong = 0.0f;
            int numGLong = 0;

            foreach (float gLong in recentGLongs)
            {
                sumGLong += gLong;
                numGLong++;

            }

            int phase = 0;
            if (numGLong > 0)
            {
                float recentGLong = sumGLong / numGLong;
                if (recentGLong < -0.2)
                {
                    // Braking
                    phase = -1;
                }
                else if (recentGLong > 0.1)
                {
                    // Accelerating
                    phase = 1;
                }
            }

			if (Math.Abs(steerAngle) > 0.1 && lastSpeed > 60)
			{
				double angularVelocity = physics.LocalAngularVelocity[2];
                CornerDynamics cd = new CornerDynamics(physics.SpeedKmh, 0, graphics.CompletedLaps, phase);

				if (Math.Abs(angularVelocity * 57.2958) > 0.1)
				{
					float steeredAngleDegs = steerAngle * steerLock / 2.0f / steerRatio;

                    /*
					if (Math.Abs(steeredAngleDegs) > 0.33f)
						cd.Usos = 10 * -steeredAngleDegs / physics.LocalAngularVelocity[1];
					*/

                    double steerAngleRadians = -steeredAngleDegs / 57.2958;
                    double wheelBaseMeter = (float)wheelbase / 10;
                    double radius = wheelBaseMeter / steerAngleRadians;

                    double perimeter = radius * PI * 2;
                    double perimeterSpeed = lastSpeed / 3.6;
                    double idealAngularVelocity = perimeterSpeed / perimeter * 2 * PI;

                    double slip = Math.Abs(idealAngularVelocity) - Math.Abs(angularVelocity);

                    if (steerAngle > 0)
                    {
                        if (angularVelocity < idealAngularVelocity)
                            slip *= -1;
                    }
                    else
                    {
                        if (angularVelocity > idealAngularVelocity)
                            slip *= -1;
                    }

                    cd.Usos = slip * 57.2989 * 10;

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
                    }
                }

				cornerDynamicsList.Add(cd);

				int completedLaps = graphics.CompletedLaps;

				if (lastCompletedLaps != completedLaps)
					while (true)
						if (cornerDynamicsList[0].CompletedLaps < completedLaps - 2)
							cornerDynamicsList.RemoveAt(0);
						else
							break;
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

				foreach (CornerDynamics corner in cornerDynamicsList)
				{
					int phase = corner.Phase + 1;

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

        float initialX = 0.0f;
		float initialY = 0.0f;
		int coordCount = 0;

		bool writeCoordinates() {
			double velocityX = physics.LocalVelocity[0];
			double velocityY = physics.LocalVelocity[2];
			double velocityZ = physics.LocalVelocity[1];

			if ((velocityX != 0) || (velocityY != 0) || (velocityZ != 0))
			{
				int carID = 0;

				float coordinateX = cars.cars[carID].worldPosition.x;
				float coordinateY = cars.cars[carID].worldPosition.z;

				if ((coordinateX != 0) || (coordinateY != 0))
				{
					Console.WriteLine(coordinateX + "," + coordinateY);

					if (coordCount == 0)
					{
						initialX = coordinateX;
						initialY = coordinateY;
					}
					else if (coordCount > 100 && Math.Abs(coordinateX - initialX) < 10.0 && Math.Abs(coordinateY - initialY) < 10.0)
						return false;

					coordCount += 1;
				}
			}

			return true;
		}

		float[] xCoordinates = new float[60];
		float[] yCoordinates = new float[60];
		int numCoordinates = 0;
		long lastUpdate = 0;

		void checkCoordinates()
		{
			if (DateTimeOffset.Now.ToUnixTimeMilliseconds() > (lastUpdate + 2000))
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
						for (int i = 0; i < numCoordinates; i++)
						{
							if (Math.Abs(xCoordinates[i] - coordinateX) < 20 && Math.Abs(yCoordinates[i] - coordinateY) < 20)
							{
								SendAutomationMessage("positionTrigger:" + (i + 1) + ";" + xCoordinates[i] + ";" + yCoordinates[i]);

								lastUpdate = DateTimeOffset.Now.ToUnixTimeMilliseconds();

								break;
							}
						}
				}
			}
        }

        public void initializeTrigger(string[] args)
        {
            for (int i = 1; i < (args.Length - 1); i += 2)
            {
                xCoordinates[numCoordinates] = float.Parse(args[i]);
                yCoordinates[numCoordinates] = float.Parse(args[i + 1]);

                numCoordinates += 1;
            }
        }

        public void initializeAnalyzer(string[] args)
        {
            dataFile = args[1];

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
        }

        public void Run(bool mapTrack, bool positionTrigger, bool analyzeTelemetry)
		{
			bool running = false;

			int countdown = 4000;
			int safety = 200;
			long counter = 0;

			float lastTime = graphics.SessionTimeLeft;

			while (true)
			{
				counter++;

				physics = ReadPhysics();
				graphics = ReadGraphics();
				staticInfo = ReadStaticInfo();
				cars = ReadCars();

				bool wait = true;

                if (analyzeTelemetry)
                {
                    if (collectTelemetry())
					{
                        if (counter % 20 == 0)
                            writeTelemetry();
                    }
                    else
                        break;
                }
                else if (mapTrack)
				{
					if (!writeCoordinates())
						break;
				}
				else if (positionTrigger)
					checkCoordinates();
				else
				{
					if (!running)
						running = ((lastTime != graphics.SessionTimeLeft) || (countdown-- <= 0) || (physics.SpeedKmh >= 200));

					if (running)
					{
						if (physics.SpeedKmh > 120)
							safety = 200;

						if ((safety-- <= 0) && (waitYellowFlagState > 0))
							running = false;
					}
					else if ((safety <= 0) && (physics.SpeedKmh > 120))
					{
						running = true;
						safety = 200;
					}

					if (running)
					{
						if ((graphics.Status == AC_STATUS.AC_LIVE) && (graphics.IsInPit == 0) && (graphics.IsInPitLane == 0))
						{
							if (!checkFlagState() && !checkPositions())
								wait = !checkPitWindow();
							else
								wait = false;
						}
						else
						{
							longitudinalRearDistance = 5;
					
							lastSituation = CLEAR;
							carBehind = false;
							carBehindLeft = false;
							carBehindRight = false;
							carBehindReported = false;

							lastFlagState = 0;
						}
					}
				}

                if (analyzeTelemetry)
                    Thread.Sleep(10);
                else if (positionTrigger)
                    Thread.Sleep(10);
                else if (wait)
					Thread.Sleep(50);
			}

			Close();
		}
	}
}
