using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ksBroadcastingNetwork.Structs
{
    public struct RealtimeCarUpdate
    {
        public int CarIndex { get; internal set; }
        public int DriverIndex { get; internal set; }
        public int Gear { get; internal set; }
        public float WorldPosX { get; internal set; }
        public float WorldPosY { get; internal set; }
        public float Yaw { get; internal set; }
        public CarLocationEnum CarLocation { get; internal set; }
        public int Kmh { get; internal set; }
        public int Position { get; internal set; }
        public int TrackPosition { get; internal set; }
        public float SplinePosition { get; internal set; }
        public int Delta { get; internal set; }
        public LapInfo BestSessionLap { get; internal set; }
        public LapInfo LastLap { get; internal set; }
        public LapInfo CurrentLap { get; internal set; }
        public int Laps { get; internal set; }
        public ushort CupPosition { get; internal set; }
        public byte DriverCount { get; internal set; }
    }
}
