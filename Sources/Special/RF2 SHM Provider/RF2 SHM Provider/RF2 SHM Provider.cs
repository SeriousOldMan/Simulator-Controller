/*
RF2 SHM Provider main class.

Small parts original by: The Iron Wolf (vleonavicius@hotmail.com; thecrewchief.org)
*/
using RF2SHMProvider.rFactor2Data;
using System;
using System.Text;
using System.Threading;
using static RF2SHMProvider.rFactor2Constants;
using static RF2SHMProvider.rFactor2Constants.rF2GamePhase;
using static RF2SHMProvider.rFactor2Constants.rF2PitState;

namespace RF2SHMProvider {
	public class SHMProvider {
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

		public SHMProvider() {
			if (!this.connected)
				this.Connect();

			try {
				extendedBuffer.GetMappedData(ref extended);
				scoringBuffer.GetMappedData(ref scoring);
				telemetryBuffer.GetMappedData(ref telemetry);
				rulesBuffer.GetMappedData(ref rules);
				forceFeedbackBuffer.GetMappedDataUnsynchronized(ref forceFeedback);
				graphicsBuffer.GetMappedDataUnsynchronized(ref graphics);
				pitInfoBuffer.GetMappedData(ref pitInfo);
				weatherBuffer.GetMappedData(ref weather);
			}
			catch (Exception) {
				this.Disconnect();
			}
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

			if (forName.Contains(" ")) {
				string[] names = forName.Split(' ');

				return names[1];
			}
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
			if (carName.Contains(carClass))
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
			if (carName[0] == '#')
			{
				char[] delims = { ' ' };
				string[] parts = carName.Split(delims, 2);

				return parts[0].Split('#')[1].Trim();
			}
			else if (carName.Contains("#"))
				return carName.Split('#')[1].Trim().Split(' ')[0].Trim();
			else
				return id.ToString();
		}

		public void ReadStandings() {
			Console.WriteLine("[Position Data]");

			Console.Write("Car.Count="); Console.WriteLine(scoring.mScoringInfo.mNumVehicles);

			for (int i = 1; i <= scoring.mScoringInfo.mNumVehicles; ++i) {
				rF2VehicleScoring vehicle = scoring.mVehicles[i - 1];

				Console.Write("Car."); Console.Write(i); Console.Write(".Nr="); Console.WriteLine(vehicle.mID);
				Console.Write("Car."); Console.Write(i); Console.Write(".Position="); Console.WriteLine(vehicle.mPlace);

				Console.Write("Car."); Console.Write(i); Console.Write(".Lap="); Console.WriteLine(vehicle.mTotalLaps);
				Console.Write("Car."); Console.Write(i); Console.Write(".Lap.Running="); Console.WriteLine(vehicle.mLapDist / scoring.mScoringInfo.mLapDist);
				Console.Write("Car."); Console.Write(i); Console.Write(".Lap.Valid="); Console.WriteLine(vehicle.mCountLapFlag == 2 ? "true" : "false");

				int lapTime = (int)Math.Round(Normalize(vehicle.mLastLapTime) * 1000);
				int sector1Time = (int)Math.Round(Normalize(vehicle.mLastSector1) * 1000);
				int sector2Time = (int)Math.Round(Normalize(vehicle.mLastSector2) * 1000);
				int sector3Time = lapTime - sector1Time - sector2Time;

				Console.Write("Car."); Console.Write(i); Console.Write(".Time="); Console.WriteLine(lapTime);
				Console.Write("Car."); Console.Write(i); Console.Write(".Time.Sectors="); Console.WriteLine(sector1Time + "," + sector2Time + "," + sector3Time);


				string carModel = GetCarName(GetStringFromBytes(vehicle.mVehicleClass), GetStringFromBytes(vehicle.mVehicleName));
				string carNr = GetCarNr(vehicle.mID, GetStringFromBytes(vehicle.mVehicleClass), GetStringFromBytes(vehicle.mVehicleName));
				
				Console.Write("Car."); Console.Write(i); Console.Write(".Nr="); Console.WriteLine(carNr);
				Console.Write("Car."); Console.Write(i); Console.Write(".Car="); Console.WriteLine(carModel);

				Console.Write("Car."); Console.Write(i); Console.Write(".Driver.Forname="); Console.WriteLine(GetForname(vehicle.mDriverName));
				Console.Write("Car."); Console.Write(i); Console.Write(".Driver.Surname="); Console.WriteLine(GetSurname(vehicle.mDriverName));
				Console.Write("Car."); Console.Write(i); Console.Write(".Driver.Nickname="); Console.WriteLine(GetNickname(vehicle.mDriverName));

				Console.Write("Car."); Console.Write(i); Console.Write(".InPitLane="); Console.WriteLine(vehicle.mInPits != 0 ? "true" : "false");
				Console.Write("Car."); Console.Write(i); Console.Write(".InPit="); Console.WriteLine(vehicle.mPitState == (byte)Stopped ? "true" : "false");

				if (vehicle.mIsPlayer != 0)
				{
					Console.Write("Driver.Car=");
					Console.WriteLine(i);
				}
			}
		}

