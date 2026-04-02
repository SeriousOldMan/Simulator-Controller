using System;
using System.Collections.Generic;

namespace F125UDPProtocol
{
    // ── F1 25 UDP Specification ─────────────────────────────────────────
    // 16 packet types, 29-byte PacketHeader, all Little-Endian.
    // Default port 20777, max 22 cars.
    // Wheel order in F1 25 packets: [RL=0, RR=1, FL=2, FR=3]
    // Our output order:             [FL=0, FR=1, RL=2, RR=3]
    // Reorder indices: { 2, 3, 0, 1 }
    // ─────────────────────────────────────────────────────────────────────

    public static class F125Constants
    {
        public const int MaxCars = 22;
        public const int DefaultPort = 20777;
        public const int HeaderSize = 29;

        // Wheel reorder: F1 25 [RL,RR,FL,FR] → output [FL,FR,RL,RR]
        public static readonly int[] WheelReorder = { 2, 3, 0, 1 };

        public static readonly Dictionary<byte, string> ClassNames = new Dictionary<byte, string>
        {
            { 0, "F1" },
            { 1, "F1 Classic" },
            { 2, "F2" },
            { 1, "F1 Sprint" }
        };

        public static readonly Dictionary<byte, string> PenaltyNames = new Dictionary<byte, string>
        {
            { 0, "DT" },
            { 1, "SG" },
            { 4, "TIME" },
            { 6, "DSQ" }
        };

        // Hardcoded names for tracks. In this format ──> Track ID → Name
        public static readonly Dictionary<byte, string> TrackNames = new Dictionary<byte, string>
        {
            {  0, "Melbourne" },
            {  1, "Sepang" },
            {  2, "Shanghai" },
            {  3, "Sakhir" },
            {  4, "Catalunya" },
            {  5, "Monaco" },
            {  6, "Montreal" },
            {  7, "Silverstone" },
            {  8, "Hockenheim" },
            {  9, "Hungaroring" },
            { 10, "Spa" },
            { 11, "Monza" },
            { 12, "Singapore" },
            { 13, "Suzuka" },
            { 14, "Abu Dhabi" },
            { 15, "Austin" },
            { 16, "Interlagos" },
            { 17, "Red Bull Ring" },
            { 18, "Sochi" },
            { 19, "Mexico City" },
            { 20, "Baku" },
            { 21, "Sakhir Short" },
            { 22, "Silverstone Short" },
            { 23, "Austin Short" },
            { 24, "Suzuka Short" },
            { 25, "Hanoi" },
            { 26, "Zandvoort" },
            { 27, "Imola" },
            { 28, "Portimao" },
            { 29, "Jeddah" },
            { 30, "Miami" },
            { 31, "Las Vegas" },
            { 32, "Losail" },
            { 33, "Lusail" },
        };

        // Hardcoded names for teams. In this format ──> Team ID → Name
        public static readonly Dictionary<byte, string> TeamNames = new Dictionary<byte, string>
        {
            {  0, "Mercedes" },
            {  1, "Ferrari" },
            {  2, "Red Bull Racing" },
            {  3, "Williams" },
            {  4, "Aston Martin" },
            {  5, "Alpine" },
            {  6, "RB" },
            {  7, "Haas" },
            {  8, "McLaren" },
            {  9, "Sauber" },
            // My Team / generic
            { 41, "F1 Custom Team" },
            { 104, "Mercedes 2020" },
            { 105, "Ferrari 2020" },
            { 106, "Red Bull 2020" },
            { 107, "Williams 2020" },
            { 108, "Racing Point 2020" },
            { 109, "Renault 2020" },
            { 110, "AlphaTauri 2020" },
            { 111, "Haas 2020" },
            { 112, "McLaren 2020" },
            { 113, "Alfa Romeo 2020" },
            { 143, "Art GP '24" },
            { 144, "Campos '24" },
            { 145, "Carlin '24" },
            { 146, "Rodin Motorsport '24" },
            { 147, "Dams '24" },
            { 148, "Hitech '24" },
            { 149, "Invicta '24" },
            { 150, "MP Motorsport '24" },
            { 151, "Prema '24" },
            { 152, "Trident '24" },
            { 153, "Van Amersfoort '24" },
            { 154, "AIX '24" },
        };

        // ── Tyre Compound → Visual Name ─────────────────────────────────
        public static readonly Dictionary<byte, string> TyreCompounds = new Dictionary<byte, string>
        {
            { 16, "Soft" },       // C5
            { 17, "Medium" },     // C4
            { 18, "Hard" },       // C3
            { 19, "Soft" },       // C2 (alternate mapping)
            { 20, "Medium" },     // C1 (alternate mapping)
            {  7, "Intermediate" },
            {  8, "Wet" },
        };

        public static readonly Dictionary<byte, string> TyreVisualCompounds = new Dictionary<byte, string>
        {
            { 16, "Soft" },
            { 17, "Medium" },
            { 18, "Hard" },
            { 19, "Soft" },
            { 20, "Medium" },
            {  7, "Intermediate" },
            {  8, "Wet" },
        };

        // Hardcoded names for session types. In this format ──> Session Type → Display Name 
        public static readonly Dictionary<byte, string> SessionTypes = new Dictionary<byte, string>
        {
            {  0, "Other" },
            {  1, "Practice" },
            {  2, "Practice" },
            {  3, "Practice" },
            {  4, "Practice" },    // Short Practice
            {  5, "Qualification" },
            {  6, "Qualification" },
            {  7, "Qualification" },
            {  8, "Qualification" }, // Short Qual
            {  9, "Qualification" }, // OSQ
            { 10, "Race" },
            { 11, "Race" },
            { 12, "Race" },
            { 12, "Race" },
            { 13, "Race" },
            { 14, "Race" },
            { 15, "Race" },
            { 16, "Race" },
            { 17, "Race" },
            { 18, "Time Trial" },
        };

        // ── Weather → Display Name ───────────────────────────────────────
        public static readonly Dictionary<byte, string> WeatherTypes = new Dictionary<byte, string>
        {
            { 0, "Dry" },
            { 1, "Dry" },         // Light Cloud
            { 2, "Dry" },         // Overcast
            { 3, "LightRain" },
            { 4, "MediumRain" },
            { 5, "HeavyRain" },   // Storm
        };

        public static string GetClassName(byte classId)
        {
            string name;
            return ClassNames.TryGetValue(classId, out name) ? name : "Unknown";
        }

        public static string GetPenaltyName(byte penId)
        {
            string name;
            return PenaltyNames.TryGetValue(penId, out name) ? name : "";
        }

