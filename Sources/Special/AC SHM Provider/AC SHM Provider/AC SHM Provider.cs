using System;
using System.IO;
using System.IO.MemoryMappedFiles;
using System.Runtime.InteropServices;
using System.Text;
using System.Threading;

namespace ACSHMProvider
{
    enum AC_MEMORY_STATUS { DISCONNECTED, CONNECTING, CONNECTED }

    public class SHMProvider
    {
        bool connected = false;

        private AC_MEMORY_STATUS memoryStatus = AC_MEMORY_STATUS.DISCONNECTED;
        public bool IsRunning { get { return (memoryStatus == AC_MEMORY_STATUS.CONNECTED); } }

        Physics physics;
        Graphics graphics;
        Cars cars;
        StaticInfo staticInfo;

        public SHMProvider()
        {
            connected = ConnectToSharedMemory();
        }

        string GetSession(AC_SESSION_TYPE session) {
            switch (session) {
                case AC_SESSION_TYPE.AC_PRACTICE:
                    return "Practice";
                case AC_SESSION_TYPE.AC_QUALIFY:
                    return "Qualification";
                case AC_SESSION_TYPE.AC_RACE:
                    return "Race";
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
            if (GetSession(graphics.Session) != "Practice" && staticInfo.IsTimedRace == 0)
                return (graphics.NumberOfLaps - graphics.CompletedLaps);
            else {
                if (graphics.iLastTime > 0)
                    return ((GetRemainingTime(timeLeft) / graphics.iLastTime) + 1);
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

                physics = ReadPhysics();
                graphics = ReadGraphics();
                staticInfo = ReadStaticInfo();
                cars = ReadCars();

                memoryStatus = AC_MEMORY_STATUS.CONNECTED;

                return true;
            }
            catch (FileNotFoundException)
            {
                return false;
            }
        }

        public void Close()
        {
            memoryStatus = AC_MEMORY_STATUS.DISCONNECTED;
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

        public void ReadStandings()
        {
            Console.WriteLine("[Position Data]");

            if (connected)
            {
                Console.Write("Car.Count="); Console.WriteLine(cars.numVehicles);

                for (int i = 1; i <= cars.numVehicles; ++i)
                {
                    AcCarInfo car = cars.cars[i - 1];

                    Console.Write("Car."); Console.Write(i); Console.Write(".Nr="); Console.WriteLine(car.carId);
                    Console.Write("Car."); Console.Write(i); Console.Write(".Position="); Console.WriteLine(car.carRealTimeLeaderboardPosition + 1);

                    Console.Write("Car."); Console.Write(i); Console.Write(".Lap="); Console.WriteLine(car.lapCount);
                    Console.Write("Car."); Console.Write(i); Console.Write(".Lap.Running="); Console.WriteLine(car.splinePosition);
                    Console.Write("Car."); Console.Write(i); Console.Write(".Lap.Valid="); Console.WriteLine((car.currentLapInvalid == 1) ? "false" : "true");

                    int lapTime = car.lastLapTimeMS;
                    int sector1Time = 0;
                    int sector2Time = 0;
                    int sector3Time = 0;

                    Console.Write("Car."); Console.Write(i); Console.Write(".Time="); Console.WriteLine(lapTime);
                    Console.Write("Car."); Console.Write(i); Console.Write(".Time.Sectors="); Console.WriteLine(sector1Time + "," + sector2Time + "," + sector3Time);

                    string carModel = GetStringFromBytes(car.carModel);

                    Console.Write("Car."); Console.Write(i); Console.Write(".Car="); Console.WriteLine(carModel);

                    string driverName = GetStringFromBytes(car.driverName);

                    Console.Write("Car."); Console.Write(i); Console.Write(".Driver.Forname="); Console.WriteLine(GetForname(driverName));
                    Console.Write("Car."); Console.Write(i); Console.Write(".Driver.Surname="); Console.WriteLine(GetSurname(driverName));
                    Console.Write("Car."); Console.Write(i); Console.Write(".Driver.Nickname="); Console.WriteLine(GetNickname(driverName));

                    Console.Write("Car."); Console.Write(i); Console.Write(".InPitLane="); Console.WriteLine((car.isCarInPitline + car.isCarInPit) == 0 ? "false" : "true");
                    Console.Write("Car."); Console.Write(i); Console.Write(".InPit="); Console.WriteLine((car.isCarInPit == 0) ? "false" : "true");
                }

                Console.WriteLine("Driver.Car=" + ((cars.numVehicles > 0) ? 1 : 0));
            }
            else
            {
                Console.WriteLine("Car.Count=0");
                Console.WriteLine("Driver.Car=0");
            }
        }

        public void ReadSetup()
        {
            Console.WriteLine("[Setup Data]");
            if (connected)
            {
            }
        }

        public void ReadData() {
            Console.WriteLine("[Session Data]");

            Console.Write("Active="); Console.WriteLine((connected && graphics.Status != AC_STATUS.AC_OFF) ? "true" : "false");

            string session = "";
            long timeLeft = 0;

            if (connected)
            {
                Console.Write("Paused="); Console.WriteLine((graphics.Status == AC_STATUS.AC_REPLAY || graphics.Status == AC_STATUS.AC_PAUSE) ? "true" : "false");

                if (GetSession(graphics.Session) != "Practice" && staticInfo.IsTimedRace == 0 &&
                    (graphics.NumberOfLaps - graphics.CompletedLaps) <= 0)
                    session = "Finished";
                else if (graphics.Flag == AC_FLAG_TYPE.AC_CHECKERED_FLAG)
                    session = "Finished";
                else
                    session = GetSession(graphics.Session);

                Console.Write("Session="); Console.WriteLine(session);

                Console.Write("Car="); Console.WriteLine(staticInfo.CarModel);
                Console.Write("Track="); Console.WriteLine(staticInfo.Track + "-" + staticInfo.TrackConfiguration);
                Console.Write("SessionFormat="); Console.WriteLine((session == "Practice" || staticInfo.IsTimedRace != 0) ? "Time" : "Laps");
                Console.Write("FuelAmount="); Console.WriteLine(staticInfo.MaxFuel);

                /*
                if (session == "Practice")
                {
                    Console.WriteLine("SessionTimeRemaining=3600000");
                    Console.WriteLine("SessionLapsRemaining=30");
                }
                else
                {
                */
                    timeLeft = (long)graphics.SessionTimeLeft;

                    if (timeLeft < 0)
                    {
                        timeLeft = 3600 * 1000;
                    }

                    Console.Write("SessionTimeRemaining="); Console.WriteLine(GetRemainingTime(timeLeft));
                    Console.Write("SessionLapsRemaining="); Console.WriteLine(GetRemainingLaps(timeLeft));
                /*
                }
                */
            }
            else
                return;

            Console.WriteLine("[Stint Data]");

            Console.WriteLine("DriverForname=" + staticInfo.PlayerName);
            Console.WriteLine("DriverSurname=" + staticInfo.PlayerSurname);
            Console.WriteLine("DriverNickname=" + staticInfo.PlayerNick);
            
            Console.WriteLine("Sector=" + graphics.CurrentSectorIndex + 1);
            Console.WriteLine("Laps=" + graphics.CompletedLaps);

            Console.WriteLine("LapValid=true");
            Console.WriteLine("LapLastTime=" + graphics.iLastTime);
            Console.WriteLine("LapBestTime=" + graphics.iBestTime);

            /*
            if (session == "Practice")
            {
                Console.WriteLine("StintTimeRemaining=3600000");
                Console.WriteLine("DriverTimeRemaining=3600000");
            }
            else
            {
            */
                long time = GetRemainingTime(timeLeft);

                Console.WriteLine("StintTimeRemaining=" + time);
                Console.WriteLine("DriverTimeRemaining=" + time);
            /*
            }
            */
            Console.WriteLine("InPit=" + (graphics.IsInPit != 0 ? "true" : "false"));

            Console.WriteLine("[Track Data]");

            Console.Write("Temperature="); Console.WriteLine(physics.RoadTemp);
            Console.WriteLine("Grip=" + GetGrip(graphics.SurfaceGrip));

            for (int id = 0; id < cars.numVehicles; id++)
                Console.WriteLine("Car." + (id + 1) + ".Position=" + cars.cars[id].worldPosition.x + "," + cars.cars[id].worldPosition.z);

            Console.WriteLine("[Weather Data]");

            Console.WriteLine("Temperature=" + physics.AirTemp);
            Console.WriteLine("Weather=Dry");
            Console.WriteLine("Weather10min=Dry");
            Console.WriteLine("Weather30min=Dry");

            Console.WriteLine("[Car Data]");

            Console.WriteLine("MAP=n/a");
            Console.WriteLine("TCRaw=" + physics.TC);
            Console.WriteLine("ABSRaw=" + physics.Abs);
            
            Console.Write("FuelRemaining="); Console.WriteLine(physics.Fuel);

            Console.WriteLine("TyreCompoundRaw=" + graphics.TyreCompound);
            Console.WriteLine("TyreTemperature=" + physics.TyreCoreTemperature[0] + "," + physics.TyreCoreTemperature[1] + ","
                                                 + physics.TyreCoreTemperature[2] + "," + physics.TyreCoreTemperature[3]);
            Console.WriteLine("TyrePressure=" + physics.WheelsPressure[0] + "," + physics.WheelsPressure[1] + ","
                                              + physics.WheelsPressure[2] + "," + physics.WheelsPressure[3]);
            /*
            Console.WriteLine("TyreWear=" + Math.Round(physics.TyreWear[0]) + "," + Math.Round(physics.TyreWear[1]) + ","
                                          + Math.Round(physics.TyreWear[2]) + "," + Math.Round(physics.TyreWear[3]));
            */
            Console.WriteLine("BrakeTemperature=" + physics.BrakeTemp[0] + "," + physics.BrakeTemp[1] + ","
                                                 + physics.BrakeTemp[2] + "," + physics.BrakeTemp[3]);

            float damageFront = physics.CarDamage[0];
            float damageRear = physics.CarDamage[1];
            float damageLeft = physics.CarDamage[2];
            float damageRight = physics.CarDamage[3];

            Console.WriteLine("BodyworkDamage=" + damageFront + "," + damageRear + "," + damageLeft + "," + damageRight + ","
                                                + (damageFront + damageRear + damageLeft + damageRight));
            Console.WriteLine("SuspensionDamage=0, 0, 0, 0");
            Console.WriteLine("EngineDamage=0");
        }
    }
}
