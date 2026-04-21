using F125UDPProtocol;
using System;
using System.Configuration;
using System.Globalization;
using System.Text;
using System.Threading;
using static System.Collections.Specialized.BitVector32;

namespace F125UDPConnector
{
    public class F125UDPConnector
    {
        private F125UDPReceiver.F125UDPReceiver receiver;
        private readonly CultureInfo enUS = new CultureInfo("en-US");

        public F125UDPConnector()
        {
        }

        public bool Open(string host = "127.0.0.1", int port = 20777, bool useMulticast = true) // May change from 127.0.0.1
        {
            try
            {
                if (receiver != null)
                    receiver.Stop();

                receiver = new F125UDPReceiver.F125UDPReceiver(port, host, useMulticast);

                bool started = receiver.Start();

				/*
                if (started)
                {
                    started = false;

                    for (int i = 0; i <= 3 && !started; i++)
                        if (receiver.HasReceivedData())
                            started = true;
                        else
                            Thread.Sleep(200);
                }
				*/

                if (!started)
                    receiver = null;

                return started;
            }
            catch
            {
                return false;
            }
        }

        public void Close()
        {
            try
            {
                receiver?.Stop();
                receiver = null;
            }
            catch { }
        }

        public bool HasData(string type = "Telemetry")
        {
            if (receiver == null || receiver.GetSessionData() == null
                                 || receiver.GetLapData() == null
                                 || receiver.GetParticipantsData() == null)
                return false;

            if (type == "Telemetry")
                return (receiver.GetMotionData() != null &&
                        receiver.GetCarTelemetryData() != null &&
                        receiver.GetCarStatusData() != null &&
                        receiver.GetCarDamageData() != null &&
                        receiver.GetCarSetupData() != null);
            else
                return true;
        }

        public string Call(string request)
        {
            try
            {
                if (receiver == null)
                {
                    if (!Open())
                        return "[Session Data]\nActive=false\n";
                }
                else if (!receiver.IsActive())
                    return "[Session Data]\nActive=false\n";
                
                if (request != null && request.ToLower().Contains("standings"))
                    return GenerateStandings();
                else
                    return GenerateTelemetry();
            }
            catch
            {
                return "[Session Data]\nActive=false\n";
            }
        }

        // ── Telemetry Output ──────────────────────────────────────────

        private int previousLap = 0;
        private int lastLap = 0;