        public static string GetTrackName(byte trackId)
        {
            string name;
            return TrackNames.TryGetValue(trackId, out name) ? name : "Unknown";
        }

        public static string GetTeamName(byte teamId)
        {
            string name;
            return TeamNames.TryGetValue(teamId, out name) ? name : "Unknown";
        }

        public static string GetTyreCompound(byte actualCompound)
        {
            string name;
            return TyreCompounds.TryGetValue(actualCompound, out name) ? name : "Unknown";
        }

        public static string GetTyreVisualCompound(byte visualCompound)
        {
            string name;
            return TyreVisualCompounds.TryGetValue(visualCompound, out name) ? name : "Unknown";
        }

        public static string GetSessionType(byte sessionType)
        {
            string name;
            return SessionTypes.TryGetValue(sessionType, out name) ? name : "Other";
        }

        public static string GetWeather(byte weatherId)
        {
            string name;
            return WeatherTypes.TryGetValue(weatherId, out name) ? name : "Dry";
        }
    }

    // ═══════════════════════════════════════════════════════════════════
    //  Packet Header (29 bytes)
    // ═══════════════════════════════════════════════════════════════════
    public class PacketHeader
    {
        public ushort PacketFormat;          // 2025
        public byte GameYear;                // 25
        public byte GameMajorVersion;
        public byte GameMinorVersion;
        public byte PacketVersion;
        public byte PacketId;                // Packet type identifier
        public ulong SessionUID;
        public float SessionTime;
        public uint FrameIdentifier;
        public uint OverallFrameIdentifier;
        public byte PlayerCarIndex;
        public byte SecondaryPlayerCarIndex;

        public static PacketHeader Decode(byte[] data)
        {
            var h = new PacketHeader();
            int o = 0;
            h.PacketFormat = BitConverter.ToUInt16(data, o); o += 2;
            h.GameYear = data[o++];
            h.GameMajorVersion = data[o++];
            h.GameMinorVersion = data[o++];
            h.PacketVersion = data[o++];
            h.PacketId = data[o++];
            h.SessionUID = BitConverter.ToUInt64(data, o); o += 8;
            h.SessionTime = BitConverter.ToSingle(data, o); o += 4;
            h.FrameIdentifier = BitConverter.ToUInt32(data, o); o += 4;
            h.OverallFrameIdentifier = BitConverter.ToUInt32(data, o); o += 4;
            h.PlayerCarIndex = data[o++];
            h.SecondaryPlayerCarIndex = data[o++];
            return h;
        }
    }

    // ═══════════════════════════════════════════════════════════════════
    //  Packet 0 – Motion Data (1349 bytes)
    // ═══════════════════════════════════════════════════════════════════
    public class CarMotionData
    {
        public float WorldPositionX;
        public float WorldPositionY;
        public float WorldPositionZ;
        public float WorldVelocityX;
        public float WorldVelocityY;
        public float WorldVelocityZ;
        public short WorldForwardDirX;      // normalized * 32767
        public short WorldForwardDirY;
        public short WorldForwardDirZ;
        public short WorldRightDirX;
        public short WorldRightDirY;
        public short WorldRightDirZ;
        public float GForceLateral;
        public float GForceLongitudinal;
        public float GForceVertical;
        public float Yaw;
        public float Pitch;
        public float Roll;

        public static CarMotionData Decode(byte[] data, ref int o)
        {
            var m = new CarMotionData();
            m.WorldPositionX = BitConverter.ToSingle(data, o); o += 4;
            m.WorldPositionY = BitConverter.ToSingle(data, o); o += 4;
            m.WorldPositionZ = BitConverter.ToSingle(data, o); o += 4;
            m.WorldVelocityX = BitConverter.ToSingle(data, o); o += 4;
            m.WorldVelocityY = BitConverter.ToSingle(data, o); o += 4;
            m.WorldVelocityZ = BitConverter.ToSingle(data, o); o += 4;
            m.WorldForwardDirX = BitConverter.ToInt16(data, o); o += 2;
            m.WorldForwardDirY = BitConverter.ToInt16(data, o); o += 2;
            m.WorldForwardDirZ = BitConverter.ToInt16(data, o); o += 2;
            m.WorldRightDirX = BitConverter.ToInt16(data, o); o += 2;
            m.WorldRightDirY = BitConverter.ToInt16(data, o); o += 2;
            m.WorldRightDirZ = BitConverter.ToInt16(data, o); o += 2;
            m.GForceLateral = BitConverter.ToSingle(data, o); o += 4;
            m.GForceLongitudinal = BitConverter.ToSingle(data, o); o += 4;
            m.GForceVertical = BitConverter.ToSingle(data, o); o += 4;
            m.Yaw = BitConverter.ToSingle(data, o); o += 4;
            m.Pitch = BitConverter.ToSingle(data, o); o += 4;
            m.Roll = BitConverter.ToSingle(data, o); o += 4;
            return m;
        }
    }

    public class PacketMotionData
    {
        public PacketHeader Header;
        public CarMotionData[] CarMotion = new CarMotionData[F125Constants.MaxCars];

        public static PacketMotionData Decode(byte[] data) {
            var p = new PacketMotionData();
            p.Header = PacketHeader.Decode(data);
            int o = F125Constants.HeaderSize;
            for (int i = 0; i < F125Constants.MaxCars; i++)
                p.CarMotion[i] = CarMotionData.Decode(data, ref o);
            return p;
        }
    }

    // ═══════════════════════════════════════════════════════════════════
    //  Packet 1 – Session Data (753 bytes)
    // ═══════════════════════════════════════════════════════════════════
    public class MarshalZone
    {
        public float ZoneStart;
        public sbyte ZoneFlag;  // -1=invalid, 0=none, 1=green, 2=blue, 3=yellow

        public static MarshalZone Decode(byte[] data, ref int o)
        {
            var z = new MarshalZone();
            z.ZoneStart = BitConverter.ToSingle(data, o); o += 4;
            z.ZoneFlag = (sbyte)data[o++];
            return z;
        }
    }

    public class WeatherForecastSample
    {
        public byte SessionType;
        public byte TimeOffset;          // minutes
        public byte Weather;
        public sbyte TrackTemperature;
        public sbyte TrackTemperatureChange;  // 0=up, 1=down, 2=no change
        public sbyte AirTemperature;
        public sbyte AirTemperatureChange;
        public byte RainPercentage;

