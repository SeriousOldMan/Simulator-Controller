using System;
using Newtonsoft.Json;

namespace SimulatorController.SimHub.Plugin
{
    /// <summary>
    /// Root model for Simulator Controller session state.
    /// CRITICAL: All properties are nullable to handle missing data gracefully.
    /// </summary>
    public class SessionState
    {
        [JsonProperty("Assistants")]
        public AssistantsData Assistants { get; set; }

        [JsonProperty("Automation")]
        public AutomationData Automation { get; set; }

        [JsonProperty("Brakes")]
        public BrakesData Brakes { get; set; }

        [JsonProperty("Engine")]
        public EngineData Engine { get; set; }

        [JsonProperty("Conditions")]
        public ConditionsData Conditions { get; set; }

        [JsonProperty("Damage")]
        public DamageData Damage { get; set; }

        [JsonProperty("Duration")]
        public DurationData Duration { get; set; }

        [JsonProperty("Fuel")]
        public FuelData Fuel { get; set; }

        [JsonProperty("Pitstop")]
        public PitstopData Pitstop { get; set; }

        [JsonProperty("Session")]
        public SessionData Session { get; set; }

        [JsonProperty("Standings")]
        public StandingsData Standings { get; set; }

        [JsonProperty("Stint")]
        public StintData Stint { get; set; }

        [JsonProperty("Strategy")]
        public StrategyData Strategy { get; set; }

        [JsonProperty("TeamServer")]
        public TeamServerData TeamServer { get; set; }

        [JsonProperty("Tyres")]
        public TyresData Tyres { get; set; }

        [JsonProperty("Instructions")]
        public InstructionsData Instructions { get; set; }
    }

    #region Assistants

    public class AssistantsData
    {
        [JsonProperty("Mode")]
        public string Mode { get; set; }

        [JsonProperty("Race Engineer")]
        public AssistantState RaceEngineer { get; set; }

        [JsonProperty("Race Spotter")]
        public AssistantState RaceSpotter { get; set; }

        [JsonProperty("Race Strategist")]
        public AssistantState RaceStrategist { get; set; }

        [JsonProperty("Driving Coach")]
        public AssistantState DrivingCoach { get; set; }

        [JsonProperty("Session")]
        public string Session { get; set; }
    }

    public class AssistantState
    {
        [JsonProperty("Muted")]
        public bool? Muted { get; set; }

        [JsonProperty("State")]
        public string State { get; set; }
    }

    #endregion

    #region Automation

    public class AutomationData
    {
        [JsonProperty("Automation")]
        public string Automation { get; set; }

        [JsonProperty("Car")]
        public string Car { get; set; }

        [JsonProperty("Session")]
        public string Session { get; set; }

        [JsonProperty("Simulator")]
        public string Simulator { get; set; }

        [JsonProperty("Track")]
        public string Track { get; set; }

        [JsonProperty("State")]
        public string State { get; set; }
    }

    #endregion

    #region Brakes

    public class BrakesData
    {
        [JsonProperty("Temperatures")]
        public double?[] Temperatures { get; set; }

        [JsonProperty("Wear")]
        public int?[] Wear { get; set; }
    }

    #endregion

    #region Engine

    public class EngineData
    {
        [JsonProperty("WaterTemperature")]
        public double? WaterTemperature { get; set; }

        [JsonProperty("OilTemperature")]
        public double? OilTemperature { get; set; }
    }

    #endregion

    #region Conditions

    public class ConditionsData
    {
        [JsonProperty("AirTemperature")]
        public double? AirTemperature { get; set; }

        [JsonProperty("Grip")]
        public string Grip { get; set; }

        [JsonProperty("TrackTemperature")]
        public double? TrackTemperature { get; set; }

        [JsonProperty("Weather")]
        public string Weather { get; set; }

        [JsonProperty("Weather10Min")]
        public string Weather10Min { get; set; }

        [JsonProperty("Weather30Min")]
        public string Weather30Min { get; set; }
    }

    #endregion

    #region Damage

    public class DamageData
    {
        [JsonProperty("Bodywork")]
        public BodyworkDamage Bodywork { get; set; }

        [JsonProperty("Suspension")]
        public SuspensionDamage Suspension { get; set; }

        [JsonProperty("Engine")]
        public double? Engine { get; set; }

        [JsonProperty("LapDelta")]
        public double? LapDelta { get; set; }

        [JsonProperty("RepairTime")]
        public double? RepairTime { get; set; }
    }

    public class BodyworkDamage
    {
        [JsonProperty("Front")]
        public double? Front { get; set; }

        [JsonProperty("Left")]
        public double? Left { get; set; }

        [JsonProperty("Right")]
        public double? Right { get; set; }

        [JsonProperty("Rear")]
        public double? Rear { get; set; }

        [JsonProperty("All")]
        public double? All { get; set; }
    }

