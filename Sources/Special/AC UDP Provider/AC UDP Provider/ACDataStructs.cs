using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Runtime.InteropServices;

namespace ACUDPProvider
{
    internal static class AcConverter
    {
        // Copy structure to new memory, return array (pointer) of raw bytes.
        public static byte[] structToBytes<T>(T str) where T : struct
        {
            int size = Marshal.SizeOf<T>();
            byte[] arr = new byte[size];
            IntPtr ptr = Marshal.AllocHGlobal(size);
            Marshal.StructureToPtr<T>(str, ptr, true);
            Marshal.Copy(ptr, arr, 0, size);
            Marshal.FreeHGlobal(ptr);
            return arr;
        }

        // Copy bytes to memory, return object from those bytes.
        public static T bytesToStruct<T>(byte[] bytes) where T : struct
        {
            T str = default(T);
            int size = Marshal.SizeOf(str);
            IntPtr ptr = Marshal.AllocHGlobal(size);
            Marshal.Copy(bytes, 0, ptr, size);
            str = Marshal.PtrToStructure<T>(ptr);
            Marshal.FreeHGlobal(ptr);

            return str;
        }

        // Data to send for initial handshake, update mode selection, and dismissal.
        [StructLayout(LayoutKind.Sequential, Pack = 0)]
        public struct handshaker
        {
            public handshaker(HandshakeOperation operationId, uint identifier = 1, uint version = 1)
            {
                this.identifier = identifier;
                this.version = version;
                this.operationId = operationId;
            }

            [MarshalAs(UnmanagedType.U4)]
            public uint identifier; // Android, iOS, currently not used.

            [MarshalAs(UnmanagedType.U4)]
            public uint version; // Expected AC remote telemetry interface version.

            [MarshalAs(UnmanagedType.U4)]
            public HandshakeOperation operationId; // Type of handshake packet.

            public enum HandshakeOperation
            {
                Connect,
                CarInfo,
                Lapinfo,
                Disconnect
            };
        }

        [StructLayout(LayoutKind.Sequential, CharSet = CharSet.Unicode, Pack = 1)]
        public struct handshakerResponse
        {
            [MarshalAs(UnmanagedType.ByValTStr, SizeConst = 50)]
            public string carName;

            [MarshalAs(UnmanagedType.ByValTStr, SizeConst = 50)]
            public string driverName;

            [MarshalAs(UnmanagedType.U4)]
            public uint identifier; // Status code from the server, currently just '4242' to see that it works.

            [MarshalAs(UnmanagedType.U4)]
            public uint version; // Server version, not yet supported.

            [MarshalAs(UnmanagedType.ByValTStr, SizeConst = 50)]
            public string trackName;

            [MarshalAs(UnmanagedType.ByValTStr, SizeConst = 50)]
            public string trackConfig;
        }

        [StructLayout(LayoutKind.Sequential, CharSet = CharSet.Unicode, Pack = 1)]
        public struct RTLap
        {
            [MarshalAs(UnmanagedType.U4)]
            public int carIdentifierNumber;

            [MarshalAs(UnmanagedType.U4)]
            public int lap;

            [MarshalAs(UnmanagedType.ByValTStr, SizeConst = 50)]
            public string driverName;

            [MarshalAs(UnmanagedType.ByValTStr, SizeConst = 50)]
            public string carName;

            [MarshalAs(UnmanagedType.U4)]
            public int time;
        };

        [StructLayout(LayoutKind.Explicit, CharSet = CharSet.Unicode, Pack = 1, Size = 328)]
        public struct RTCarInfo
        {
            [MarshalAs(UnmanagedType.ByValTStr, SizeConst = 2), FieldOffset(0 * 4)]
            public string identifier;
            [MarshalAs(UnmanagedType.U4), FieldOffset(1 * 4)]
            public int size;

            [MarshalAs(UnmanagedType.R4), FieldOffset(2 * 4)]
            public float speed_Kmh;
            [MarshalAs(UnmanagedType.R4), FieldOffset(3 * 4)]
            public float speed_Mph;
            [MarshalAs(UnmanagedType.R4), FieldOffset(4 * 4)]
            public float speed_Ms;

            [MarshalAs(UnmanagedType.U1), FieldOffset(5 * 4)]
            public bool isAbsEnabled;
            [MarshalAs(UnmanagedType.U1), FieldOffset(5 * 4 + 1)]
            public bool isAbsInAction;
            [MarshalAs(UnmanagedType.U1), FieldOffset(5 * 4 + 2)]
            public bool isTcInAction;
            [MarshalAs(UnmanagedType.U1), FieldOffset(5 * 4 + 3)]
            public bool isTcEnabled;
            [MarshalAs(UnmanagedType.U1), FieldOffset(6 * 4 + 2)]
            public bool isInPit;
            [MarshalAs(UnmanagedType.U1), FieldOffset(6 * 4 + 3)]
            public bool isEngineLimiterOn;

