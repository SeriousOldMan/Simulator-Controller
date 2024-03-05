/*
RF2 SHM Provider main class.

Small parts original by: The Iron Wolf (vleonavicius@hotmail.com; thecrewchief.org)
*/
using SHMConnector.rFactor2Data;
using System;
using System.Diagnostics.Eventing.Reader;
using System.Globalization;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading;
using static SHMConnector.rFactor2Constants;
using static SHMConnector.rFactor2Constants.rF2GamePhase;
using static SHMConnector.rFactor2Constants.rF2PitState;

namespace SHMConnector {
	public class SHMConnector {
		bool connected = false;

		// Read buffers:
		MappedBuffer<rF2Telemetry> telemetryBuffer = new MappedBuffer<rF2Telemetry>(rFactor2Constants.MM_TELEMETRY_FILE_NAME, true /*partial*/, true /*skipUnchanged*/);
		MappedBuffer<rF2Scoring> scoringBuffer = new MappedBuffer<rF2Scoring>(rFactor2Constants.MM_SCORING_FILE_NAME, true /*partial*/, true /*skipUnchanged*/);
		MappedBuffer<rF2Rules> rulesBuffer = new MappedBuffer<rF2Rules>(rFactor2Constants.MM_RULES_FILE_NAME, true /*partial*/, true /*skipUnchanged*/);
		MappedBuffer<rF2ForceFeedback> forceFeedbackBuffer = new MappedBuffer<rF2ForceFeedback>(rFactor2Constants.MM_FORCE_FEEDBACK_FILE_NAME, false /*partial*/, false /*skipUnchanged*/);
		MappedBuffer<rF2Graphics> graphicsBuffer = new MappedBuffer<rF2Graphics>(rFactor2Constants.MM_GRAPHICS_FILE_NAME, false /*partial*/, false /*skipUnchanged*/);
		MappedBuffer<rF2PitInfo> pitInfoBuffer = new MappedBuffer<rF2PitInfo>(rFactor2Constants.MM_PITINFO_FILE_NAME, false /*partial*/, true /*skipUnchanged*/);
		MappedBuffer<rF2Weather> weatherBuffer = new MappedBuffer<rF2Weather>(rFactor2Constants.MM_WEATHER_FILE_NAME, false /*partial*/, true /*skipUnchanged*/);
		MappedBuffer<rF2Extended> extendedBuffer = new MappedBuffer<rF2Extended>(rFactor2Constants.MM_EXTENDED_FILE_NAME, false /*partial*/, true /*skipUnchanged*/);

		// Write buffers:
		MappedBuffer<rF2HWControl> hwControlBuffer = new MappedBuffer<rF2HWControl>(rFactor2Constants.MM_HWCONTROL_FILE_NAME);
		MappedBuffer<rF2WeatherControl> weatherControlBuffer = new MappedBuffer<rF2WeatherControl>(rFactor2Constants.MM_WEATHER_CONTROL_FILE_NAME);
		MappedBuffer<rF2RulesControl> rulesControlBuffer = new MappedBuffer<rF2RulesControl>(rFactor2Constants.MM_RULES_CONTROL_FILE_NAME);
		MappedBuffer<rF2PluginControl> pluginControlBuffer = new MappedBuffer<rF2PluginControl>(rFactor2Constants.MM_PLUGIN_CONTROL_FILE_NAME);

		// Marshalled views:
		rF2Telemetry telemetry;
		rF2Scoring scoring;
		rF2Rules rules;
		rF2ForceFeedback forceFeedback;
		rF2Graphics graphics;
		rF2PitInfo pitInfo;
		rF2Weather weather;
		rF2Extended extended;

		// Marashalled output views:
		rF2HWControl hwControl;
		rF2WeatherControl weatherControl;
		rF2RulesControl rulesControl;
		rF2PluginControl pluginControl;

		public SHMConnector() {
		}

		public bool Open()
		{
			if (!this.connected)
				this.Connect();

			return connected;
		}

        public void Close()
		{
			this.Disconnect();
		}

        public string Call(string request)
        {
            Thread.CurrentThread.CurrentCulture = CultureInfo.CreateSpecificCulture("en-US");

            try
            {
                extendedBuffer.GetMappedData(ref extended);
                scoringBuffer.GetMappedData(ref scoring);
                telemetryBuffer.GetMappedData(ref telemetry);
                rulesBuffer.GetMappedData(ref rules);
                forceFeedbackBuffer.GetMappedDataUnsynchronized(ref forceFeedback);
                graphicsBuffer.GetMappedDataUnsynchronized(ref graphics);
                pitInfoBuffer.GetMappedData(ref pitInfo);
                weatherBuffer.GetMappedData(ref weather);
            }
            catch (Exception)
            {
                this.Disconnect();

                return "";
            }

            if (request.StartsWith("Pitstop"))
            {
				request = request.Split(new char[] { '=' }, 2)[1];

                string[] arguments = request.Split('=');
                string[] message = arguments[2].Split(':');

                if (arguments[0] == "Set")
                    this.ExecutePitstopSetCommand(message[0], message[1].Split(';'));
                else if ((arguments[0] == "Increase") || (arguments[0] == "Decrease"))
                    this.ExecutePitstopChangeCommand(message[0], arguments[0], message[1].Split(';'));

				return "";
            }
            else if (request.StartsWith("Setup"))
                return this.ReadSetup();
            else if (request.StartsWith("Standings"))
                return this.ReadStandings();
            else
                return this.ReadData(); // + this.ReadSetup();
        }

