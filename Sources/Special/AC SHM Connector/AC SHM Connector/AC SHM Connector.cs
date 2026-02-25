using System;
using System.Data;
using System.Globalization;
using System.IO;
using System.IO.MemoryMappedFiles;
using System.Runtime.InteropServices;
using System.Text;
using System.Threading;

namespace SHMConnector
{
    enum AC_MEMORY_STATUS { DISCONNECTED, CONNECTING, CONNECTED }

    public class SHMConnector
    {
        bool connected = false;

        private AC_MEMORY_STATUS memoryStatus = AC_MEMORY_STATUS.DISCONNECTED;
        public bool IsRunning { get { return (memoryStatus == AC_MEMORY_STATUS.CONNECTED); } }

        Physics physics;
        Graphics graphics;
        Cars cars;
        StaticInfo staticInfo;

        private const int MAX_CARS = 64;
        private const int SECTOR_UPDATE_INTERVAL_MS = 50;
        
        private int[] previousSector = new int[MAX_CARS];
        private int[] sector1Times = new int[MAX_CARS];
        private int[] sector2Times = new int[MAX_CARS];
        private int[] sectorStartTimes = new int[MAX_CARS];
        private readonly object sectorLock = new object();

        private int[] lastSector1Times = new int[MAX_CARS];
        private int[] lastSector2Times = new int[MAX_CARS];
        private int[] lastSector3Times = new int[MAX_CARS];

        private float sectorBoundary1;
        private float sectorBoundary2;
        private bool sectorBoundariesCalibrated;
        private int lastObservedSector = -1;
        
        private Thread sectorUpdateThread;
        private volatile bool shouldStopThread;

        public SHMConnector()
        {
            for (int i = 0; i < MAX_CARS; i++)
                previousSector[i] = -1;
            
            sectorUpdateThread = new Thread(SectorUpdateWorker);
            sectorUpdateThread.IsBackground = true;
            sectorUpdateThread.Start();
        }

        string GetSession(AC_SESSION_TYPE session) {
            switch (session) {
                case AC_SESSION_TYPE.AC_PRACTICE:
                    return "Practice";
                case AC_SESSION_TYPE.AC_QUALIFY:
                    return "Qualification";
                case AC_SESSION_TYPE.AC_RACE:
                    return "Race";
                case AC_SESSION_TYPE.AC_HOTLAP:
                    return "Time Trial";
                case AC_SESSION_TYPE.AC_TIME_ATTACK:
                    return "Time Trial";
                default:
                    return "Other";
            }
        }

        static string[] gripNames = { "Dusty", "Old", "Slow", "Green", "Fast", "Optimum" };

        static string GetGrip(float surfaceGrip) {
            return gripNames[Math.Max(1, (int)Math.Round(6 - (((1 - surfaceGrip) / 0.15) * 6))) - 1];
        }

        private long GetRemainingLaps(long timeLeft)
        {
            if (GetSession(graphics.Session) != "Practice")
            {
                if (staticInfo.IsTimedRace == 0)
                    return (graphics.NumberOfLaps - graphics.CompletedLaps);
                else
                {
                    if (graphics.iLastTime > 0)
                        return ((GetRemainingTime(timeLeft) / graphics.iLastTime) + 1);
                    else
                        return 0;
                }
            }
            else
            {
                if (graphics.iBestTime > 0)
                    return ((GetRemainingTime(timeLeft) / graphics.iBestTime) + 1);
                else
                    return 0;
            }
        }

        private long GetRemainingTime(long timeLeft)
        {
            if (GetSession(graphics.Session) == "Practice" || staticInfo.IsTimedRace != 0)
            {
                long time = (timeLeft - (graphics.iBestTime * graphics.NumberOfLaps));

                if (time > 0)
                    return time;
                else
                    return 0;
            }
            else
                return (GetRemainingLaps(timeLeft) * graphics.iLastTime);
        }

