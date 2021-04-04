using RF2SHMReader.rFactor2Data;
using System;
using System.Text;
using static RF2SHMReader.rFactor2Constants;
using static RF2SHMReader.rFactor2Constants.rF2GamePhase;
using static RF2SHMReader.rFactor2Constants.rF2PitState;

namespace RF2SHMReader {
	public class SHMReader {
		public static bool useStockCarRulesPlugin = false;

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

		public SHMReader(){
		}
	
		public void Run() {
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

			rF2VehicleScoring playerScoring = GetPlayerScoring(ref scoring);
			rF2VehicleTelemetry playerTelemetry = GetPlayerTelemetry(playerScoring.mID, ref telemetry);

			Console.WriteLine("[Race Data]");
			if (connected) {
				Console.Write("Track="); Console.WriteLine(GetStringFromBytes(playerScoring.mVehicleName));
				Console.Write("Car="); Console.WriteLine(GetStringFromBytes(playerTelemetry.mTrackName));
				Console.Write("RaceFormat="); Console.WriteLine("Time");
				Console.Write("FuelAmount="); Console.WriteLine(Math.Round(playerTelemetry.mFuelCapacity));
			}

			Console.WriteLine("[Stint Data]");
			Console.Write("Active="); Console.WriteLine(connected ? "true" : "false");
			if (connected) {
				Console.Write("Paused="); Console.WriteLine(scoring.mScoringInfo.mGamePhase == (byte)PausedOrHeartbeat ? "true" : "false");

				string session;

				if (scoring.mScoringInfo.mSession >= 10 && scoring.mScoringInfo.mSession <= 13)
					session = "RACE";
				else if (scoring.mScoringInfo.mSession >= 1 && scoring.mScoringInfo.mSession <= 4)
					session = "PRACTICE";
				else if (scoring.mScoringInfo.mSession >= 1 && scoring.mScoringInfo.mSession <= 4)
					session = "QUALIFICATION";
				else
					session = "OTHER";

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

				Console.Write("LapLastTime="); Console.WriteLine(Math.Round((playerScoring.mLastLapTime * 1000)));
				Console.Write("LapBestTime="); Console.WriteLine(Math.Round((playerScoring.mBestLapTime * 1000)));

				Console.Write("Laps="); Console.WriteLine(playerScoring.mTotalLaps);

				Console.Write("RaceTimeRemaining="); Console.WriteLine(scoring.mScoringInfo.mEndET);
				Console.Write("StintTimeRemaining="); Console.WriteLine(scoring.mScoringInfo.mEndET);
				Console.Write("DriverTimeRemaining="); Console.WriteLine(scoring.mScoringInfo.mEndET);

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

				Console.Write("TyreCompound="); Console.WriteLine(playerTelemetry.mFrontTireCompoundName);
				Console.Write("BodyworkDamage=0, 0, 0, 0, "); Console.WriteLine(extended.mTrackedDamages[playerTelemetry.mID].mAccumulatedImpactMagnitude);
				Console.WriteLine("SuspensionDamage=0, 0, 0, 0");
			}

			Console.WriteLine("[Track Data]");

			if (connected) {
				Console.WriteLine("Grip=OPTIMUM");
				Console.Write("Temperature="); Console.WriteLine(scoring.mScoringInfo.mTrackTemp);
			}

			Console.WriteLine("[Weather Data]");

			if (connected) {
				Console.Write("Temperature="); Console.WriteLine(scoring.mScoringInfo.mAmbientTemp);

				string theWeather;

				if (scoring.mScoringInfo.mRaining == 0.0)
					theWeather = "Dry";
				else if (scoring.mScoringInfo.mRaining <= 0.2)
					theWeather = "Drizzle";
				else if (scoring.mScoringInfo.mRaining <= 0.4)
					theWeather = "LightRain";
				else if (scoring.mScoringInfo.mRaining <= 0.6)
					theWeather = "MediumRain";
				else if (scoring.mScoringInfo.mRaining <= 0.8)
					theWeather = "HeavyRain";
				else
					theWeather = "Thunderstorm";

				Console.Write("Weather="); Console.WriteLine(theWeather);
				Console.Write("Weather10Min="); Console.WriteLine(theWeather);
				Console.Write("Weather30Min="); Console.WriteLine(theWeather);
			}
		}

		private static double GetCelcius(double kelvin) {
			return kelvin - 273.15;
		}

		private static double GetPsi(double kPa) {
			return kPa / 6.895;
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
	}
}