        public string GetForname(byte[] name) {
			string forName = GetStringFromBytes(name);

			if (forName.Contains(" ")) {
				string[] names = forName.Split(' ');

				return names[0];
			}
			else
				return forName;
		}

		public string GetSurname(byte[] name) {
			string forName = GetStringFromBytes(name);

			if (forName.Contains(" "))
				return string.Join(" ", forName.Split(' ').Skip(1));
			else
				return "";
		}

		public string GetNickname(byte[] name) {
			string forName = GetStringFromBytes(name);

			if (forName.Contains(" ")) {
				string[] names = forName.Split(' ');

				return names[0].Substring(0, 1) + names[1].Substring(0, 1);
			}
			else
				return "";
		}

		public string GetCarName(string carClass, string carName)
        {
			carName = carName.Trim();

            if (carName.Length > 0)
            {
                if (carName[0] == '#')
                {
                    char[] delims = { ' ' };
                    string[] parts = carName.Split(delims, 2);

                    if (parts.Length > 1)
                        carName = parts[1].Trim();
                }
                else if (carName.Contains("#"))
                    carName = carName.Split('#')[0].Trim();
            }
            else
                carName = carClass;

            return carName;
		}

		public string GetCarNr(int id, string carClass, string carName)
		{
            carName = carName.Trim();

			if (carName.Length > 0)
			{
				if (carName[0] == '#')
				{
					char[] delims = { ' ' };
					string[] parts = carName.Split(delims, 2);

					return parts[0].Split('#')[1].Trim();
				}
				else if (carName.Contains("#"))
					return carName.Split('#')[1].Trim().Split(' ')[0].Trim();
				else
					return (id + 1).ToString();
			}
			else
                return (id + 1).ToString();
        }

		public string ReadStandings()
		{
			StringWriter strWriter = new StringWriter();
            rF2VehicleScoring playerVehicle = GetPlayerScoring(ref scoring);

            strWriter.WriteLine("[Position Data]");

			if (connected)
			{
				strWriter.Write("Car.Count="); strWriter.WriteLine(scoring.mScoringInfo.mNumVehicles);

				for (int i = 1; i <= scoring.mScoringInfo.mNumVehicles; ++i)
				{
					rF2VehicleScoring vehicle = scoring.mVehicles[i - 1];

					strWriter.Write("Car."); strWriter.Write(i); strWriter.Write(".Position="); strWriter.WriteLine(vehicle.mPlace);

					strWriter.Write("Car."); strWriter.Write(i); strWriter.Write(".Laps="); strWriter.WriteLine(vehicle.mTotalLaps);
					strWriter.Write("Car."); strWriter.Write(i); strWriter.Write(".Lap.Running="); strWriter.WriteLine(vehicle.mLapDist / scoring.mScoringInfo.mLapDist);
					strWriter.Write("Car."); strWriter.Write(i); strWriter.Write(".Lap.Running.Valid="); strWriter.WriteLine(vehicle.mCountLapFlag == 2 ? "true" : "false");

					int lapTime = (int)Math.Round(Normalize(vehicle.mLastLapTime) * 1000);

					if (lapTime == 0)
						lapTime = (int)Math.Round(Normalize(vehicle.mBestLapTime) * 1000);

					int sector1Time = (int)Math.Round(Normalize(vehicle.mLastSector1) * 1000);
					int sector2Time = (int)Math.Round(Normalize(vehicle.mLastSector2) * 1000);
					int sector3Time = lapTime - sector1Time - sector2Time;

					strWriter.Write("Car."); strWriter.Write(i); strWriter.Write(".Time="); strWriter.WriteLine(lapTime);
					strWriter.Write("Car."); strWriter.Write(i); strWriter.Write(".Time.Sectors="); strWriter.WriteLine(sector1Time + "," + sector2Time + "," + sector3Time);

					string carClass = GetStringFromBytes(vehicle.mVehicleClass);
					string carModel = GetCarName(carClass, GetStringFromBytes(vehicle.mVehicleName));
					string carNr = GetCarNr(vehicle.mID, carClass, GetStringFromBytes(vehicle.mVehicleName));

					strWriter.Write("Car."); strWriter.Write(i); strWriter.Write(".Nr="); strWriter.WriteLine(carNr);
					strWriter.Write("Car."); strWriter.Write(i); strWriter.Write(".Class="); strWriter.WriteLine(carClass);
					strWriter.Write("Car."); strWriter.Write(i); strWriter.Write(".Car="); strWriter.WriteLine(carModel);

					strWriter.Write("Car."); strWriter.Write(i); strWriter.Write(".Driver.Forname="); strWriter.WriteLine(GetForname(vehicle.mDriverName));
					strWriter.Write("Car."); strWriter.Write(i); strWriter.Write(".Driver.Surname="); strWriter.WriteLine(GetSurname(vehicle.mDriverName));
					strWriter.Write("Car."); strWriter.Write(i); strWriter.Write(".Driver.Nickname="); strWriter.WriteLine(GetNickname(vehicle.mDriverName));

					strWriter.Write("Car."); strWriter.Write(i); strWriter.Write(".InPitLane="); strWriter.WriteLine(vehicle.mInPits != 0 ? "true" : "false");
					strWriter.Write("Car."); strWriter.Write(i); strWriter.Write(".InPit="); strWriter.WriteLine(vehicle.mPitState == (byte)Stopped ? "true" : "false");

					if (vehicle.mIsPlayer == 1)
                    {
						strWriter.Write("Driver.Car=");
						strWriter.WriteLine(i);
					}
				}
			}
			else
			{
				strWriter.WriteLine("Active=false");
				strWriter.WriteLine("Car.Count=0");
				strWriter.WriteLine("Driver.Car=0");
			}

            return strWriter.ToString();
		}