        public static WeatherForecastSample Decode(byte[] data, ref int o)
        {
            var s = new WeatherForecastSample();
            s.SessionType = data[o++];
            s.TimeOffset = data[o++];
            s.Weather = data[o++];
            s.TrackTemperature = (sbyte)data[o++];
            s.TrackTemperatureChange = (sbyte)data[o++];
            s.AirTemperature = (sbyte)data[o++];
            s.AirTemperatureChange = (sbyte)data[o++];
            s.RainPercentage = data[o++];
            return s;
        }
    }

    public class PacketSessionData
    {
        public PacketHeader Header;
        public byte Weather;
        public sbyte TrackTemperature;
        public sbyte AirTemperature;
        public byte TotalLaps;
        public ushort TrackLength;
        public byte SessionType;
        public sbyte TrackId;
        public byte Formula;               // 0=F1, 1=F1 Classic, 2=F2, 3=F1 Sprint
        public ushort SessionTimeLeft;
        public ushort SessionDuration;
        public byte PitSpeedLimit;
        public byte GamePaused;
        public byte IsSpectating;
        public byte SpectatorCarIndex;
        public byte SliProNativeSupport;
        public byte NumMarshalZones;
        public MarshalZone[] MarshalZones = new MarshalZone[21];
        public byte SafetyCarStatus;       // 0=none, 1=full, 2=virtual, 3=formation lap
        public byte NetworkGame;
        public byte NumWeatherForecastSamples;
        public WeatherForecastSample[] WeatherForecastSamples = new WeatherForecastSample[64];
        public byte ForecastAccuracy;
        public byte AIDifficulty;
        public uint SeasonLinkIdentifier;
        public uint WeekendLinkIdentifier;
        public uint SessionLinkIdentifier;
        public byte PitStopWindowIdealLap;
        public byte PitStopWindowLatestLap;
        public byte PitStopRejoinPosition;
        public byte SteeringAssist;
        public byte BrakingAssist;
        public byte GearboxAssist;           // 1=manual, 2=manual+suggested, 3=auto
        public byte PitAssist;
        public byte PitReleaseAssist;
        public byte ERSAssist;
        public byte DRSAssist;
        public byte DynamicRacingLine;       // 0=off, 1=corners, 2=full
        public byte DynamicRacingLineType;   // 0=2D, 1=3D
        public byte GameMode;
        public byte RuleSet;
        public uint TimeOfDay;
        public byte SessionLength;           // 0=none, 2=very short, 3=short, 4=medium, 5=medium long, 6=long, 7=full
        public byte SpeedUnitsLeadPlayer;
        public byte TemperatureUnitsLeadPlayer;
        public byte SpeedUnitsSecondaryPlayer;
        public byte TemperatureUnitsSecondaryPlayer;
        public byte NumSafetyCarPeriods;
        public byte NumVirtualSafetyCarPeriods;
        public byte NumRedFlagPeriods;
        public byte EqualCarPerformance;
        public byte RecoveryMode;
        public byte FlashbackLimit;
        public byte SurfaceType;
        public byte LowFuelMode;
        public byte RaceStarts;
        public byte TyreSetsMode;
        public byte GearShiftAssist;
        public float TimeTrialPBCarIdx;
        public float TimeTrialRivalCarIdx;
        public byte ExtraLap;

        public static PacketSessionData Decode(byte[] data)
        {
            var p = new PacketSessionData();
            p.Header = PacketHeader.Decode(data);
            int o = F125Constants.HeaderSize;

            p.Weather = data[o++];
            p.TrackTemperature = (sbyte)data[o++];
            p.AirTemperature = (sbyte)data[o++];
            p.TotalLaps = data[o++];
            p.TrackLength = BitConverter.ToUInt16(data, o); o += 2;
            p.SessionType = data[o++];
            p.TrackId = (sbyte)data[o++];
            p.Formula = data[o++];
            p.SessionTimeLeft = BitConverter.ToUInt16(data, o); o += 2;
            p.SessionDuration = BitConverter.ToUInt16(data, o); o += 2;
            p.PitSpeedLimit = data[o++];
            p.GamePaused = data[o++];
            p.IsSpectating = data[o++];
            p.SpectatorCarIndex = data[o++];
            p.SliProNativeSupport = data[o++];
            p.NumMarshalZones = data[o++];
            for (int i = 0; i < 21; i++)
                p.MarshalZones[i] = MarshalZone.Decode(data, ref o);
            p.SafetyCarStatus = data[o++];
            p.NetworkGame = data[o++];
            p.NumWeatherForecastSamples = data[o++];
            for (int i = 0; i < 64; i++)
                p.WeatherForecastSamples[i] = WeatherForecastSample.Decode(data, ref o);
            p.ForecastAccuracy = data[o++];
            p.AIDifficulty = data[o++];
            p.SeasonLinkIdentifier = BitConverter.ToUInt32(data, o); o += 4;
            p.WeekendLinkIdentifier = BitConverter.ToUInt32(data, o); o += 4;
            p.SessionLinkIdentifier = BitConverter.ToUInt32(data, o); o += 4;
            p.PitStopWindowIdealLap = data[o++];
            p.PitStopWindowLatestLap = data[o++];
            p.PitStopRejoinPosition = data[o++];
            p.SteeringAssist = data[o++];
            p.BrakingAssist = data[o++];
            p.GearboxAssist = data[o++];
            p.PitAssist = data[o++];
            p.PitReleaseAssist = data[o++];
            p.ERSAssist = data[o++];
            p.DRSAssist = data[o++];
            p.DynamicRacingLine = data[o++];
            p.DynamicRacingLineType = data[o++];
            p.GameMode = data[o++];
            p.RuleSet = data[o++];
            p.TimeOfDay = BitConverter.ToUInt32(data, o); o += 4;
            p.SessionLength = data[o++];
            p.SpeedUnitsLeadPlayer = data[o++];
            p.TemperatureUnitsLeadPlayer = data[o++];
            p.SpeedUnitsSecondaryPlayer = data[o++];
            p.TemperatureUnitsSecondaryPlayer = data[o++];
            p.NumSafetyCarPeriods = data[o++];
            p.NumVirtualSafetyCarPeriods = data[o++];
            p.NumRedFlagPeriods = data[o++];
            p.EqualCarPerformance = data[o++];
            p.RecoveryMode = data[o++];
            p.FlashbackLimit = data[o++];
            p.SurfaceType = data[o++];
            p.LowFuelMode = data[o++];
            p.RaceStarts = data[o++];
            p.TyreSetsMode = data[o++];
            p.GearShiftAssist = data[o++];
            p.TimeTrialPBCarIdx = BitConverter.ToSingle(data, o); o += 4;
            p.TimeTrialRivalCarIdx = BitConverter.ToSingle(data, o); o += 4;
            p.ExtraLap = data[o++];

            return p;
        }
    }