        private bool ConnectToSharedMemory()
        {
            try
            {
                memoryStatus = AC_MEMORY_STATUS.CONNECTING;

                // Connect to shared memory
                physicsMMF = MemoryMappedFile.OpenExisting("Local\\acpmf_physics");
                graphicsMMF = MemoryMappedFile.OpenExisting("Local\\acpmf_graphics");
                staticInfoMMF = MemoryMappedFile.OpenExisting("Local\\acpmf_static");
                carsInfoMMF = MemoryMappedFile.OpenExisting("Local\\acpmf_cars");

                /*
                physics = ReadPhysics();
                graphics = ReadGraphics();
                staticInfo = ReadStaticInfo();
                cars = ReadCars();
                */

                memoryStatus = AC_MEMORY_STATUS.CONNECTED;

                return true;
            }
            catch (FileNotFoundException)
            {
                return false;
            }
        }

        MemoryMappedFile physicsMMF;
        MemoryMappedFile graphicsMMF;
        MemoryMappedFile staticInfoMMF;
        MemoryMappedFile carsInfoMMF;

        public Physics ReadPhysics()
        {
            using (var stream = physicsMMF.CreateViewStream())
            {
                using (var reader = new BinaryReader(stream))
                {
                    var size = Marshal.SizeOf(typeof(Physics));
                    var bytes = reader.ReadBytes(size);
                    var handle = GCHandle.Alloc(bytes, GCHandleType.Pinned);
                    var data = (Physics)Marshal.PtrToStructure(handle.AddrOfPinnedObject(), typeof(Physics));
                    handle.Free();
                    return data;
                }
            }
        }

        public Graphics ReadGraphics()
        {
            using (var stream = graphicsMMF.CreateViewStream())
            {
                using (var reader = new BinaryReader(stream))
                {
                    var size = Marshal.SizeOf(typeof(Graphics));
                    var bytes = reader.ReadBytes(size);
                    var handle = GCHandle.Alloc(bytes, GCHandleType.Pinned);
                    var data = (Graphics)Marshal.PtrToStructure(handle.AddrOfPinnedObject(), typeof(Graphics));
                    handle.Free();
                    return data;
                }
            }
        }

        public StaticInfo ReadStaticInfo()
        {
            using (var stream = staticInfoMMF.CreateViewStream())
            {
                using (var reader = new BinaryReader(stream))
                {
                    var size = Marshal.SizeOf(typeof(StaticInfo));
                    var bytes = reader.ReadBytes(size);
                    var handle = GCHandle.Alloc(bytes, GCHandleType.Pinned);
                    var data = (StaticInfo)Marshal.PtrToStructure(handle.AddrOfPinnedObject(), typeof(StaticInfo));
                    handle.Free();
                    return data;
                }
            }
        }

        public Cars ReadCars()
        {
            using (var stream = carsInfoMMF.CreateViewStream())
            {
                using (var reader = new BinaryReader(stream))
                {
                    while (true)
                    {
                        var size = Marshal.SizeOf(typeof(Cars));
                        var bytes = reader.ReadBytes(size);
                        var handle = GCHandle.Alloc(bytes, GCHandleType.Pinned);
                        var data = (Cars)Marshal.PtrToStructure(handle.AddrOfPinnedObject(), typeof(Cars));

                        int packetID = data.packetID;

                        if (packetID == -1)
                        {
                            handle.Free();

                            Thread.Sleep(10);

                            continue;
                        }

                        data = (Cars)Marshal.PtrToStructure(handle.AddrOfPinnedObject(), typeof(Cars));

                        handle.Free();

                        if (packetID == data.packetID)
                            return data;
                        else
                            Thread.Sleep(10);
                    }
                }
            }
        }

        private static string GetStringFromBytes(byte[] bytes)
        {
            if (bytes == null)
                return "";

            var nullIdx = Array.IndexOf(bytes, (byte)0);

            return nullIdx >= 0 ? Encoding.Default.GetString(bytes, 0, nullIdx) : Encoding.Default.GetString(bytes);
        }

