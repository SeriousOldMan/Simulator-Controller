using System;
using System.Globalization;
using System.Text;
using System.Threading;
using PMRUDPProtocol;

namespace PMRUDPConnector
{
    public class PMRUDPConnector
    {
        private const int MAX_CARS = 128;
        private const int SECTOR_UPDATE_INTERVAL_MS = 50;
        
        private PMRUDPReceiver.PMRUDPReceiver receiver;
        private readonly CultureInfo enUS = new CultureInfo("en-US");

        private readonly bool[] sectorStarted = new bool[MAX_CARS];
        private readonly int[] previousSector = new int[MAX_CARS];
        private readonly float[] sector1Times = new float[MAX_CARS];
        private readonly float[] sector2Times = new float[MAX_CARS];
        private readonly float[] lastLapSector1Times = new float[MAX_CARS];
        private readonly float[] lastLapSector2Times = new float[MAX_CARS];
        private readonly float[] lastLapSector3Times = new float[MAX_CARS];
        private readonly float[] sectorStartTimes = new float[MAX_CARS];
        private readonly float[] previousLapTime = new float[MAX_CARS];
        private readonly float[] lastLapTimes = new float[MAX_CARS];
        private readonly object sectorLock = new object();
        private Thread sectorUpdateThread;
        private volatile bool stopThread;

        public PMRUDPConnector() : this(true)
        {
        }

        public PMRUDPConnector(bool enableSampler)
        {
            for (int i = 0; i < MAX_CARS; i++)
            {
                previousSector[i] = -1;
                sectorStarted[i] = false;
            }

            if (enableSampler)
            {
                sectorUpdateThread = new Thread(SectorUpdateWorker)
                {
                    IsBackground = true,
                    Priority = ThreadPriority.BelowNormal
                };
                sectorUpdateThread.Start();
            }
        }

        public int GetRemainingLaps()
        {
            var raceInfo = receiver.GetRaceInfo();
            var playerState = receiver.GetPlayerState();

            if (raceInfo.SessionIsLaps)
                return (int)(raceInfo.Duration - Math.Max(0, playerState.CurrentLap - 1));
            else
                try {
                    return (int)(GetRemainingTime() / (playerState.BestLapTime * 1000));
                }
                catch {
                    return 1;
                }
        }

        public long GetRemainingTime()
        {
            var raceInfo = receiver.GetRaceInfo();
            var playerState = receiver.GetPlayerState();

            if (raceInfo.SessionIsLaps)
                try {
                    return (long)(GetRemainingLaps() * playerState.BestLapTime * 1000);
                }
                catch {
                    return 60000;
                }
            else
                return (long)((raceInfo.Duration - (int)(raceInfo.SessionTimeElapsed * 1000)) * 1000);
        }

        private string GetWeather(string weather)
        {
            switch (weather.ToLower()) {
                case "hot":
                case "cold":
                    return "Dry";
                case "light rain":
                case "lightrain":
                    return "LightRain";
                case "rainfall":
                    return "HeavyRain";
                default:
                    return "Dry";
            }
        }

        public bool Open(string multiCastGroup = "224.0.0.150", int multiCastPort = 7576, bool useMultiCast = true)
        {
            try
            {
                if (receiver != null)
                    receiver.Stop();

                receiver = new PMRUDPReceiver.PMRUDPReceiver(multiCastPort, multiCastGroup, useMultiCast);
                
                bool started = receiver.Start();
				
				if (started) {
					started = false;
					
					for (int i = 0; i <= 3 && !started; i++)
						if (receiver.HasReceivedData())
							started = true;
						else
							Thread.Sleep(200);
				}

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
                stopThread = true;
                if (sectorUpdateThread != null && sectorUpdateThread.IsAlive)
                {
                    if (!sectorUpdateThread.Join(200))
                        sectorUpdateThread.Abort();
                }
                
                receiver?.Stop();
                receiver = null;
            }
            catch
            {
            }
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

                bool writeStandings = request != null && request.ToLower().Contains("standings");
                return writeStandings ? GenerateStandings() : GenerateTelemetry();
            }
            catch
            {
                return "[Session Data]\nActive=false\n";
            }
        }

