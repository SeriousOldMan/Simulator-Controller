using RF2SHMReader.rFactor2Data;
using System;
using System.Text;
using System.Threading;
using static RF2SHMReader.rFactor2Constants;
using static RF2SHMReader.rFactor2Constants.rF2GamePhase;
using static RF2SHMReader.rFactor2Constants.rF2PitState;

namespace RF2SHMReader {
	public class SHMReader {
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

		public SHMReader() {
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

		public void ReadData() {
			rF2VehicleScoring playerScoring = GetPlayerScoring(ref scoring);
			rF2VehicleTelemetry playerTelemetry = GetPlayerTelemetry(playerScoring.mID, ref telemetry);

			Console.WriteLine("[Session Data]");
			if (connected) {
				Console.Write("Car="); Console.WriteLine(GetStringFromBytes(playerScoring.mVehicleName));
				Console.Write("Track="); Console.WriteLine(GetStringFromBytes(playerTelemetry.mTrackName));
				Console.Write("RaceFormat="); Console.WriteLine((scoring.mScoringInfo.mEndET < 0.0) ? "Lap" : "Time");
				Console.Write("FuelAmount="); Console.WriteLine(Math.Round(playerTelemetry.mFuelCapacity));
			}

			Console.WriteLine("[Stint Data]");
			Console.Write("Active="); Console.WriteLine((connected && (extended.mSessionStarted != 0)) ? "true" : "false");
			if (connected) {
				Console.Write("Paused="); Console.WriteLine(scoring.mScoringInfo.mGamePhase == (byte)PausedOrHeartbeat ? "true" : "false");

				string session;

				if (scoring.mScoringInfo.mSession >= 10 && scoring.mScoringInfo.mSession <= 13)
					session = "Race";
				else if (scoring.mScoringInfo.mSession >= 0 && scoring.mScoringInfo.mSession <= 4)
					session = "Practice";
				else if (scoring.mScoringInfo.mSession >= 5 && scoring.mScoringInfo.mSession <= 8)
					session = "Qualification";
				else
					session = "Other";

				Console.Write("Session="); Console.WriteLine(session);

				string forName = GetStringFromBytes(scoring.mScoringInfo.mPlayerName);

				if (forName.Contains(" ")) {
					string[] names = forName.Split(' ');

					Console.Write("DriverForname="); Console.WriteLine(names[0]);
					Console.Write("DriverSurname="); Console.WriteLine(names[1]);
					Console.Write("DriverNickname="); Console.WriteLine(names[0].Substring(0, 1) + names[1].Substring(0, 1));
				}
				else {
					Console.Write("DriverForname="); Console.WriteLine(forName);
					Console.WriteLine("DriverSurname=");
					Console.WriteLine("DriverNickname=");
				}

				Console.Write("LapLastTime="); Console.WriteLine(Math.Round(playerScoring.mLastLapTime * 1000));
				Console.Write("LapBestTime="); Console.WriteLine(Math.Round(playerScoring.mBestLapTime * 1000));

				Console.Write("Laps="); Console.WriteLine(playerScoring.mTotalLaps);

				Console.Write("RaceLapsRemaining="); Console.WriteLine(GetRemainingLaps(ref playerScoring));

				long time = GetRemainingTime(ref playerScoring);

				Console.Write("RaceTimeRemaining="); Console.WriteLine(time);
				Console.Write("StintTimeRemaining="); Console.WriteLine(time);
				Console.Write("DriverTimeRemaining="); Console.WriteLine(time);

				Console.Write("InPit="); Console.WriteLine(playerScoring.mPitState == (byte)Stopped ? "true" : "false");
			}

			Console.WriteLine("[Car Data]");
			if (connected) {
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

				string compound = GetStringFromBytes(playerTelemetry.mFrontTireCompoundName);

				Console.Write("TyreCompound="); Console.WriteLine(compound.Contains("Rain") ? "Wet" : "Dry");

				if (compound.Contains("Soft"))
					Console.WriteLine("TyreCompoundColor=Red");
				else if (compound.Contains("Medium"))
					Console.WriteLine("TyreCompoundColor=White");
				else if (compound.Contains("Hard"))
					Console.WriteLine("TyreCompoundColor=Blue");
				else
					Console.WriteLine("TyreCompoundColor=Black");

				Console.Write("BodyworkDamage=0, 0, 0, 0, "); Console.WriteLine(extended.mTrackedDamages[playerTelemetry.mID].mAccumulatedImpactMagnitude / 1000);
				Console.WriteLine("SuspensionDamage=0, 0, 0, 0");
			}

			Console.WriteLine("[Track Data]");

			if (connected) {
				Console.WriteLine("Grip=Optimum");
				Console.Write("Temperature="); Console.WriteLine(scoring.mScoringInfo.mTrackTemp);
			}

			Console.WriteLine("[Weather Data]");

			if (connected) {
				Console.Write("Temperature="); Console.WriteLine(scoring.mScoringInfo.mAmbientTemp);

				string theWeather = GetWeather(scoring.mScoringInfo.mDarkCloud, scoring.mScoringInfo.mRaining);

				Console.Write("Weather="); Console.WriteLine(theWeather);
				Console.Write("Weather10Min="); Console.WriteLine(theWeather);
				Console.Write("Weather30Min="); Console.WriteLine(theWeather);
			}

			Console.WriteLine("[Pitstop Data]");
			if (connected) {
				Console.Write("Category="); Console.Write(pitInfo.mPitMenu.mCategoryIndex);
				Console.Write(" -> "); Console.WriteLine(GetStringFromBytes(pitInfo.mPitMenu.mCategoryName));
				Console.Write("Choices="); Console.Write(pitInfo.mPitMenu.mChoiceIndex);
				Console.Write(" -> "); Console.WriteLine(GetStringFromBytes(pitInfo.mPitMenu.mChoiceString));
				Console.Write("NumChoices="); Console.WriteLine(pitInfo.mPitMenu.mNumChoices);
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

		private long GetRemainingLaps(ref rF2VehicleScoring playerScoring) {
			if (playerScoring.mTotalLaps < 1)
				return 0;

			if (scoring.mScoringInfo.mEndET <= 0.0) {
				return scoring.mScoringInfo.mMaxLaps - playerScoring.mTotalLaps;
			}
			else {
				if (playerScoring.mLastLapTime > 0)
					return (long)Math.Round(GetRemainingTime(ref playerScoring) / (playerScoring.mLastLapTime * 1000)) + 1;
				else
					return 0;
			}
		}

		private long GetRemainingTime(ref rF2VehicleScoring playerScoring) {
			if (playerScoring.mTotalLaps < 1)
				return 0;

			if (scoring.mScoringInfo.mEndET > 0.0) {
				return (long)((scoring.mScoringInfo.mEndET - (playerScoring.mLastLapTime * playerScoring.mTotalLaps)) * 1000);
			}
			else {
				return (long)(GetRemainingLaps(ref playerScoring) * playerScoring.mLastLapTime * 1000);
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

		private void ExecuteRefuelCommand(string fuelArgument) {
			int targetFuel = (int)Double.Parse(fuelArgument);

			SelectPitstopCategory("Fuel");

			int deltaFuel = targetFuel - pitInfo.mPitMenu.mChoiceIndex;

			if (deltaFuel > 0)
				SendPitstopCommand(new string('+', deltaFuel));
		}

		private void ExecuteTyreCompoundCommand(string[] tyreArgument) {
			string compound = tyreArgument[0];
			string compoundColor = tyreArgument[1];
		}

		private void ExecuteTyreSetCommand(string tyreSetArgument) {
			int tyreSet = (int)Int16.Parse(tyreSetArgument);
		}

		private void ExecuteTyrePressureCommand(string[] tyreArgument) {
			int pressureFL = (int)GetKpa(Double.Parse(tyreArgument[0]));
			int pressureFR = (int)GetKpa(Double.Parse(tyreArgument[1]));
			int pressureRL = (int)GetKpa(Double.Parse(tyreArgument[2]));
			int pressureRR = (int)GetKpa(Double.Parse(tyreArgument[3]));
		}

		private void ExecuteRepairCommand(string repairType) {
			switch (repairType) {
				case "Bodywork":

					break;
				case "Suspension":

					break;
			}
		}

		public void ExecutePitstopCommand(string command, string[] arguments) {
			if (!this.connected || this.extended.mHWControlInputEnabled == 0)
				return;

			switch (command) {
				case "Refuel":
					ExecuteRefuelCommand(arguments[1]);
					break;
				case "Tyre Compound":
					ExecuteTyreCompoundCommand(arguments[1].Split(';'));
					break;
				case "Tyre Set":
					ExecuteTyreSetCommand(arguments[1]);
					break;
				case "Tyre Pressure":
					ExecuteTyrePressureCommand(arguments[1].Split(';'));
					break;
				case "Repair":
					ExecuteRepairCommand(arguments[1]);
					break;
			}
		}

		private void SelectPitstopCategory(string category) {
			while (category != GetStringFromBytes(pitInfo.mPitMenu.mCategoryName)) {
				SendPitstopCommand("D");

				pitInfoBuffer.GetMappedData(ref pitInfo);
			}
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
    }
}