		public void ReadData() {
			rF2VehicleScoring playerScoring = GetPlayerScoring(ref scoring);
			rF2VehicleTelemetry playerTelemetry = GetPlayerTelemetry(playerScoring.mID, ref telemetry);

			string session = "";

			Console.WriteLine("[Session Data]");
			Console.Write("Active="); Console.WriteLine((connected && (extended.mSessionStarted != 0)) ? "true" : "false");
			if (connected) {
				if (playerTelemetry.mWheels == null)
					Console.WriteLine("Paused=true");
				else
				{
					Console.Write("Paused=");
					Console.WriteLine(scoring.mScoringInfo.mGamePhase <= (byte)GridWalk || scoring.mScoringInfo.mGamePhase == (byte)PausedOrHeartbeat ? "true" : "false");
				}

				if (scoring.mScoringInfo.mGamePhase == (byte)SessionOver)
					session = "Finished";
				if (scoring.mScoringInfo.mSession >= 10 && scoring.mScoringInfo.mSession <= 13)
					session = "Race";
				else if (scoring.mScoringInfo.mSession >= 0 && scoring.mScoringInfo.mSession <= 4)
					session = "Practice";
				else if (scoring.mScoringInfo.mSession >= 5 && scoring.mScoringInfo.mSession <= 8)
					session = "Qualification";
				else
					session = "Other";

				Console.Write("Session="); Console.WriteLine(session);

				string vehicleClass = GetStringFromBytes(playerScoring.mVehicleClass);
				string vehicleName = GetStringFromBytes(playerScoring.mVehicleName);

				Console.Write("Car="); Console.WriteLine(GetCarName(vehicleClass, vehicleName));
				Console.Write("CarName="); Console.WriteLine(vehicleName);
				Console.Write("CarClass="); Console.WriteLine(vehicleClass);
				Console.Write("Track="); Console.WriteLine(GetStringFromBytes(playerTelemetry.mTrackName));
				Console.Write("SessionFormat="); Console.WriteLine((scoring.mScoringInfo.mEndET < 0.0) ? "Lap" : "Time");
				Console.Write("FuelAmount="); Console.WriteLine(Math.Round(playerTelemetry.mFuelCapacity));

				/*
				if (session == "Practice")
				{
					Console.WriteLine("SessionTimeRemaining=3600000");

					Console.WriteLine("SessionLapsRemaining=30");
				}
				else
				{
				*/
					long time = GetRemainingTime(ref playerScoring);

					Console.Write("SessionTimeRemaining="); Console.WriteLine(time);

					Console.Write("SessionLapsRemaining="); Console.WriteLine(GetRemainingLaps(ref playerScoring));
				/*
				}
				*/
			}

			Console.WriteLine("[Stint Data]");
			if (connected) {
				Console.Write("DriverForname="); Console.WriteLine(GetForname(scoring.mScoringInfo.mPlayerName));
				Console.Write("DriverSurname="); Console.WriteLine(GetSurname(scoring.mScoringInfo.mPlayerName));
				Console.Write("DriverNickname="); Console.WriteLine(GetNickname(scoring.mScoringInfo.mPlayerName));

				Console.Write("LapValid="); Console.WriteLine((playerScoring.mCountLapFlag > 0) ? "true" : "false");
				
				Console.Write("LapLastTime="); Console.WriteLine(Math.Round(Normalize(playerScoring.mLastLapTime) * 1000));
				Console.Write("LapBestTime="); Console.WriteLine(Math.Round(Normalize(playerScoring.mBestLapTime) * 1000));

				Console.Write("Sector="); Console.WriteLine(playerScoring.mSector == 0 ? 3 : playerScoring.mSector);
				Console.Write("Laps="); Console.WriteLine(playerScoring.mTotalLaps);

				/*
				if (session == "Practice")
				{
					Console.WriteLine("StintTimeRemaining=3600000");
					Console.WriteLine("DriverTimeRemaining=3600000");
				}
				else
				{
				*/
					long time = GetRemainingTime(ref playerScoring);

					Console.Write("StintTimeRemaining="); Console.WriteLine(time);
					Console.Write("DriverTimeRemaining="); Console.WriteLine(time);
				/*
				}
				*/
				Console.Write("InPit="); Console.WriteLine(playerScoring.mPitState == (byte)Stopped ? "true" : "false");
			}

			Console.WriteLine("[Car Data]");
			if (connected && (playerTelemetry.mWheels != null)) {
				Console.WriteLine("MAP=n/a");
				Console.Write("TC="); Console.WriteLine(extended.mPhysics.mTractionControl);
				Console.Write("ABS="); Console.WriteLine(extended.mPhysics.mAntiLockBrakes);
				
				Console.Write("FuelRemaining="); Console.WriteLine(playerTelemetry.mFuel);
				Console.Write("TyreTemperature=");
				Console.WriteLine(GetCelcius(playerTelemetry.mWheels[0].mTireCarcassTemperature) + "," +
								  GetCelcius(playerTelemetry.mWheels[1].mTireCarcassTemperature) + "," +
								  GetCelcius(playerTelemetry.mWheels[2].mTireCarcassTemperature) + "," +
								  GetCelcius(playerTelemetry.mWheels[3].mTireCarcassTemperature));
				Console.Write("TyrePressure=");
				Console.WriteLine(GetPsi(playerTelemetry.mWheels[0].mPressure) + "," +
								  GetPsi(playerTelemetry.mWheels[1].mPressure) + "," +
								  GetPsi(playerTelemetry.mWheels[2].mPressure) + "," +
								  GetPsi(playerTelemetry.mWheels[3].mPressure));
				Console.Write("TyreWear=");
				if (extended.mPhysics.mTireMult > 0)
					Console.WriteLine((100 - Math.Round(playerTelemetry.mWheels[0].mWear * 100)) + "," +
									  (100 - Math.Round(playerTelemetry.mWheels[1].mWear * 100)) + "," +
									  (100 - Math.Round(playerTelemetry.mWheels[2].mWear * 100)) + "," +
									  (100 - Math.Round(playerTelemetry.mWheels[3].mWear * 100)));
				else
					Console.WriteLine("0,0,0,0");
				Console.Write("BrakeTemperature=");
				Console.WriteLine(GetCelcius(playerTelemetry.mWheels[0].mBrakeTemp) + "," +
								  GetCelcius(playerTelemetry.mWheels[1].mBrakeTemp) + "," +
								  GetCelcius(playerTelemetry.mWheels[2].mBrakeTemp) + "," +
								  GetCelcius(playerTelemetry.mWheels[3].mBrakeTemp));

				string compound = GetStringFromBytes(playerTelemetry.mFrontTireCompoundName);
			
				Console.Write("TyreCompoundRaw="); Console.WriteLine(compound);

				Console.Write("BodyworkDamage=0, 0, 0, 0, "); Console.WriteLine(extended.mTrackedDamages[playerTelemetry.mID].mAccumulatedImpactMagnitude / 1000);
				Console.WriteLine("SuspensionDamage=0, 0, 0, 0");
				Console.WriteLine("EngineDamage=0");
			}

			Console.WriteLine("[Track Data]");

			if (connected)
			{
				Console.WriteLine("Grip=Optimum");
				Console.Write("Temperature="); Console.WriteLine(scoring.mScoringInfo.mTrackTemp);

				for (int i = 0; i < scoring.mScoringInfo.mNumVehicles; ++i)	{
					var vehicle = scoring.mVehicles[i];

					Console.WriteLine("Car." + (i + 1) + ".Position=" + vehicle.mPos.x + "," + (- vehicle.mPos.z));
				}
			}

			Console.WriteLine("[Weather Data]");

			if (connected) {
				Console.Write("Temperature="); Console.WriteLine(scoring.mScoringInfo.mAmbientTemp);

				string theWeather = GetWeather(scoring.mScoringInfo.mDarkCloud, scoring.mScoringInfo.mRaining);

				Console.Write("Weather="); Console.WriteLine(theWeather);
				Console.Write("Weather10Min="); Console.WriteLine(theWeather);
				Console.Write("Weather30Min="); Console.WriteLine(theWeather);
			}

			Console.WriteLine("[Test Data]");
			if (connected) {
				Console.Write("Category="); Console.Write(pitInfo.mPitMenu.mCategoryIndex);
				Console.Write(" -> "); Console.WriteLine(GetStringFromBytes(pitInfo.mPitMenu.mCategoryName));
				Console.Write("Choices="); Console.Write(pitInfo.mPitMenu.mChoiceIndex);
				Console.Write(" -> "); Console.WriteLine(GetStringFromBytes(pitInfo.mPitMenu.mChoiceString));
				Console.Write("NumChoices="); Console.WriteLine(pitInfo.mPitMenu.mNumChoices);
			}
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
				else
					return 0;
			}
		}

