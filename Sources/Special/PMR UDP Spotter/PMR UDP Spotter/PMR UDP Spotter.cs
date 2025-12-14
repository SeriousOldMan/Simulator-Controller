using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Diagnostics.Eventing.Reader;
using System.Drawing;
using System.IO;
using System.Reflection;
using System.Runtime.InteropServices;
using System.Runtime.InteropServices.ComTypes;
using System.Text;
using System.Threading;

namespace PMRUDPSpotter {
	public class UDPSpotter
    {
        private PMRUDPReceiver receiver;

        bool connected = false;
		
		string multiCastGroup;
		int multiCastPort;
		bool useMultiCast;

        public UDPSpotter(string multiCastGroup = "224.0.0.150", int multiCastPort = 7576, bool useMultiCast = true) {
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
				FindWindowEx(0, 0, null, "Race Spotter.ahk");

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

		const int YELLOW_SECTOR_1 = 1;
		const int YELLOW_SECTOR_2 = 2;
		const int YELLOW_SECTOR_3 = 4;

		const int YELLOW_ALL = (YELLOW_SECTOR_1 + YELLOW_SECTOR_2 + YELLOW_SECTOR_3);

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

        string computeAlert(int newSituation) {
			string alert = noAlert;

			if (lastSituation == newSituation)
			{
				if (lastSituation > CLEAR)
				{
					if (situationCount > situationRepeat)
					{
						situationCount = 0;

						alert = "Hold";
					}
					else
						situationCount += 1;
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

				if ((Math.Abs(transY) < ((transY > 0) ? longitudinalFrontDistance : longitudinalRearDistance)) &&
					(Math.Abs(transX) < lateralDistance) && (Math.Abs(otherZ - carZ) < verticalDistance))
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
            var playerVehicle = receiver.GetPlayerState();
            var playerTelemetry = receiver.GetPlayerTelemetry();
            var participantStates = receiver.GetAllParticipantStates();

            if (!hasLastCoordinates)
				lastCoordinates = new double[participantStates.Count, 3];

			double velocityX = playerTelemetry.Chassis.VelocityWS[0];
			double velocityY = playerTelemetry.Chassis.VelocityWS[1];
            double velocityZ = playerTelemetry.Chassis.VelocityWS[2];

            int carID = 0;

			for (int i = 0; i < participantStates.Count; ++i)
				if (participantStates[i].IsPlayer)
				{
					carID = i;

					break;
				}

			if ((velocityX != 0) || (velocityY != 0) || (velocityZ != 0))
			{
				double angle = vectorAngle(velocityX, velocityZ);

				double coordinateX = playerTelemetry.Chassis.PosWS[0];
				double coordinateY = playerTelemetry.Chassis.PosWS[1];
                double coordinateZ = playerTelemetry.Chassis.PosWS[2];
				double speed = 0.0;

                int newSituation = CLEAR;
				bool skip = false;

                carBehind = false;
                carBehindLeft = false;
                carBehindRight = false;

                if (hasLastCoordinates)
				{
					speed = vectorLength(lastCoordinates[carID, 0] - coordinateX, lastCoordinates[carID, 2] - coordinateZ);

					if (speed == 0)
						skip = true;
					else
						for (int i = 0; i < Math.Min(participantStates.Count, lastCoordinates.Length); ++i)
						{
							var vehicle = participantStates[i];

							if ((!vehicle.IsPlayer && !vehicle.InPits && !vehicle.InPitLane)) {
                                var telemetry = receiver.GetParticpantTelemetry(vehicle.VehicleId);
								double otherSpeed = vectorLength(lastCoordinates[i, 0] - telemetry.Chassis.PosWS[0],
																 lastCoordinates[i, 2] - telemetry.Chassis.PosWS[2]);

								if (otherSpeed == 0)
									continue;

								// Console.WriteLine(speed + " - " + otherSpeed);

								if ((Math.Abs(speed - otherSpeed) / speed < 0.5) && sameHeading(lastCoordinates[carID, 0] - coordinateX,
																								lastCoordinates[carID, 2] - coordinateZ,
																								lastCoordinates[i, 0] - telemetry.Chassis.PosWS[0],
																								lastCoordinates[i, 2] - telemetry.Chassis.PosWS[2]))
								{
									bool faster = false;

									if (hasLastCoordinates)
										faster = otherSpeed > speed * 1.05;

									newSituation |= checkCarPosition(coordinateX, coordinateZ, coordinateY, angle, faster,
                                                                     telemetry.Chassis.PosWS[0], telemetry.Chassis.PosWS[2], telemetry.Chassis.PosWS[1]);

									if ((newSituation == THREE) && carBehind)
										break;
								}
							}
					}
				}

				if (!skip)
				{
					for (int i = 0; i < participantStates.Count; ++i)
					{
						var telemetry = receiver.GetParticpantTelemetry(participantStates[i].VehicleId);

						lastCoordinates[i, 0] = telemetry.Chassis.PosWS[0];
						lastCoordinates[i, 1] = telemetry.Chassis.PosWS[1];
						lastCoordinates[i, 2] = telemetry.Chassis.PosWS[2];
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
				}

				string alert = computeAlert(skip ? lastSituation : newSituation);

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
				carBehindReported = false;
			}

			return false;
        }

        double vehicleSpeed(ref UDPVehicleTelemetry telemetry)
        {
			var chassis = telemetry.Chassis;

            return Math.Sqrt(chassis.VelocityLS[0] * chassis.VelocityLS[0] +
                             chassis.VelocityLS[1] * chassis.VelocityLS[1] +
                             chassis.VelocityLS[2] * chassis.VelocityLS[2]) * 3.6;
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

		void updateIdealLine(ref UDPVehicleTelemetry telemetry, double running, double speed) {
			var x = telemetry.Chassis.PosWS[0];
            var z = telemetry.Chassis.PosWS[2];

            idealLine[(int)Math.Round(running * (idealLine.Count - 1))].update((float)speed, (float)x, (float)z);
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
            int last = (idealLine.Count - 1);
            int index = Math.Min(last, Math.Max(0, (int)Math.Round(running * last)));

            return idealLine[index].getSpeed();
        }

        void clearAverageSpeed(double running)
        {
            int last = (idealLine.Count - 1);
            int index = Math.Min(last, Math.Max(0, (int)Math.Round(running * last)));

            idealLine[index].clear();
			
			index -= 1;
			
			if (index >= 0)
				idealLine[index].clear();
			
			index += 2;
			
			if (index <= last)
				idealLine[index].clear();
        }

        double bestLapTime = int.MaxValue;

		int completedLaps = 0;
		int numAccidents = 0;

		string semFileName = "";

		int thresholdSpeed = 60;

        bool checkAccident(ref UDPParticipantRaceState playerVehicle)
        {
			bool accident = false;

			if (playerVehicle.InPits || playerVehicle.InPitLane)
			{
				bestLapTime = int.MaxValue;

				return false;
			}

            List<SlowCarInfo> accidentsAhead = new List<SlowCarInfo>();
            List<SlowCarInfo> accidentsBehind = new List<SlowCarInfo>();
            List<SlowCarInfo> slowCarsAhead = new List<SlowCarInfo>();

            var trackLength = receiver.GetRaceInfo().LayoutLength;

            if (idealLine.Count == 0)
			{

                idealLine.Capacity = (int)(trackLength / 4) + 1;

				for (int i = 0; i < (trackLength / 4); i++)
					idealLine.Add(new IdealLine());
			}

            if ((playerVehicle.LastLapTime > 0) && ((playerVehicle.LastLapTime * 1.002) < bestLapTime))
            {
                bestLapTime = playerVehicle.LastLapTime;

                for (int i = 0; i < idealLine.Count; i++)
                    idealLine[i].clear();
            }

			if (System.IO.File.Exists(semFileName))
			{
				System.IO.File.Delete(semFileName);

                for (int i = 0; i < idealLine.Count; i++)
                    idealLine[i].clear();
            }
	
			if (Math.Max(0, playerVehicle.CurrentLap - 1) > completedLaps) {
				if (numAccidents >= (trackLength / 1000)) {
					for (int i = 0; i < idealLine.Count; i++)
						idealLine[i].clear();
				}
				
				completedLaps = Math.Max(0, playerVehicle.CurrentLap - 1);
				numAccidents = 0;
			}

            try
			{
				var participantStates = receiver.GetAllParticipantStates();

				for (int i = 0; i < participantStates.Count; ++i)
				{
                    UDPParticipantRaceState vehicle = participantStates[i];
					UDPVehicleTelemetry telemetry = receiver.GetParticpantTelemetry(vehicle.VehicleId);
                    
					if (vehicle.InPits || vehicle.InPitLane)
                        continue;

                    double speed = vehicleSpeed(ref telemetry);
                    double running = Math.Max(0, Math.Min(1, Math.Abs(vehicle.LapProgress)));
                    double avgSpeed = getAverageSpeed(running);

                    if (!vehicle.IsPlayer)
                    {
                        if (speed >= 1)
						{
							if (speed < (avgSpeed / 2))
							{
								long distanceAhead = (long)(((vehicle.LapProgress > playerVehicle.LapProgress) ? vehicle.LapProgress * trackLength
																											   : (vehicle.LapProgress * trackLength + trackLength)) -
															playerVehicle.LapProgress * trackLength);

                                clearAverageSpeed(running);

                                if (speed < (avgSpeed / 5))
								{
									if (distanceAhead < aheadAccidentDistance)
										accidentsAhead.Add(new SlowCarInfo(i + 1, distanceAhead));

									long distanceBehind = (long)(((vehicle.LapProgress < playerVehicle.LapProgress) ? playerVehicle.LapProgress * trackLength
																													: (playerVehicle.LapProgress * trackLength + trackLength)) -
																 vehicle.LapProgress * trackLength);

									if (distanceBehind < behindAccidentDistance)
										accidentsBehind.Add(new SlowCarInfo(i + 1, distanceBehind));
								}
								else if (distanceAhead < slowCarDistance)
									slowCarsAhead.Add(new SlowCarInfo(i + 1, distanceAhead));
							}
							else
								updateIdealLine(ref telemetry, running, speed);
						}
                    }
                    else
                    {
                        if (speed >= 5)
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

            return false;
		}

        bool checkFlagState(ref UDPRaceInfo raceInfo)
		{
            // No support by Project Motor Recing

            return false;
		}

		bool checkPitWindow(ref UDPRaceInfo raceInfo)
		{
			// No support by Project Motor Recing

			return false;
		}

		bool greenFlagReported = false;

		bool greenFlag() {
            // No support by Project Motor Recing

            return false;
        }

		float lastTopSpeed = 0;
        int lastLaps = 0;

        void updateTopSpeed(ref UDPParticipantRaceState playerVehicle,
                            ref UDPVehicleTelemetry playerTelemetry)
        {
            float speed = (float)vehicleSpeed(ref playerTelemetry);

            if (speed > lastTopSpeed)
                lastTopSpeed = speed;

            if (Math.Max(0, playerVehicle.CurrentLap - 1) > lastLaps)
            {
                SendSpotterMessage("speedUpdate:" + lastTopSpeed);

                lastTopSpeed = 0;
                lastLaps = Math.Max(0, playerVehicle.CurrentLap - 1);
            }
        }

        double initialX = 0.0d;
		double initialY = 0.0d;
		int coordCount = 0;
		bool mapStarted = false;
		int mapLap = -1;

        bool writeCoordinates(ref UDPParticipantRaceState playerVehicle,
                              ref UDPVehicleTelemetry playerTelemetry)
		{
            double velocityX = playerTelemetry.Chassis.VelocityWS[0];
            double velocityY = playerTelemetry.Chassis.VelocityWS[1];
            double velocityZ = playerTelemetry.Chassis.VelocityWS[2];

            if (!mapStarted)
                if (mapLap == -1)
                {
                    mapLap = Math.Max(0, playerVehicle.CurrentLap - 1);

                    return true;
                }
                else if (Math.Max(0, playerVehicle.CurrentLap - 1) == mapLap)
                    return true;

			if ((velocityX != 0) || (velocityY != 0) || (velocityZ != 0))
			{
				double coordinateX = playerTelemetry.Chassis.PosWS[0];
				double coordinateY = playerTelemetry.Chassis.PosWS[2];

				mapStarted = true;

                Console.WriteLine(coordinateX + ", " + coordinateY);

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
		string triggerType = "Automation";

		void checkCoordinates(ref UDPVehicleTelemetry playerTelemetry)
		{
			if (DateTimeOffset.Now.ToUnixTimeMilliseconds() > (lastUpdate + 2000))
			{
				var participantStates = receiver.GetAllParticipantStates();

                double velocityX = playerTelemetry.Chassis.VelocityWS[0];
                double velocityY = playerTelemetry.Chassis.VelocityWS[1];
                double velocityZ = playerTelemetry.Chassis.VelocityWS[2];

                if ((velocityX != 0) || (velocityY != 0) || (velocityZ != 0))
				{
					double coordinateX = playerTelemetry.Chassis.PosWS[0];
					double coordinateY = playerTelemetry.Chassis.PosWS[2];

                    for (int i = 0; i < numCoordinates; i += 1)
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
		int startTelemetryLap = -1;
        int telemetryLap = -1;
		double lastRunning = -1;

        void collectCarTelemetry(ref UDPParticipantRaceState playerVehicle,
								 ref UDPVehicleTelemetry playerTelemetry)
        {
            int playerID = playerTelemetry.VehicleId;
			int lastLap = Math.Max(0, playerVehicle.CurrentLap - 1);
            var trackLength = receiver.GetRaceInfo().LayoutLength;

            if (lastLap < startTelemetryLap)
				return;

            try
            {
                if (lastLap != telemetryLap)
                {
                    try
                    {
                        if (telemetryFile != null) {
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

                    telemetryLap = (lastLap + 1);

                    telemetryFile = new StreamWriter(telemetryDirectory + "\\Lap " + telemetryLap + ".tmp", false);
					
					lastRunning = -1;
                }

				if (playerVehicle.LapProgress > lastRunning)
                {
                    lastRunning = playerVehicle.LapProgress;
					
					telemetryFile.Write(lastRunning * trackLength + ";");
					telemetryFile.Write((float)playerTelemetry.Input.Accelerator + ";");
					telemetryFile.Write((float)playerTelemetry.Input.Brake + ";");
					telemetryFile.Write((float)playerTelemetry.Input.Steering + ";");
					telemetryFile.Write((float)playerTelemetry.Input.Gear + ";");
					telemetryFile.Write((float)playerTelemetry.Drivetrain.EngineRPM + ";");
					telemetryFile.Write(vehicleSpeed(ref playerTelemetry) + ";");

					telemetryFile.Write("n/a;");
					telemetryFile.Write("n/a;");

					telemetryFile.Write((playerTelemetry.Chassis.AccelerationLS[2] / 9.807f) + ";");
					telemetryFile.Write((playerTelemetry.Chassis.AccelerationLS[0] / 9.807f) + ";");

					telemetryFile.Write(playerTelemetry.Chassis.PosWS[0] + ";");
					telemetryFile.Write(playerTelemetry.Chassis.PosWS[2] + ";");

					telemetryFile.WriteLine(playerVehicle.CurrentLapTime * 1000);

                    if (System.IO.File.Exists(telemetryDirectory + "\\Telemetry.cmd"))
                        try
                        {
                            StreamWriter file = new StreamWriter(telemetryDirectory + "\\Telemetry.section", true);

                            file.Write(lastRunning * trackLength + ";");
                            file.Write((float)playerTelemetry.Input.Accelerator + ";");
                            file.Write((float)playerTelemetry.Input.Brake + ";");
                            file.Write((float)playerTelemetry.Input.Steering + ";");
                            file.Write((float)playerTelemetry.Input.Gear + ";");
                            file.Write((float)playerTelemetry.Drivetrain.EngineRPM + ";");
                            file.Write(vehicleSpeed(ref playerTelemetry) + ";");

                            file.Write("n/a;");
                            file.Write("n/a;");

                            file.Write((playerTelemetry.Chassis.AccelerationLS[2] / 9.807f) + ";");
                            file.Write((playerTelemetry.Chassis.AccelerationLS[0] / 9.807f) + ";");

                            file.Write(playerTelemetry.Chassis.PosWS[0] + ";");
                            file.Write(playerTelemetry.Chassis.PosWS[2] + ";");

                            file.WriteLine(playerVehicle.CurrentLapTime * 1000);

                            file.Close();
                        }
                        catch (Exception) { }
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

        public void initializeTrigger(string type, string[] args, int index)
        {
			triggerType = type;

			for (int i = index; i < (args.Length - 1); i += 2)
			{
				xCoordinates[numCoordinates] = float.Parse(args[i]);
				yCoordinates[numCoordinates] = float.Parse(args[i + 1]);

                if (++numCoordinates > 59)
                    break;
            }
        }

        public void initializeSpotter(string[] args, int index)
        {
			if (args.Length > index)
			{
				string trackLength = args[index++];
			}

            if (args.Length > index)
                aheadAccidentDistance = int.Parse(args[index++]);

            if (args.Length > index)
                behindAccidentDistance = int.Parse(args[index++]);

            if (args.Length > index)
                slowCarDistance = int.Parse(args[index++]);

            if (args.Length > index)
                semFileName = args[index++];

            if (args.Length > index)
                thresholdSpeed = int.Parse(args[index++]);
        }

        public bool active() {
			return (receiver.GetRaceInfo().State == UDPRaceSessionState.Active);
		}

		public void Run(bool mapTrack, bool positionTrigger, string telemetryFolder = "") {
			bool running = true;
			int countdown = 4000;
			long counter = 0;
			bool carTelemetry = (telemetryFolder.Length > 0);

			telemetryDirectory = telemetryFolder;

            while (true) {
				counter++;

				if (!connected)
					Connect();

				if (connected) {
					bool wait = true;

					var playerVehicle = receiver.GetPlayerState();
					var playerTelemetry = receiver.GetPlayerTelemetry();

					if (startTelemetryLap == -1)
						startTelemetryLap = Math.Max(0, playerVehicle.CurrentLap - 1) + 1;
						
                    if (mapTrack)
					{
						if (!writeCoordinates(ref playerVehicle, ref playerTelemetry))
							break;
					}
					else if (positionTrigger)
						checkCoordinates(ref playerTelemetry);
					else if (active())
					{
						if (running)
						{
                            if (carTelemetry)
                                collectCarTelemetry(ref playerScoring);
                            else
                            {
                                if (extended.mSessionStarted != 0 && scoring.mScoringInfo.mGamePhase < (byte)SessionStopped &&
									playerScoring.mPitState < (byte)Entering)
								{
									updateTopSpeed(ref playerScoring);

                                    if (cycle > nextSpeedUpdate)
                                    {
										float speed = (float)vehicleSpeed(ref playerScoring);

                                        nextSpeedUpdate = cycle + 50;

                                        if ((speed >= thresholdSpeed) && !enabled)
                                        {
                                            enabled = true;

                                            SendSpotterMessage("enableSpotter");
                                        }
                                        else if ((speed < thresholdSpeed) && enabled)
                                        {
                                            enabled = false;

                                            SendSpotterMessage("disableSpotter");
                                        }
                                    }

                                    cycle += 1;

									if (!startGo || !greenFlag())
										if (enabled)
											if (checkAccident(ref playerScoring))
												wait = false;
											else if (checkFlagState(ref playerScoring) || checkPositions(ref playerScoring))
												wait = false;
											else
												wait = !checkPitWindow(ref playerScoring);
								}
								else
								{
									longitudinalRearDistance = 5;

									lastSituation = CLEAR;
									carBehind = false;
									carBehindReported = false;

									lastFlagState = 0;
								}
							}
                        }
                        else
                            wait = true;
                    }
                    else
                        wait = true;

					if (carTelemetry || positionTrigger)
                        Thread.Sleep(10);
                    else if (wait)
						Thread.Sleep(50);
				}
				else
					Thread.Sleep(1000);
            }
		}
    }
}