        private string GenerateTelemetry()
        {
            var sb = new StringBuilder();

            sb.Append("[Session Data]\n");

            for (int i = 0; i < 15; i++)
                if (HasData("Telemetry"))
                    break;
                else
                    Thread.Sleep(100);

            if (!HasData("Telemetry"))
                {
                    sb.Append("Active=false\n");
                    return sb.ToString();
                }

            var session = receiver.GetSessionData();
            var lapData = receiver.GetLapData();
            var motion = receiver.GetMotionData();
            var telemetry = receiver.GetCarTelemetryData();
            var status = receiver.GetCarStatusData();
            var damage = receiver.GetCarDamageData();
            var setup = receiver.GetCarSetupData();
            var participants = receiver.GetParticipantsData();

            int playerIdx = session.Header.PlayerCarIndex;
            int numCars = participants != null ? participants.NumActiveCars : 0;

            var playerLap = lapData.LapDataArr[playerIdx];
            var playerHistory = receiver.GetSessionHistoryData(playerIdx);

            int GetRemainingLaps() {
                if (session.SessionType == 18)
                    return 1;
                else if (session.SessionType >= 10)
                    return (int)(session.TotalLaps - Math.Max(0, playerLap.CurrentLapNum - 1));
                else
                    try
                    {
                        uint bestLap;

                        if (playerHistory != null && playerHistory.BestLapTimeLapNum > 0
                            && playerHistory.BestLapTimeLapNum <= playerHistory.NumLaps)
                            bestLap = playerHistory.LapHistories[playerHistory.BestLapTimeLapNum - 1].LapTimeInMS;
                        else
                            bestLap = playerLap.LastLapTimeInMS;

                        return (int)(GetRemainingTime() / bestLap);
                    }
                    catch
                    {
                        return 1;
                    }
            }

            long GetRemainingTime()
            {
                if (session.SessionType == 18)
                    return 60000;
                else if (session.SessionType >= 10)
                    try
                    {
                        uint bestLap;

                        if (playerHistory != null && playerHistory.BestLapTimeLapNum > 0
                            && playerHistory.BestLapTimeLapNum <= playerHistory.NumLaps)
                            bestLap = playerHistory.LapHistories[playerHistory.BestLapTimeLapNum - 1].LapTimeInMS;
                        else
                            bestLap = playerLap.LastLapTimeInMS;

                        return (long)(GetRemainingLaps() * bestLap);
                    }
                    catch
                    {
                        return 60000;
                    }
                else
                    return (long)(session.SessionTimeLeft * 1000);
            }

            if (playerLap == null)
            {
                sb.Append("Active=false\n");
                return sb.ToString();
            }

            sb.Append("Active=true\n");
            sb.AppendFormat("Paused={0}\n", session.GamePaused != 0 || receiver.IsPaused() ? "true" : "false");
            sb.AppendFormat("Session={0}\n", F125Constants.GetSessionType(session.SessionType));

            // Car name – use team name
            string carName = "F1 25";
            if (participants != null && playerIdx < numCars)
                carName = NormalizeName(F125Constants.GetTeamName(participants.Participants[playerIdx].TeamId));
            sb.AppendFormat("Car={0}\n", carName);

            // Track
            sb.AppendFormat("Track={0}\n", NormalizeName(F125Constants.GetTrackName((byte)session.TrackId)));
            sb.AppendFormat("TrackLength={0}\n", I(session.TrackLength));

            // Fuel capacity
            if (status != null)
                sb.AppendFormat("FuelAmount={0}\n", F(status.CarStatus[playerIdx].FuelCapacity));

            // Session format & remaining
            bool isLaps = session.SessionType >= 10; // Race types
            sb.AppendFormat("SessionFormat={0}\n", isLaps ? "Laps" : "Time");

            if (playerLap.ResultStatus >= 3)
            {
                sb.AppendFormat("SessionTimeRemaining=0\n");
                sb.AppendFormat("SessionLapsRemaining=0\n");
            }
            else
            {
                sb.AppendFormat("SessionTimeRemaining={0}\n", L(GetRemainingTime()));
                sb.AppendFormat("SessionLapsRemaining={0}\n", I(GetRemainingLaps()));
            }

            // ── [Car Data] ──────────────────────────────────────────────
            sb.Append("[Car Data]\n");

            CarStatusData playerStatus = (status != null) ? status.CarStatus[playerIdx] : null;
            CarTelemetryData playerTelem = (telemetry != null) ? telemetry.CarTelemetry[playerIdx] : null;
            CarDamageData playerDamage = (damage != null) ? damage.CarDamage[playerIdx] : null;
            int[] wr = F125Constants.WheelReorder;

            // Engine map
            if (playerStatus != null)
            {
                if (playerStatus.FuelMix < 4)
                    sb.AppendFormat("MAP={0}\n", playerStatus.FuelMix + 1);
                else
                    sb.Append("MAP=n/a\n");
                sb.AppendFormat("TC={0}\n", "n/a"); // I(playerStatus.TractionControl));
                sb.AppendFormat("ABS={0}\n", "n/a"); // I(playerStatus.AntiLockBrakes));
                sb.AppendFormat("BB={0}\n", F(playerStatus.FrontBrakeBias));
            }
            else
            {
                sb.Append("MAP=n/a\nTC=n/a\nABS=n/a\nBB=n/a\n");
            }

            // Bodywork damage
            if (playerDamage != null)
            {
                int frontDamage = (playerDamage.FrontLeftWingDamage +
                                   playerDamage.FrontRightWingDamage);
                int rearDamage = (playerDamage.RearWingDamage + playerDamage.DiffuserDamage);
                int leftDamage = playerDamage.SidepodDamage;
                int rightDamage = playerDamage.SidepodDamage;

                sb.AppendFormat("BodyworkDamage={0},{1},{2},{3},{4}\n",
                    I(frontDamage), I(rearDamage), I(leftDamage), I(rightDamage),
                    I(frontDamage + rearDamage + leftDamage + rightDamage));

                /*
                // Suspension damage
                sb.AppendFormat("SuspensionDamage={0},{1},{2},{3}\n",
                    I(playerDamage.TyresDamage[wr[0]]),
                    I(playerDamage.TyresDamage[wr[1]]),
                    I(playerDamage.TyresDamage[wr[2]]),
                    I(playerDamage.TyresDamage[wr[3]]));
                */
                sb.Append("SuspensionDamage=0,0,0,0\n");

                sb.AppendFormat("EngineDamage={0}\n", I((playerDamage.EngineDamage + playerDamage.GearBoxDamage) / 2));

                /*
                // Damage
                sb.AppendFormat("DRSFault={0}\n", playerDamage.DRSFault != 0 ? "true" : "false");
                sb.AppendFormat("ERSFault={0}\n", playerDamage.ERSFault != 0 ? "true" : "false");
                */

                // Tyre wear
                sb.AppendFormat("TyreWear={0},{1},{2},{3}\n",
                    F(playerDamage.TyresWear[wr[0]]),
                    F(playerDamage.TyresWear[wr[1]]),
                    F(playerDamage.TyresWear[wr[2]]),
                    F(playerDamage.TyresWear[wr[3]]));
            }
            else
            {
                sb.Append("BodyworkDamage=0,0,0,0,0\n");
                sb.Append("SuspensionDamage=0,0,0,0\n");
                sb.Append("EngineDamage=0\n");
            }

            // Remaining Fuel
            if (playerStatus != null)
            {
                sb.AppendFormat("FuelRemaining={0}\n", F(playerStatus.FuelInTank));
                // sb.AppendFormat("FuelRemainingLaps={0}\n", F(playerStatus.FuelRemainingLaps));
            }

            // Tyre temperatures & pressures
            if (playerTelem != null)
            {
                sb.AppendFormat("TyreTemperature={0},{1},{2},{3}\n",
                    I(playerTelem.TyresSurfaceTemperature[wr[0]]),
                    I(playerTelem.TyresSurfaceTemperature[wr[1]]),
                    I(playerTelem.TyresSurfaceTemperature[wr[2]]),
                    I(playerTelem.TyresSurfaceTemperature[wr[3]]));

                sb.AppendFormat("TyreInnerTemperature={0},{1},{2},{3}\n",
                    I(playerTelem.TyresInnerTemperature[wr[0]]),
                    I(playerTelem.TyresInnerTemperature[wr[1]]),
                    I(playerTelem.TyresInnerTemperature[wr[2]]),
                    I(playerTelem.TyresInnerTemperature[wr[3]]));

                sb.AppendFormat("TyreMiddleTemperature={0},{1},{2},{3}\n",
                    I(playerTelem.TyresSurfaceTemperature[wr[0]]),
                    I(playerTelem.TyresSurfaceTemperature[wr[1]]),
                    I(playerTelem.TyresSurfaceTemperature[wr[2]]),
                    I(playerTelem.TyresSurfaceTemperature[wr[3]]));

                sb.AppendFormat("TyreOuterTemperature={0},{1},{2},{3}\n",
                    I(playerTelem.TyresSurfaceTemperature[wr[0]]),
                    I(playerTelem.TyresSurfaceTemperature[wr[1]]),
                    I(playerTelem.TyresSurfaceTemperature[wr[2]]),
                    I(playerTelem.TyresSurfaceTemperature[wr[3]]));

                // Tyre pressure 
                sb.AppendFormat("TyrePressure={0},{1},{2},{3}\n",
                    F(playerTelem.TyresPressure[wr[0]]),
                    F(playerTelem.TyresPressure[wr[1]]),
                    F(playerTelem.TyresPressure[wr[2]]),
                    F(playerTelem.TyresPressure[wr[3]]));

                // Brake temperature
                sb.AppendFormat("BrakeTemperature={0},{1},{2},{3}\n",
                    I(playerTelem.BrakesTemperature[wr[0]]),
                    I(playerTelem.BrakesTemperature[wr[1]]),
                    I(playerTelem.BrakesTemperature[wr[2]]),
                    I(playerTelem.BrakesTemperature[wr[3]]));
            }

            // Brake wear
            if (playerDamage != null)
            {
                sb.AppendFormat("BrakeWear={0},{1},{2},{3}\n",
                    I(playerDamage.BrakesDamage[wr[0]]),
                    I(playerDamage.BrakesDamage[wr[1]]),
                    I(playerDamage.BrakesDamage[wr[2]]),
                    I(playerDamage.BrakesDamage[wr[3]]));
            }
            else
                sb.Append("BrakeWear=0,0,0,0\n");

            // Tyre compound
            if (playerStatus != null)
            {
                string compound = F125Constants.GetTyreCompound(playerStatus.ActualTyreCompound);
                string visual = F125Constants.GetTyreVisualCompound(playerStatus.VisualTyreCompound);
                sb.AppendFormat("TyreCompoundRaw={0}\n", visual);
            }

            // Engine/water temperature
            if (playerTelem != null)
                sb.AppendFormat("WaterTemperature={0}\n", I(playerTelem.EngineTemperature));

            /*
            // ERS data
            if (playerStatus != null)
            {
                sb.AppendFormat("ERSLevel={0}\n", F(playerStatus.ERSStoreEnergy / 4000000.0f * 100));
                sb.AppendFormat("ERSDeployMode={0}\n", I(playerStatus.ERSDeployMode));
                sb.AppendFormat("ERSDeployedThisLap={0}\n", F(playerStatus.ERSDeployedThisLap));
                sb.AppendFormat("ERSHarvestedThisLapMGUK={0}\n", F(playerStatus.ERSHarvestedThisLapMGUK));
                sb.AppendFormat("ERSHarvestedThisLapMGUH={0}\n", F(playerStatus.ERSHarvestedThisLapMGUH));
            }

            // DRS (May be removed in F1 26 DLC)
            if (playerTelem != null)
                sb.AppendFormat("DRS={0}\n", playerTelem.DRS != 0 ? "true" : "false");
            if (playerStatus != null)
                sb.AppendFormat("DRSAllowed={0}\n", playerStatus.DRSAllowed != 0 ? "true" : "false");

            // Speed & RPM
            if (playerTelem != null)
            {
                sb.AppendFormat("Speed={0}\n", I(playerTelem.Speed));
                sb.AppendFormat("RPM={0}\n", I(playerTelem.EngineRPM));
                sb.AppendFormat("Gear={0}\n", I(playerTelem.Gear));
            }
            */

            // ── [Stint Data] ─────────────────────────────────────────────
            sb.Append("[Stint Data]\n");

            if (participants != null && playerIdx < numCars)
            {
                ParseDriverName(participants.Participants[playerIdx].Name,
                    out string forename, out string surname, out string nickname);
                sb.AppendFormat("DriverForname={0}\n", forename);
                sb.AppendFormat("DriverSurname={0}\n", surname);
                sb.AppendFormat("DriverNickname={0}\n", nickname);
            }

            sb.AppendFormat("Position={0}\n", I(playerLap.CarPosition));
            sb.AppendFormat("LapValid={0}\n", playerLap.CurrentLapInvalid == 0 ? "true" : "false");
            sb.AppendFormat("LapLastTime={0}\n", L(playerLap.LastLapTimeInMS));
            
            if (playerHistory != null && playerHistory.BestLapTimeLapNum > 0
                && playerHistory.BestLapTimeLapNum <= playerHistory.NumLaps)
            {
                var bestLap = playerHistory.LapHistories[playerHistory.BestLapTimeLapNum - 1];
                sb.AppendFormat("LapBestTime={0}\n", L(bestLap.LapTimeInMS));
            }
            else
                sb.AppendFormat("LapBestTime={0}\n", L(playerLap.LastLapTimeInMS));

            int lap;

            if (playerLap.ResultStatus >= 3)
                lap = previousLap + 1;
            else
            {
                lap = Math.Max(0, playerLap.CurrentLapNum - 1);

                previousLap = lap;
            }
					
            sb.AppendFormat("Sector={0}\n", I(playerLap.Sector + 1));
            sb.AppendFormat("Runninig={0}\n", F((session.TrackLength > 0) ?
													Math.Max(0, Math.Min(1, playerLap.LapDistance / session.TrackLength)) : 0));
            sb.AppendFormat("Laps={0}\n", I(lap));

            /*
            if (playerLap.Sector1TimeInMS > 0 || playerLap.Sector1TimeMinutes > 0)
                sb.AppendFormat("SectorTimes={0}", L(playerLap.Sector1TimeMinutes * 60000 + playerLap.Sector1TimeInMS));
            else
                sb.Append("SectorTimes=");
            
            if (playerLap.Sector2TimeInMS > 0 || playerLap.Sector2TimeMinutes > 0)
                sb.AppendFormat(",{0}\n", L(playerLap.Sector2TimeMinutes * 60000 + playerLap.Sector2TimeInMS));
            else
                sb.Append("\n");
            */

            sb.AppendFormat("StintTimeRemaining={0}\n", L(GetRemainingTime()));
            sb.AppendFormat("DriverTimeRemaining={0}\n", L(GetRemainingTime()));

            // Pit status
            bool inPitLane = playerLap.PitStatus == 1 || playerLap.PitStatus == 2;
            bool inPit = playerLap.PitStatus == 2;
            sb.AppendFormat("InPit={0}\n", inPit ? "true" : "false");
            sb.AppendFormat("InPitLane={0}\n", inPitLane ? "true" : "false");
            sb.AppendFormat("NumPitStops={0}\n", I(playerLap.NumPitStops));

            /*
            sb.AppendFormat("Penalties={0}\n", I(playerLap.Penalties));
            sb.AppendFormat("Warnings={0}\n", I(playerLap.TotalWarnings));
            sb.AppendFormat("CornerCuttingWarnings={0}\n", I(playerLap.CornerCuttingWarnings));
            */

            string penalty = receiver.GetLastPenalty();

            if (penalty != null)
                sb.AppendFormat("Penalty={0}\n", penalty);

            sb.AppendFormat("Warnings={0}\n", receiver.GetLastWarnings());

            // Delta
            sb.AppendFormat("GapAhead={0}\n",
                L(playerLap.DeltaToCarInFrontMinutes * 60000 + playerLap.DeltaToCarInFrontInMS));

            /*
            sb.AppendFormat("DeltaToLeader={0}\n",
                L(playerLap.DeltaToRaceLeaderMinutes * 60000 + playerLap.DeltaToRaceLeaderInMS));
            */

            if (lastLap != lap)
            {
                receiver.ClearLastPenalty();

                lastLap = lap;
            }

            // ── [Track Data] ─────────────────────────────────────────────
            sb.Append("[Track Data]\n");
            sb.AppendFormat("Length={0}\n", I(session.TrackLength));
            sb.AppendFormat("Temperature={0}\n", I(session.TrackTemperature));
            sb.AppendFormat("Grip={0}\n", session.Weather < 3 ? "Optimum" : "Wet"); // F1 25 doesn't expose grip level directly

            // Car pos
            if (motion != null && numCars > 0)
            {
                for (int i = 0; i < numCars; i++)
                {
                    var cm = motion.CarMotion[i];
                    sb.AppendFormat("Car.{0}.Position={1},{2}\n", i + 1,
                        cm.WorldPositionX.ToString("F1", enUS),
                        cm.WorldPositionZ.ToString("F1", enUS));
                }
            }

            /*
            // Safety car
            sb.AppendFormat("SafetyCarStatus={0}\n",
                session.SafetyCarStatus == 0 ? "None" :
                session.SafetyCarStatus == 1 ? "Full" :
                session.SafetyCarStatus == 2 ? "Virtual" : "FormationLap");
            */

            // ── [Weather Data] ───────────────────────────────────────────
            sb.Append("[Weather Data]\n");
            sb.AppendFormat("Temperature={0}\n", I(session.AirTemperature));
            sb.AppendFormat("Weather={0}\n", F125Constants.GetWeather(session.Weather));

            // Weather
            string weather10 = null;
            string weather30 = null;
            int rain10 = 0;
            int rain30 = 0;

            for (int i = 0; i < session.NumWeatherForecastSamples; i++)
            {
                var sample = session.WeatherForecastSamples[i];
                if (sample == null) continue;

                if (sample.TimeOffset < 10 && weather10 == null)
                {
                    weather10 = F125Constants.GetWeather(sample.Weather);
                    rain10 = sample.RainPercentage;
                }
                if (sample.TimeOffset >= 30 && sample.TimeOffset < 40 && weather30 == null)
                {
                    weather30 = F125Constants.GetWeather(sample.Weather);
                    rain30 = sample.RainPercentage;
                }
            }

            if (weather10 == null)
                weather10 = F125Constants.GetWeather(session.Weather);

            if (weather30 == null)
                weather30 = F125Constants.GetWeather(session.Weather);

            sb.AppendFormat("Weather10Min={0}\n", weather10);
            sb.AppendFormat("Weather30Min={0}\n", weather30);

            /*
            sb.AppendFormat("Rain10Min={0}\n", I(rain10));
            sb.AppendFormat("Rain30Min={0}\n", I(rain30));
            */

            // ── [Setup Data] ─────────────────────────────────────────────
            if (setup != null) {
                CarSetupData playerSetup = setup.CarSetups[playerIdx];

                if (playerSetup != null)
                {
                    sb.Append("[Setup Data]\n");

                    sb.AppendFormat("TyrePressureFL={0}\n", playerSetup.FrontLeftTyrePressure);
                    sb.AppendFormat("TyrePressureFR={0}\n", playerSetup.FrontRightTyrePressure);
                    sb.AppendFormat("TyrePressureRL={0}\n", playerSetup.RearLeftTyrePressure);
                    sb.AppendFormat("TyrePressureRR={0}\n", playerSetup.RearRightTyrePressure);
                }
            }

            return sb.ToString();
        }

