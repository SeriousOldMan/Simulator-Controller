using ACSHMProvider;
using System;
using System.IO;
using System.IO.MemoryMappedFiles;
using System.Runtime.InteropServices;

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

        string GetGrip(float surfaceGrip) {
            return "Optimum";
        }

        private long GetRemainingLaps(long timeLeft)
        {
            if (staticInfo.IsTimedRace == 0)
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
            if (staticInfo.IsTimedRace != 0)
                return (timeLeft - (graphics.iLastTime * graphics.NumberOfLaps));
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

                physics = ReadPhysics();
                graphics = ReadGraphics();
                staticInfo = ReadStaticInfo();

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

        public void ReadSetup()
        {
            Console.WriteLine("[Setup Data]");
            if (connected)
            {
            }
        }
        public void ReadStandings()
        {
            Console.WriteLine("[Position Data]");

            Console.WriteLine("Car.Count=0");
            Console.WriteLine("Driver.Car=0");

        }
        public void ReadData() {
            Console.WriteLine("[Session Data]");

            Console.Write("Active="); Console.WriteLine((connected && graphics.Status != AC_STATUS.AC_OFF) ? "true" : "false");

            long timeLeft = 0;

            if (connected)
            {
                Console.Write("Paused="); Console.WriteLine((graphics.Status == AC_STATUS.AC_REPLAY || graphics.Status == AC_STATUS.AC_PAUSE) ? "true" : "false");

                Console.Write("Session="); Console.WriteLine(GetSession(graphics.Session));

                Console.Write("Car="); Console.WriteLine(staticInfo.CarModel);
                Console.Write("Track="); Console.WriteLine(staticInfo.Track + "-" + staticInfo.TrackConfiguration);
                Console.Write("SessionFormat="); Console.WriteLine(staticInfo.IsTimedRace != 0 ? "Time" : "Lap");
                Console.Write("FuelAmount"); Console.WriteLine(staticInfo.MaxFuel);

                timeLeft = (long)graphics.SessionTimeLeft;

                if (timeLeft < 0)
                {
                    timeLeft = 3600 * 1000;
                }

                Console.Write("SessionTimeRemaining="); Console.WriteLine(GetRemainingTime(timeLeft));
                Console.Write("SessionLapsRemaining="); Console.WriteLine(GetRemainingLaps(timeLeft));
            }
            else
                return;

            Console.WriteLine("[Stint Data]");

            Console.WriteLine("DriverForname=" + staticInfo.PlayerName);
            Console.WriteLine("DriverSurname=" + staticInfo.PlayerSurname);
            Console.WriteLine("DriverNickname=" + staticInfo.PlayerNick);
            
            Console.WriteLine("Sector=", graphics.CurrentSectorIndex + 1);
            Console.WriteLine("Laps=" + graphics.CompletedLaps);

            Console.WriteLine("LapValid=true");
            Console.WriteLine("LapLastTime=" + graphics.iLastTime);
            Console.WriteLine("LapBestTime", graphics.iBestTime);

            long time = GetRemainingTime(timeLeft);

            Console.WriteLine("StintTimeRemaining=" + time);
            Console.WriteLine("DriverTimeRemaining=" + time);
            Console.WriteLine("InPit=", graphics.IsInPit != 0 ? "true" : "false");

            Console.WriteLine("[Track Data]");

            Console.Write("Temperature="); Console.WriteLine(physics.RoadTemp);
            Console.Write("Grip="); Console.WriteLine(GetGrip(graphics.SurfaceGrip));

            Console.WriteLine("[Weather Data]");

            Console.WriteLine("Temperature=", physics.AirTemp);
            Console.WriteLine("Weather=Dry");
            Console.WriteLine("Weather10min=Dry");
            Console.WriteLine("Weather30min=Dry");

            Console.WriteLine("[Car Data]");

            Console.WriteLine("MAP=n/a");
            Console.WriteLine("TC=", physics.TC);
            Console.WriteLine("ABS=", physics.Abs);
            
            Console.Write("FuelRemaining"); Console.WriteLine(physics.Fuel);

            Console.WriteLine("TyreCompoundRaw=" + graphics.TyreCompound);
            Console.WriteLine("TyreTemperature=" + physics.TyreCoreTemperature[0] + "," + physics.TyreCoreTemperature[1] + ","
                                                 + physics.TyreCoreTemperature[2] + "," + physics.TyreCoreTemperature[3]);
            Console.WriteLine("TyrePressure=" + physics.WheelsPressure[0] + "," + physics.WheelsPressure[1] + ","
                                              + physics.WheelsPressure[2] + "," + physics.WheelsPressure[3]);

            float damageFront = physics.CarDamage[0];
            float damageRear = physics.CarDamage[1];
            float damageLeft = physics.CarDamage[2];
            float damageRight = physics.CarDamage[3];

            Console.WriteLine("BodyworkDamage=" + damageFront + "," + damageRear + "," + damageLeft + "," + damageRight + ","
                                                + (damageFront + damageRear + damageLeft + damageRight));
            Console.WriteLine("SuspensionDamage=0, 0, 0, 0");
        }
    }
}
