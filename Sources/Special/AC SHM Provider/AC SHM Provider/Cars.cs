using System;
using System.Runtime.InteropServices;

namespace ACSHMProvider
{
    public class CarsEventArgs : EventArgs
    {
        public CarsEventArgs(Cars cars)
        {
            this.Cars = cars;
        }

        public Cars Cars { get; private set; }
    }


    [StructLayout(LayoutKind.Sequential, Pack = 4, CharSet = CharSet.Ansi)]
    [Serializable]
    public struct AcPos
    {
        public float x;
        public float y;
        public float z;
    }

    [StructLayout(LayoutKind.Sequential, Pack = 4, CharSet = CharSet.Ansi)]
    [Serializable]
    public struct AcCarInfo
    {
        public int carId;
        [MarshalAsAttribute(UnmanagedType.ByValArray, SizeConst = 64)]
        public byte[] driverName;
        [MarshalAsAttribute(UnmanagedType.ByValArray, SizeConst = 64)]
        public byte[] carModel;
        public float speedMS;
        public int bestLapMS;
        public int lapCount;
        public int currentLapInvalid;
        public int currentLapTimeMS;
        public int lastLapTimeMS;
        public AcPos worldPosition;
        public int isCarInPitline;
        public int isCarInPit;
        public int carLeaderboardPosition;
        public int carRealTimeLeaderboardPosition;
        public float splinePosition;
        public int isConnected;
        [MarshalAs(UnmanagedType.ByValArray, SizeConst = 4)]
        public float[] suspensionDamage;
        public float engineLifeLeft;
        [MarshalAs(UnmanagedType.ByValArray, SizeConst = 4)]
        public float[] tyreInflation;
    }

    [StructLayout(LayoutKind.Sequential, Pack = 4, CharSet = CharSet.Ansi)]
    [Serializable]
    public struct Cars
    {
        public int numVehicles;
        public int focusVehicle;
        [MarshalAsAttribute(UnmanagedType.ByValArray, SizeConst = 512)]
        public byte[] serverName;
        [MarshalAsAttribute(UnmanagedType.ByValArray, SizeConst = 64)]
        public AcCarInfo[] cars;
        [MarshalAsAttribute(UnmanagedType.ByValArray, SizeConst = 512)]
        public byte[] acInstallPath;
        public int isInternalMemoryModuleLoaded;
        [MarshalAsAttribute(UnmanagedType.ByValArray, SizeConst = 32)]
        public byte[] pluginVersion;
    }
}