		public string ReadData() {
            StringWriter strWriter = new StringWriter();

            rF2VehicleScoring playerScoring = GetPlayerScoring(ref scoring);
			rF2VehicleTelemetry playerTelemetry = GetPlayerTelemetry(playerScoring.mID, ref telemetry);

			string session = "";

			strWriter.WriteLine("[Session Data]");
			strWriter.Write("Active="); strWriter.WriteLine((connected && (extended.mSessionStarted != 0)) ? "true" : "false");
			if (connected) {
				if (playerTelemetry.mWheels == null)
					strWriter.WriteLine("Paused=true");
				else
				{
					strWriter.Write("Paused=");
					strWriter.WriteLine(scoring.mScoringInfo.mGamePhase <= (byte)GridWalk || scoring.mScoringInfo.mGamePhase == (byte)PausedOrHeartbeat ? "true" : "false");
				}

				if (scoring.mScoringInfo.mEndET <= 0.0 && (scoring.mScoringInfo.mMaxLaps - playerScoring.mTotalLaps) <= 0)
					session = "Finished";
				else if (scoring.mScoringInfo.mSession >= 10 && scoring.mScoringInfo.mSession <= 13)
					session = "Race";
				else if (scoring.mScoringInfo.mSession >= 0 && scoring.mScoringInfo.mSession <= 4)
					session = "Practice";
				else if (scoring.mScoringInfo.mSession >= 5 && scoring.mScoringInfo.mSession <= 8)
					session = "Qualification";
				else
					session = "Other";

				strWriter.Write("Session="); strWriter.WriteLine(session);

				string vehicleClass = GetStringFromBytes(playerScoring.mVehicleClass);
				string vehicleName = GetStringFromBytes(playerScoring.mVehicleName);

				strWriter.Write("Car="); strWriter.WriteLine(GetCarName(vehicleClass, vehicleName));
				strWriter.Write("CarName="); strWriter.WriteLine(vehicleName);
				strWriter.Write("CarClass="); strWriter.WriteLine(vehicleClass);
				strWriter.Write("Track="); strWriter.WriteLine(GetStringFromBytes(playerTelemetry.mTrackName));
				strWriter.Write("SessionFormat="); strWriter.WriteLine((scoring.mScoringInfo.mEndET <= 0.0) ? "Laps" : "Time");
				strWriter.Write("FuelAmount="); strWriter.WriteLine(Math.Round(playerTelemetry.mFuelCapacity));

				long time = GetRemainingTime(ref playerScoring);

				strWriter.Write("SessionTimeRemaining="); strWriter.WriteLine(time);

				strWriter.Write("SessionLapsRemaining="); strWriter.WriteLine(GetRemainingLaps(ref playerScoring));
			}

			strWriter.WriteLine("[Stint Data]");
			if (connected) {
				strWriter.Write("DriverForname="); strWriter.WriteLine(GetForname(scoring.mScoringInfo.mPlayerName));
				strWriter.Write("DriverSurname="); strWriter.WriteLine(GetSurname(scoring.mScoringInfo.mPlayerName));
				strWriter.Write("DriverNickname="); strWriter.WriteLine(GetNickname(scoring.mScoringInfo.mPlayerName));

				strWriter.Write("Position="); strWriter.WriteLine(playerScoring.mPlace);

                strWriter.Write("LapValid="); strWriter.WriteLine((playerScoring.mCountLapFlag == 2) ? "true" : "false");
				
				strWriter.Write("LapLastTime="); strWriter.WriteLine(Math.Round(Normalize(playerScoring.mLastLapTime > 0 ? playerScoring.mLastLapTime
																													 : playerScoring.mBestLapTime) * 1000));
				strWriter.Write("LapBestTime="); strWriter.WriteLine(Math.Round(Normalize(playerScoring.mBestLapTime) * 1000));

				if (playerScoring.mNumPenalties > 0)
                    strWriter.WriteLine("Penalty=true");

                strWriter.Write("Sector="); strWriter.WriteLine(playerScoring.mSector == 0 ? 3 : playerScoring.mSector);
				strWriter.Write("Laps="); strWriter.WriteLine(playerScoring.mTotalLaps);

				long time = GetRemainingTime(ref playerScoring);

				strWriter.Write("StintTimeRemaining="); strWriter.WriteLine(time);
				strWriter.Write("DriverTimeRemaining="); strWriter.WriteLine(time);
				strWriter.Write("InPit="); strWriter.WriteLine(playerScoring.mPitState == (byte)Stopped ? "true" : "false");
			}

			strWriter.WriteLine("[Car Data]");
			if (connected && (playerTelemetry.mWheels != null)) {
				strWriter.WriteLine("MAP=n/a");
				strWriter.Write("TC="); strWriter.WriteLine(extended.mPhysics.mTractionControl);
				strWriter.Write("ABS="); strWriter.WriteLine(extended.mPhysics.mAntiLockBrakes);
				
				strWriter.Write("FuelRemaining="); strWriter.WriteLine(playerTelemetry.mFuel);
				strWriter.Write("TyreTemperature=");
				strWriter.WriteLine(GetCelcius(playerTelemetry.mWheels[0].mTireCarcassTemperature) + "," +
								    GetCelcius(playerTelemetry.mWheels[1].mTireCarcassTemperature) + "," +
								    GetCelcius(playerTelemetry.mWheels[2].mTireCarcassTemperature) + "," +
								    GetCelcius(playerTelemetry.mWheels[3].mTireCarcassTemperature));
				strWriter.Write("TyrePressure=");
				strWriter.WriteLine(GetPsi(playerTelemetry.mWheels[0].mPressure) + "," +
								    GetPsi(playerTelemetry.mWheels[1].mPressure) + "," +
								    GetPsi(playerTelemetry.mWheels[2].mPressure) + "," +
								    GetPsi(playerTelemetry.mWheels[3].mPressure));
				strWriter.Write("TyreWear=");
				if (extended.mPhysics.mTireMult > 0)
					strWriter.WriteLine((100 - Math.Round(playerTelemetry.mWheels[0].mWear * 100)) + "," +
									    (100 - Math.Round(playerTelemetry.mWheels[1].mWear * 100)) + "," +
									    (100 - Math.Round(playerTelemetry.mWheels[2].mWear * 100)) + "," +
									    (100 - Math.Round(playerTelemetry.mWheels[3].mWear * 100)));
				else
					strWriter.WriteLine("0,0,0,0");
				strWriter.Write("BrakeTemperature=");
				strWriter.WriteLine(GetCelcius(playerTelemetry.mWheels[0].mBrakeTemp) + "," +
								    GetCelcius(playerTelemetry.mWheels[1].mBrakeTemp) + "," +
								    GetCelcius(playerTelemetry.mWheels[2].mBrakeTemp) + "," +
								    GetCelcius(playerTelemetry.mWheels[3].mBrakeTemp));

				string compound = GetStringFromBytes(playerTelemetry.mFrontTireCompoundName);
			
				strWriter.Write("TyreCompoundRaw="); strWriter.WriteLine(compound);

				strWriter.Write("BodyworkDamage=0, 0, 0, 0, "); strWriter.WriteLine(extended.mTrackedDamages[playerTelemetry.mID].mAccumulatedImpactMagnitude / 1000);
				strWriter.WriteLine("SuspensionDamage=0, 0, 0, 0");
				strWriter.WriteLine("EngineDamage=0");
			}

			strWriter.WriteLine("[Track Data]");
			if (connected)
			{
                strWriter.Write("Length="); strWriter.WriteLine(scoring.mScoringInfo.mLapDist);
                strWriter.WriteLine("Grip=Optimum");
				strWriter.Write("Temperature="); strWriter.WriteLine(scoring.mScoringInfo.mTrackTemp);

				for (int i = 0; i < scoring.mScoringInfo.mNumVehicles; ++i)	{
					var vehicle = scoring.mVehicles[i];

					strWriter.WriteLine("Car." + (i + 1) + ".Position=" + vehicle.mPos.x + "," + (- vehicle.mPos.z));
				}
			}

			strWriter.WriteLine("[Weather Data]");
			if (connected) {
				strWriter.Write("Temperature="); strWriter.WriteLine(scoring.mScoringInfo.mAmbientTemp);

				string theWeather = GetWeather(scoring.mScoringInfo.mDarkCloud, scoring.mScoringInfo.mRaining);

				strWriter.Write("Weather="); strWriter.WriteLine(theWeather);
				strWriter.Write("Weather10Min="); strWriter.WriteLine(theWeather);
				strWriter.Write("Weather30Min="); strWriter.WriteLine(theWeather);
			}

			strWriter.WriteLine("[Test Data]");
			if (connected) {
				strWriter.Write("Category="); strWriter.Write(pitInfo.mPitMenu.mCategoryIndex);
				strWriter.Write(" -> "); strWriter.WriteLine(GetStringFromBytes(pitInfo.mPitMenu.mCategoryName));
				strWriter.Write("Choices="); strWriter.Write(pitInfo.mPitMenu.mChoiceIndex);
				strWriter.Write(" -> "); strWriter.WriteLine(GetStringFromBytes(pitInfo.mPitMenu.mChoiceString));
				strWriter.Write("NumChoices="); strWriter.WriteLine(pitInfo.mPitMenu.mNumChoices);
			}

			return strWriter.ToString();
		}

