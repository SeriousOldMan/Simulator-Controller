using SQLite;
using System;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace TeamServer.Model.Data
{
    public abstract class DataObject : ModelObject
    {
        [Indexed]
        public int AccountID { get; set; }
    
        [Indexed]
        public long Modified { get; set; } = DateTime.Now.ToFileTimeUtc();

        [Ignore]
        public TeamServer.Model.Access.Account Account
        {
            get {
                return ObjectManager.GetAccountAsync(this.AccountID).Result;
            }
        }

        public override System.Threading.Tasks.Task Save()
        {
            Modified = DateTime.Now.ToFileTimeUtc();

            return base.Save();
        }
    }

    public abstract class SimulatorObject : DataObject
    {
        public string Simulator { get; set; }
    }

    [Table("Data_Licenses")]
    public class License : SimulatorObject
    {
        [Indexed]
        public string Driver { get; set; }

        public string Forname { get; set; }

        public string Surname { get; set; }

        public string Nickname { get; set; }
    }

    public abstract class CarObject : SimulatorObject
    {
        [Indexed]
        public string Car { get; set; }

        [Indexed]
        public string Track { get; set; }

        [Indexed]
        public string Driver { get; set; }
    }

    [Table("Data_Documents")]
    public class Document : TelemetryObject
    {
    }

    public abstract class TelemetryObject : CarObject
    {
        public string Weather { get; set; }

        public float AirTemperature { get; set; }

        public float TrackTemperature { get; set; }

        public string TyreCompound { get; set; }

        public string TyreCompoundColor { get; set; }

        public float FuelRemaining { get; set; }

        public float FuelConsumption { get; set; }

        public float LapTime { get; set; }
    }

    [Table("Data_Electronics")]
    public class Electronics : TelemetryObject
    {
        public string Map { get; set; }

        public string TC { get; set; }

        public string ABS { get; set; }
    }

    [Table("Data_Tyres")]
    public class Tyres : TelemetryObject
    {
        public int Laps { get; set; }

        public float PressureFrontLeft { get; set; }

        public float PressureFrontRight { get; set; }

        public float PressureRearLeft { get; set; }

        public float PressureRearRight { get; set; }

        public float TemperatureFrontLeft { get; set; }

        public float TemperatureFrontRight { get; set; }

        public float TemperatureRearLeft { get; set; }

        public float TemperatureRearRight { get; set; }

        public float WearFrontLeft { get; set; }

        public float WearFrontRight { get; set; }

        public float WearRearLeft { get; set; }

        public float WearRearRight { get; set; }
    }

    [Table("Data_Brakes")]
    public class Brakes : TelemetryObject
    {
        public int Laps { get; set; }

        public float RotorWearFrontLeft { get; set; }

        public float RotorWearFrontRight { get; set; }

        public float RotorWearRearLeft { get; set; }

        public float RotorWearRearRight { get; set; }

        public float PadWearFrontLeft { get; set; }

        public float PadWearFrontRight { get; set; }

        public float PadWearRearLeft { get; set; }

        public float PadWearRearRight { get; set; }
    }

    public abstract class PressuresObject : CarObject
    {
        [Indexed]
        public string Weather { get; set; }

        [Indexed]
        public float AirTemperature { get; set; }

        [Indexed]
        public float TrackTemperature { get; set; }

        public string TyreCompound { get; set; }

        public string TyreCompoundColor { get; set; }
    }

    [Table("Data_TyresPressures")]
    public class TyresPressures : PressuresObject
    {
        public float HotPressureFrontLeft { get; set; }

        public float HotPressureFrontRight { get; set; }

        public float HotPressureRearLeft { get; set; }

        public float HotPressureRearRight { get; set; }

        public float ColdPressureFrontLeft { get; set; }

        public float ColdPressureFrontRight { get; set; }

        public float ColdPressureRearLeft { get; set; }

        public float ColdPressureRearRight { get; set; }
    }

    [Table("Data_TyresPressuresDistribution")]
    public class TyresPressuresDistribution : PressuresObject
    {
        public string Type { get; set; }

        public string Tyre { get; set; }

        public float Pressure { get; set; }

        public int Count { get; set; }
    }
}