    public class SuspensionDamage
    {
        [JsonProperty("FrontLeft")]
        public double? FrontLeft { get; set; }

        [JsonProperty("FrontRight")]
        public double? FrontRight { get; set; }

        [JsonProperty("RearLeft")]
        public double? RearLeft { get; set; }

        [JsonProperty("RearRight")]
        public double? RearRight { get; set; }
    }

    #endregion

    #region Duration

    public class DurationData
    {
        [JsonProperty("Format")]
        public string Format { get; set; }

        [JsonProperty("SessionLapsLeft")]
        public int? SessionLapsLeft { get; set; }

        [JsonProperty("SessionTimeLeft")]
        public string SessionTimeLeft { get; set; }

        [JsonProperty("StintLapsLeft")]
        public int? StintLapsLeft { get; set; }

        [JsonProperty("StintTimeLeft")]
        public string StintTimeLeft { get; set; }
    }

    #endregion

    #region Fuel

    public class FuelData
    {
        [JsonProperty("AvgFuelConsumption")]
        public double? AvgFuelConsumption { get; set; }

        [JsonProperty("LastFuelConsumption")]
        public double? LastFuelConsumption { get; set; }

        [JsonProperty("RemainingFuel")]
        public double? RemainingFuel { get; set; }

        [JsonProperty("RemainingFuelLaps")]
        public int? RemainingFuelLaps { get; set; }

        [JsonProperty("AvgEnergyConsumption")]
        public double? AvgEnergyConsumption { get; set; }

        [JsonProperty("LastEnergyConsumption")]
        public double? LastEnergyConsumption { get; set; }

        [JsonProperty("RemainingEnergy")]
        public double? RemainingEnergy { get; set; }

        [JsonProperty("RemainingEnergyLaps")]
        public int? RemainingEnergyLaps { get; set; }
    }

    #endregion

    #region Pitstop

    public class PitstopData
    {
        [JsonProperty("State")]
        public string State { get; set; }

        [JsonProperty("Fuel")]
        public double? Fuel { get; set; }

        [JsonProperty("Lap")]
        public int? Lap { get; set; }

        [JsonProperty("Driver")]
        public string Driver { get; set; }

        [JsonProperty("ServiceTime")]
        public int? ServiceTime { get; set; }

        [JsonProperty("RepairTime")]
        public int? RepairTime { get; set; }

        [JsonProperty("PitlaneDelta")]
        public int? PitlaneDelta { get; set; }

        [JsonProperty("Number")]
        public int? Number { get; set; }

        [JsonProperty("Prepared")]
        public int? Prepared { get; set; }

        [JsonProperty("TyreCompoundFrontLeft")]
        public string TyreCompoundFrontLeft { get; set; }

        [JsonProperty("TyreCompoundFrontRight")]
        public string TyreCompoundFrontRight { get; set; }

        [JsonProperty("TyreCompoundRearLeft")]
        public string TyreCompoundRearLeft { get; set; }

        [JsonProperty("TyreCompoundRearRight")]
        public string TyreCompoundRearRight { get; set; }

        [JsonProperty("TyrePressures")]
        public double?[] TyrePressures { get; set; }

        [JsonProperty("TyrePressureIncrements")]
        public double?[] TyrePressureIncrements { get; set; }

        [JsonProperty("TyreSet")]
        public int? TyreSet { get; set; }

        [JsonProperty("Brakes")]
        public bool? Brakes { get; set; }

        [JsonProperty("RepairBodywork")]
        public bool? RepairBodywork { get; set; }

        [JsonProperty("RepairSuspension")]
        public bool? RepairSuspension { get; set; }

        [JsonProperty("RepairEngine")]
        public bool? RepairEngine { get; set; }

        [JsonProperty("RepairFrontAero")]
        public bool? RepairFrontAero { get; set; }

        [JsonProperty("RepairRearAero")]
        public bool? RepairRearAero { get; set; }
    }

    #endregion

    #region Session

    public class SessionData
    {
        [JsonProperty("Car")]
        public string Car { get; set; }

        [JsonProperty("Session")]
        public string Session { get; set; }

        [JsonProperty("Simulator")]
        public string Simulator { get; set; }

        [JsonProperty("Track")]
        public string Track { get; set; }

        [JsonProperty("Profile")]
        public string Profile { get; set; }

        [JsonProperty("DriverTimeLeft")]
        public string DriverTimeLeft { get; set; }
    }

    #endregion

    #region Standings

    public class StandingsData
    {
        [JsonProperty("Ahead")]
        public DriverStanding Ahead { get; set; }

        [JsonProperty("Behind")]
        public DriverStanding Behind { get; set; }

        [JsonProperty("ClassPosition")]
        public int? ClassPosition { get; set; }

        [JsonProperty("Focus")]
        public DriverStanding Focus { get; set; }

        [JsonProperty("Leader")]
        public DriverStanding Leader { get; set; }