        private string GenerateTelemetry()
        {
            var sb = new StringBuilder();
            var raceInfo = receiver.GetRaceInfo();
            var playerState = receiver.GetPlayerState();
            var playerTelem = receiver.GetPlayerTelemetry();
            var participants = receiver.GetAllParticipantStates();

            participants.Sort((a, b) => a.VehicleId.CompareTo(b.VehicleId));

            sb.Append("[Session Data]\n");

            if (raceInfo == null || playerState == null || playerTelem == null || participants == null)
            {
                sb.Append("Active=false\n");
                return sb.ToString();
            }

            sb.Append("Active=true\n");
            sb.AppendFormat("Paused={0}\n", raceInfo.State == UDPRaceSessionState.Active ? "false" : "true");
            
            string sessionType = raceInfo.Session.ToLower();
            if (sessionType.Contains("race"))
                sb.Append("Session=Race\n");
            else if (sessionType.Contains("qual"))
                sb.Append("Session=Qualification\n");
            else if (sessionType.Contains("practice"))
                sb.Append("Session=Practice\n");
            else
                sb.Append("Session=Other\n");

            sb.AppendFormat("Car={0}\n", NormalizeName(playerState.VehicleName));
            sb.AppendFormat("Track={0}-{1}\n", NormalizeName(raceInfo.Track), NormalizeName(raceInfo.Layout));

            sb.AppendFormat("FuelAmount={0}\n", F(playerTelem.Constant.FuelCapacity));

            sb.AppendFormat("SessionFormat={0}\n", raceInfo.SessionIsLaps ? "Laps" : "Time");
            sb.AppendFormat("SessionTimeRemaining={0}\n", L(GetRemainingTime()));
            sb.AppendFormat("SessionLapsRemaining={0}\n", I(GetRemainingLaps()));

            sb.Append("[Car Data]\n");
            sb.Append("MAP=n/a\n");
            sb.AppendFormat("TC={0}\n", (playerTelem.Setup.TCSLevel >= 0) ? I(playerTelem.Setup.TCSLevel) : "n/a");
            sb.AppendFormat("ABS={0}\n", (playerTelem.Setup.ABSLevel >= 0) ? I(playerTelem.Setup.ABSLevel) : "n/a");
            sb.AppendFormat("BB={0}\n", (playerTelem.Setup.BrakeBias >= 0) ? F((float)Math.Round(playerTelem.Setup.BrakeBias * 100, 2)) : "n/a");
            sb.Append("BodyworkDamage=0,0,0,0,0\n");
            sb.Append("SuspensionDamage=0,0,0,0\n");
            sb.AppendFormat("EngineDamage={0}\n", F(playerState.EngineDamage * 100));

            if (playerTelem != null)
            {
                sb.AppendFormat("FuelRemaining={0}\n", F(playerTelem.Drivetrain.FuelRemaining));

                if (playerTelem.Wheels.Count >= 4)
                {
                    var w = playerTelem.Wheels;
                    sb.AppendFormat("TyreTemperature={0},{1},{2},{3}\n",
                        F(w[0].TreadTemp[1]), F(w[1].TreadTemp[1]), F(w[2].TreadTemp[1]), F(w[3].TreadTemp[1]));
                    
                    sb.AppendFormat("TyreInnerTemperature={0},{1},{2},{3}\n",
                        F(w[0].TreadTemp[0]), F(w[1].TreadTemp[2]), F(w[2].TreadTemp[0]), F(w[3].TreadTemp[2]));
                    
                    sb.AppendFormat("TyreMiddleTemperature={0},{1},{2},{3}\n",
                        F(w[0].TreadTemp[1]), F(w[1].TreadTemp[1]), F(w[2].TreadTemp[1]), F(w[3].TreadTemp[1]));
                    
                    sb.AppendFormat("TyreOuterTemperature={0},{1},{2},{3}\n",
                        F(w[0].TreadTemp[2]), F(w[1].TreadTemp[0]), F(w[2].TreadTemp[2]), F(w[3].TreadTemp[0]));
                    
                    sb.AppendFormat("TyrePressure={0},{1},{2},{3}\n",
                        F(w[0].Pressure / 100000 * 14.5038f), F(w[1].Pressure / 100000 * 14.5038f),
                        F(w[2].Pressure / 100000 * 14.5038f), F(w[3].Pressure / 100000 * 14.5038f));
                    
                    // sb.Append("TyreWear=0,0,0,0\n");
                    
                    string tyreCompoundFront = !string.IsNullOrEmpty(playerState.TyreCompoundFront) ? playerState.TyreCompoundFront : "Dry";
					
					sb.AppendFormat("TyreCompoundRaw={0}\n", tyreCompoundFront);
					sb.AppendFormat("TyreCompoundRawFront={0}\n", tyreCompoundFront);
					sb.AppendFormat("TyreCompoundRawRear={0}\n", !string.IsNullOrEmpty(playerState.TyreCompoundRear) ? playerState.TyreCompoundRear : "Dry");
                    
                    sb.AppendFormat("BrakeTemperature={0},{1},{2},{3}\n",
                        F(w[0].BrakeTemp), F(w[1].BrakeTemp), F(w[2].BrakeTemp), F(w[3].BrakeTemp));
                }

                sb.Append("BrakeWear=0,0,0,0\n");

                if (playerTelem.Drivetrain.EngineCoolantTemperature > 0)
                    sb.AppendFormat("WaterTemperature={0}\n", F(playerTelem.Drivetrain.EngineCoolantTemperature));

                if (playerTelem.Drivetrain.EngineOilTemperature > 0)
                    sb.AppendFormat("OilTemperature={0}\n", F(playerTelem.Drivetrain.EngineOilTemperature));
            }

            int playerIndex = -1;
            for (int i = 0; i < participants.Count && i < MAX_CARS; i++)
            {
                if (participants[i].IsPlayer) { playerIndex = i; break; }
            }

            float sampledLastLapTime = 0;
            if (playerIndex >= 0)
            {
                lock (sectorLock)
                {
                    sampledLastLapTime = lastLapTimes[playerIndex];
                }
            }

            sb.Append("[Stint Data]\n");
            ParseDriverName(playerState.DriverName, out string forename, out string surname, out string nickname);
            sb.AppendFormat("DriverForname={0}\n", forename);
            sb.AppendFormat("DriverSurname={0}\n", surname);
            sb.AppendFormat("DriverNickname={0}\n", nickname);
            sb.AppendFormat("Position={0}\n", playerState.RacePos);
            sb.AppendFormat("LapValid={0}\n", playerState.LapValid ? "true" : "false");
            sb.AppendFormat("LapLastTime={0}\n", sampledLastLapTime > 0 ? I(sampledLastLapTime * 1000) : I(playerState.BestLapTime * 1000));
            sb.AppendFormat("LapBestTime={0}\n", I(playerState.BestLapTime * 1000));
            sb.AppendFormat("Sector={0}\n", Math.Min(playerState.CurrentSector, 2) + 1);
            sb.AppendFormat("Laps={0}\n", Math.Max(0, playerState.CurrentLap - 1));
            sb.AppendFormat("StintTimeRemaining={0}\n", L(GetRemainingTime()));
            sb.AppendFormat("DriverTimeRemaining={0}\n", L(GetRemainingTime()));
            sb.AppendFormat("InPit={0}\n", playerState.InPits ? "true" : "false");
            sb.AppendFormat("InPitLane={0}\n", playerState.InPitLane ? "true" : "false");

            sb.Append("[Track Data]\n");
            sb.AppendFormat("Length={0}\n", F(raceInfo.LayoutLength));
            sb.AppendFormat("Temperature={0}\n", F(raceInfo.TrackTemperature));
            sb.AppendFormat("Grip={0}\n", raceInfo.TrackGrip >= 0.9f ? "Optimum" : raceInfo.TrackGrip >= 0.7f ? "Green" : "Greasy");

            for (int i = 0; i < participants.Count; i++)
            {
                var t = receiver.GetParticpantTelemetry(participants[i].VehicleId);
                int carNum = i + 1;

                if (t != null)
                    sb.AppendFormat("Car.{0}.Position={1},{2}\n", carNum, t.Chassis.PosWS[0], t.Chassis.PosWS[2]);
                else
                    sb.AppendFormat("Car.{0}.Position=false\n", carNum);
            }

            sb.Append("[Weather Data]\n");
            sb.AppendFormat("Temperature={0}\n", F(raceInfo.AmbientTemperature));
            sb.AppendFormat("Weather={0}\n", GetWeather(raceInfo.Weather));
            sb.AppendFormat("Weather10Min={0}\n", GetWeather(raceInfo.Weather));
            sb.AppendFormat("Weather30Min={0}\n", GetWeather(raceInfo.Weather));

            sb.Append("[Debug Data]\n");
            sb.AppendFormat("GameMode={0}\n", raceInfo.GameMode);
            sb.AppendFormat("Flags={0}\n", playerState.Flags);
            sb.AppendFormat("LF Material={0}\n", playerTelem.Wheels[0].ContactMaterialHash);

            return sb.ToString();
        }

