/*
RF2 SHM Spotter main class.

Small parts original by: The Iron Wolf (vleonavicius@hotmail.com; thecrewchief.org)
*/
using RF2SHMSpotter.rFactor2Data;
using System;
using System.Collections.Generic;
using System.Diagnostics.Eventing.Reader;
using System.Drawing;
using System.IO;
using System.Reflection;
using System.Runtime.InteropServices;
using System.Runtime.InteropServices.ComTypes;
using System.Text;
using System.Threading;
using System.Windows.Forms;
using static RF2SHMSpotter.rFactor2Constants;
using static RF2SHMSpotter.rFactor2Constants.rF2GamePhase;
using static RF2SHMSpotter.rFactor2Constants.rF2PitState;
using static System.Net.WebRequestMethods;
using static System.Windows.Forms.VisualStyles.VisualStyleElement.TextBox;

namespace RF2SHMSpotter {
	public class SHMSpotter {
		bool connected = false;

		// Read buffers:
		MappedBuffer<rF2Scoring> scoringBuffer = new MappedBuffer<rF2Scoring>(rFactor2Constants.MM_SCORING_FILE_NAME, true /*partial*/, true /*skipUnchanged*/);
        MappedBuffer<rF2Extended> extendedBuffer = new MappedBuffer<rF2Extended>(rFactor2Constants.MM_EXTENDED_FILE_NAME, false /*partial*/, true /*skipUnchanged*/);
        MappedBuffer<rF2Telemetry> telemetryBuffer = new MappedBuffer<rF2Telemetry>(rFactor2Constants.MM_TELEMETRY_FILE_NAME, true /*partial*/, true /*skipUnchanged*/);

        // Marshalled views:
        rF2Scoring scoring;
        rF2Extended extended;
        rF2Telemetry telemetry;