    // ═══════════════════════════════════════════════════════════════════
    //  Packet 2 – Lap Data (1285 bytes)
    // ═══════════════════════════════════════════════════════════════════
    public class LapData
    {
        public uint LastLapTimeInMS;
        public uint CurrentLapTimeInMS;
        public ushort Sector1TimeInMS;
        public byte Sector1TimeMinutes;
        public ushort Sector2TimeInMS;
        public byte Sector2TimeMinutes;
        public ushort DeltaToCarInFrontInMS;
        public byte DeltaToCarInFrontMinutes;
        public ushort DeltaToRaceLeaderInMS;
        public byte DeltaToRaceLeaderMinutes;
        public float LapDistance;
        public float TotalDistance;
        public float SafetyCarDelta;
        public byte CarPosition;
        public byte CurrentLapNum;
        public byte PitStatus;              // 0=none, 1=pitting, 2=in pit area
        public byte NumPitStops;
        public byte Sector;                 // 0=S1, 1=S2, 2=S3
        public byte CurrentLapInvalid;
        public byte Penalties;
        public byte TotalWarnings;
        public byte CornerCuttingWarnings;
        public byte NumUnservedDriveThroughPens;
        public byte NumUnservedStopGoPens;
        public byte GridPosition;
        public byte DriverStatus;           // 0=garage, 1=flying, 2=in lap, 3=out lap, 4=on track
        public byte ResultStatus;           // 0=invalid, 1=inactive, 2=active, 3=finished, 4=DNF, 5=DSQ, 6=not classified, 7=retired
        public byte PitLaneTimerActive;
        public ushort PitLaneTimeInLaneInMS;
        public ushort PitStopTimerInMS;
        public byte PitStopShouldServePen;

        public static LapData Decode(byte[] data, ref int o)
        {
            var l = new LapData();
            l.LastLapTimeInMS = BitConverter.ToUInt32(data, o); o += 4;
            l.CurrentLapTimeInMS = BitConverter.ToUInt32(data, o); o += 4;
            l.Sector1TimeInMS = BitConverter.ToUInt16(data, o); o += 2;
            l.Sector1TimeMinutes = data[o++];
            l.Sector2TimeInMS = BitConverter.ToUInt16(data, o); o += 2;
            l.Sector2TimeMinutes = data[o++];
            l.DeltaToCarInFrontInMS = BitConverter.ToUInt16(data, o); o += 2;
            l.DeltaToCarInFrontMinutes = data[o++];
            l.DeltaToRaceLeaderInMS = BitConverter.ToUInt16(data, o); o += 2;
            l.DeltaToRaceLeaderMinutes = data[o++];
            l.LapDistance = BitConverter.ToSingle(data, o); o += 4;
            l.TotalDistance = BitConverter.ToSingle(data, o); o += 4;
            l.SafetyCarDelta = BitConverter.ToSingle(data, o); o += 4;
            l.CarPosition = data[o++];
            l.CurrentLapNum = data[o++];
            l.PitStatus = data[o++];
            l.NumPitStops = data[o++];
            l.Sector = data[o++];
            l.CurrentLapInvalid = data[o++];
            l.Penalties = data[o++];
            l.TotalWarnings = data[o++];
            l.CornerCuttingWarnings = data[o++];
            l.NumUnservedDriveThroughPens = data[o++];
            l.NumUnservedStopGoPens = data[o++];
            l.GridPosition = data[o++];
            l.DriverStatus = data[o++];
            l.ResultStatus = data[o++];
            l.PitLaneTimerActive = data[o++];
            l.PitLaneTimeInLaneInMS = BitConverter.ToUInt16(data, o); o += 2;
            l.PitStopTimerInMS = BitConverter.ToUInt16(data, o); o += 2;
            l.PitStopShouldServePen = data[o++];
            return l;
        }
    }

    public class PacketLapData
    {
        public PacketHeader Header;
        public LapData[] LapDataArr = new LapData[F125Constants.MaxCars];
        public byte TimeTrialPBCarIdx;
        public byte TimeTrialRivalCarIdx;

        public static PacketLapData Decode(byte[] data)
        {
            var p = new PacketLapData();
            p.Header = PacketHeader.Decode(data);
            int o = F125Constants.HeaderSize;
            for (int i = 0; i < F125Constants.MaxCars; i++)
                p.LapDataArr[i] = LapData.Decode(data, ref o);
            p.TimeTrialPBCarIdx = data[o++];
            p.TimeTrialRivalCarIdx = data[o++];
            return p;
        }
    }

    // ═══════════════════════════════════════════════════════════════════
    //  Packet 3 – Event Data (45 bytes)
    // ═══════════════════════════════════════════════════════════════════
    public class PacketEventData
    {
        public PacketHeader Header;
        public string EventStringCode;     // 4-char code
        public byte[] EventDetails;        // remaining bytes (variable meaning per event)

        public static PacketEventData Decode(byte[] data)
        {
            var p = new PacketEventData();
            p.Header = PacketHeader.Decode(data);
            int o = F125Constants.HeaderSize;
            p.EventStringCode = System.Text.Encoding.ASCII.GetString(data, o, 4); o += 4;
            if (data.Length > o)
            {
                p.EventDetails = new byte[data.Length - o];
                Array.Copy(data, o, p.EventDetails, 0, p.EventDetails.Length);
            }
            else
                p.EventDetails = new byte[0];
            return p;
        }
    }

    // ═══════════════════════════════════════════════════════════════════
    //  Packet 4 – Participants Data (1284 bytes)
    // ═══════════════════════════════════════════════════════════════════
    public class ParticipantData
    {
        public byte AiControlled;
        public byte DriverId;
        public byte NetworkId;
        public byte TeamId;
        public byte MyTeam;
        public byte RaceNumber;
        public byte Nationality;
        public string Name = "";            // 48 chars max, null-terminated UTF-8
        public byte YourTelemetry;
        public byte ShowOnlineNames;
        public ushort TechLevel;
        public byte Platform;

        public static ParticipantData Decode(byte[] data, ref int o)
        {
            var pd = new ParticipantData();
            pd.AiControlled = data[o++];
            pd.DriverId = data[o++];
            pd.NetworkId = data[o++];
            pd.TeamId = data[o++];
            pd.MyTeam = data[o++];
            pd.RaceNumber = data[o++];
            pd.Nationality = data[o++];
            // Name: 48 bytes, null-terminated
            int nameEnd = o;
            for (int i = 0; i < 48; i++)
            {
                if (data[o + i] == 0) { nameEnd = o + i; break; }
                if (i == 47) nameEnd = o + 48;
            }
            pd.Name = System.Text.Encoding.UTF8.GetString(data, o, nameEnd - o);
            o += 48;
            pd.YourTelemetry = data[o++];
            pd.ShowOnlineNames = data[o++];
            pd.TechLevel = BitConverter.ToUInt16(data, o); o += 2;
            pd.Platform = data[o++];
            return pd;
        }
    }

