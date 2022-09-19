using SQLite;
using System;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace TeamServer.Model.Store
{
    public abstract class StoreData : ModelObject
    {
        [Indexed]
        public int AccountID { get; set; }

        [Ignore]
        public TeamServer.Model.Access.Account Account
        {
            get {
                return ObjectManager.GetAccountAsync(this.AccountID).Result;
            }
        }
    }

    [Table("Store_Drivers")]
    public class DriverData : StoreData
    {
        [Indexed]
        public string ID { get; set; }

        public string Forname { get; set; }

        public string Surname { get; set; }

        public string Nickname { get; set; }
    }

    public abstract class SimulatorData : StoreData
    {
        public string Simulator { get; set; }

        [Indexed]
        public string Car { get; set; }

        [Indexed]
        public string Track { get; set; }

        [Indexed]
        public string Driver { get; set; }
    }

    public abstract class TelemetryData : SimulatorData
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

    [Table("Store_Electronics")]
    public class ElectronicsData : TelemetryData
    {
        public string Map { get; set; }

        public string TC { get; set; }

        public string ABS { get; set; }
    }

    [Table("Store_Tyres")]
    public class TyresData : TelemetryData
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

    [Table("Store_Brakes")]
    public class BrakesData : TelemetryData
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

    public abstract class PressuresData : SimulatorData
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

    [Table("Store_Tyres_Pressures")]
    public class TyresPressuresData : PressuresData
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

    [Table("Store_Tyres_Pressures_Distribution")]
    public class TyresPressuresDistributionData : PressuresData
    {
        public string Type { get; set; }

        public string Tyre { get; set; }

        public float Pressure { get; set; }

        public int Count { get; set; }
    }
}