        // ── Standings Output ──────────────────────────────────────────

        private string GenerateStandings()
        {
            var sb = new StringBuilder();

            sb.Append("[Position Data]\n");

            for (int i = 0; i < 15; i++)
                if (HasData("Standings"))
                    break;
                else
                    Thread.Sleep(100);

            if (!HasData("Standings"))
            {
                sb.Append("Car.Count=0\n");

                return sb.ToString();
            }

            var session = receiver.GetSessionData();
            var lapData = receiver.GetLapData();
            var participants = receiver.GetParticipantsData();

            int numCars = participants.NumActiveCars;
            int playerIdx = session.Header.PlayerCarIndex;

            sb.Append("Active=true\n");
            sb.AppendFormat("Driver.Car={0}\n", playerIdx + 1);

            for (int i = 0; i < numCars; i++)
            {
                var ld = lapData.LapDataArr[i];
                var part = participants.Participants[i];
                int carNum = i + 1;

                sb.AppendFormat("Car.{0}.Nr={1}\n", carNum, I(part.RaceNumber));
                sb.AppendFormat("Car.{0}.ID={1}\n", carNum, carNum);
                sb.AppendFormat("Car.{0}.Class={1}\n", carNum, F125Constants.GetClassName(session.Formula));
                sb.AppendFormat("Car.{0}.Position={1}\n", carNum, I(ld.CarPosition));
                sb.AppendFormat("Car.{0}.Laps={1}\n", carNum, I(Math.Max(0, ld.CurrentLapNum - 1)));
                
                // Lap progress: lapDistance / trackLength
                float running = (session.TrackLength > 0) ?
                    Math.Max(0, Math.Min(1, ld.LapDistance / session.TrackLength)) : 0;
                sb.AppendFormat("Car.{0}.Lap.Running={1}\n", carNum, F(running));
                sb.AppendFormat("Car.{0}.Lap.Running.Valid={1}\n", carNum,
                    ld.CurrentLapInvalid == 0 ? "true" : "false");

                if (ld.CurrentLapTimeInMS > 0)
                    sb.AppendFormat("Car.{0}.Lap.Running.Time={1}\n", carNum, L(ld.CurrentLapTimeInMS));

                // Last lap time
                sb.AppendFormat("Car.{0}.Time={1}\n", carNum, L(ld.LastLapTimeInMS));

                // Sector times from history
                var hist = receiver.GetSessionHistoryData(i);
                if (hist != null && ld.CurrentLapNum >= 2)
                {
                    int lastLapIdx = ld.CurrentLapNum - 2;
                    if (lastLapIdx >= 0 && lastLapIdx < hist.NumLaps)
                    {
                        var lapHist = hist.LapHistories[lastLapIdx];
                        long s1 = lapHist.Sector1TimeMinutes * 60000 + lapHist.Sector1TimeInMS;
                        long s2 = lapHist.Sector2TimeMinutes * 60000 + lapHist.Sector2TimeInMS;
                        long s3 = lapHist.Sector3TimeMinutes * 60000 + lapHist.Sector3TimeInMS;

                        if (s1 > 0 && s2 > 0 && s3 > 0)
                            sb.AppendFormat("Car.{0}.Time.Sectors={1},{2},{3}\n", carNum, L(s1), L(s2), L(s3));
                    }
                }

                // Car/team name
                sb.AppendFormat("Car.{0}.Car={1}\n", carNum,
                    NormalizeName(F125Constants.GetTeamName(part.TeamId)));

                // Driver name
                ParseDriverName(part.Name, out string forename, out string surname, out string nickname);
                sb.AppendFormat("Car.{0}.Driver.Forname={1}\n", carNum, forename);
                sb.AppendFormat("Car.{0}.Driver.Surname={1}\n", carNum, surname);
                sb.AppendFormat("Car.{0}.Driver.Nickname={1}\n", carNum, nickname);

                bool carInPitLane = ld.PitStatus == 1 || ld.PitStatus == 2;
                bool carInPit = ld.PitStatus == 2;
                sb.AppendFormat("Car.{0}.InPitLane={1}\n", carNum, carInPitLane ? "true" : "false");
                sb.AppendFormat("Car.{0}.InPit={1}\n", carNum, carInPit ? "true" : "false");
            }

            sb.AppendFormat("Car.Count={0}\n", numCars);

            return sb.ToString();
        }