        private string GenerateStandings()
        {
            var sb = new StringBuilder();
            var raceInfo = receiver.GetRaceInfo();
            var participants = receiver.GetAllParticipantStates();

            sb.Append("[Position Data]\n");

            if (raceInfo == null || participants.Count == 0)
            {
                sb.Append("Active=false\n");
                sb.Append("Car.Count=0\n");
                sb.Append("Driver.Car=0\n");
                return sb.ToString();
            }

            participants.Sort((a, b) => a.VehicleId.CompareTo(b.VehicleId));

            sb.Append("Active=true\n");

            int playerCar = 0;
            for (int i = 0; i < participants.Count; i++)
            {
                if (participants[i].IsPlayer)
                {
                    playerCar = i + 1;
                    break;
                }
            }

            sb.AppendFormat("Driver.Car={0}\n", playerCar);

            for (int i = 0; i < participants.Count; i++)
            {
                var p = participants[i];
                int carNum = i + 1;

                sb.AppendFormat("Car.{0}.Nr={1}\n", carNum, p.VehicleId);
                sb.AppendFormat("Car.{0}.ID={1}\n", carNum, p.VehicleId + 1);
                sb.AppendFormat("Car.{0}.Class={1}\n", carNum, p.VehicleClass);
                sb.AppendFormat("Car.{0}.Position={1}\n", carNum, p.RacePos);
                sb.AppendFormat("Car.{0}.Laps={1}\n", carNum, Math.Max(0, p.CurrentLap - 1));
                sb.AppendFormat("Car.{0}.Lap.Running={1}\n", carNum, F(p.LapProgress));
                sb.AppendFormat("Car.{0}.Lap.Running.Valid={1}\n", carNum, p.LapValid ? "true" : "false");
                
				float currentLapTime = p.CurrentLapTime;
                
				if (currentLapTime > 0)
                    sb.AppendFormat("Car.{0}.Lap.Running.Time={1}\n", carNum, I(currentLapTime * 1000));
				
                float lastLapTime;
                float s1Time, s2Time, s3Time;
                
                lock (sectorLock)
                {
                    lastLapTime = lastLapTimes[i];
					
                    s1Time = lastLapSector1Times[i];
                    s2Time = lastLapSector2Times[i];
                    s3Time = lastLapSector3Times[i];
                }
                
                if (lastLapTime > 0)
                {
                    sb.AppendFormat("Car.{0}.Time={1}\n", carNum, I(lastLapTime * 1000));
					
					if (s1Time != 0 && s2Time != 0 && s3Time != 0)
						sb.AppendFormat("Car.{0}.Time.Sectors={1},{2},{3}\n", carNum,
							I(s1Time * 1000),
							I(s2Time * 1000),
							I(s3Time * 1000));
                }
                else
                    sb.AppendFormat("Car.{0}.Time={1}\n", carNum, I(p.BestLapTime * 1000));
                
                sb.AppendFormat("Car.{0}.Car={1}\n", carNum, NormalizeName(p.VehicleName));

                ParseDriverName(p.DriverName, out string forename, out string surname, out string nickname);
                sb.AppendFormat("Car.{0}.Driver.Forname={1}\n", carNum, forename);
                sb.AppendFormat("Car.{0}.Driver.Surname={1}\n", carNum, surname);
                sb.AppendFormat("Car.{0}.Driver.Nickname={1}\n", carNum, nickname);
                sb.AppendFormat("Car.{0}.InPitLane={1}\n", carNum, p.InPitLane ? "true" : "false");
                sb.AppendFormat("Car.{0}.InPit={1}\n", carNum, p.InPits ? "true" : "false");
            }

            sb.AppendFormat("Car.Count={0}\n", participants.Count);

            return sb.ToString();
        }