    public class PacketParticipantsData
    {
        public PacketHeader Header;
        public byte NumActiveCars;
        public ParticipantData[] Participants = new ParticipantData[F125Constants.MaxCars];

        public static PacketParticipantsData Decode(byte[] data)
        {
            var p = new PacketParticipantsData();
            p.Header = PacketHeader.Decode(data);
            int o = F125Constants.HeaderSize;
            p.NumActiveCars = data[o++];
            for (int i = 0; i < F125Constants.MaxCars; i++)
                p.Participants[i] = ParticipantData.Decode(data, ref o);
            return p;
        }
    }

    // ═══════════════════════════════════════════════════════════════════
    //  Packet 5 – Car Setups Data (1133 bytes)
    // ═══════════════════════════════════════════════════════════════════
    public class CarSetupData
    {
        public byte FrontWing;
        public byte RearWing;
        public byte OnThrottle;              // percentage
        public byte OffThrottle;
        public float FrontCamber;
        public float RearCamber;
        public float FrontToe;
        public float RearToe;
        public byte FrontSuspension;
        public byte RearSuspension;
        public byte FrontAntiRollBar;
        public byte RearAntiRollBar;
        public byte FrontSuspensionHeight;
        public byte RearSuspensionHeight;
        public byte BrakePressure;
        public byte BrakeBias;
        public float RearLeftTyrePressure;
        public float RearRightTyrePressure;
        public float FrontLeftTyrePressure;
        public float FrontRightTyrePressure;
        public byte Ballast;
        public float FuelLoad;

        public static CarSetupData Decode(byte[] data, ref int o)
        {
            var s = new CarSetupData();
            s.FrontWing = data[o++];
            s.RearWing = data[o++];
            s.OnThrottle = data[o++];
            s.OffThrottle = data[o++];
            s.FrontCamber = BitConverter.ToSingle(data, o); o += 4;
            s.RearCamber = BitConverter.ToSingle(data, o); o += 4;
            s.FrontToe = BitConverter.ToSingle(data, o); o += 4;
            s.RearToe = BitConverter.ToSingle(data, o); o += 4;
            s.FrontSuspension = data[o++];
            s.RearSuspension = data[o++];
            s.FrontAntiRollBar = data[o++];
            s.RearAntiRollBar = data[o++];
            s.FrontSuspensionHeight = data[o++];
            s.RearSuspensionHeight = data[o++];
            s.BrakePressure = data[o++];
            s.BrakeBias = data[o++];
            s.RearLeftTyrePressure = BitConverter.ToSingle(data, o); o += 4;
            s.RearRightTyrePressure = BitConverter.ToSingle(data, o); o += 4;
            s.FrontLeftTyrePressure = BitConverter.ToSingle(data, o); o += 4;
            s.FrontRightTyrePressure = BitConverter.ToSingle(data, o); o += 4;
            s.Ballast = data[o++];
            s.FuelLoad = BitConverter.ToSingle(data, o); o += 4;
            return s;
        }
    }

    public class PacketCarSetupData
    {
        public PacketHeader Header;
        public CarSetupData[] CarSetups = new CarSetupData[F125Constants.MaxCars];

        public static PacketCarSetupData Decode(byte[] data)
        {
            var p = new PacketCarSetupData();
            p.Header = PacketHeader.Decode(data);
            int o = F125Constants.HeaderSize;
            for (int i = 0; i < F125Constants.MaxCars; i++)
                p.CarSetups[i] = CarSetupData.Decode(data, ref o);
            return p;
        }
    }

    // ═══════════════════════════════════════════════════════════════════
    //  Packet 6 – Car Telemetry Data (1352 bytes)
    // ═══════════════════════════════════════════════════════════════════
    public class CarTelemetryData
    {
        public ushort Speed;                 // km/h
        public float Throttle;               // 0..1
        public float Steer;                  // -1..1 (full left to full right)
        public float Brake;                  // 0..1
        public byte Clutch;                  // 0..100
        public sbyte Gear;                   // -1=R, 0=N, 1-8
        public ushort EngineRPM;
        public byte DRS;                     // 0=off, 1=on
        public byte RevLightsPercent;
        public ushort RevLightsBitValue;
        public ushort[] BrakesTemperature = new ushort[4];  // [RL,RR,FL,FR]
        public byte[] TyresSurfaceTemperature = new byte[4];
        public byte[] TyresInnerTemperature = new byte[4];
        public ushort EngineTemperature;
        public float[] TyresPressure = new float[4];        // PSI
        public byte[] SurfaceType = new byte[4];
        public byte Overtake;

        public static CarTelemetryData Decode(byte[] data, ref int o)
        {
            var t = new CarTelemetryData();
            t.Speed = BitConverter.ToUInt16(data, o); o += 2;
            t.Throttle = BitConverter.ToSingle(data, o); o += 4;
            t.Steer = BitConverter.ToSingle(data, o); o += 4;
            t.Brake = BitConverter.ToSingle(data, o); o += 4;
            t.Clutch = data[o++];
            t.Gear = (sbyte)data[o++];
            t.EngineRPM = BitConverter.ToUInt16(data, o); o += 2;
            t.DRS = data[o++];
            t.RevLightsPercent = data[o++];
            t.RevLightsBitValue = BitConverter.ToUInt16(data, o); o += 2;
            for (int i = 0; i < 4; i++) { t.BrakesTemperature[i] = BitConverter.ToUInt16(data, o); o += 2; }
            for (int i = 0; i < 4; i++) { t.TyresSurfaceTemperature[i] = data[o++]; }
            for (int i = 0; i < 4; i++) { t.TyresInnerTemperature[i] = data[o++]; }
            t.EngineTemperature = BitConverter.ToUInt16(data, o); o += 2;
            for (int i = 0; i < 4; i++) { t.TyresPressure[i] = BitConverter.ToSingle(data, o); o += 4; }
            for (int i = 0; i < 4; i++) { t.SurfaceType[i] = data[o++]; }
            t.Overtake = data[o++];
            return t;
        }
    }

    public class PacketCarTelemetryData
    {
        public PacketHeader Header;
        public CarTelemetryData[] CarTelemetry = new CarTelemetryData[F125Constants.MaxCars];
        public byte MFDPanelIndex;
        public byte MFDPanelIndexSecondaryPlayer;
        public sbyte SuggestedGear;   // 0=none