		private long Normalize(long value) {
			return (value < 0) ? 0 : value;

		}

		private double Normalize(double value) {
			return (value < 0) ? 0 : value;

		}

		private long GetRemainingLaps(ref rF2VehicleScoring playerScoring) {
			if (playerScoring.mTotalLaps < 1)
				return 0;

			if (scoring.mScoringInfo.mEndET <= 0.0) {
				return scoring.mScoringInfo.mMaxLaps - playerScoring.mTotalLaps;
			}
			else {
				if (playerScoring.mLastLapTime > 0)
					return (long)Math.Round(GetRemainingTime(ref playerScoring) / (Normalize(playerScoring.mLastLapTime) * 1000)) + 1;
				else if (playerScoring.mEstimatedLapTime > 0)
                    return (long)Math.Round(GetRemainingTime(ref playerScoring) / (Normalize(playerScoring.mEstimatedLapTime) * 1000)) + 1;
                else
					return 1;
			}
		}

		private long GetRemainingTime(ref rF2VehicleScoring playerScoring) {
			if (playerScoring.mTotalLaps < 1)
				return 0;

			if (scoring.mScoringInfo.mEndET > 0.0)
			{
				/*
				long time = (long)((scoring.mScoringInfo.mEndET - (Normalize(playerScoring.mLastLapTime) * playerScoring.mTotalLaps)) * 1000);

				if (time > 0)
					return time;
				else
					return 0;
				*/

				return (long)Math.Max(0, scoring.mScoringInfo.mEndET - scoring.mScoringInfo.mCurrentET) * 1000;
			}
			else
			{
				if (playerScoring.mLastLapTime > 0)
                    return (long)(GetRemainingLaps(ref playerScoring) * playerScoring.mLastLapTime * 1000);
				else if (playerScoring.mEstimatedLapTime > 0)
                    return (long)(GetRemainingLaps(ref playerScoring) * playerScoring.mEstimatedLapTime * 1000);
                else
                    return (long)(GetRemainingLaps(ref playerScoring) * playerScoring.mBestLapTime * 1000);
            }
		}

