using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ksBroadcastingNetwork.Structs
{
    public class LapInfo
    {
        public int? LaptimeMS { get; internal set; }
        public List<int?> Splits { get; } = new List<int?>();
        public ushort CarIndex { get; internal set; }
        public ushort DriverIndex { get; internal set; }
        public bool IsInvalid { get; internal set; }
        public bool IsValidForBest { get; internal set; }
        public LapType Type { get; internal set; }

        public override string ToString()
        {
            return $"{LaptimeMS, 5}|{string.Join("|", Splits)}";
        }
    }
}