        public static PacketCarTelemetryData Decode(byte[] data)
        {
            var p = new PacketCarTelemetryData();
            p.Header = PacketHeader.Decode(data);
            int o = F125Constants.HeaderSize;
            for (int i = 0; i < F125Constants.MaxCars; i++)
                p.CarTelemetry[i] = CarTelemetryData.Decode(data, ref o);
            p.MFDPanelIndex = data[o++];
            p.MFDPanelIndexSecondaryPlayer = data[o++];
            p.SuggestedGear = (sbyte)data[o++];
            return p;
        }
    }

    // ═══════════════════════════════════════════════════════════════════
    //  Packet 7 – Car Status Data (1239 bytes)
    // ═══════════════════════════════════════════════════════════════════
    public class CarStatusData
    {
        public byte TractionControl;         // 0=off, 1=medium, 2=full
        public byte AntiLockBrakes;          // 0=off, 1=on
        public byte FuelMix;                 // 0=lean, 1=standard, 2=rich, 3=max
        public byte FrontBrakeBias;
        public byte PitLimiterStatus;
        public float FuelInTank;
        public float FuelCapacity;
        public float FuelRemainingLaps;
        public ushort MaxRPM;
        public ushort IdleRPM;
        public byte MaxGears;
        public byte DRSAllowed;              // 0=not allowed, 1=allowed
        public ushort DRSActivationDistance;
        public byte ActualTyreCompound;
        public byte VisualTyreCompound;
        public byte TyresAgeLaps;
        public sbyte VehicleFIAFlags;        // -1=invalid, 0=none, 1=green, 2=blue, 3=yellow
        public float PowerTrainTemperature;
        public float ERSStoreEnergy;
        public byte ERSDeployMode;           // 0=none, 1=medium, 2=hotlap, 3=overtake
        public float ERSHarvestedThisLapMGUK;
        public float ERSHarvestedThisLapMGUH;
        public float ERSDeployedThisLap;
        public byte NetworkPaused;

        public static CarStatusData Decode(byte[] data, ref int o)
        {
            var s = new CarStatusData();
            s.TractionControl = data[o++];
            s.AntiLockBrakes = data[o++];
            s.FuelMix = data[o++];
            s.FrontBrakeBias = data[o++];
            s.PitLimiterStatus = data[o++];
            s.FuelInTank = BitConverter.ToSingle(data, o); o += 4;
            s.FuelCapacity = BitConverter.ToSingle(data, o); o += 4;
            s.FuelRemainingLaps = BitConverter.ToSingle(data, o); o += 4;
            s.MaxRPM = BitConverter.ToUInt16(data, o); o += 2;
            s.IdleRPM = BitConverter.ToUInt16(data, o); o += 2;
            s.MaxGears = data[o++];
            s.DRSAllowed = data[o++];
            s.DRSActivationDistance = BitConverter.ToUInt16(data, o); o += 2;
            s.ActualTyreCompound = data[o++];
            s.VisualTyreCompound = data[o++];
            s.TyresAgeLaps = data[o++];
            s.VehicleFIAFlags = (sbyte)data[o++];
            s.PowerTrainTemperature = BitConverter.ToSingle(data, o); o += 4;
            s.ERSStoreEnergy = BitConverter.ToSingle(data, o); o += 4;
            s.ERSDeployMode = data[o++];
            s.ERSHarvestedThisLapMGUK = BitConverter.ToSingle(data, o); o += 4;
            s.ERSHarvestedThisLapMGUH = BitConverter.ToSingle(data, o); o += 4;
            s.ERSDeployedThisLap = BitConverter.ToSingle(data, o); o += 4;
            s.NetworkPaused = data[o++];
            return s;
        }
    }

    public class PacketCarStatusData
    {
        public PacketHeader Header;
        public CarStatusData[] CarStatus = new CarStatusData[F125Constants.MaxCars];

        public static PacketCarStatusData Decode(byte[] data)
        {
            var p = new PacketCarStatusData();
            p.Header = PacketHeader.Decode(data);
            int o = F125Constants.HeaderSize;
            for (int i = 0; i < F125Constants.MaxCars; i++)
                p.CarStatus[i] = CarStatusData.Decode(data, ref o);
            return p;
        }
    }

    // ═══════════════════════════════════════════════════════════════════
    //  Packet 8 – Final Classification Data (1042 bytes)
    // ═══════════════════════════════════════════════════════════════════
    public class FinalClassificationData
    {
        public byte Position;
        public byte NumLaps;
        public byte GridPosition;
        public byte Points;
        public byte NumPitStops;
        public byte ResultStatus;
        public uint BestLapTimeInMS;
        public double TotalRaceTime;
        public byte PenaltiesTime;
        public byte NumPenalties;
        public byte NumTyreStints;
        public byte[] TyreStintsActual = new byte[8];
        public byte[] TyreStintsVisual = new byte[8];
        public byte[] TyreStintsEndLaps = new byte[8];

        public static FinalClassificationData Decode(byte[] data, ref int o)
        {
            var f = new FinalClassificationData();
            f.Position = data[o++];
            f.NumLaps = data[o++];
            f.GridPosition = data[o++];
            f.Points = data[o++];
            f.NumPitStops = data[o++];
            f.ResultStatus = data[o++];
            f.BestLapTimeInMS = BitConverter.ToUInt32(data, o); o += 4;
            f.TotalRaceTime = BitConverter.ToDouble(data, o); o += 8;
            f.PenaltiesTime = data[o++];
            f.NumPenalties = data[o++];
            f.NumTyreStints = data[o++];
            for (int i = 0; i < 8; i++) f.TyreStintsActual[i] = data[o++];
            for (int i = 0; i < 8; i++) f.TyreStintsVisual[i] = data[o++];
            for (int i = 0; i < 8; i++) f.TyreStintsEndLaps[i] = data[o++];
            return f;
        }
    }

    public class PacketFinalClassificationData
    {
        public PacketHeader Header;
        public byte NumCars;
        public FinalClassificationData[] ClassificationData = new FinalClassificationData[F125Constants.MaxCars];

        public static PacketFinalClassificationData Decode(byte[] data)
        {
            var p = new PacketFinalClassificationData();
            p.Header = PacketHeader.Decode(data);
            int o = F125Constants.HeaderSize;
            p.NumCars = data[o++];
            for (int i = 0; i < F125Constants.MaxCars; i++)
                p.ClassificationData[i] = FinalClassificationData.Decode(data, ref o);
            return p;
        }
    }