		private static string GetWeather(double cloudLevel, double rainLevel) {
			if (rainLevel == 0.0)
				return "Dry";
			else if (rainLevel <= 0.2)
				return (cloudLevel < 0.5) ? "Drizzle" : "LightRain";
			else if (rainLevel <= 0.4)
				return (cloudLevel < 0.3) ? "Drizzle" : ((cloudLevel > 0.7) ? "MediumRain" : "LightRain");
			else if (rainLevel <= 0.6)
				return (cloudLevel < 0.2) ? "LightRain" : ((cloudLevel > 0.7) ? "HeavyRain" : "MediumRain");
			else if (rainLevel <= 0.8)
				return (cloudLevel < 0.2) ? "MediumRain" : ((cloudLevel > 0.7) ? "ThunderStorm" : "HeavyRain");
			else
				return (cloudLevel < 0.2) ? "HeavyRain" : "Thunderstorm";
		}

		private static double GetCelcius(double kelvin) {
			return kelvin - 273.15;
		}

		private static double GetPsi(double kPa) {
			return kPa / 6.895;
		}

		private static double GetKpa(double psi) {
			return psi * 6.895;
		}

		private static string GetStringFromBytes(byte[] bytes) {
			if (bytes == null)
				return "";

			var nullIdx = Array.IndexOf(bytes, (byte)0);

			return nullIdx >= 0 ? Encoding.Default.GetString(bytes, 0, nullIdx) : Encoding.Default.GetString(bytes);
		}

        static rF2VehicleScoring noPlayer = new rF2VehicleScoring();

