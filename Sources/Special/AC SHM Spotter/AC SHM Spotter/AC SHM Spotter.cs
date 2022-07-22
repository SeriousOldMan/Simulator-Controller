using System;
using System.Diagnostics;
using System.IO;
using System.IO.MemoryMappedFiles;
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
		const double longitudinalDistance = 4;
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

				if ((Math.Abs(transY) < longitudinalDistance) && (Math.Abs(transX) < lateralDistance) && (Math.Abs(otherZ - carZ) < verticalDistance))
					return (transX < 0) ? RIGHT : LEFT;
				else
				{
					if (transY < 0)
					{
						carBehind = true;

						if ((faster && Math.Abs(transY) < longitudinalDistance * 1.5) ||
							(Math.Abs(transY) < longitudinalDistance * 2 && Math.Abs(transX) > lateralDistance / 2))
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
					if (id != carID)
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

				string alert = computeAlert(newSituation);

				if (alert != noAlert)
				{
					if (alert != "Hold")
						carBehindReported = false;

					SendSpotterMessage("proximityAlert:" + alert);

					return true;
				}
				else if (carBehind)
				{
					if (!carBehindReported)
					{
						carBehindReported = true;

						SendSpotterMessage(carBehindLeft ? "proximityAlert:BehindLeft" :
														   (carBehindRight ? "proximityAlert:BehindRight" : "proximityAlert:Behind"));

						return true;
					}
				}
				else
					carBehindReported = false;
			}
			else
			{
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

		void checkPitWindow()
		{
			// No support by Assetto Corsa
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

		public void Run(bool mapTrack, bool positionTrigger)
		{
			bool running = false;

			int countdown = 4000;
			int safety = 200;

			float lastTime = graphics.SessionTimeLeft;

			while (true)
			{
				if (mapTrack)
				{
					if (!writeCoordinates())
						break;
				}
				else if (positionTrigger)
					checkCoordinates();
				else
				{
					physics = ReadPhysics();
					graphics = ReadGraphics();
					staticInfo = ReadStaticInfo();
					cars = ReadCars();

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
								checkPitWindow();
						}
						else
						{
							lastSituation = CLEAR;
							carBehind = false;
							carBehindLeft = false;
							carBehindRight = false;
							carBehindReported = false;

							lastFlagState = 0;
						}
					}
				}

				if (positionTrigger)
					Thread.Sleep(10);
				else
					Thread.Sleep(50);
			}

			Close();
		}
	}
}