        // ── Helpers ───────────────────────────────────────────────────

        private string NormalizeName(string name)
        {
            if (string.IsNullOrEmpty(name)) return "";
            return name.Replace("/", " ").Replace(":", " ").Replace("*", " ")
                       .Replace("?", " ").Replace("<", " ").Replace(">", " ")
                       .Replace("|", " ");
        }

        private void ParseDriverName(string fullName, out string forename, out string surname, out string nickname)
        {
            if (string.IsNullOrEmpty(fullName))
            {
                forename = "";
                surname = "";
                nickname = "";
                return;
            }

            string[] parts = fullName.Trim().Split(new[] { ' ' }, StringSplitOptions.RemoveEmptyEntries);
            if (parts.Length == 0)
            {
                forename = "";
                surname = "";
                nickname = "";
            }
            else if (parts.Length == 1)
            {
                forename = parts[0];
                surname = "";

                string newName = F125Constants.GetDriverName(forename);

                if (newName == forename)
                    nickname = parts[0].Length > 0 ? parts[0].Substring(0, 1) : "";
                else
                    ParseDriverName(newName, out forename, out surname, out nickname);
            }
            else
            {
                forename = parts[0];
                surname = parts[parts.Length - 1];
                nickname = forename.Substring(0, 1) + surname.Substring(0, 1);
            }
        }

        private string F(float value) { return value.ToString("F2", enUS); }
        private string I(float value) { return ((int)value).ToString(enUS); }
        private string I(int value) { return value.ToString(enUS); }
        private string I(uint value) { return value.ToString(enUS); }
        private string I(ushort value) { return value.ToString(enUS); }
        private string I(byte value) { return value.ToString(enUS); }
        private string I(sbyte value) { return value.ToString(enUS); }
        private string L(float value) { return ((long)value).ToString(enUS); }
        private string L(long value) { return value.ToString(enUS); }
        private string L(uint value) { return value.ToString(enUS); }
    }
}