        public static rF2VehicleScoring GetPlayerScoring(ref rF2Scoring scoring) {
			for (int i = 0; i < scoring.mScoringInfo.mNumVehicles; ++i) {
				var vehicle = scoring.mVehicles[i];

				/*
				switch ((rFactor2Constants.rF2Control)vehicle.mControl) {
					case rFactor2Constants.rF2Control.AI:
					case rFactor2Constants.rF2Control.Player:
					case rFactor2Constants.rF2Control.Remote:
						if (vehicle.mIsPlayer == 1)
							return vehicle;

						continue;

					default:
						continue;
				}
				*/

				if (vehicle.mIsPlayer == 1)
                    return vehicle;
            }

			return noPlayer;
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

					this.telemetryBuffer.Connect();
					this.scoringBuffer.Connect();
					this.rulesBuffer.Connect();
					this.forceFeedbackBuffer.Connect();
					this.graphicsBuffer.Connect();
					this.pitInfoBuffer.Connect();
					this.weatherBuffer.Connect();

					this.hwControlBuffer.Connect();
					this.hwControlBuffer.GetMappedData(ref this.hwControl);
					this.hwControl.mLayoutVersion = rFactor2Constants.MM_HWCONTROL_LAYOUT_VERSION;

					this.weatherControlBuffer.Connect();
					this.weatherControlBuffer.GetMappedData(ref this.weatherControl);
					this.weatherControl.mLayoutVersion = rFactor2Constants.MM_WEATHER_CONTROL_LAYOUT_VERSION;

					this.rulesControlBuffer.Connect();
					this.rulesControlBuffer.GetMappedData(ref this.rulesControl);
					this.rulesControl.mLayoutVersion = rFactor2Constants.MM_RULES_CONTROL_LAYOUT_VERSION;

					this.pluginControlBuffer.Connect();
					this.pluginControlBuffer.GetMappedData(ref this.pluginControl);
					this.pluginControl.mLayoutVersion = rFactor2Constants.MM_PLUGIN_CONTROL_LAYOUT_VERSION;

					// Scoring cannot be enabled on demand.
					this.pluginControl.mRequestEnableBuffersMask = /*(int)SubscribedBuffer.Scoring | */(int)SubscribedBuffer.Telemetry | (int)SubscribedBuffer.Rules
					| (int)SubscribedBuffer.ForceFeedback | (int)SubscribedBuffer.Graphics | (int)SubscribedBuffer.Weather | (int)SubscribedBuffer.PitInfo;
					this.pluginControl.mRequestHWControlInput = 1;
					this.pluginControl.mRequestRulesControlInput = 1;
					this.pluginControl.mRequestWeatherControlInput = 1;
					this.pluginControl.mVersionUpdateBegin = this.pluginControl.mVersionUpdateEnd = this.pluginControl.mVersionUpdateBegin + 1;
					this.pluginControlBuffer.PutMappedData(ref this.pluginControl);

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
			this.rulesBuffer.Disconnect();
			this.telemetryBuffer.Disconnect();
			this.forceFeedbackBuffer.Disconnect();
			this.pitInfoBuffer.Disconnect();
			this.weatherBuffer.Disconnect();
			this.graphicsBuffer.Disconnect();

			this.hwControlBuffer.Disconnect();
			this.weatherControlBuffer.Disconnect();
			this.rulesControlBuffer.Disconnect();
			this.pluginControlBuffer.Disconnect();

			this.connected = false;
		}

		private void SendPitMenuCmd(byte[] commandStr, double fRetVal) {
			if (commandStr != null) {
				this.hwControl.mVersionUpdateBegin = this.hwControl.mVersionUpdateEnd = this.hwControl.mVersionUpdateBegin + 1;

				this.hwControl.mControlName = new byte[rFactor2Constants.MAX_HWCONTROL_NAME_LEN];
				for (int i = 0; i < commandStr.Length; ++i)
					this.hwControl.mControlName[i] = commandStr[i];

				this.hwControl.mfRetVal = fRetVal;

				this.hwControlBuffer.PutMappedData(ref this.hwControl);
			}
		}

		private void ExecuteSetRefuelCommand(string fuelArgument) {
			Console.Write("Adjusting Refuel: "); Console.WriteLine(fuelArgument);

			int targetFuel = Int16.Parse(fuelArgument);

			if (!SelectPitstopCategory("FUEL:"))
				return;

			int deltaFuel = targetFuel - pitInfo.mPitMenu.mChoiceIndex;

			if (deltaFuel > 0)
				SendPitstopCommand(new string('+', deltaFuel));
			else
				SendPitstopCommand(new string('-', Math.Abs(deltaFuel)));
		}
		
		private void ExecuteChangeRefuelCommand(char action, string stepsArgument) {
			if (!SelectPitstopCategory("FUEL:"))
				return;

			SendPitstopCommand(new string(action, (int)Double.Parse(stepsArgument)));
		}

		private void ExecuteSetTyreCompoundCommand(string tyreCompound) {
			if (tyreCompound == "None") {
				Console.WriteLine("Adjusting Tyre Compound: No Change");

				tyreCompound = "No Change";
			}
			else {
				Console.Write("Adjusting Tyre Compound: ");
				Console.WriteLine(tyreCompound);
			}

			void selectAxleTyreCompound(string category) {
				if (SelectPitstopCategory(category))
					SelectPitstopOption(tyreCompound, "+");
			}

			selectAxleTyreCompound("F TIRES:");
			selectAxleTyreCompound("R TIRES:");
		}
		