        private string NormalizeName(string name)
        {
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
                nickname = parts[0].Length > 0 ? parts[0].Substring(0, 1) : "";
            }
            else
            {
                forename = parts[0];
                surname = parts[parts.Length - 1];
                nickname = forename.Substring(0, 1) + surname.Substring(0, 1);
            }
        }

        private string F(float value)
        {
            return value.ToString("F2", enUS);
        }

        private string I(float value)
        {
            return ((int)value).ToString(enUS);
        }

        private string L(float value)
        {
            return ((long)value).ToString(enUS);
        }

        private string I(int value)
        {
            return value.ToString(enUS);
        }

        private void SectorUpdateWorker()
        {
            while (!stopThread)
            {
                try
                {
                    if (receiver != null && receiver.HasReceivedData())
                    {
                        var participants = receiver.GetAllParticipantStates();
                        if (participants != null)
                        {
                            for (int i = 0; i < participants.Count && i < MAX_CARS; i++)
                            {
                                UpdateSectorTimes(participants[i], i);
                            }
                        }
                    }
                    
                    Thread.Sleep(SECTOR_UPDATE_INTERVAL_MS);
                }
                catch
                {
                    Thread.Sleep(SECTOR_UPDATE_INTERVAL_MS);
                }
            }
        }

        private void UpdateSectorTimes(UDPParticipantRaceState state, int carIndex)
        {
            if (carIndex >= MAX_CARS)
                return;

            int currentSector = Math.Min(state.CurrentSector, 2);
            float currentTime = state.CurrentLapTime;

            lock (sectorLock)
            {
                int prevSector = previousSector[carIndex];

                if (!sectorStarted[carIndex])
                {
                    if ((currentSector != 0) && (prevSector == -1))
                        previousSector[carIndex] = currentSector;
                    else if ((prevSector > 0) && (currentSector == 0))
                    {
                        sectorStarted[carIndex] = true;
                        sectorStartTimes[carIndex] = 0;
                        previousSector[carIndex] = 0;
                    }

                    return;
                }

                if (currentSector != prevSector)
                {
                    if (previousSector[carIndex] == 0)
                        sector1Times[carIndex] = currentTime - sectorStartTimes[carIndex];
                    else if (previousSector[carIndex] == 1)
                        sector2Times[carIndex] = currentTime - sectorStartTimes[carIndex];
                    else {
                        lastLapSector1Times[carIndex] = sector1Times[carIndex];
                        lastLapSector2Times[carIndex] = sector2Times[carIndex];
                        lastLapSector3Times[carIndex] = previousLapTime[carIndex] - sectorStartTimes[carIndex] + (currentTime / 2);

                        lastLapTimes[carIndex] = lastLapSector1Times[carIndex] + lastLapSector2Times[carIndex] + lastLapSector3Times[carIndex];
						
						sector1Times[carIndex] = 0;
						sector2Times[carIndex] = 0;
                    }

                    previousSector[carIndex] = currentSector;
                    sectorStartTimes[carIndex] = (currentSector == 0) ? 0 : currentTime;
                }

                previousLapTime[carIndex] = currentTime;
            }
        }
    }
}
