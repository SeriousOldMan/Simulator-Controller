using System;
using System.Collections.Generic;
using System.IO;
using System.Runtime.InteropServices;
using System.Threading;
using F125UDPProtocol;

namespace F125UDPSpotter {
	public class UDPSpotter
    {
        private F125UDPReceiver.F125UDPReceiver receiver;

        bool connected = false;
		
		string host;
		int port;
		bool useMultiCast;

		long lastDataUpdate = Environment.TickCount;

        public UDPSpotter(string host = "127.0.0.1", int port = 20777, bool useMultiCast = true) {
            this.host = host;
            this.port = port;
            this.useMultiCast = useMultiCast;

            if (!this.connected)
				this.Connect();
		}

        private bool HasData()
        {
            if (receiver == null || receiver.GetSessionData() == null
                                 || receiver.GetLapData() == null
                                 || receiver.GetCarTelemetryData() == null
                                 || receiver.GetCarStatusData() == null
                                 || receiver.GetParticipantsData() == null
                                 || receiver.GetMotionData() == null
                                 || receiver.GetMotionExData() == null)
                return false;
				
            return true;
        }

		private void Connect() {
			if (!this.connected) {
				try {
                    if (receiver != null)
                        receiver.Stop();

                    receiver = new F125UDPReceiver.F125UDPReceiver(port, host, useMultiCast);

                    bool started = receiver.Start();

                    if (started)
                    {
                        started = false;

                        for (int i = 0; i <= 3 && !started; i++)
                            if (receiver.HasReceivedData())
                                started = true;
                            else
                                Thread.Sleep(200);
							
						/*
						if (started)
							for (int i = 0; i < 15; i++)
								if (HasData())
									break;
								else
									Thread.Sleep(100);
						*/
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

		const int YELLOW = 1;
		const int YELLOW_ALL = 2;
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
            var motion = receiver.GetMotionData();
			var lapData = receiver.GetLapData();
			var participants = receiver.GetParticipantsData();

			if (motion == null || lapData == null || participants == null)
				return false;

			int playerIdx = motion.Header.PlayerCarIndex;
			int numCars = participants.NumActiveCars;

			if (!hasLastCoordinates)
				lastCoordinates = new double[F125Constants.MaxCars, 3];

			// Player velocity
			var playerMotion = motion.CarMotion[playerIdx];
			double velocityX = playerMotion.WorldVelocityX;
			double velocityY = playerMotion.WorldVelocityY;
            double velocityZ = playerMotion.WorldVelocityZ;

			if ((velocityX != 0) || (velocityY != 0) || (velocityZ != 0))
			{
				// F1 25: X/Z = horizontal plane, Y = vertical/up
				double angle = vectorAngle(velocityX, velocityZ);

				double coordinateX = playerMotion.WorldPositionX;
				double coordinateY = playerMotion.WorldPositionY;
                double coordinateZ = playerMotion.WorldPositionZ;
				double speed = 0.0;

                int newSituation = CLEAR;
				bool skip = false;

                carBehind = false;
                carBehindLeft = false;
                carBehindRight = false;

                if (hasLastCoordinates)
				{
					speed = vectorLength(lastCoordinates[playerIdx, 0] - coordinateX,
										 lastCoordinates[playerIdx, 2] - coordinateZ);

					if (speed == 0)
						skip = true;
					else
						for (int i = 0; i < numCars; ++i)
						{
							if (i == playerIdx) continue;

							var otherLap = lapData.LapDataArr[i];

							// Skip cars not active or in pits
							if (otherLap.ResultStatus < 2) continue;
							if (otherLap.PitStatus != 0) continue;

							var otherMotion = motion.CarMotion[i];
							double otherSpeed = vectorLength(lastCoordinates[i, 0] - otherMotion.WorldPositionX,
															 lastCoordinates[i, 2] - otherMotion.WorldPositionZ);

							if (otherSpeed == 0)
								continue;

							if ((Math.Abs(speed - otherSpeed) / speed < 0.5) && sameHeading(lastCoordinates[playerIdx, 0] - coordinateX,
																							lastCoordinates[playerIdx, 2] - coordinateZ,
																							lastCoordinates[i, 0] - otherMotion.WorldPositionX,
																							lastCoordinates[i, 2] - otherMotion.WorldPositionZ))
							{
								bool faster = false;

								if (hasLastCoordinates)
									faster = otherSpeed > speed * 1.05;

								// checkCarPosition uses X/Z for horizontal, Y for vertical
								newSituation |= checkCarPosition(coordinateX, coordinateZ, coordinateY, angle, faster,
																 otherMotion.WorldPositionX, otherMotion.WorldPositionZ, otherMotion.WorldPositionY);

								if ((newSituation == THREE) && carBehind)
									break;
							}
						}
				}

				if (!skip)
				{
					for (int i = 0; i < numCars; ++i)
					{
						var cm = motion.CarMotion[i];

						lastCoordinates[i, 0] = cm.WorldPositionX;
						lastCoordinates[i, 1] = cm.WorldPositionY;
						lastCoordinates[i, 2] = cm.WorldPositionZ;
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

        double vehicleSpeed(CarMotionData cm)
        {
            return Math.Sqrt(cm.WorldVelocityX * cm.WorldVelocityX +
                             cm.WorldVelocityY * cm.WorldVelocityY +
                             cm.WorldVelocityZ * cm.WorldVelocityZ) * 3.6;
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
                        speeds.RemoveAt(i);

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

		void updateIdealLine(CarMotionData cm, double running, double speed) {
            idealLine[(int)Math.Round(running * (idealLine.Count - 1))].update((float)speed, cm.WorldPositionX, cm.WorldPositionZ);
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

        bool checkAccident()
        {
			bool accident = false;

			var session = receiver.GetSessionData();
			var motion = receiver.GetMotionData();
			var lapData = receiver.GetLapData();
			var participants = receiver.GetParticipantsData();

			if (session == null || motion == null || lapData == null || participants == null)
				return false;

			int playerIdx = session.Header.PlayerCarIndex;
			int numCars = participants.NumActiveCars;
			var playerLap = lapData.LapDataArr[playerIdx];

			if (playerLap.PitStatus != 0)
			{
				bestLapTime = int.MaxValue;
				return false;
			}

            List<SlowCarInfo> accidentsAhead = new List<SlowCarInfo>();
            List<SlowCarInfo> accidentsBehind = new List<SlowCarInfo>();
            List<SlowCarInfo> slowCarsAhead = new List<SlowCarInfo>();

            float trackLength = session.TrackLength;
			float playerRunning = (trackLength > 0) ? Math.Max(0, Math.Min(1, playerLap.LapDistance / trackLength)) : 0;

            if (idealLine.Count == 0)
			{
                idealLine.Capacity = (int)(trackLength / 4) + 1;

				for (int i = 0; i < (trackLength / 4); i++)
					idealLine.Add(new IdealLine());
			}

            if ((playerLap.LastLapTimeInMS > 0) && ((playerLap.LastLapTimeInMS * 1.002) < bestLapTime))
            {
                bestLapTime = playerLap.LastLapTimeInMS;

                for (int i = 0; i < idealLine.Count; i++)
                    idealLine[i].clear();
            }

			if (System.IO.File.Exists(semFileName))
			{
				System.IO.File.Delete(semFileName);

                for (int i = 0; i < idealLine.Count; i++)
                    idealLine[i].clear();
            }
	
			int currentCompletedLaps = Math.Max(0, playerLap.CurrentLapNum - 1);

			if (currentCompletedLaps > completedLaps) {
				if (numAccidents >= (trackLength / 1000)) {
					for (int i = 0; i < idealLine.Count; i++)
						idealLine[i].clear();
				}
				
				completedLaps = currentCompletedLaps;
				numAccidents = 0;
			}

            try
			{
				for (int i = 0; i < numCars; ++i)
				{
                    var carLap = lapData.LapDataArr[i];
					var carMotion = motion.CarMotion[i];
                    
					if (carLap.PitStatus != 0)
                        continue;
					if (carLap.ResultStatus < 2)
						continue;

                    double speed = vehicleSpeed(carMotion);
					float carRunning = (trackLength > 0) ? Math.Max(0, Math.Min(1, Math.Abs(carLap.LapDistance) / trackLength)) : 0;
                    double avgSpeed = getAverageSpeed(carRunning);

                    if (i != playerIdx)
                    {
                        if (speed >= 1)
						{
							if (speed < (avgSpeed / 2))
							{
								long distanceAhead = (long)(((carRunning > playerRunning) ? carRunning * trackLength
																						  : (carRunning * trackLength + trackLength)) -
															playerRunning * trackLength);

                                clearAverageSpeed(carRunning);

                                if (speed < (avgSpeed / 5))
								{
									if (distanceAhead < aheadAccidentDistance)
										accidentsAhead.Add(new SlowCarInfo(i + 1, distanceAhead));

									long distanceBehind = (long)(((carRunning < playerRunning) ? playerRunning * trackLength
																							   : (playerRunning * trackLength + trackLength)) -
																 carRunning * trackLength);

									if (distanceBehind < behindAccidentDistance)
										accidentsBehind.Add(new SlowCarInfo(i + 1, distanceBehind));
								}
								else if (distanceAhead < slowCarDistance)
									slowCarsAhead.Add(new SlowCarInfo(i + 1, distanceAhead));
							}
							else
								updateIdealLine(carMotion, carRunning, speed);
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

        bool checkFlagState()
		{
			var lapData = receiver.GetLapData();
			var session = receiver.GetSessionData();
			var status = receiver.GetCarStatusData();

			if (lapData == null || session == null || status == null)
				return false;

			int playerIdx = session.Header.PlayerCarIndex;
			var playerStatus = status.CarStatus[playerIdx];

			// F1 25: VehicleFIAFlags: 0=None, 1=Green, 2=Blue, 3=Yellow, 4=Red
			byte flags = (byte)playerStatus.VehicleFIAFlags;

			if (session.SafetyCarStatus == 1)
			{
				if ((lastFlagState & YELLOW_ALL) == 0)
				{
					SendSpotterMessage("yellowFlag:All");

					lastFlagState |= YELLOW_ALL;

					return true;
				}
			}
            else if ((waitYellowFlagState & YELLOW) != 0)
            {
                if (yellowCount > 50)
                {
                    if (flags != 3) // Not yellow
                        waitYellowFlagState &= ~YELLOW;

                    yellowCount = 0;

                    if ((waitYellowFlagState & YELLOW) != 0)
                    {
                        SendSpotterMessage("yellowFlag:Ahead");

                        waitYellowFlagState &= ~YELLOW;

                        return true;
                    }
                }
                else
                    yellowCount += 1;
            }
            else
                yellowCount = 0;

            if (flags == 2) // Blue flag
            {
                if ((lastFlagState & BLUE) == 0 && cycle > nextBlueFlag)
                {
                    nextBlueFlag = cycle + 400;

                    SendSpotterMessage("blueFlag");

                    lastFlagState |= BLUE;

                    return true;
                }
                else if (blueCount > 1000)
                {
                    lastFlagState &= ~BLUE;

                    blueCount = 0;
                }
                else
                    blueCount += 1;
            }
            else
            {
                lastFlagState &= ~BLUE;

                blueCount = 0;
            }

            if (flags == 3) // Yellow flag
            {
                if ((lastFlagState & YELLOW) == 0)
                {
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
			// No pit window support in F1 25 UDP

			return false;
		}

		bool greenFlagReported = false;

		bool greenFlag() {
            var session = receiver.GetSessionData();
            var eventData = receiver.GetEventData();

            if (eventData != null && eventData.EventStringCode == "LGOT" && session != null &&
									 (F125Constants.GetSessionType(session.SessionType) == "Race")) {
				greenFlagReported = true;
				
				SendSpotterMessage("greenFlag");
				
				Thread.Sleep(2000);
				
				return true;
			}
			else
				return false;
		}

		float lastTopSpeed = 0;
        int lastLaps = 0;

        void updateTopSpeed()
        {
			var motion = receiver.GetMotionData();
			var lapData = receiver.GetLapData();

			if (motion == null || lapData == null) return;

			int playerIdx = motion.Header.PlayerCarIndex;
            float speed = (float)vehicleSpeed(motion.CarMotion[playerIdx]);
			int currentLaps = Math.Max(0, lapData.LapDataArr[playerIdx].CurrentLapNum - 1);

            if (speed > lastTopSpeed)
                lastTopSpeed = speed;

            if (currentLaps > lastLaps)
            {
                SendSpotterMessage("speedUpdate:" + lastTopSpeed);

                lastTopSpeed = 0;
                lastLaps = currentLaps;
            }
        }

        double initialX = 0.0d;
		double initialY = 0.0d;
		int coordCount = 0;
		bool mapStarted = false;
		int mapLap = -1;

        bool writeCoordinates()
		{
			var motion = receiver.GetMotionData();
			var lapData = receiver.GetLapData();

			if (motion == null || lapData == null) return true;

			int playerIdx = motion.Header.PlayerCarIndex;
			var playerMotion = motion.CarMotion[playerIdx];
			var playerLap = lapData.LapDataArr[playerIdx];
			int currentLaps = Math.Max(0, playerLap.CurrentLapNum - 1);

            double velocityX = playerMotion.WorldVelocityX;
            double velocityY = playerMotion.WorldVelocityY;
            double velocityZ = playerMotion.WorldVelocityZ;

            if (!mapStarted)
                if (mapLap == -1)
                {
                    mapLap = currentLaps;

                    return true;
                }
                else if (currentLaps == mapLap)
                    return true;

			if ((velocityX != 0) || (velocityY != 0) || (velocityZ != 0))
			{
				// F1 25: X/Z for horizontal 2D map
				double coordinateX = playerMotion.WorldPositionX;
				double coordinateY = playerMotion.WorldPositionZ;

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

		void checkCoordinates()
		{
			if (DateTimeOffset.Now.ToUnixTimeMilliseconds() > (lastUpdate + 2000))
			{
				var motion = receiver.GetMotionData();

				if (motion == null) return;

				int playerIdx = motion.Header.PlayerCarIndex;
				var playerMotion = motion.CarMotion[playerIdx];

                double velocityX = playerMotion.WorldVelocityX;
                double velocityY = playerMotion.WorldVelocityY;
                double velocityZ = playerMotion.WorldVelocityZ;

                if ((velocityX != 0) || (velocityY != 0) || (velocityZ != 0))
				{
					double coordinateX = playerMotion.WorldPositionX;
					double coordinateY = playerMotion.WorldPositionZ;

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
        DateTime startTime;
        double lastRunning = -1;

        void collectCarTelemetry()
        {
			var session = receiver.GetSessionData();
			var motion = receiver.GetMotionData();
			var lapData = receiver.GetLapData();
			var telemetry = receiver.GetCarTelemetryData();
			
			if (session == null || motion == null || lapData == null) return;

			int playerIdx = session.Header.PlayerCarIndex;
			var playerLap = lapData.LapDataArr[playerIdx];
			var playerMotion = motion.CarMotion[playerIdx];

			int lastLap = Math.Max(0, playerLap.CurrentLapNum - 1);
            float trackLength = session.TrackLength;
			float running = (trackLength > 0) ? Math.Max(0, Math.Min(1, playerLap.LapDistance / trackLength)) : 0;

            if (lastLap < startTelemetryLap)
				return;

            try
            {
                if ((lastLap + 1) != telemetryLap)
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

					startTime = DateTime.Now;

                    telemetryFile = new StreamWriter(telemetryDirectory + "\\Lap " + telemetryLap + ".tmp", false);
					
					lastRunning = -1;
                }

				if (running > lastRunning)
                {
                    lastRunning = running;
					
					float throttle = 0, brake = 0, steer = 0;
					int gear = 0, rpm = 0;
					float speed = (float)vehicleSpeed(playerMotion);
					
					if (telemetry != null)
					{
						var pt = telemetry.CarTelemetry[playerIdx];
						throttle = pt.Throttle;
						brake = pt.Brake;
						steer = pt.Steer;
						gear = pt.Gear;
						rpm = (int)pt.EngineRPM;
					}

					telemetryFile.Write(lastRunning * trackLength + ";");
					telemetryFile.Write(throttle + ";");
					telemetryFile.Write(brake + ";");
					telemetryFile.Write(steer + ";");
					telemetryFile.Write(gear + ";");
					telemetryFile.Write(rpm + ";");
					telemetryFile.Write(speed + ";");
					telemetryFile.Write("n/a;");
					telemetryFile.Write("n/a;");
					telemetryFile.Write(playerMotion.GForceLongitudinal + ";");
					telemetryFile.Write(playerMotion.GForceLateral + ";");
					telemetryFile.Write(playerMotion.WorldPositionX + ";");
					telemetryFile.Write(playerMotion.WorldPositionZ + ";");

					TimeSpan difference = DateTime.Now.Subtract(startTime);

                    telemetryFile.WriteLine(difference.Minutes * 60000 + difference.Seconds * 1000 + difference.Milliseconds);

                    if (System.IO.File.Exists(telemetryDirectory + "\\Telemetry.cmd"))
                        try
                        {
                            StreamWriter file = new StreamWriter(telemetryDirectory + "\\Telemetry.section", true);

                            file.Write(lastRunning * trackLength + ";");
							file.Write(throttle + ";");
							file.Write(brake + ";");
							file.Write(steer + ";");
							file.Write(gear + ";");
							file.Write(rpm + ";");
							file.Write(speed + ";");

                            file.Write("n/a;");
                            file.Write("n/a;");

                            file.Write(playerMotion.GForceLongitudinal + ";");
                            file.Write(playerMotion.GForceLateral + ";");

                            file.Write(playerMotion.WorldPositionX + ";");
                            file.Write(playerMotion.WorldPositionZ + ";");

                            file.WriteLine(playerLap.CurrentLapTimeInMS);

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
				index++; // trackLength

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
			if (HasData()) {
				if ((lastDataUpdate + 2000) > receiver.GetLastUpdate())
                {
                    lastDataUpdate = receiver.GetLastUpdate();

                    return false;
                }
                else
                {
                    lastDataUpdate = receiver.GetLastUpdate();

                    return true;
                }
            }
            else
                return false;
        }

		public void Run(bool mapTrack, bool positionTrigger, string telemetryFolder = "") {
			bool running = true;
			long counter = 0;
			bool carTelemetry = (telemetryFolder.Length > 0);

			telemetryDirectory = telemetryFolder;

            while (true) {
				counter++;

				if (!connected)
					Connect();

				if (connected) {
					bool wait = true;

					if (active()) {
						if (startTelemetryLap == -1)
						{
							var lapData = receiver.GetLapData();
							if (lapData != null)
							{
								int playerIdx = lapData.Header.PlayerCarIndex;
								startTelemetryLap = Math.Max(0, lapData.LapDataArr[playerIdx].CurrentLapNum - 1) + 1;
							}
						}

						if (mapTrack) {
							if (!writeCoordinates())
								break;
						}
						else if (positionTrigger)
							checkCoordinates();
						else if (running) {
							if (!greenFlagReported && (counter > 8000))
								greenFlagReported = true;
								
							if (carTelemetry)
								collectCarTelemetry();
							else {
								var lapData = receiver.GetLapData();
								int playerIdx = (lapData != null) ? lapData.Header.PlayerCarIndex : 0;
								var playerLap = (lapData != null) ? lapData.LapDataArr[playerIdx] : null;
								bool inPits = (playerLap != null) && (playerLap.PitStatus != 0);
									
								if (!inPits) {
									updateTopSpeed();

									if (cycle > nextSpeedUpdate)
									{
										var motion = receiver.GetMotionData();
										float speed = 0;
										if (motion != null)
											speed = (float)vehicleSpeed(motion.CarMotion[playerIdx]);

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

									if (enabled && !greenFlag())
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
									carBehindReported = false;

									lastFlagState = 0;
								}
							}
						}

						if (carTelemetry || positionTrigger)
							Thread.Sleep(10);
						else if (wait)
							Thread.Sleep(50);
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