		private void ExecuteChangeTyreCompoundCommand(char action, string stepsArgument) {
			if (!SelectPitstopCategory("F TIRES:"))
				return;

			SendPitstopCommand(new string(action, (int)Double.Parse(stepsArgument)));
			
			if (!SelectPitstopCategory("R TIRES:"))
				return;

			SendPitstopCommand(new string(action, (int)Double.Parse(stepsArgument)));
		}

		private void ExecuteSetTyreSetCommand(string tyreSetArgument) {
			Console.Write("Adjusting Tyre Set: "); Console.WriteLine(tyreSetArgument[0]);
		}

		private void ExecuteChangeTyreSetCommand(char action, string stepsArgument) {
		}

		private void ExecuteSetTyrePressureCommand(string[] tyrePressureArgument) {
			void updatePressure(string category, string position, double targetPressure) {
				targetPressure = GetKpa(targetPressure);

				Console.Write("Adjusting Tyre Pressure "); Console.Write(position); Console.Write(": ");
				Console.WriteLine(targetPressure);

				if (!SelectPitstopCategory(category))
					return;

				string currentPressure = GetStringFromBytes(pitInfo.mPitMenu.mChoiceString);

				if (currentPressure.Contains(" "))
					currentPressure = currentPressure.Split(' ')[0];

				int deltaPressure = (int)targetPressure - Int16.Parse(currentPressure);

				if (deltaPressure > 0)
					SendPitstopCommand(new string('+', deltaPressure));
				else
					SendPitstopCommand(new string('-', Math.Abs(deltaPressure)));
			}

			updatePressure("FL PRESS:", "FL", Double.Parse(tyrePressureArgument[0]));
			updatePressure("FR PRESS:", "FR", Double.Parse(tyrePressureArgument[1]));
			updatePressure("RL PRESS:", "RL", Double.Parse(tyrePressureArgument[2]));
			updatePressure("RR PRESS:", "RR", Double.Parse(tyrePressureArgument[3]));
		}
		
		private void ExecuteChangeTyrePressureCommand(char action, string[] stepsArgument) {
			void updatePressure(string category, double pressureIncrement) {
				if (pressureIncrement != 0.0) {
					if (!SelectPitstopCategory(category))
						return;

					SendPitstopCommand(new string(action, Math.Max(1, (int)Math.Round(GetKpa(pressureIncrement)))));
				}
			}
			
			updatePressure("FL PRESS:", Double.Parse(stepsArgument[0]));
			updatePressure("FR PRESS:", Double.Parse(stepsArgument[1]));
			updatePressure("RL PRESS:", Double.Parse(stepsArgument[2]));
			updatePressure("RR PRESS:", Double.Parse(stepsArgument[3]));
		}

		private void ExecuteSetRepairCommand(string repairType) {
			Console.Write("Adjusting Repair: ");

			string option = "Not";

			switch (repairType) {
				case "Bodywork":
					Console.WriteLine("Bodywork");

					option = "Body";
					break;
				case "Suspension":
					Console.WriteLine("Suspension");

					option = "Suspension";
					break;
				case "Both":
					Console.WriteLine("Bodywork & Suspension");

					option = "All";
					break;
				case "Nothing":
					Console.WriteLine("Nothing");

					option = "Not";
					break;
			}

			if (SelectPitstopCategory("DAMAGE:"))
				SelectPitstopOption(option, "+");
		}
		
		private void ExecuteChangeRepairCommand(char action, string stepsArgument) {
			if (!SelectPitstopCategory("DAMAGE:"))
				return;

			SendPitstopCommand(new string(action, (int)Double.Parse(stepsArgument)));
		}
		
		private void ExecuteChangeDriverCommand(char action, string stepsArgument) {
			if (!SelectPitstopCategory("DRIVER:"))
				return;

			SendPitstopCommand(new string(action, (int)Double.Parse(stepsArgument)));
		}

		public void ExecutePitstopSetCommand(string command, string[] arguments) {
			if (!this.connected || this.extended.mHWControlInputEnabled == 0)
				return;

			switch (command) {
				case "Refuel":
					ExecuteSetRefuelCommand(arguments[0]);
					break;
				case "Tyre Compound":
					ExecuteSetTyreCompoundCommand(arguments[0]);
					break;
				case "Tyre Set":
					ExecuteSetTyreSetCommand(arguments[0]);
					break;
				case "Tyre Pressure":
					ExecuteSetTyrePressureCommand(arguments);
					break;
				case "Repair":
					ExecuteSetRepairCommand(arguments[0]);
					break;
			}
		}

		public void ExecutePitstopChangeCommand(string command, string direction, string[] arguments) {
			if (!this.connected || this.extended.mHWControlInputEnabled == 0)
				return;
			
			char action = (direction == "Increase" ? '+' : '-');
			
			switch (command) {
				case "Refuel":
					ExecuteChangeRefuelCommand(action, arguments[0]);
					break;
				case "Tyre Compound":
					ExecuteChangeTyreCompoundCommand(action, arguments[0]);
					break;
				case "Tyre Pressure":
					ExecuteChangeTyrePressureCommand(action, arguments);
					break;
				case "Driver":
					ExecuteChangeDriverCommand(action, arguments[0]);
					break;
				case "Repair":
					ExecuteChangeRepairCommand(action, arguments[0]);
					break;
			}
		}
		