        [JsonProperty("OverallPosition")]
        public int? OverallPosition { get; set; }
    }

    public class DriverStanding
    {
        [JsonProperty("Delta")]
        public string Delta { get; set; }

        [JsonProperty("InPit")]
        public bool? InPit { get; set; }

        [JsonProperty("LapTime")]
        public string LapTime { get; set; }

        [JsonProperty("Laps")]
        public int? Laps { get; set; }

        [JsonProperty("Nr")]
        public int? Nr { get; set; }
    }

    #endregion

    #region Stint

    public class StintData
    {
        [JsonProperty("BestTime")]
        public string BestTime { get; set; }

        [JsonProperty("Driver")]
        public string Driver { get; set; }

        [JsonProperty("Lap")]
        public int? Lap { get; set; }

        [JsonProperty("Laps")]
        public int? Laps { get; set; }

        [JsonProperty("LastTime")]
        public string LastTime { get; set; }

        [JsonProperty("BestSpeed")]
        public double? BestSpeed { get; set; }

        [JsonProperty("LastSpeed")]
        public double? LastSpeed { get; set; }

        [JsonProperty("Position")]
        public int? Position { get; set; }
    }

    #endregion

    #region Strategy

    public class StrategyData
    {
        [JsonProperty("State")]
        public string State { get; set; }

        [JsonProperty("Fuel")]
        public double? Fuel { get; set; }

        [JsonProperty("Lap")]
        public int? Lap { get; set; }

        [JsonProperty("Position")]
        public int? Position { get; set; }

        [JsonProperty("PlannedPitstops")]
        public int? PlannedPitstops { get; set; }

        [JsonProperty("RemainingPitstops")]
        public int? RemainingPitstops { get; set; }

        [JsonProperty("TyreCompoundFrontLeft")]
        public string TyreCompoundFrontLeft { get; set; }

        [JsonProperty("TyreCompoundFrontRight")]
        public string TyreCompoundFrontRight { get; set; }

        [JsonProperty("TyreCompoundRearLeft")]
        public string TyreCompoundRearLeft { get; set; }

        [JsonProperty("TyreCompoundRearRight")]
        public string TyreCompoundRearRight { get; set; }

        [JsonProperty("Pitstops")]
        public PlannedPitstop[] Pitstops { get; set; }
    }

    public class PlannedPitstop
    {
        [JsonProperty("Nr")]
        public int? Nr { get; set; }

        [JsonProperty("Fuel")]
        public double? Fuel { get; set; }

        [JsonProperty("TyreCompoundFrontLeft")]
        public string TyreCompoundFrontLeft { get; set; }

        [JsonProperty("TyreCompoundFrontRight")]
        public string TyreCompoundFrontRight { get; set; }

        [JsonProperty("TyreCompoundRearLeft")]
        public string TyreCompoundRearLeft { get; set; }

        [JsonProperty("TyreCompoundRearRight")]
        public string TyreCompoundRearRight { get; set; }
    }

    #endregion

    #region Team Server

    public class TeamServerData
    {
        [JsonProperty("Driver")]
        public string Driver { get; set; }

        [JsonProperty("Server")]
        public string Server { get; set; }

        [JsonProperty("Session")]
        public string Session { get; set; }

        [JsonProperty("Team")]
        public string Team { get; set; }

        [JsonProperty("Token")]
        public string Token { get; set; }
    }

    #endregion

    #region Tyres

    public class TyresData
    {
        [JsonProperty("HotPressures")]
        public double?[] HotPressures { get; set; }

        [JsonProperty("ColdPressures")]
        public double?[] ColdPressures { get; set; }

        [JsonProperty("PressureLosses")]
        public double?[] PressureLosses { get; set; }

        [JsonProperty("Temperatures")]
        public double?[] Temperatures { get; set; }

        [JsonProperty("Wear")]
        public double?[] Wear { get; set; }

        [JsonProperty("Laps")]
        public int?[] Laps { get; set; }

        [JsonProperty("TyreCompoundFrontLeft")]
        public string TyreCompoundFrontLeft { get; set; }

        [JsonProperty("TyreCompoundFrontRight")]
        public string TyreCompoundFrontRight { get; set; }

        [JsonProperty("TyreCompoundRearLeft")]
        public string TyreCompoundRearLeft { get; set; }

        [JsonProperty("TyreCompoundRearRight")]
        public string TyreCompoundRearRight { get; set; }

        [JsonProperty("TyreSet")]
        public int? TyreSet { get; set; }
    }

    #endregion

    #region Instructions

    public class InstructionsData
    {
        [JsonProperty("Corner")]
        public int? Corner { get; set; }

        [JsonProperty("Hints")]
        public HintData[] Hints { get; set; }
    }

    public class HintData
    {
        [JsonProperty("Hint")]
        public string Hint { get; set; }

        [JsonProperty("Message")]
        public string Message { get; set; }
    }

    #endregion
}
