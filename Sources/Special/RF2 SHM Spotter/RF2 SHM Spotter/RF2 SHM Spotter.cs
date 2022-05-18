/*
RF2 SHM Spotter main class.

Small parts original by: The Iron Wolf (vleonavicius@hotmail.com; thecrewchief.org)
*/
using RF2SHMSpotter.rFactor2Data;
using System;
using System.Runtime.InteropServices;
using System.Text;
using System.Threading;
using static RF2SHMSpotter.rFactor2Constants;
using static RF2SHMSpotter.rFactor2Constants.rF2GamePhase;
using static RF2SHMSpotter.rFactor2Constants.rF2PitState;

namespace RF2SHMSpotter {
	public class SHMSpotter {
		bool connected = false;

		// Read buffers:
		MappedBuffer<rF2Scoring> scoringBuffer = new MappedBuffer<rF2Scoring>(rFactor2Constants.MM_SCORING_FILE_NAME, true /*partial*/, true /*skipUnchanged*/);
		MappedBuffer<rF2Extended> extendedBuffer = new MappedBuffer<rF2Extended>(rFactor2Constants.MM_EXTENDED_FILE_NAME, false /*partial*/, true /*skipUnchanged*/);

		// Marshalled views:
		rF2Scoring scoring;
		rF2Extended extended;

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

		public static rF2VehicleTelemetry GetPlayerTelemetry(int id, ref rF2Telemetry telemetry) {
			var playerVehTelemetry = new rF2VehicleTelemetry();

			for (int i = 0; i < telemetry.mNumVehicles; ++i) {
				var vehicle = telemetry.mVehicles[i];

				if (vehicle.mID == id) {
					playerVehTelemetry = vehicle;

					break;
				}
			}

			return playerVehTelemetry;
		}