            [MarshalAs(UnmanagedType.R4), FieldOffset(7 * 4)]
            public float accG_vertical;
            [MarshalAs(UnmanagedType.R4), FieldOffset(8 * 4)]
            public float accG_horizontal;
            [MarshalAs(UnmanagedType.R4), FieldOffset(9 * 4)]
            public float accG_frontal;

            [MarshalAs(UnmanagedType.U4), FieldOffset(10 * 4)]
            public int lapTime;
            [MarshalAs(UnmanagedType.U4), FieldOffset(11 * 4)]
            public int lastLap;
            [MarshalAs(UnmanagedType.U4), FieldOffset(12 * 4)]
            public int bestLap;
            [MarshalAs(UnmanagedType.U4), FieldOffset(13 * 4)]
            public int lapCount;

            [MarshalAs(UnmanagedType.R4), FieldOffset(14 * 4)]
            public float gas;
            [MarshalAs(UnmanagedType.R4), FieldOffset(15 * 4)]
            public float brake;
            [MarshalAs(UnmanagedType.R4), FieldOffset(16 * 4)]
            public float clutch;
            [MarshalAs(UnmanagedType.R4), FieldOffset(17 * 4)]
            public float engineRPM;
            [MarshalAs(UnmanagedType.R4), FieldOffset(18 * 4)]
            public float steer;
            [MarshalAs(UnmanagedType.U4), FieldOffset(19 * 4)]
            public int gear;
            [MarshalAs(UnmanagedType.R4), FieldOffset(20 * 4)]
            public float cgHeight;

            [MarshalAs(UnmanagedType.ByValArray, ArraySubType = UnmanagedType.R4, SizeConst = 4), FieldOffset(21 * 4)]
            public float[] wheelAngularSpeed;
            [MarshalAs(UnmanagedType.ByValArray, ArraySubType = UnmanagedType.R4, SizeConst = 4), FieldOffset(25 * 4)]
            public float[] slipAngle;
            [MarshalAs(UnmanagedType.ByValArray, ArraySubType = UnmanagedType.R4, SizeConst = 4), FieldOffset(29 * 4)]
            public float[] slipAngle_ContactPatch;
            [MarshalAs(UnmanagedType.ByValArray, ArraySubType = UnmanagedType.R4, SizeConst = 4), FieldOffset(33 * 4)]
            public float[] slipRatio;
            [MarshalAs(UnmanagedType.ByValArray, ArraySubType = UnmanagedType.R4, SizeConst = 4), FieldOffset(37 * 4)]
            public float[] tyreSlip;
            [MarshalAs(UnmanagedType.ByValArray, ArraySubType = UnmanagedType.R4, SizeConst = 4), FieldOffset(41 * 4)]
            public float[] ndSlip;
            [MarshalAs(UnmanagedType.ByValArray, ArraySubType = UnmanagedType.R4, SizeConst = 4), FieldOffset(45 * 4)]
            public float[] load;
            [MarshalAs(UnmanagedType.ByValArray, ArraySubType = UnmanagedType.R4, SizeConst = 4), FieldOffset(49 * 4)]
            public float[] Dy;
            [MarshalAs(UnmanagedType.ByValArray, ArraySubType = UnmanagedType.R4, SizeConst = 4), FieldOffset(53 * 4)]
            public float[] Mz;
            [MarshalAs(UnmanagedType.ByValArray, ArraySubType = UnmanagedType.R4, SizeConst = 4), FieldOffset(57 * 4)]
            public float[] tyreDirtyLevel;

            [MarshalAs(UnmanagedType.ByValArray, ArraySubType = UnmanagedType.R4, SizeConst = 4), FieldOffset(61 * 4)]
            public float[] camberRAD;
            [MarshalAs(UnmanagedType.ByValArray, ArraySubType = UnmanagedType.R4, SizeConst = 4), FieldOffset(65 * 4)]
            public float[] tyreRadius;
            [MarshalAs(UnmanagedType.ByValArray, ArraySubType = UnmanagedType.R4, SizeConst = 4), FieldOffset(69 * 4)]
            public float[] tyreLoadedRadius;
            [MarshalAs(UnmanagedType.ByValArray, ArraySubType = UnmanagedType.R4, SizeConst = 4), FieldOffset(73 * 4)]
            public float[] suspensionHeight;

            [MarshalAs(UnmanagedType.R4), FieldOffset(77 * 4)]
            public float carPositionNormalized;
            [MarshalAs(UnmanagedType.R4), FieldOffset(78 * 4)]
            public float carSlope;
            [MarshalAs(UnmanagedType.ByValArray, ArraySubType = UnmanagedType.R4, SizeConst = 3), FieldOffset(79 * 4)]
            public float[] carCoordinates;

        };
    }

}