    // ═══════════════════════════════════════════════════════════════════
    //  Packet 9 – Lobby Info Data (954 bytes)
    // ═══════════════════════════════════════════════════════════════════
    public class LobbyInfoData
    {
        public byte AiControlled;
        public byte TeamId;
        public byte Nationality;
        public byte Platform;
        public string Name = "";
        public byte CarNumber;
        public byte ReadyStatus;

        public static LobbyInfoData Decode(byte[] data, ref int o)
        {
            var l = new LobbyInfoData();
            l.AiControlled = data[o++];
            l.TeamId = data[o++];
            l.Nationality = data[o++];
            l.Platform = data[o++];
            int nameEnd = o;
            for (int i = 0; i < 48; i++)
            {
                if (data[o + i] == 0) { nameEnd = o + i; break; }
                if (i == 47) nameEnd = o + 48;
            }
            l.Name = System.Text.Encoding.UTF8.GetString(data, o, nameEnd - o);
            o += 48;
            l.CarNumber = data[o++];
            l.ReadyStatus = data[o++];
            return l;
        }
    }

    public class PacketLobbyInfoData
    {
        public PacketHeader Header;
        public byte NumPlayers;
        public LobbyInfoData[] LobbyPlayers = new LobbyInfoData[F125Constants.MaxCars];

        public static PacketLobbyInfoData Decode(byte[] data)
        {
            var p = new PacketLobbyInfoData();
            p.Header = PacketHeader.Decode(data);
            int o = F125Constants.HeaderSize;
            p.NumPlayers = data[o++];
            for (int i = 0; i < F125Constants.MaxCars; i++)
                p.LobbyPlayers[i] = LobbyInfoData.Decode(data, ref o);
            return p;
        }
    }

    // ═══════════════════════════════════════════════════════════════════
    //  Packet 10 – Car Damage Data (1041 bytes)
    // ═══════════════════════════════════════════════════════════════════
    public class CarDamageData
    {
        public float[] TyresWear = new float[4];       // [RL,RR,FL,FR] percentage
        public byte[] TyresDamage = new byte[4];
        public byte[] BrakesDamage = new byte[4];
        public byte FrontLeftWingDamage;
        public byte FrontRightWingDamage;
        public byte RearWingDamage;
        public byte FloorDamage;
        public byte DiffuserDamage;
        public byte SidepodDamage;
        public byte DRSFault;
        public byte ERSFault;
        public byte GearBoxDamage;
        public byte EngineDamage;
        public byte EngineMGUHWear;
        public byte EngineESWear;
        public byte EngineCEWear;
        public byte EngineICEWear;
        public byte EngineMGUKWear;
        public byte EngineTCWear;
        public byte EngineBlown;              // 0=OK, 1=blown
        public byte EngineSeized;

        public static CarDamageData Decode(byte[] data, ref int o)
        {
            var d = new CarDamageData();
            for (int i = 0; i < 4; i++) { d.TyresWear[i] = BitConverter.ToSingle(data, o); o += 4; }
            for (int i = 0; i < 4; i++) d.TyresDamage[i] = data[o++];
            for (int i = 0; i < 4; i++) d.BrakesDamage[i] = data[o++];
            d.FrontLeftWingDamage = data[o++];
            d.FrontRightWingDamage = data[o++];
            d.RearWingDamage = data[o++];
            d.FloorDamage = data[o++];
            d.DiffuserDamage = data[o++];
            d.SidepodDamage = data[o++];
            d.DRSFault = data[o++];
            d.ERSFault = data[o++];
            d.GearBoxDamage = data[o++];
            d.EngineDamage = data[o++];
            d.EngineMGUHWear = data[o++];
            d.EngineESWear = data[o++];
            d.EngineCEWear = data[o++];
            d.EngineICEWear = data[o++];
            d.EngineMGUKWear = data[o++];
            d.EngineTCWear = data[o++];
            d.EngineBlown = data[o++];
            d.EngineSeized = data[o++];
            return d;
        }
    }

    public class PacketCarDamageData
    {
        public PacketHeader Header;
        public CarDamageData[] CarDamage = new CarDamageData[F125Constants.MaxCars];

        public static PacketCarDamageData Decode(byte[] data)
        {
            var p = new PacketCarDamageData();
            p.Header = PacketHeader.Decode(data);
            int o = F125Constants.HeaderSize;
            for (int i = 0; i < F125Constants.MaxCars; i++)
                p.CarDamage[i] = CarDamageData.Decode(data, ref o);
            return p;
        }
    }

    // ═══════════════════════════════════════════════════════════════════
    //  Packet 11 – Session History Data (1460 bytes)
    // ═══════════════════════════════════════════════════════════════════
    public class LapHistoryData
    {
        public uint LapTimeInMS;
        public ushort Sector1TimeInMS;
        public byte Sector1TimeMinutes;
        public ushort Sector2TimeInMS;
        public byte Sector2TimeMinutes;
        public ushort Sector3TimeInMS;
        public byte Sector3TimeMinutes;
        public byte LapValidBitFlags;       // bit 0=lap valid, bit 1=S1, bit 2=S2, bit 3=S3

        public static LapHistoryData Decode(byte[] data, ref int o)
        {
            var l = new LapHistoryData();
            l.LapTimeInMS = BitConverter.ToUInt32(data, o); o += 4;
            l.Sector1TimeInMS = BitConverter.ToUInt16(data, o); o += 2;
            l.Sector1TimeMinutes = data[o++];
            l.Sector2TimeInMS = BitConverter.ToUInt16(data, o); o += 2;
            l.Sector2TimeMinutes = data[o++];
            l.Sector3TimeInMS = BitConverter.ToUInt16(data, o); o += 2;
            l.Sector3TimeMinutes = data[o++];
            l.LapValidBitFlags = data[o++];
            return l;
        }
    }

    public class TyreStintHistoryData
    {
        public byte EndLap;                  // 255 = current stint
        public byte TyreActualCompound;
        public byte TyreVisualCompound;

        public static TyreStintHistoryData Decode(byte[] data, ref int o)
        {
            var t = new TyreStintHistoryData();
            t.EndLap = data[o++];
            t.TyreActualCompound = data[o++];
            t.TyreVisualCompound = data[o++];
            return t;
        }
    }

    public class PacketSessionHistoryData
    {
        public PacketHeader Header;
        public byte CarIdx;
        public byte NumLaps;
        public byte NumTyreStints;
        public byte BestLapTimeLapNum;
        public byte BestSector1LapNum;
        public byte BestSector2LapNum;
        public byte BestSector3LapNum;
        public LapHistoryData[] LapHistories = new LapHistoryData[100];
        public TyreStintHistoryData[] TyreStintHistories = new TyreStintHistoryData[8];