		private void Connect() {
			if (!this.connected) {
				try {
					// Extended buffer is the last one constructed, so it is an indicator RF2SM is ready.
					this.extendedBuffer.Connect();
					this.scoringBuffer.Connect();

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

			this.connected = false;
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

		void SendMessage(string message)
		{
			int winHandle = FindWindowEx(0, 0, null, "Race Spotter.exe");

			if (winHandle == 0)
				FindWindowEx(0, 0, null, "Race Spotter.ahk");

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

		const int YELLOW_SECTOR_1 = 1;
		const int YELLOW_SECTOR_2 = 2;
		const int YELLOW_SECTOR_3 = 4;

		const int YELLOW_FULL = (YELLOW_SECTOR_1 + YELLOW_SECTOR_2 + YELLOW_SECTOR_3);

		const int BLUE = 16;

		int blueCount = 0;

		int lastFlagState = 0;

		string computeAlert(int newSituation) {
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
					return (transX > 0) ? RIGHT : LEFT;
				else
				{
					if (transY < 0)
					{
						carBehind = true;

						if ((faster && transY < longitudinalDistance * 1.5) ||
							(transY < longitudinalDistance * 2 && Math.Abs(transX) > lateralDistance / 2))
							if (transX > 0)
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
			double velocityZ = ori[RowZ].x * lVelocityX + ori[RowZ].y * lVelocityY + ori[RowZ].z * lVelocityZ;

			if ((velocityX != 0) || (velocityY != 0) || (velocityZ != 0))
			{
				double angle = vectorAngle(velocityX, velocityZ);

				// Console.WriteLine(vectorAngle(lVelocityX, lVelocityY));
				// Console.WriteLine(angle);
				// Console.WriteLine();

				double coordinateX = playerScoring.mPos.x;
				double coordinateY = playerScoring.mPos.y;
				double coordinateZ = playerScoring.mPos.z;
				double speed = 0.0;

				if (hasLastCoordinates)
					speed = vectorLength(lastCoordinates[carID, 0] - coordinateX, lastCoordinates[carID, 2] - coordinateZ);

				int newSituation = CLEAR;

				carBehind = false;
				carBehindLeft = false;
				carBehindRight = false;

				for (int i = 0; i < scoring.mScoringInfo.mNumVehicles; ++i)
				{
					var vehicle = scoring.mVehicles[i];

					if (vehicle.mIsPlayer == 0)
					{
						// Console.Write(i); Console.Write(" "); Console.Write(vehicle.mPos.x); Console.Write(" ");
						// Console.Write(vehicle.mPos.z); Console.Write(" "); Console.WriteLine(vehicle.mPos.y);

						bool faster = false;

						if (hasLastCoordinates)
							faster = vectorLength(lastCoordinates[i, 0] - vehicle.mPos.x,
												  lastCoordinates[i, 2] - vehicle.mPos.z) > speed * 1.01;

						newSituation |= checkCarPosition(coordinateX, coordinateZ, coordinateY, angle, faster,
														 vehicle.mPos.x, vehicle.mPos.z, vehicle.mPos.y);

						if ((newSituation == THREE) && carBehind)
							break;
					}
				}

				for (int i = 0; i < scoring.mScoringInfo.mNumVehicles; ++i)
				{
					var position = scoring.mVehicles[i].mPos;

					lastCoordinates[i, 0] = position.x;
					lastCoordinates[i, 1] = position.y;
					lastCoordinates[i, 2] = position.z;
				}

				hasLastCoordinates = true;

				string alert = computeAlert(newSituation);

				if (alert != noAlert)
				{
					if (alert != "Hold")
						carBehindReported = false;

					SendMessage("proximityAlert:" + alert);

					return true;
				}
				else if (carBehind)
				{
					if (!carBehindReported)
					{
						carBehindReported = true;

						SendMessage(carBehindLeft ? "proximityAlert:BehindLeft" :
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
				carBehindReported = false;
			}

			return false;
		}

		bool checkFlagState(ref rF2VehicleScoring playerScoring)
		{
			if (playerScoring.mFlag == (byte)rF2PrimaryFlag.Blue)
			{
				if ((lastFlagState & BLUE) == 0)
				{
					SendMessage("blueFlag");

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

			if (scoring.mScoringInfo.mGamePhase == (byte)rF2GamePhase.FullCourseYellow)
			{
				if ((lastFlagState & YELLOW_FULL) == 0)
				{
					SendMessage("yellowFlag:Full");

					lastFlagState |= YELLOW_FULL;

					return true;
				}
			}
			else if (scoring.mScoringInfo.mSectorFlag[0] == 1)
			{
				if ((lastFlagState & YELLOW_SECTOR_1) == 0)
				{
					SendMessage("yellowFlag:Sector;1");

					lastFlagState |= YELLOW_SECTOR_1;

					return true;
				}
			}
			else if (scoring.mScoringInfo.mSectorFlag[1] == 1)
			{
				if ((lastFlagState & YELLOW_SECTOR_2) == 0)
				{
					SendMessage("yellowFlag:Sector;2");

					lastFlagState |= YELLOW_SECTOR_2;

					return true;
				}
			}
			else if (scoring.mScoringInfo.mSectorFlag[2] == 1)
			{
				if ((lastFlagState & YELLOW_SECTOR_3) == 0)
				{
					SendMessage("yellowFlag:Sector;3");

					lastFlagState |= YELLOW_SECTOR_3;

					return true;
				}
			}
			else
			{
				if ((lastFlagState & YELLOW_SECTOR_1) != 0 || (lastFlagState & YELLOW_SECTOR_2) != 0 ||
					(lastFlagState & YELLOW_SECTOR_3) != 0)
				{
					SendMessage("yellowFlag:Clear");

					lastFlagState &= ~YELLOW_FULL;

					return true;
				}
			}

			return false;
		}

		void checkPitWindow(ref rF2VehicleScoring playerScoring)
		{
			// No support by rFactor 2
		}

		public void Run() {
			bool running = false;
			int countdown = 4000;

			while (true) {
				if (!connected)
					Connect();

				if (connected)
				{
					try
					{
						extendedBuffer.GetMappedData(ref extended);
						scoringBuffer.GetMappedData(ref scoring);
					}
					catch (Exception)
					{
						this.Disconnect();
					}

					if (connected) {
						if (!running)
							if ((scoring.mScoringInfo.mGamePhase == (byte)rF2GamePhase.GreenFlag) || (countdown-- <= 0))
								running = true;

						if (running)
						{
							rF2VehicleScoring playerScoring = GetPlayerScoring(ref scoring);

							if (extended.mSessionStarted != 0 && scoring.mScoringInfo.mGamePhase < (byte)SessionStopped &&
								playerScoring.mPitState < (byte)Entering)
							{
								if (!checkFlagState(ref playerScoring) && !checkPositions(ref playerScoring))
									checkPitWindow(ref playerScoring);
							}
							else
							{
								lastSituation = CLEAR;
								carBehind = false;
								carBehindReported = false;

								lastFlagState = 0;
							}
						}

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