		private long GetRemainingTime(ref rF2VehicleScoring playerScoring) {
			if (playerScoring.mTotalLaps < 1)
				return 0;

			if (scoring.mScoringInfo.mEndET > 0.0)
			{
				long time = (long)((scoring.mScoringInfo.mEndET - (Normalize(playerScoring.mLastLapTime) * playerScoring.mTotalLaps)) * 1000);

				if (time > 0)
					return time;
				else
					return 0;
			}
			else
				return (long)(GetRemainingLaps(ref playerScoring) * Normalize(playerScoring.mLastLapTime) * 1000);
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

		public static rF2VehicleScoring GetPlayerScoring(ref rF2Scoring scoring) {
			var playerVehScoring = new rF2VehicleScoring();

			for (int i = 0; i < scoring.mScoringInfo.mNumVehicles; ++i) {
				var vehicle = scoring.mVehicles[i];

				switch ((rFactor2Constants.rF2Control)vehicle.mControl) {
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
			int tries = 5;

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
			int tries = 5;

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
				Thread.Sleep(100);

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

			this.nextKeyHandlingTime = now + TimeSpan.FromMilliseconds(100);
		}

		public void ReadSetup() {
			Console.WriteLine("[Setup Data]");
			
			if (connected) {
				if (!SelectPitstopCategory("FUEL:"))
					return;

				Console.Write("FuelAmount="); Console.WriteLine(pitInfo.mPitMenu.mChoiceIndex);

				if (!SelectPitstopCategory("F TIRES:"))
					return;

				Console.Write("TyreCompound=");

				string compound = GetStringFromBytes(pitInfo.mPitMenu.mChoiceString);

				Console.WriteLine("TyreCompoundRaw=" + compound);
				
				void writePressure(string category, string key) {
					if (!SelectPitstopCategory(category))
						return;

					string currentPressure = GetStringFromBytes(pitInfo.mPitMenu.mChoiceString);

					if (currentPressure.Contains(" "))
						currentPressure = currentPressure.Split(' ')[0];

					Console.Write(key); Console.Write("="); Console.WriteLine(GetPsi(Int16.Parse(currentPressure)));
				}

				writePressure("FL PRESS:", "TyrePressureFL");
				writePressure("FR PRESS:", "TyrePressureFR");
				writePressure("RL PRESS:", "TyrePressureRL");
				writePressure("RR PRESS:", "TyrePressureRR");

				if (!SelectPitstopCategory("DAMAGE:"))
					return;

				string option = GetStringFromBytes(pitInfo.mPitMenu.mChoiceString);

				if (option.Contains("All")) {
					Console.WriteLine("RepairSupension=true");
					Console.WriteLine("RepairBodywork=true");
				}
				else if (option.Contains("Bodywork")) {
					Console.WriteLine("RepairSupension=false");
					Console.WriteLine("RepairBodywork=true");
				}
				else if (option.Contains("Suspension")) {
					Console.WriteLine("RepairSupension=true");
					Console.WriteLine("RepairBodywork=false");
				}
				else {
					Console.WriteLine("RepairSupension=false");
					Console.WriteLine("RepairBodywork=false");
				}

			}
		}
    }
}
