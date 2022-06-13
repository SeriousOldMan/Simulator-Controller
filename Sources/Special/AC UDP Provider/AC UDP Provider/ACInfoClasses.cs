using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ACUDPProvider
{
    public class SessionInfo
    {
        public string driverName { get; set; } = "drivername";
        public string carName { get; set; } = "carname";
        public string trackName { get; set; } = "trackname";
        public string trackLayout { get; set; } = "tracklayout";
    }

    public class LapInfo
    {
        public string driverName { get; set; } = "drivername";
        public string carName { get; set; } = "carname";
        public int carIdentifier { get; set; } = 0;
        public int lapNumber { get; set; } = 0;
        public TimeSpan lapTime { get; set; } = TimeSpan.Zero;
    }

    public class CarInfo
    {
        public string identifier;

        public int position;

        public float splinePosition;

        public TimeSpan lastLapTime { get; set; } = TimeSpan.Zero;
        public TimeSpan bestLapTime { get; set; } = TimeSpan.Zero;
        public TimeSpan currentLapTime { get; set; } = TimeSpan.Zero;

        public int lapNumber { get; set; }

        public float speedAsKmh { get; set; }
        public int Gear { get; set; } = 0;
        public float maxRPM { get; private set; }
        private float _enginerpm = 0;
        public float engineRPM
        {
            get { return _enginerpm; }
            set {
                if (value > maxRPM)
                    maxRPM = value;
                _enginerpm = value;
            }
        }
    }

    internal static class AcHelperFunctions
    {
        public static string SanitiseString(string instring)
        {
            int index = instring.IndexOf('%');
            return instring.Substring(0, index);
        }
    }
}