        string normalizeName(string result)
        {
            result = result.Replace("/", "");
            result = result.Replace(":", "");
            result = result.Replace("*", "");
            result = result.Replace("?", "");
            result = result.Replace("<", "");
            result = result.Replace(">", "");
            result = result.Replace("|", "");

            return result;
        }

        public string GetForname(string name)
        {
            if (name.Contains(" "))
            {
                string[] names = name.Split(' ');

                return names[0];
            }
            else
                return name;
        }

        public string GetSurname(string name)
        {
            if (name.Contains(" "))
            {
                string[] names = name.Split(' ');

                return names[1];
            }
            else
                return "";
        }

        public string GetNickname(string name)
        {
            if (name.Contains(" "))
            {
                string[] names = name.Split(' ');

                return names[0].Substring(0, 1) + names[1].Substring(0, 1);
            }
            else
                return "";
        }

        private void SectorUpdateWorker()
        {
            while (!shouldStopThread)
            {
                try
                {
                    if (connected)
                        lock (sectorLock)
                        {
                            graphics = ReadGraphics();
                            cars = ReadCars();

                            if (!sectorBoundariesCalibrated && cars.numVehicles > 0)
                            {
                                CalibrateSectorBoundaries(graphics, ref cars.cars[0]);
                            }

                            if (sectorBoundariesCalibrated && cars.numVehicles > 0)
                                for (int i = 0; i < cars.numVehicles; i++)
                                {
                                    ref AcCarInfo car = ref cars.cars[i];
                                    if (car.isConnected == 0)
                                        continue;

                                    int currentSector = GetSectorFromSplinePosition(car.splinePosition);
                                    UpdateSectorTimes(i, currentSector, graphics.iCurrentTime, car.lastLapTimeMS);
                                }
                        }
                }
                catch
                {
                }
                
                Thread.Sleep(SECTOR_UPDATE_INTERVAL_MS);
            }
        }

        private void CalibrateSectorBoundaries(Graphics graphics, ref AcCarInfo playerCar)
        {
            int currentSector = Math.Min(graphics.CurrentSectorIndex, 2);

            if (lastObservedSector != currentSector)
            {
                if (lastObservedSector == 0 && currentSector == 1)
                {
                    sectorBoundary1 = playerCar.splinePosition;
                }
                else if (lastObservedSector == 1 && currentSector == 2)
                {
                    sectorBoundary2 = playerCar.splinePosition;
                    sectorBoundariesCalibrated = true;
                }
                
                lastObservedSector = currentSector;
            }
        }

        private int GetSectorFromSplinePosition(float splinePosition)
        {
            if (splinePosition < sectorBoundary1)
                return 0;
            else if (splinePosition < sectorBoundary2)
                return 1;
            else
                return 2;
        }

        private void UpdateSectorTimes(int carIndex, int currentSector, int currentTime, int lapTime)
        {
            if (carIndex < 0 || carIndex >= MAX_CARS)
                return;

            int prevSector = previousSector[carIndex];
            
            if (prevSector == -1)
            {
				if (currentSector == 0) {
					sectorStartTimes[carIndex] = currentTime;
					previousSector[carIndex] = 0;
				}
            }
			else if (currentSector != prevSector)
            {
                int sectorTime = currentTime - sectorStartTimes[carIndex];
                
                if (prevSector == 0)
                    sector1Times[carIndex] = sectorTime;
                else if (prevSector == 1)
                    sector2Times[carIndex] = sectorTime;
                else
                {
                    lastSector1Times[carIndex] = sector1Times[carIndex];
                    lastSector2Times[carIndex] = sector2Times[carIndex];
                    lastSector3Times[carIndex] = lapTime - sector1Times[carIndex] - sector2Times[carIndex];

                    sector1Times[carIndex] = 0;
                    sector2Times[carIndex] = 0;
                }
                
                sectorStartTimes[carIndex] = currentTime;
                previousSector[carIndex] = Math.Min(currentSector, 2);
            }
        }

