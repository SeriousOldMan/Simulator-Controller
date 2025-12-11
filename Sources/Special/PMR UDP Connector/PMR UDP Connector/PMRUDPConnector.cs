using System;
using System.Collections.Generic;
using System.Globalization;
using System.Net.Sockets;
using System.Text;
using System.Threading;

namespace PMRUDPConnector
{
    public class PMRUDPConnector
    {
        private PMRUDPReceiver receiver;
        private readonly CultureInfo enUS = new CultureInfo("en-US");

        public PMRUDPConnector()
        {
        }

        public bool Open()
        {
            try
            {
                if (receiver != null)
                    receiver.Stop();

                receiver = new PMRUDPReceiver();
                
                bool started = receiver.Start();
				
				if (started) {
					started = false;
					
					for (int i = 0; i <= 3 && !started; i++)
						if (receiver.HasReceivedData())
							started = true;
						else
							Thread.Sleep(100);
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

                bool writeStandings = request != null && request.Contains("Standings");
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
            // GameMode ???
            
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

            sb.AppendFormat("SessionFormat={0}\n", raceInfo.IsLaps ? "Laps" : "Time");
            sb.AppendFormat("SessionTimeRemaining={0}\n", I(raceInfo.Duration * 1000)); // session time abziehen
            sb.AppendFormat("SessionLapsRemaining={0}\n", 0); // Berechnung ????

            sb.Append("[Car Data]\n");
            sb.Append("MAP=n/a\n");
            sb.AppendFormat("TC={0}\n", (playerTelem.Setup.TCSLevel >= 0) ? I(playerTelem.Setup.TCSLevel) : "n/a");
            sb.AppendFormat("ABS={0}\n", (playerTelem.Setup.ABSLevel >= 0) ? I(playerTelem.Setup.ABSLevel) : "n/a");
            sb.Append("BodyworkDamage=0,0,0,0,0\n");
            sb.Append("SuspensionDamage=0,0,0,0\n");
            sb.Append("EngineDamage=0\n");

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
                        F(w[0].Pressure), F(w[1].Pressure), F(w[2].Pressure), F(w[3].Pressure));
                    
                    sb.Append("TyreWear=0,0,0,0\n");
                    
                    sb.AppendFormat("BrakeTemperature={0},{1},{2},{3}\n",
                        F(w[0].BrakeTemp), F(w[1].BrakeTemp), F(w[2].BrakeTemp), F(w[3].BrakeTemp));
                }

                sb.Append("BrakeWear=0,0,0,0\n");

                if (playerTelem.Drivetrain.EngineCoolantTemperature > 0)
                    sb.AppendFormat("WaterTemperature={0}\n", F(playerTelem.Drivetrain.EngineCoolantTemperature));

                if (playerTelem.Drivetrain.EngineOilTemperature > 0)
                    sb.AppendFormat("OilTemperature={0}\n", F(playerTelem.Drivetrain.EngineOilTemperature));
            }

            sb.Append("[Stint Data]\n");
            ParseDriverName(playerState.DriverName, out string forename, out string surname, out string nickname);
            sb.AppendFormat("DriverForname={0}\n", forename);
            sb.AppendFormat("DriverSurname={0}\n", surname);
            sb.AppendFormat("DriverNickname={0}\n", nickname);
            sb.AppendFormat("Position={0}\n", playerState.RacePos);
            sb.Append("LapValid=true\n");
            sb.AppendFormat("LapLastTime={0}\n", I(playerState.CurrentLapTime * 1000));
            sb.AppendFormat("LapBestTime={0}\n", I(playerState.BestLapTime * 1000));
            sb.AppendFormat("Sector={0}\n", playerState.CurrentSector + 1);
            sb.AppendFormat("Laps={0}\n", playerState.CurrentLap);
            sb.AppendFormat("StintTimeRemaining={0}\n", I(raceInfo.Duration * 1000));
            sb.AppendFormat("DriverTimeRemaining={0}\n", I(raceInfo.Duration * 1000));
            sb.AppendFormat("InPit={0}\n", playerState.InPits ? "true" : "false");
            sb.AppendFormat("InPitLane={0}\n", playerState.InPits ? "true" : "false");

            sb.Append("[Track Data]\n");
            sb.AppendFormat("Length={0}\n", F(raceInfo.LayoutLength));
            sb.AppendFormat("Temperature={0}\n", F(raceInfo.TrackTemperature));
            sb.Append("Grip=Optimum\n");

            for (int i = 0; i < participants.Count; i++)
            {
                var t = receiver.GetParticpantTelemetry(participants[i].VehicleId);
                int carNum = i + 1;

                if (t != null)
                    sb.AppendFormat("Car.{0}.Position={1},{2}\n", carNum, t.Chassis.PosWS[0], t.Chassis.PosWS[1]); // Testen*
                else
                    sb.AppendFormat("Car.{0}.Position=false\n", carNum);
            }

            sb.Append("[Weather Data]\n");
            sb.AppendFormat("Temperature={0}\n", F(raceInfo.AmbientTemperature));
            sb.AppendFormat("Weather={0}\n", "Dry"); // raceInfo.Weather);
            sb.AppendFormat("Weather10Min={0}\n", "Dry"); // raceInfo.Weather);
            sb.AppendFormat("Weather30Min={0}\n", "Dry"); // raceInfo.Weather);

            sb.Append("[Debug Data]\n");
            sb.AppendFormat("Mode={0}\n", raceInfo.GameMode);

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
                sb.AppendFormat("Car.{0}.Laps={1}\n", carNum, p.CurrentLap);
                sb.AppendFormat("Car.{0}.Lap.Running={1}\n", carNum, F(- p.LapProgress));// Testen
                sb.AppendFormat("Car.{0}.Lap.Running.Valid=true\n", carNum);
                sb.AppendFormat("Car.{0}.Time={1}\n", carNum, I(p.CurrentLapTime * 1000));

                if (p.CurrentSectorTimes.Count >= 3) // Testen
                {
                    sb.AppendFormat("Car.{0}.Time.Sectors={1},{2},{3}\n", carNum,
                        I(p.CurrentSectorTimes[0] * 1000),
                        I(p.CurrentSectorTimes[1] * 1000),
                        I(p.CurrentSectorTimes[2] * 1000));
                }

                sb.AppendFormat("Car.{0}.Car={1}\n", carNum, NormalizeName(p.VehicleName));

                ParseDriverName(p.DriverName, out string forename, out string surname, out string nickname);
                sb.AppendFormat("Car.{0}.Driver.Forname={1}\n", carNum, forename);
                sb.AppendFormat("Car.{0}.Driver.Surname={1}\n", carNum, surname);
                sb.AppendFormat("Car.{0}.Driver.Nickname={1}\n", carNum, nickname);
                sb.AppendFormat("Car.{0}.InPitLane={1}\n", carNum, p.InPits ? "true" : "false");
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

        private string I(int value)
        {
            return value.ToString(enUS);
        }
    }
}
