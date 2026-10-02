using System;
using System.Runtime.InteropServices;

namespace ACSHMSpotter
{
    public class PhysicsEventArgs : EventArgs
    {
        public PhysicsEventArgs (Physics physics)
        {
            this.Physics = physics;
        }

        public Physics Physics { get; private set; }
    }

    [StructLayout (LayoutKind.Sequential)]
    public struct Coordinates
    {
        public float X;
        public float Y;
        public float Z;
    }

    [StructLayout (LayoutKind.Sequential, Pack = 4, CharSet = CharSet.Unicode)]
    [Serializable]
    public struct Physics
    {
        public int PacketId;
        public float Gas;
        public float Brake;
        public float Fuel;
        public int Gear;
        public int Rpms;
        public float SteerAngle;
        public float SpeedKmh;

        [MarshalAs (UnmanagedType.ByValArray, SizeConst = 3)]
        public float[] Velocity;
        [MarshalAs (UnmanagedType.ByValArray, SizeConst = 3)]
        public float[] AccG;
        [MarshalAs (UnmanagedType.ByValArray, SizeConst = 4)]
        public float[] WheelSlip;
        [MarshalAs (UnmanagedType.ByValArray, SizeConst = 4)]
        public float[] WheelLoad;
        [MarshalAs (UnmanagedType.ByValArray, SizeConst = 4)]
        public float[] WheelsPressure;
        [MarshalAs (UnmanagedType.ByValArray, SizeConst = 4)]
        public float[] WheelAngularSpeed;
        [MarshalAs (UnmanagedType.ByValArray, SizeConst = 4)]
        public float[] TyreWear;
        [MarshalAs (UnmanagedType.ByValArray, SizeConst = 4)]
        public float[] TyreDirtyLevel;
        [MarshalAs (UnmanagedType.ByValArray, SizeConst = 4)]
        public float[] TyreCoreTemperature;
        [MarshalAs (UnmanagedType.ByValArray, SizeConst = 4)]
        public float[] CamberRad;
        [MarshalAs (UnmanagedType.ByValArray, SizeConst = 4)]
        public float[] SuspensionTravel;

        public float Drs;
        public float TC;
        public float Heading;
        public float Pitch;
        public float Roll;
        public float CgHeight;

        [MarshalAs (UnmanagedType.ByValArray, SizeConst = 5)]
        public float[] CarDamage;

        public int NumberOfTyresOut;
        public int PitLimiterOn;
        public float Abs;

        public float KersCharge;
        public float KersInput;
        public int AutoShifterOn;
        [MarshalAs (UnmanagedType.ByValArray, SizeConst = 2)]
        public float[] RideHeight;

        // since 1.5
        public float TurboBoost;
        public float Ballast;
        public float AirDensity;

        // since 1.6
        public float AirTemp;
        public float RoadTemp;
        [MarshalAs (UnmanagedType.ByValArray, SizeConst = 3)]
        public float[] LocalAngularVelocity;
        public float FinalFF;

        // since 1.7
        public float PerformanceMeter;
        public int EngineBrake;
        public int ErsRecoveryLevel;
        public int ErsPowerLevel;
        public int ErsHeatCharging;
        public int ErsisCharging;
        public float KersCurrentKJ;
        public int DrsAvailable;
        public int DrsEnabled;
        [MarshalAs (UnmanagedType.ByValArray, SizeConst = 4)]
        public float[] BrakeTemp;

        // since 1.10
        public float Clutch;

        [MarshalAs (UnmanagedType.ByValArray, SizeConst = 4)]
        public float[] TyreTempI;
        [MarshalAs (UnmanagedType.ByValArray, SizeConst = 4)]
        public float[] TyreTempM;
        [MarshalAs (UnmanagedType.ByValArray, SizeConst = 4)]
        public float[] TyreTempO;

        // since 1.10.2
        public int IsAIControlled;

        // since 1.11
        [MarshalAs (UnmanagedType.ByValArray, SizeConst = 4)]
        public Coordinates[] TyreContactPoint;
        [MarshalAs (UnmanagedType.ByValArray, SizeConst = 4)]
        public Coordinates[] TyreContactNormal;
        [MarshalAs (UnmanagedType.ByValArray, SizeConst = 4)]
        public Coordinates[] TyreContactHeading;
        public float BrakeBias;

        // since 1.12
        [MarshalAs (UnmanagedType.ByValArray, SizeConst = 3)]
        public float[] LocalVelocity;
    }
}