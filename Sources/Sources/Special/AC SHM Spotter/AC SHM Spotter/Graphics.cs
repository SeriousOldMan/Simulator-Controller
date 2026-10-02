using System;
using System.Collections.Generic;
using System.Linq;
using System.Runtime.InteropServices;
using System.Text;
using System.Threading.Tasks;

namespace ACSHMSpotter
{
    public enum AC_FLAG_TYPE
    {
        AC_NO_FLAG = 0,
        AC_BLUE_FLAG = 1,
        AC_YELLOW_FLAG = 2,
        AC_BLACK_FLAG = 3,
        AC_WHITE_FLAG = 4,
        AC_CHECKERED_FLAG = 5,
        AC_PENALTY_FLAG = 6
    }

    public enum AC_STATUS
    {
        AC_OFF = 0,
        AC_REPLAY = 1,
        AC_LIVE = 2,
        AC_PAUSE = 3
    }

    public enum AC_SESSION_TYPE
    {
        AC_UNKNOWN = -1,
        AC_PRACTICE = 0,
        AC_QUALIFY = 1,
        AC_RACE = 2,
        AC_HOTLAP = 3,
        AC_TIME_ATTACK = 4,
        AC_DRIFT = 5,
        AC_DRAG = 6
    }

    public class GraphicsEventArgs : EventArgs
    {
        public GraphicsEventArgs (Graphics graphics)
        {
            this.Graphics = graphics;
        }

        public Graphics Graphics { get; private set; }
    }

    [StructLayout (LayoutKind.Sequential, Pack = 4, CharSet = CharSet.Unicode)]
    [Serializable]
    public struct Graphics
    {
        public int PacketId;
        public AC_STATUS Status;
        public AC_SESSION_TYPE Session;
        [MarshalAs (UnmanagedType.ByValTStr, SizeConst = 15)]
        public String CurrentTime;
        [MarshalAs (UnmanagedType.ByValTStr, SizeConst = 15)]
        public String LastTime;
        [MarshalAs (UnmanagedType.ByValTStr, SizeConst = 15)]
        public String BestTime;
        [MarshalAs (UnmanagedType.ByValTStr, SizeConst = 15)]
        public String Split;
        public int CompletedLaps;
        public int Position;
        public int iCurrentTime;
        public int iLastTime;
        public int iBestTime;
        public float SessionTimeLeft;
        public float DistanceTraveled;
        public int IsInPit;
        public int CurrentSectorIndex;
        public int LastSectorTime;
        public int NumberOfLaps;
        [MarshalAs (UnmanagedType.ByValTStr, SizeConst = 33)]
        public String TyreCompound;

        public float ReplayTimeMultiplier;
        public float NormalizedCarPosition;
        [MarshalAs (UnmanagedType.ByValArray, SizeConst = 3)]
        public float[] CarCoordinates;

        public float PenaltyTime;
        public AC_FLAG_TYPE Flag;
        public int IdealLineOn;

        // since 1.5
        public int IsInPitLane;
        public float SurfaceGrip;
    
        // since 1.13
        public int MandatoryPitDone;
    }
}