        public SHMSpotter() {
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

		bool checkPositions(ref rF2VehicleScoring playerScoring)
		{
			if (!hasLastCoordinates)
				lastCoordinates = new double[scoring.mScoringInfo.mNumVehicles, 3];

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
				double angle = vectorAngle(velocityX, velocityZ);

				// Console.WriteLine(vectorAngle(lVelocityX, lVelocityY));
				// Console.WriteLine(angle);
				// Console.WriteLine();

				double coordinateX = playerScoring.mPos.x;
				double coordinateY = playerScoring.mPos.y;
				double coordinateZ = (- playerScoring.mPos.z);
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
						for (int i = 0; i < scoring.mScoringInfo.mNumVehicles; ++i)
						{
							var vehicle = scoring.mVehicles[i];

							if ((vehicle.mIsPlayer == 0) && (vehicle.mInPits == 0))
							{
								// Console.Write(i); Console.Write(" "); Console.Write(vehicle.mPos.x); Console.Write(" ");
								// Console.Write(vehicle.mPos.z); Console.Write(" "); Console.WriteLine(vehicle.mPos.y);

								double otherSpeed = vectorLength(lastCoordinates[i, 0] - vehicle.mPos.x,
																 lastCoordinates[i, 2] - (-vehicle.mPos.z));

								if (otherSpeed == 0)
									continue;

								// Console.WriteLine(speed + " - " + otherSpeed);

								if ((Math.Abs(speed - otherSpeed) / speed < 0.5) && sameHeading(lastCoordinates[carID, 0] - coordinateX,
																								lastCoordinates[carID, 2] - coordinateZ,
																								lastCoordinates[i, 0] - vehicle.mPos.x,
																								lastCoordinates[i, 2] - (-vehicle.mPos.z)))
								{
									bool faster = false;

									if (hasLastCoordinates)
										faster = otherSpeed > speed * 1.05;

									newSituation |= checkCarPosition(coordinateX, coordinateZ, coordinateY, angle, faster,
																	 vehicle.mPos.x, (-vehicle.mPos.z), vehicle.mPos.y);

									if ((newSituation == THREE) && carBehind)
										break;
								}
							}
					}
				}

				if (!skip)
				{
					for (int i = 0; i < scoring.mScoringInfo.mNumVehicles; ++i)
					{
						var position = scoring.mVehicles[i].mPos;

						lastCoordinates[i, 0] = position.x;
						lastCoordinates[i, 1] = position.y;
						lastCoordinates[i, 2] = (-position.z);
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

        double vehicleSpeed(ref rF2VehicleScoring vehicle)
        {
            rF2Vec3 localVel = vehicle.mLocalVel;

            return Math.Sqrt(localVel.x * localVel.x + localVel.y * localVel.y + localVel.z * localVel.z) * 3.6;
        }

        double vehicleSpeed(ref rF2VehicleTelemetry vehicle)
        {
            rF2Vec3 localVel = vehicle.mLocalVel;

            return Math.Sqrt(localVel.x * localVel.x + localVel.y * localVel.y + localVel.z * localVel.z) * 3.6;
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

		void updateIdealLine(ref rF2VehicleScoring vehicle, double running, double speed) {
            idealLine[(int)Math.Round(running * (idealLine.Count - 1))].update((float)speed, (float)vehicle.mPos.x, (float)vehicle.mPos.z);
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

        bool checkAccident(ref rF2VehicleScoring playerScoring)
        {
			bool accident = false;

			if (playerScoring.mInPits != 0)
			{
				bestLapTime = int.MaxValue;

				return false;
			}

            List<SlowCarInfo> accidentsAhead = new List<SlowCarInfo>();
            List<SlowCarInfo> accidentsBehind = new List<SlowCarInfo>();
            List<SlowCarInfo> slowCarsAhead = new List<SlowCarInfo>();

			if (idealLine.Count == 0)
			{
				idealLine.Capacity = (int)(scoring.mScoringInfo.mLapDist / 4) + 1;

				for (int i = 0; i < (scoring.mScoringInfo.mLapDist / 4); i++)
					idealLine.Add(new IdealLine());
			}

            if ((playerScoring.mLastLapTime > 0) && ((playerScoring.mLastLapTime * 1.002) < bestLapTime))
            {
                bestLapTime = playerScoring.mLastLapTime;

                for (int i = 0; i < idealLine.Count; i++)
                    idealLine[i].clear();
            }

			if (System.IO.File.Exists(semFileName))
			{
				System.IO.File.Delete(semFileName);

                for (int i = 0; i < idealLine.Count; i++)
                    idealLine[i].clear();
            }
	
			if (playerScoring.mTotalLaps > completedLaps) {
				if (numAccidents >= (scoring.mScoringInfo.mLapDist / 1000)) {
					for (int i = 0; i < idealLine.Count; i++)
						idealLine[i].clear();
				}
				
				completedLaps = playerScoring.mTotalLaps;
				numAccidents = 0;
			}

            try
			{
				for (int i = 0; i < scoring.mScoringInfo.mNumVehicles; ++i)
				{
                    ref rF2VehicleScoring vehicle = ref scoring.mVehicles[i];
                    
					if (vehicle.mInPits != 0)
                        continue;

                    double speed = vehicleSpeed(ref vehicle);
                    double running = Math.Max(0, Math.Min(1, Math.Abs(vehicle.mLapDist / scoring.mScoringInfo.mLapDist)));
                    double avgSpeed = getAverageSpeed(running);

                    if (vehicle.mIsPlayer != 1)
                    {
                        if (speed >= 1)
						{
							if (speed < (avgSpeed / 2))
							{
								long distanceAhead = (long)(((vehicle.mLapDist > playerScoring.mLapDist) ? vehicle.mLapDist
																										 : (vehicle.mLapDist + scoring.mScoringInfo.mLapDist)) - playerScoring.mLapDist);

                                clearAverageSpeed(running);

                                if (speed < (avgSpeed / 5))
								{
									if (distanceAhead < aheadAccidentDistance)
										accidentsAhead.Add(new SlowCarInfo(i + 1, distanceAhead));

									long distanceBehind = (long)(((vehicle.mLapDist < playerScoring.mLapDist) ? playerScoring.mLapDist
																											  : (playerScoring.mLapDist + scoring.mScoringInfo.mLapDist)) - vehicle.mLapDist);

									if (distanceBehind < behindAccidentDistance)
										accidentsBehind.Add(new SlowCarInfo(i + 1, distanceBehind));
								}
								else if (distanceAhead < slowCarDistance)
									slowCarsAhead.Add(new SlowCarInfo(i + 1, distanceAhead));
							}
							else
								updateIdealLine(ref vehicle, running, speed);
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

        bool checkFlagState(ref rF2VehicleScoring playerScoring)
		{
			if ((waitYellowFlagState & YELLOW_SECTOR_1) != 0 || (waitYellowFlagState & YELLOW_SECTOR_2) != 0 || (waitYellowFlagState & YELLOW_SECTOR_3) != 0)
			{
				yellowCount += 1;

				if (yellowCount > 50)
				{
					if (scoring.mScoringInfo.mSectorFlag[0] == 0)
						waitYellowFlagState &= ~YELLOW_SECTOR_1;

					if (scoring.mScoringInfo.mSectorFlag[1] == 0)
						waitYellowFlagState &= ~YELLOW_SECTOR_2;

					if (scoring.mScoringInfo.mSectorFlag[1] == 0)
						waitYellowFlagState &= ~YELLOW_SECTOR_3;

					yellowCount = 0;

					if ((waitYellowFlagState & YELLOW_SECTOR_1) != 0)
					{
						SendSpotterMessage("yellowFlag:Sector;1");

						waitYellowFlagState &= ~YELLOW_SECTOR_1;

						return true;
					}

					if ((waitYellowFlagState & YELLOW_SECTOR_2) != 0)
					{
						SendSpotterMessage("yellowFlag:Sector;2");

						waitYellowFlagState &= ~YELLOW_SECTOR_2;

						return true;
					}

					if ((waitYellowFlagState & YELLOW_SECTOR_3) != 0)
					{
						SendSpotterMessage("yellowFlag:Sector;3");

						waitYellowFlagState &= ~YELLOW_SECTOR_3;

						return true;
					}
				}
			}
			else
				yellowCount = 0;

			if (playerScoring.mFlag == (byte)rF2PrimaryFlag.Blue)
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

			/*
			if (scoring.mScoringInfo.mGamePhase == (byte)rF2GamePhase.FullCourseYellow)
			{
				if ((lastFlagState & YELLOW_FULL) == 0)
				{
					SendSpotterMessage("yellowFlag:Full");

					lastFlagState |= YELLOW_FULL;

					return true;
				}
			}
			*/
			if ((scoring.mScoringInfo.mSectorFlag[0] == 1) && (scoring.mScoringInfo.mSectorFlag[1] == 1) && (scoring.mScoringInfo.mSectorFlag[2] == 1))
			{
				if ((lastFlagState & YELLOW_ALL) == 0)
				{
					SendSpotterMessage("yellowFlag:All");

					lastFlagState |= YELLOW_ALL;

					return true;
				}
			}
			else if (scoring.mScoringInfo.mSectorFlag[0] == 1)
			{
				if ((lastFlagState & YELLOW_SECTOR_1) == 0)
				{
					/*
					SendSpotterMessage("yellowFlag:Sector;1");

					lastFlagState |= YELLOW_SECTOR_1;

					return true;
					*/

					lastFlagState |= YELLOW_SECTOR_1;
					waitYellowFlagState |= YELLOW_SECTOR_1;
					yellowCount = 0;
				}
			}
			else if (scoring.mScoringInfo.mSectorFlag[1] == 1)
			{
				if ((lastFlagState & YELLOW_SECTOR_2) == 0)
				{
					/*
					SendSpotterMessage("yellowFlag:Sector;2");

					lastFlagState |= YELLOW_SECTOR_2;

					return true;
					*/

					lastFlagState |= YELLOW_SECTOR_2;
					waitYellowFlagState |= YELLOW_SECTOR_2;
					yellowCount = 0;
				}
			}
			else if (scoring.mScoringInfo.mSectorFlag[2] == 1)
			{
				if ((lastFlagState & YELLOW_SECTOR_3) == 0)
				{
					/*
					SendSpotterMessage("yellowFlag:Sector;3");

					lastFlagState |= YELLOW_SECTOR_3;

					return true;
					*/

					lastFlagState |= YELLOW_SECTOR_2;
					waitYellowFlagState |= YELLOW_SECTOR_2;
					yellowCount = 0;
				}
			}
			else
			{
				if ((lastFlagState & YELLOW_SECTOR_1) != 0 || (lastFlagState & YELLOW_SECTOR_2) != 0 ||
					(lastFlagState & YELLOW_SECTOR_3) != 0)
				{
					if (waitYellowFlagState != lastFlagState)
						SendSpotterMessage("yellowFlag:Clear");

					lastFlagState &= ~YELLOW_ALL;
					waitYellowFlagState &= ~YELLOW_ALL;
					yellowCount = 0;

					return true;
				}
			}

			return false;
		}

		bool checkPitWindow(ref rF2VehicleScoring playerScoring)
		{
			// No support by rFactor 2

			return false;
		}

		bool greenFlagReported = false;

		bool greenFlag() {
			if (!greenFlagReported && (scoring.mScoringInfo.mGamePhase == (byte)rF2GamePhase.GreenFlag)
								   && (scoring.mScoringInfo.mSession >= 10 && scoring.mScoringInfo.mSession <= 13)) {
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

        void updateTopSpeed(ref rF2VehicleScoring playerScoring)
        {
            float speed = (float)vehicleSpeed(ref playerScoring);

            if (speed > lastTopSpeed)
                lastTopSpeed = speed;

            if (playerScoring.mTotalLaps > lastLaps)
            {
                SendSpotterMessage("speedUpdate:" + lastTopSpeed);

                lastTopSpeed = 0;
                lastLaps = playerScoring.mTotalLaps;
            }
        }

        double initialX = 0.0d;
		double initialY = 0.0d;
		int coordCount = 0;
		bool mapStarted = false;
		int mapLap = -1;

		bool writeCoordinates(ref rF2VehicleScoring playerScoring)
		{
			double lVelocityX = playerScoring.mLocalVel.x;
			double lVelocityY = playerScoring.mLocalVel.y;
			double lVelocityZ = playerScoring.mLocalVel.z;

            if (!mapStarted)
                if (mapLap == -1)
                {
                    mapLap = playerScoring.mTotalLaps;

                    return true;
                }
                else if (playerScoring.mTotalLaps == mapLap)
                    return true;

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
				double coordinateY = (-playerScoring.mPos.z);

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

		void checkCoordinates(ref rF2VehicleScoring playerScoring)
		{
			if (DateTimeOffset.Now.ToUnixTimeMilliseconds() > (lastUpdate + 2000))
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
		double lastRunning = -1;

        void collectCarTelemetry(ref rF2VehicleScoring playerScoring)
        {
            int playerID = playerScoring.mID;

            try
            {
                if ((playerScoring.mTotalLaps + 1) != telemetryLap)
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

                    telemetryLap = (playerScoring.mTotalLaps + 1);

                    telemetryFile = new StreamWriter(telemetryDirectory + "\\Lap " + telemetryLap + ".tmp", false);
					
					lastRunning = -1;
                }

				if (playerScoring.mLapDist > lastRunning)
                {
                    ref rF2VehicleTelemetry vehicle = ref GetPlayerTelemetry(playerID, ref telemetry);

                    lastRunning = playerScoring.mLapDist;
					
					telemetryFile.Write(playerScoring.mLapDist + ";");
					telemetryFile.Write((float)vehicle.mFilteredThrottle + ";");
					telemetryFile.Write((float)vehicle.mFilteredBrake + ";");
					telemetryFile.Write((float)vehicle.mFilteredSteering + ";");
					telemetryFile.Write((float)vehicle.mGear + ";");
					telemetryFile.Write((float)vehicle.mEngineRPM + ";");
					telemetryFile.Write(vehicleSpeed(ref playerScoring) + ";");

					telemetryFile.Write("n/a;");
					telemetryFile.Write("n/a;");

					telemetryFile.Write((-playerScoring.mLocalAccel.z / 9.807f) + ";");
					telemetryFile.Write((playerScoring.mLocalAccel.x / 9.807f) + ";");

					telemetryFile.Write(playerScoring.mPos.x + ";");
					telemetryFile.Write(-playerScoring.mPos.z + ";");

					telemetryFile.WriteLine((vehicle.mElapsedTime - vehicle.mLapStartET) * 1000);

                    if (System.IO.File.Exists(telemetryDirectory + "\\Telemetry.cmd"))
                        try
                        {
                            StreamWriter file = new StreamWriter(telemetryDirectory + "\\Telemetry.section", true);

                            file.Write(playerScoring.mLapDist + ";");
                            file.Write((float)vehicle.mFilteredThrottle + ";");
                            file.Write((float)vehicle.mFilteredBrake + ";");
                            file.Write((float)vehicle.mFilteredSteering + ";");
                            file.Write((float)vehicle.mGear + ";");
                            file.Write((float)vehicle.mEngineRPM + ";");
                            file.Write(vehicleSpeed(ref playerScoring) + ";");

                            file.Write("n/a;");
                            file.Write("n/a;");

                            file.Write((-playerScoring.mLocalAccel.z / 9.807f) + ";");
                            file.Write((playerScoring.mLocalAccel.x / 9.807f) + ";");

                            file.Write(playerScoring.mPos.x + ";");
                            file.Write(-playerScoring.mPos.z + ";");

                            file.WriteLine((vehicle.mElapsedTime - vehicle.mLapStartET) * 1000);

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

        bool started = false;

        public bool active() {
			if (started)
				return true;
			else if ((scoring.mScoringInfo.mSession >= 10 && scoring.mScoringInfo.mSession <= 13)
						&& (scoring.mScoringInfo.mGamePhase != (byte)rF2GamePhase.GreenFlag) && (GetPlayerScoring(ref scoring).mTotalLaps == 0))
				return false;
			
			started = true;

			return true;
		}

		public void Run(bool mapTrack, bool positionTrigger, string telemetryFolder = "") {
            bool running = false;
			int countdown = 4000;
			long counter = 0;
			bool carTelemetry = (telemetryFolder.Length > 0);

			telemetryDirectory = telemetryFolder;

            while (true) {
				counter++;

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
						bool wait = true;

						ref rF2VehicleScoring playerScoring = ref GetPlayerScoring(ref scoring);

                        if (mapTrack)
						{
							if (!writeCoordinates(ref playerScoring))
								break;
						}
						else if (positionTrigger)
							checkCoordinates(ref playerScoring);
						else if (active())
						{
							bool startGo = (scoring.mScoringInfo.mGamePhase == (byte)rF2GamePhase.GreenFlag);

							if (!greenFlagReported && (counter > 8000))
								greenFlagReported = true;

							if (!running)
							{
								countdown -= 1;

								if (startGo || (countdown <= 0))
									running = true;
							}

							if (scoring.mScoringInfo.mGamePhase <= (byte)GridWalk || scoring.mScoringInfo.mGamePhase == (byte)PausedOrHeartbeat)
								running = false;

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
				else
					Thread.Sleep(1000);
            }
		}
    }
}