		private bool SelectPitstopOption(string option, string direction) {
			int tries = 2;

			pitInfoBuffer.GetMappedData(ref pitInfo);

			string start = GetStringFromBytes(pitInfo.mPitMenu.mChoiceString);

			while (!GetStringFromBytes(pitInfo.mPitMenu.mChoiceString).Contains(option)) {
				SendPitstopCommand(direction);

				pitInfoBuffer.GetMappedData(ref pitInfo);

				if ((GetStringFromBytes(pitInfo.mPitMenu.mChoiceString) == start) && (--tries == 0)) {
					// Console.Write("Not found: "); Console.WriteLine(category);

					return false;
				}
			}
			
			return true;
		}

		private bool SelectPitstopCategory(string category) {
			int tries = 2;

			pitInfoBuffer.GetMappedData(ref pitInfo);

			string start = GetStringFromBytes(pitInfo.mPitMenu.mCategoryName);

			while (category != GetStringFromBytes(pitInfo.mPitMenu.mCategoryName)) {
				SendPitstopCommand("D");

				pitInfoBuffer.GetMappedData(ref pitInfo);

				if ((GetStringFromBytes(pitInfo.mPitMenu.mCategoryName) == start) && (--tries == 0)) {
					// Console.Write("Not found: "); Console.WriteLine(category);

					return false;
				}
			}

			return true;
        }

        private DateTime nextKeyHandlingTime = DateTime.MinValue;

		private void SendPitstopCommand(string command) {
			var now = DateTime.Now;
			if (now < this.nextKeyHandlingTime)
				Thread.Sleep(200);

			for (int i = 0; i < command.Length; i++) {
				byte[] commandStr = null;
				var fRetVal = 1.0;

				if (command[i] == '+')
					commandStr = Encoding.Default.GetBytes("PitMenuIncrementValue");
				else if (command[i] == '-')
					commandStr = Encoding.Default.GetBytes("PitMenuDecrementValue");
				else if (command[i] == 'U')
					commandStr = Encoding.Default.GetBytes("PitMenuUp");
				else if (command[i] == 'D')
					commandStr = Encoding.Default.GetBytes("PitMenuDown");

				this.SendPitMenuCmd(commandStr, fRetVal);

				Thread.Sleep(100);
			}

			this.nextKeyHandlingTime = now + TimeSpan.FromMilliseconds(200);
		}

		public string ReadSetup() {
            StringWriter strWriter = new StringWriter();

            strWriter.WriteLine("[Setup Data]");

			if (connected)
			{
				if (SelectPitstopCategory("FUEL:"))
					strWriter.Write("FuelAmount="); strWriter.WriteLine(pitInfo.mPitMenu.mChoiceIndex);

				if (!SelectPitstopCategory("F TIRES:"))
				{
					string compound = GetStringFromBytes(pitInfo.mPitMenu.mChoiceString);

					if (compound != "No Change")
						strWriter.WriteLine("TyreCompoundRaw=" + compound);
					else
						strWriter.WriteLine("TyreCompoundRaw=false");

					void writePressure(string category, string key)
					{
						if (SelectPitstopCategory(category))
						{
							string currentPressure = GetStringFromBytes(pitInfo.mPitMenu.mChoiceString);

							if (currentPressure.Contains(" "))
								currentPressure = currentPressure.Split(' ')[0];

							strWriter.Write(key); strWriter.Write("="); strWriter.WriteLine(GetPsi(Int16.Parse(currentPressure)));
						}
					}

					writePressure("FL PRESS:", "TyrePressureFL");
					writePressure("FR PRESS:", "TyrePressureFR");
					writePressure("RL PRESS:", "TyrePressureRL");
					writePressure("RR PRESS:", "TyrePressureRR");
				}

				if (SelectPitstopCategory("DAMAGE:"))
				{
					string option = GetStringFromBytes(pitInfo.mPitMenu.mChoiceString);

					if (option.Contains("All"))
					{
						strWriter.WriteLine("RepairSupension=true");
						strWriter.WriteLine("RepairBodywork=true");
					}
					else if (option.Contains("Bodywork"))
					{
						strWriter.WriteLine("RepairSupension=false");
						strWriter.WriteLine("RepairBodywork=true");
					}
					else if (option.Contains("Suspension"))
					{
						strWriter.WriteLine("RepairSupension=true");
						strWriter.WriteLine("RepairBodywork=false");
					}
					else
					{
						strWriter.WriteLine("RepairSupension=false");
						strWriter.WriteLine("RepairBodywork=false");
					}
				}
			}

			return strWriter.ToString();
		}
    }
}