        public static PacketSessionHistoryData Decode(byte[] data)
        {
            var p = new PacketSessionHistoryData();
            p.Header = PacketHeader.Decode(data);
            int o = F125Constants.HeaderSize;
            p.CarIdx = data[o++];
            p.NumLaps = data[o++];
            p.NumTyreStints = data[o++];
            p.BestLapTimeLapNum = data[o++];
            p.BestSector1LapNum = data[o++];
            p.BestSector2LapNum = data[o++];
            p.BestSector3LapNum = data[o++];
            for (int i = 0; i < 100; i++)
                p.LapHistories[i] = LapHistoryData.Decode(data, ref o);
            for (int i = 0; i < 8; i++)
                p.TyreStintHistories[i] = TyreStintHistoryData.Decode(data, ref o);
            return p;
        }
    }

    // ═══════════════════════════════════════════════════════════════════
    //  Packet 12 – Tyre Sets Data (231 bytes)
    // ═══════════════════════════════════════════════════════════════════
    public class TyreSetData
    {
        public byte ActualTyreCompound;
        public byte VisualTyreCompound;
        public byte Wear;
        public byte Available;
        public byte RecommendedSession;
        public byte LifeSpan;
        public byte UsableLife;
        public short LapDeltaTime;
        public byte Fitted;

        public static TyreSetData Decode(byte[] data, ref int o)
        {
            var t = new TyreSetData();
            t.ActualTyreCompound = data[o++];
            t.VisualTyreCompound = data[o++];
            t.Wear = data[o++];
            t.Available = data[o++];
            t.RecommendedSession = data[o++];
            t.LifeSpan = data[o++];
            t.UsableLife = data[o++];
            t.LapDeltaTime = BitConverter.ToInt16(data, o); o += 2;
            t.Fitted = data[o++];
            return t;
        }
    }

    public class PacketTyreSetsData
    {
        public PacketHeader Header;
        public byte CarIdx;
        public TyreSetData[] TyreSets = new TyreSetData[20];
        public byte FittedIdx;

        public static PacketTyreSetsData Decode(byte[] data)
        {
            var p = new PacketTyreSetsData();
            p.Header = PacketHeader.Decode(data);
            int o = F125Constants.HeaderSize;
            p.CarIdx = data[o++];
            for (int i = 0; i < 20; i++)
                p.TyreSets[i] = TyreSetData.Decode(data, ref o);
            p.FittedIdx = data[o++];
            return p;
        }
    }

    // ═══════════════════════════════════════════════════════════════════
    //  Packet 13 – Motion Ex Data (273 bytes) – Player car only
    // ═══════════════════════════════════════════════════════════════════
    public class PacketMotionExData
    {
        public PacketHeader Header;

        // Suspension position [RL,RR,FL,FR]
        public float[] SuspensionPosition = new float[4];
        public float[] SuspensionVelocity = new float[4];
        public float[] SuspensionAcceleration = new float[4];
        public float[] WheelSpeed = new float[4];
        public float[] WheelSlipRatio = new float[4];
        public float[] WheelSlipAngle = new float[4];
        public float[] WheelLatForce = new float[4];
        public float[] WheelLongForce = new float[4];
        public float HeightOfCOGAboveGround;
        public float LocalVelocityX;
        public float LocalVelocityY;
        public float LocalVelocityZ;
        public float AngularVelocityX;
        public float AngularVelocityY;
        public float AngularVelocityZ;
        public float AngularAccelerationX;
        public float AngularAccelerationY;
        public float AngularAccelerationZ;
        public float FrontWheelsAngle;       // radians
        public float[] WheelVertForce = new float[4];

        public static PacketMotionExData Decode(byte[] data)
        {
            var p = new PacketMotionExData();
            p.Header = PacketHeader.Decode(data);
            int o = F125Constants.HeaderSize;
            for (int i = 0; i < 4; i++) { p.SuspensionPosition[i] = BitConverter.ToSingle(data, o); o += 4; }
            for (int i = 0; i < 4; i++) { p.SuspensionVelocity[i] = BitConverter.ToSingle(data, o); o += 4; }
            for (int i = 0; i < 4; i++) { p.SuspensionAcceleration[i] = BitConverter.ToSingle(data, o); o += 4; }
            for (int i = 0; i < 4; i++) { p.WheelSpeed[i] = BitConverter.ToSingle(data, o); o += 4; }
            for (int i = 0; i < 4; i++) { p.WheelSlipRatio[i] = BitConverter.ToSingle(data, o); o += 4; }
            for (int i = 0; i < 4; i++) { p.WheelSlipAngle[i] = BitConverter.ToSingle(data, o); o += 4; }
            for (int i = 0; i < 4; i++) { p.WheelLatForce[i] = BitConverter.ToSingle(data, o); o += 4; }
            for (int i = 0; i < 4; i++) { p.WheelLongForce[i] = BitConverter.ToSingle(data, o); o += 4; }
            p.HeightOfCOGAboveGround = BitConverter.ToSingle(data, o); o += 4;
            p.LocalVelocityX = BitConverter.ToSingle(data, o); o += 4;
            p.LocalVelocityY = BitConverter.ToSingle(data, o); o += 4;
            p.LocalVelocityZ = BitConverter.ToSingle(data, o); o += 4;
            p.AngularVelocityX = BitConverter.ToSingle(data, o); o += 4;
            p.AngularVelocityY = BitConverter.ToSingle(data, o); o += 4;
            p.AngularVelocityZ = BitConverter.ToSingle(data, o); o += 4;
            p.AngularAccelerationX = BitConverter.ToSingle(data, o); o += 4;
            p.AngularAccelerationY = BitConverter.ToSingle(data, o); o += 4;
            p.AngularAccelerationZ = BitConverter.ToSingle(data, o); o += 4;
            p.FrontWheelsAngle = BitConverter.ToSingle(data, o); o += 4;
            for (int i = 0; i < 4; i++) { p.WheelVertForce[i] = BitConverter.ToSingle(data, o); o += 4; }
            return p;
        }
    }

    // ═══════════════════════════════════════════════════════════════════
    //  Packet 14 – Time Trial Data (101 bytes)
    // ═══════════════════════════════════════════════════════════════════
    // Skipped for now – not needed for core telemetry/racing integration.

    // ═══════════════════════════════════════════════════════════════════
    //  Packet 15 – Lap Positions Data (1131 bytes)
    // ═══════════════════════════════════════════════════════════════════
    // Skipped for now – provides position-per-lap history, not essential.
}