        public string ReadStandings()
        {
            StringWriter strWriter = new StringWriter();

            strWriter.WriteLine("[Position Data]");

            if (connected) {
                lock (sectorLock)
                {
                    cars = ReadCars();

                    strWriter.Write("Car.Count="); strWriter.WriteLine(cars.numVehicles);

                    int idx = 1;

                    for (int i = 1; i <= cars.numVehicles; ++i)
                    {
                        ref AcCarInfo car = ref cars.cars[i - 1];

                        if (car.isConnected == 0)
                            continue;

                        strWriter.Write("Car."); strWriter.Write(idx); strWriter.Write(".ID="); strWriter.WriteLine(i);
                        strWriter.Write("Car."); strWriter.Write(idx); strWriter.Write(".Nr="); strWriter.WriteLine(car.carId);
                        strWriter.Write("Car."); strWriter.Write(idx); strWriter.Write(".Position="); strWriter.WriteLine(car.carRealTimeLeaderboardPosition + 1);

                        strWriter.Write("Car."); strWriter.Write(idx); strWriter.Write(".Laps="); strWriter.WriteLine(car.lapCount);
                        strWriter.Write("Car."); strWriter.Write(idx); strWriter.Write(".Lap.Running="); strWriter.WriteLine(car.splinePosition);
                        strWriter.Write("Car."); strWriter.Write(idx); strWriter.Write(".Lap.Running.Valid="); strWriter.WriteLine((car.currentLapInvalid == 1) ? "false" : "true");

                        int lapTime = car.currentLapTimeMS;

                        if (lapTime > 0)
                        {
                            strWriter.Write("Car."); strWriter.Write(idx); strWriter.Write(".Lap.Running.Time="); strWriter.WriteLine(lapTime);
                        }

                        lapTime = car.lastLapTimeMS;

                        int carIndex = i - 1;
                        int sector1Time, sector2Time, sector3Time;

                        lock (sectorLock)
                        {
                            sector1Time = lastSector1Times[carIndex];
                            sector2Time = lastSector2Times[carIndex];
                            sector3Time = lastSector3Times[carIndex];
                        }

                        if (lapTime > 0)
                        {
                            strWriter.Write("Car."); strWriter.Write(idx); strWriter.Write(".Time="); strWriter.WriteLine(lapTime);

                            if (sector1Time > 0 && sector2Time > 0 && sector3Time > 0)
                            {
                                strWriter.Write("Car."); strWriter.Write(idx); strWriter.Write(".Time.Sectors="); strWriter.WriteLine(sector1Time + "," + sector2Time + "," + sector3Time);
                            }
                        }
                        else
                        {
                            strWriter.Write("Car."); strWriter.Write(idx); strWriter.Write(".Time="); strWriter.WriteLine(lapTime);
                        }

                        string carModel = GetStringFromBytes(car.carModel);

                        strWriter.Write("Car."); strWriter.Write(idx); strWriter.Write(".Car="); strWriter.WriteLine(normalizeName(carModel));

                        string driverName = GetStringFromBytes(car.driverName);

                        strWriter.Write("Car."); strWriter.Write(idx); strWriter.Write(".Driver.Forname="); strWriter.WriteLine(GetForname(driverName));
                        strWriter.Write("Car."); strWriter.Write(idx); strWriter.Write(".Driver.Surname="); strWriter.WriteLine(GetSurname(driverName));
                        strWriter.Write("Car."); strWriter.Write(idx); strWriter.Write(".Driver.Nickname="); strWriter.WriteLine(GetNickname(driverName));

                        strWriter.Write("Car."); strWriter.Write(idx); strWriter.Write(".InPitLane="); strWriter.WriteLine((car.isCarInPitline + car.isCarInPit) == 0 ? "false" : "true");
                        strWriter.Write("Car."); strWriter.Write(idx); strWriter.Write(".InPit="); strWriter.WriteLine((car.isCarInPit == 0) ? "false" : "true");

                        idx += 1;
                    }

                    strWriter.WriteLine("Driver.Car=" + ((cars.numVehicles > 0) ? 1 : 0));
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

        public string ReadSetup()
        {
            return "";
        }

        // Determine if the race is timed or lap based bceause AC doesn't provide this info correctly
        public bool IsTimedRace()
        {
            bool isTimedBasedOnRemainingTime = graphics.SessionTimeLeft >= 0;

            // Race may still be time based as at the end of a timed race the session time left goes negative
            bool isTimedBasedOnTrackLength = GetRemainingLaps((long)graphics.SessionTimeLeft) <= -1;

            return isTimedBasedOnRemainingTime || isTimedBasedOnTrackLength;
        }

        public string ReadData()
        {
            StringWriter strWriter = new StringWriter();

            lock (sectorLock)
            {
                long timeLeft = 0;

                strWriter.WriteLine("[Session Data]");
                if (connected)
                {
                    string session = "";
                    
                    physics = ReadPhysics();
                    graphics = ReadGraphics();
                    staticInfo = ReadStaticInfo();
                    cars = ReadCars();

                    strWriter.Write("Active="); strWriter.WriteLine((graphics.Status != AC_STATUS.AC_OFF) ? "true" : "false");
                    strWriter.Write("Paused="); strWriter.WriteLine((graphics.Status == AC_STATUS.AC_REPLAY || graphics.Status == AC_STATUS.AC_PAUSE) ? "true" : "false");

                    staticInfo.IsTimedRace = IsTimedRace() ? 1 : 0;

                    session = GetSession(graphics.Session);

                    strWriter.Write("Session="); strWriter.WriteLine(session);

                    strWriter.Write("Car="); strWriter.WriteLine(normalizeName(staticInfo.CarModel));
                    strWriter.Write("Track="); strWriter.WriteLine(normalizeName(staticInfo.Track));
                    strWriter.Write("Layout="); strWriter.WriteLine(normalizeName(staticInfo.TrackConfiguration));
                    strWriter.Write("SessionFormat="); strWriter.WriteLine((session == "Practice" || staticInfo.IsTimedRace != 0) ? "Time" : "Laps");
                    strWriter.Write("FuelAmount="); strWriter.WriteLine(staticInfo.MaxFuel);

                    timeLeft = (long)graphics.SessionTimeLeft;

                    if (timeLeft < 0)
                    {
                        timeLeft = 24 * 3600 * 1000;
                    }

                    strWriter.Write("SessionTimeRemaining="); strWriter.WriteLine(GetRemainingTime(timeLeft));
                    strWriter.Write("SessionLapsRemaining="); strWriter.WriteLine(GetRemainingLaps(timeLeft));
                }
                else
                {
                    strWriter.WriteLine("Active=false");

                    return strWriter.ToString();
                }

                strWriter.WriteLine("[Stint Data]");

                if (cars.numVehicles > 0)
                {
                    AcCarInfo car = cars.cars[0];

                    strWriter.Write("Position="); strWriter.WriteLine(car.carRealTimeLeaderboardPosition + 1);
                }

                strWriter.WriteLine("DriverForname=" + staticInfo.PlayerName);
                strWriter.WriteLine("DriverSurname=" + staticInfo.PlayerSurname);
                strWriter.WriteLine("DriverNickname=" + staticInfo.PlayerNick);
            
                strWriter.WriteLine("Sector=" + (Math.Min(graphics.CurrentSectorIndex, 2) + 1));
                strWriter.WriteLine("Laps=" + graphics.CompletedLaps);

                strWriter.WriteLine("LapValid=true");
                strWriter.WriteLine("LapLastTime=" + graphics.iLastTime);
                strWriter.WriteLine("LapBestTime=" + graphics.iBestTime);

                if (graphics.Flag == AC_FLAG_TYPE.AC_PENALTY_FLAG)
                    strWriter.WriteLine("Penalty=true");

                long time = GetRemainingTime(timeLeft);

                strWriter.WriteLine("StintTimeRemaining=" + time);
                strWriter.WriteLine("DriverTimeRemaining=" + time);
                strWriter.WriteLine("InPit=" + (graphics.IsInPit != 0 ? "true" : "false"));
                strWriter.WriteLine("InPitLane=" + ((graphics.IsInPitLane + graphics.IsInPit) != 0 ? "true" : "false"));

                strWriter.WriteLine("[Track Data]");
                strWriter.Write("Length="); strWriter.WriteLine(staticInfo.TrackSPlineLength);
                strWriter.Write("Temperature="); strWriter.WriteLine(physics.RoadTemp);
                strWriter.WriteLine("Grip=" + GetGrip(graphics.SurfaceGrip));

			    int index = 1;
			
                for (int id = 0; id < cars.numVehicles; id++)
                { 
                    if (cars.cars[id].isConnected == 0)
                        continue;
                    strWriter.WriteLine("Car." + index++ + ".Position=" + cars.cars[id].worldPosition.x + "," + cars.cars[id].worldPosition.z);
                }

                strWriter.WriteLine("[Weather Data]");
                strWriter.WriteLine("Temperature=" + physics.AirTemp);
                strWriter.WriteLine("Weather=Dry");
                strWriter.WriteLine("Weather10min=Dry");
                strWriter.WriteLine("Weather30min=Dry");

                strWriter.WriteLine("[Car Data]");
                strWriter.WriteLine("MAP=n/a");
                strWriter.WriteLine("TCRaw=" + physics.TC);
                strWriter.WriteLine("ABSRaw=" + physics.Abs);
                strWriter.WriteLine("BB=" + Math.Round(physics.BrakeBias * 100, 2));

                strWriter.Write("FuelRemaining="); strWriter.WriteLine(physics.Fuel);

                strWriter.WriteLine("TyreCompoundRaw=" + graphics.TyreCompound);
                strWriter.WriteLine("TyreTemperature=" + physics.TyreCoreTemperature[0] + "," + physics.TyreCoreTemperature[1] + ","
                                                     + physics.TyreCoreTemperature[2] + "," + physics.TyreCoreTemperature[3]);
                strWriter.WriteLine("TyrePressure=" + physics.WheelsPressure[0] + "," + physics.WheelsPressure[1] + ","
                                                  + physics.WheelsPressure[2] + "," + physics.WheelsPressure[3]);
            
                strWriter.WriteLine("BrakeTemperature=" + physics.BrakeTemp[0] + "," + physics.BrakeTemp[1] + ","
                                                     + physics.BrakeTemp[2] + "," + physics.BrakeTemp[3]);

                float damageFront = physics.CarDamage[0];
                float damageRear = physics.CarDamage[1];
                float damageLeft = physics.CarDamage[2];
                float damageRight = physics.CarDamage[3];

                strWriter.WriteLine("BodyworkDamage=" + damageFront + "," + damageRear + "," + damageLeft + "," + damageRight + ","
                                                    + (damageFront + damageRear + damageLeft + damageRight));
                strWriter.WriteLine("SuspensionDamage=0, 0, 0, 0");
                strWriter.WriteLine("EngineDamage=0");

				/*
                strWriter.WriteLine("[Debug Data]");
                strWriter.WriteLine("Sector1=" + Math.Round(sectorBoundary1, 2));
                strWriter.WriteLine("Sector2=" + Math.Round(sectorBoundary2, 2));
				*/
            }

            return strWriter.ToString();
        }

        public bool Open()
        {
            if (!this.connected)
                connected = ConnectToSharedMemory();

            return connected;
        }

        public void Close()
        {
            shouldStopThread = true;
            if (sectorUpdateThread != null && sectorUpdateThread.IsAlive)
                sectorUpdateThread.Join(200);
            
            memoryStatus = AC_MEMORY_STATUS.DISCONNECTED;
			connected = false;
        }

        public string Call(string request)
        {
            Thread.CurrentThread.CurrentCulture = CultureInfo.CreateSpecificCulture("en-US");
			
			if (!connected) {
				Open();
				
				if (!connected)
					return "";
			}

            if (request.StartsWith("Setup"))
                return this.ReadSetup();
            else if (request.StartsWith("Standings"))
                return this.ReadStandings();
            else
                return this.ReadData() + this.ReadSetup();
        }
    }
}
