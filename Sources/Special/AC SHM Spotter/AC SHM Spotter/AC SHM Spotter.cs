using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Drawing;
using System.IO;
using System.IO.MemoryMappedFiles;
using System.Linq;
using System.Reflection;
using System.Runtime.InteropServices;
using System.Text;
using System.Threading;
using System.Windows.Forms;

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

        void SendAnalyzerMessage(string message)
        {
            int winHandle = FindWindowEx(0, 0, null, "Setup Workbench.exe");

            if (winHandle == 0)
                winHandle = FindWindowEx(0, 0, null, "Setup Workbench.ahk");

            if (winHandle != 0)
                SendStringMessage(winHandle, 0, "Analyzer:" + message);
        }

        const double PI = 3.14159265;

        long cycle = 0;
        long nextSpeedUpdate = 0;
		bool enabled = true;

        const double nearByXYDistance = 10.0;
		const double nearByZDistance = 6.0;
		double longitudinalFrontDistance = 4;
		double longitudinalRearDistance = 5;
		const double lateralDistance = 8;
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
		long nextCarBehind = 0;

		const int YELLOW = 1;

		const int BLUE = 16;

		int blueCount = 0;
		int yellowCount = 0;
		long nextBlueFlag = 0;

		int lastFlagState = 0;
		int waitYellowFlagState = 0;

        int aheadAccidentDistance = 800;
        int behindAccidentDistance = 500;
        int slowCarDistance = 500;

        long nextSlowCarAhead = 0;
        long nextAccidentAhead = 0;
        long nextAccidentBehind = 0;

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
							nextCarBehind = cycle + 200;

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

		bool sameHeading(double x1, double y1, double x2, double y2)
		{
			return vectorLength(x1 + x2, y1 + y2) > vectorLength(x1, y1);
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
					speed = vectorLength(lastCoordinates[carID, 0] - coordinateX, lastCoordinates[carID, 2] - coordinateZ);

				int newSituation = CLEAR;

				carBehind = false;
				carBehindLeft = false;
				carBehindRight = false;

				for (int id = 0; id < cars.numVehicles; id++)
				{
					if ((id != carID) && (cars.cars[id].isCarInPitline == 0) && (cars.cars[id].isCarInPit == 0))
					{
						double otherSpeed = vectorLength(lastCoordinates[id, 0] - cars.cars[id].worldPosition.x,
														 lastCoordinates[id, 2] - cars.cars[id].worldPosition.y);
						
						if ((Math.Abs(speed - otherSpeed) / speed < 0.5) && sameHeading(lastCoordinates[carID, 0] - coordinateX,
																						lastCoordinates[carID, 2] - coordinateZ,
																						lastCoordinates[id, 0] - cars.cars[id].worldPosition.x,
																						lastCoordinates[id, 2] - cars.cars[id].worldPosition.y))
						{
							bool faster = false;

							if (hasLastCoordinates)
								faster = otherSpeed > speed * 1.05;

							newSituation |= checkCarPosition(coordinateX, coordinateY, coordinateZ, angle, faster,
															 cars.cars[id].worldPosition.x, cars.cars[id].worldPosition.z, cars.cars[id].worldPosition.y);

							if ((newSituation == THREE) && carBehind)
								break;
						}
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

					if (carBehind && (cycle > nextCarBehind))
					{
						if (!carBehindReported)
						{
							if (carBehindLeft || carBehindRight || (carBehindCount < 20))
                            {
                                nextCarBehind = cycle + 200;
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

        class IdealLine
        {
            public int count = 0;

            List<float> speeds = new List<float>(1000);

            public float speed = 0;
            public float posX = 0;
            public float posY = 0;

			public float getSpeed()
			{
				return (count > 3) ? speed : -1;
			}

            float average()
            {
                int length = speeds.Count;
                double average = 0;

                for (int i = 0; i < length; ++i)
                    average += speeds[i];

                return (float)(average / length);
            }

            float stdDeviation()
            {
                int length = speeds.Count;
                float avg = average();
                double sqrSum = 0;

                for (int i = 0; i < length; ++i)
                {
                    float speed = speeds[i];

                    sqrSum += (speed - avg) * (speed - avg);
                }

                return (float)Math.Sqrt(sqrSum / length);
            }

            void cleanup()
            {
                int length = speeds.Count;
                float avg = average();
                float stdDev = stdDeviation();
                int i = 0;

                while (i < length)
                {
                    float speed = speeds[i];

                    if (Math.Abs(speed - avg) > stdDev)
                    {
                        speeds.Remove(i);

                        length -= 1;
                    }
                    else
                        i += 1;
                }

                count = length;
                speed = average();
            }

            public void update(float s, float x, float y)
            {
                if (count == 0)
                {
                    count = 1;

                    speeds.Add(s);

                    speed = s;

                    posX = x;
                    posY = y;
                }
                else if (count < 1000)
                {
                    count += 1;

                    speeds.Add(s);

                    speed = ((speed * count) + s) / (count + 1);

                    posX = ((posX * count) + x) / (count + 1);
                    posY = ((posY * count) + y) / (count + 1);

                    if (speeds.Count % 50 == 0 || (count > 20 && Math.Abs(speed - s) > (speed / 10)))
                        cleanup();
                }
            }

            public void clear()
            {
                count = 0;

				speeds.Clear();

                posX = 0;
                posY = 0;
            }
        }

        List<IdealLine> idealLine = new List<IdealLine>(1000);

        void updateIdealLine(ref AcCarInfo car, double running, double speed)
        {
			idealLine[(int)Math.Round(running * (idealLine.Count - 1))].update((float)speed, car.worldPosition.x, car.worldPosition.z);
        }

        class SlowCarInfo
        {
            public int vehicle;
            public long distance;

            public SlowCarInfo(int vehicle, long distance)
            {
                this.vehicle = vehicle;
                this.distance = distance;
            }
        }

        double getAverageSpeed(double running)
        {
            int last = idealLine.Count - 1;
            int index = Math.Min(last, Math.Max(0, (int)Math.Round(running * last)));

            return idealLine[index].getSpeed();
        }

        void clearAverageSpeed(double running)
        {
            int last = idealLine.Count - 1;
            int index = Math.Min(last, Math.Max(0, (int)Math.Round(running * last)));

            idealLine[index].clear();
			
			index -= 1;
			
			if (index >= 0)
				idealLine[index].clear();
			
			index += 2;
			
			if (index <= last)
				idealLine[index].clear();
        }

        int bestLapTime = int.MaxValue;

		int completedLaps = 0;
		int numAccidents = 0;

        string semFileName = "";
        int thresholdSpeed = 60;

        bool checkAccident()
        {
			bool accident = false;

			if (cars.numVehicles > 0)
			{
				if (idealLine.Count == 0)
				{
					idealLine.Capacity = (int)(staticInfo.TrackSPlineLength / 4) + 1;

					for (int i = 0; i < (staticInfo.TrackSPlineLength / 4); i++)
						idealLine.Add(new IdealLine());
				}

                ref AcCarInfo driver = ref cars.cars[0];

                if ((driver.isCarInPitline + driver.isCarInPit) > 0) {
					bestLapTime = int.MaxValue;
					
                    return false;
                }

				if ((driver.lastLapTimeMS > 0) && ((driver.lastLapTimeMS * 1.002) < bestLapTime))
				{
					bestLapTime = driver.lastLapTimeMS;

					for (int i = 0; i < idealLine.Count; i++)
						idealLine[i].clear();
                }

                if (System.IO.File.Exists(semFileName))
                {
                    System.IO.File.Delete(semFileName);

                    for (int i = 0; i < idealLine.Count; i++)
                        idealLine[i].clear();
                }

                if (graphics.CompletedLaps > completedLaps) {
					if (numAccidents >= (staticInfo.TrackSPlineLength / 1000)) {
						for (int i = 0; i < idealLine.Count; i++)
							idealLine[i].clear();
					}
					
					completedLaps = graphics.CompletedLaps;
					numAccidents = 0;
				}

                List<SlowCarInfo> accidentsAhead = new List<SlowCarInfo>();
				List<SlowCarInfo> accidentsBehind = new List<SlowCarInfo>();
				List<SlowCarInfo> slowCarsAhead = new List<SlowCarInfo>();
				double driverLapDistance = driver.splinePosition * staticInfo.TrackSPlineLength;

                try
				{
					for (int i = 1; i < cars.numVehicles; ++i)
					{
						ref AcCarInfo car = ref cars.cars[i];
                        
						if (car.isCarInPitline + car.isCarInPit > 0)
                            continue;

                        double speed = car.speedMS * 3.6;
                        double running = Math.Max(0, Math.Min(1, car.splinePosition));
                        double avgSpeed = getAverageSpeed(running);

                        if (car.carId != driver.carId)
						{
							if (speed >= 1)
							{
                                IdealLine slot = idealLine[(int)Math.Round(running * (idealLine.Count - 1))];

								if (speed < (avgSpeed / 2))
								{
									double carLapDistance = running * staticInfo.TrackSPlineLength;
									long distanceAhead = (long)(((carLapDistance > driverLapDistance) ? carLapDistance
																									  : (carLapDistance + staticInfo.TrackSPlineLength)) - driverLapDistance);

									clearAverageSpeed(running);

									if (speed < (avgSpeed / 5))
									{
										if (distanceAhead < aheadAccidentDistance)
											accidentsAhead.Add(new SlowCarInfo(i + 1, distanceAhead));

										long distanceBehind = (long)(((carLapDistance < driverLapDistance) ? driverLapDistance
																										   : (driverLapDistance + staticInfo.TrackSPlineLength)) - carLapDistance);

										if (distanceBehind < behindAccidentDistance)
											accidentsBehind.Add(new SlowCarInfo(i + 1, distanceBehind));
									}
									else if (distanceAhead < slowCarDistance)
										slowCarsAhead.Add(new SlowCarInfo(i + 1, distanceAhead));
								}
								else
									updateIdealLine(ref car, running, speed);
							}
                        }
                        else
                        {
                            if (speed >= 1)
                            {
                                if ((avgSpeed >= 0) && (speed < (avgSpeed / 2)))
                                    accident = true;
                            }
                        }
                    }
				}
				catch (Exception e) {
                    SendSpotterMessage("internalError:" + e.Message);
                }

				if (!accident)
				{
					if (accidentsAhead.Count > 0)
					{
						if (cycle > nextAccidentAhead)
						{
							long distance = long.MaxValue;
							int vehicle = 0;

							foreach (SlowCarInfo i in accidentsAhead)
								if (i.distance < distance) {
									distance = i.distance;
									vehicle = i.vehicle;
								}

							if ((distance > 50) && (vehicle > 0))
							{
								nextAccidentAhead = cycle + 400;
                                nextAccidentBehind = cycle + 200;
                                nextSlowCarAhead = cycle + 200;

								SendSpotterMessage("accidentAlert:Ahead;" + distance + ";" + vehicle);
								
								numAccidents += 1;

								return true;
							}
						}
					}

					if (slowCarsAhead.Count > 0)
					{
						if (cycle > nextSlowCarAhead)
						{
							long distance = long.MaxValue;

							foreach (SlowCarInfo i in slowCarsAhead)
								distance = Math.Min(distance, i.distance);

							if (distance > 100)
							{
								nextSlowCarAhead = cycle + 200;
                                nextAccidentBehind = cycle + 200;

                                SendSpotterMessage("slowCarAlert:" + distance);
								
								numAccidents += 1;

								return true;
							}
						}
					}

					if (accidentsBehind.Count > 0)
					{
						if (cycle > nextAccidentBehind)
						{
							long distance = long.MaxValue;
							int vehicle = 0;

							foreach (SlowCarInfo i in accidentsBehind)
								if (i.distance < distance) {
									distance = i.distance;
									vehicle = i.vehicle;
								}

							if ((distance > 50) && (vehicle > 0))
							{
								nextAccidentBehind = cycle + 400;

								SendSpotterMessage("accidentAlert:Behind;" + distance + ";" + vehicle);
								
								numAccidents += 1;

								return true;
							}
						}
					}
				}
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
				if ((lastFlagState & BLUE) == 0 && cycle > nextBlueFlag)
                {
                    nextBlueFlag = cycle + 400;

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

		float lastTopSpeed = 0;
        int lastLaps = 0;

        void updateTopSpeed()
        {
            if (physics.SpeedKmh > lastTopSpeed)
                lastTopSpeed = physics.SpeedKmh;

            if (graphics.CompletedLaps > lastLaps)
            {
                SendSpotterMessage("speedUpdate:" + lastTopSpeed);

                lastTopSpeed = 0;
                lastLaps = graphics.CompletedLaps;
            }
        }

        float initialX = 0.0f;
		float initialY = 0.0f;
		int coordCount = 0;

		bool mapStarted = false;
        int mapLap = -1;

        bool writeCoordinates() {
			double velocityX = physics.LocalVelocity[0];
			double velocityY = physics.LocalVelocity[2];
			double velocityZ = physics.LocalVelocity[1];

			if (!mapStarted)
				if (mapLap == -1)
				{
					mapLap = graphics.CompletedLaps;

					return true;
				}
				else if (graphics.CompletedLaps == mapLap)
					return true;

            if ((velocityX != 0) || (velocityY != 0) || (velocityZ != 0))
			{
				int carID = 0;

				float coordinateX = cars.cars[carID].worldPosition.x;
				float coordinateY = cars.cars[carID].worldPosition.z;

				mapStarted = true;

				if ((coordinateX != 0) || (coordinateY != 0))
				{
					Console.WriteLine(coordinateX + "," + coordinateY);

					if (coordCount == 0)
					{
						initialX = coordinateX;
						initialY = coordinateY;
					}
					else if (circuit && coordCount > 100 && Math.Abs(coordinateX - initialX) < 10.0 && Math.Abs(coordinateY - initialY) < 10.0)
						return false;

					coordCount += 1;
				}
			}
			else if (mapStarted && !circuit)
				return false;

			return true;
		}

		float[] xCoordinates = new float[256];
		float[] yCoordinates = new float[256];
		int numCoordinates = 0;
		long lastUpdate = 0;
		string triggerType = "Automation";

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
								if (triggerType == "Automation")
									SendAutomationMessage("positionTrigger:" + (i + 1) + ";" + xCoordinates[i] + ";" + yCoordinates[i]);

                                lastUpdate = DateTimeOffset.Now.ToUnixTimeMilliseconds();

								break;
							}
						}
				}
			}
        }

        string telemetryDirectory = "";
        StreamWriter telemetryFile = null;
        int telemetryLap = -1;
		float lastRunning = -1;

        void collectCarTelemetry()
        {
            ref AcCarInfo driver = ref cars.cars[0];
            
            try
            {
                if ((graphics.CompletedLaps + 1) != telemetryLap)
                {
                    try
                    {
						if (telemetryFile != null)
						{
							telemetryFile.Close();

							FileInfo info = new FileInfo(telemetryDirectory + "\\Lap " + telemetryLap + ".telemetry");

							info.Delete();

							info = new FileInfo(telemetryDirectory + "\\Lap " + telemetryLap + ".tmp");

							info.MoveTo(telemetryDirectory + "\\Lap " + telemetryLap + ".telemetry");
						}
                    }
                    catch (Exception)
                    {
                    }

                    telemetryLap = (graphics.CompletedLaps + 1);

                    telemetryFile = new StreamWriter(telemetryDirectory + "\\Lap " + telemetryLap + ".tmp", false);

					lastRunning = -1;
                }

                double velocityX = physics.LocalVelocity[0];
                double velocityY = physics.LocalVelocity[2];
                double velocityZ = physics.LocalVelocity[1];

				if ((velocityX != 0) || (velocityY != 0) || (velocityZ != 0))
				{
                    int carID = 0;

                    float playerRotation = physics.Heading;
					if (playerRotation < 0)
					{
						playerRotation = (float)(2 * Math.PI) + playerRotation;
					}
					double angle = 360 * ((2 * Math.PI) - playerRotation) / (2 * Math.PI);

                    double latG = physics.AccG[0];
					double longG = physics.AccG[2];

					// rotateBy(ref longG, ref latG, angle);

					// latG *= -1;

					float running = Math.Max(0, Math.Min(1, driver.splinePosition)) * staticInfo.TrackSPlineLength;

					if (running > lastRunning)
					{
						telemetryFile.Write(running + ";");
						telemetryFile.Write(physics.Gas + ";");
						telemetryFile.Write(physics.Brake + ";");
						telemetryFile.Write(physics.SteerAngle + ";");
						telemetryFile.Write((physics.Gear - 1) + ";");
						telemetryFile.Write(physics.Rpms + ";");
						telemetryFile.Write(physics.SpeedKmh + ";");

						telemetryFile.Write(physics.TC + ";");
						telemetryFile.Write(physics.Abs + ";");
						telemetryFile.Write(longG + ";");
						telemetryFile.Write(latG + ";");

						telemetryFile.Write(cars.cars[carID].worldPosition.x + ";");
                        telemetryFile.Write(cars.cars[carID].worldPosition.z + ";");
                        telemetryFile.WriteLine(graphics.iCurrentTime);

						if (System.IO.File.Exists(telemetryDirectory + "\\Telemetry.cmd"))
							try {
								StreamWriter file = new StreamWriter(telemetryDirectory + "\\Telemetry.section", true);

								file.Write(running + ";");
								file.Write(physics.Gas + ";");
								file.Write(physics.Brake + ";");
								file.Write(physics.SteerAngle + ";");
								file.Write((physics.Gear - 1) + ";");
								file.Write(physics.Rpms + ";");
								file.Write(physics.SpeedKmh + ";");

								file.Write(physics.TC + ";");
								file.Write(physics.Abs + ";");
								file.Write(longG + ";");
								file.Write(latG + ";");

								file.Write(cars.cars[carID].worldPosition.x + ";");
								file.Write(cars.cars[carID].worldPosition.z + ";");
								file.WriteLine(graphics.iCurrentTime);

								file.Close();
                            }
                            catch (Exception) { }

                        lastRunning = running;
                    }
                }
            }
            catch (Exception)
            {
                try
                {
                    if (telemetryFile != null)
                        telemetryFile.Close();
                }
                catch (Exception)
                {
                }

                // retry next round...
            }
        }

        public void initializeTrigger(string type, string[] args)
        {
			triggerType = type;

            for (int i = 1; i < (args.Length - 1); i += 2)
            {
                xCoordinates[numCoordinates] = float.Parse(args[i]);
                yCoordinates[numCoordinates] = float.Parse(args[i + 1]);

                if (++numCoordinates > 255)
                    break;
            }
        }

		bool circuit = true;

		public void initializeMapper(string trackType)
		{
			circuit = (trackType == "Circuit");
		}

        public void initializeSpotter(string[] args)
        {
            if (args.Length > 0)
			{
				string trackLength = args[0];
			}

            if (args.Length > 1)
                aheadAccidentDistance = int.Parse(args[1]);

            if (args.Length > 2)
                behindAccidentDistance = int.Parse(args[2]);

            if (args.Length > 3)
                slowCarDistance = int.Parse(args[3]);

            if (args.Length > 4)
                semFileName = args[4];

            if (args.Length > 5)
                thresholdSpeed = int.Parse(args[5]);
        }

        public void Run(bool mapTrack, bool positionTrigger, string telemetryFolder = "")
		{
			bool running = false;

			int countdown = 4000;
			int safety = 200;
			long counter = 0;

			float lastTime = graphics.SessionTimeLeft;

            bool carTelemetry = (telemetryFolder.Length > 0);

            telemetryDirectory = telemetryFolder;

            while (true)
			{
				counter++;

				physics = ReadPhysics();
				graphics = ReadGraphics();
				staticInfo = ReadStaticInfo();
				cars = ReadCars();

				bool wait = true;

                if (mapTrack)
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

					if (graphics.Status == AC_STATUS.AC_REPLAY || graphics.Status == AC_STATUS.AC_PAUSE)
						running = false;

                    if (running)
					{
						if (telemetryLap == -1)
							telemetryLap = (graphics.CompletedLaps + 1);

                        if (carTelemetry)
							collectCarTelemetry();
						else
						{
							if ((graphics.Status == AC_STATUS.AC_LIVE) && (graphics.IsInPit == 0) && (graphics.IsInPitLane == 0))
							{
								updateTopSpeed();

								if (cycle > nextSpeedUpdate)
								{
									nextSpeedUpdate = cycle + 50;

									if ((physics.SpeedKmh >= thresholdSpeed) && !enabled)
									{
										enabled = true;

                                        SendSpotterMessage("enableSpotter");
                                    }
									else if ((physics.SpeedKmh < thresholdSpeed) && enabled)
                                    {
                                        enabled = false;

                                        SendSpotterMessage("disableSpotter");
                                    }
                                }

								cycle += 1;

								if (enabled)
									if (checkAccident())
										wait = false;
									else if (checkFlagState() || checkPositions())
										wait = false;
									else
										wait = !checkPitWindow();
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
				}

				if (carTelemetry || positionTrigger)
                    Thread.Sleep(10);
                else if (wait)
					Thread.Sleep(50);
			}

			Close();
		}
	}
}
