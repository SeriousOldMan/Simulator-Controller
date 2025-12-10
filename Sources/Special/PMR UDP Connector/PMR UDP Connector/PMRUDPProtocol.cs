using System;
using System.Collections.Generic;
using System.Text;

namespace PMRUDPConnector
{
    public enum UDPPacketType : byte
    {
        RaceInfo = 0,
        ParticipantRaceState = 1,
        ParticipantVehicleTelemetry = 2,
        SessionStopped = 3
    }

    public enum UDPRaceSessionState : byte
    {
        Inactive = 0,
        Active = 1,
        Complete = 2
    }

    public class UDPRaceInfo
    {
        public ushort PacketVersion;
        public string Track = "";
        public string Layout = "";
        public string Season = "";
        public string Weather = "";
        public string Session = "";
        public string GameMode = "";
        public float LayoutLength;
        public float Duration;
        public float Overtime;
        public float AmbientTemperature;
        public float TrackTemperature;
        public bool IsLaps;
        public UDPRaceSessionState State;
        public byte NumParticipants;

        public static UDPRaceInfo Decode(byte[] data, ref int offset)
        {
            var info = new UDPRaceInfo();
            info.PacketVersion = BitConverter.ToUInt16(data, offset); offset += 2;
            info.Track = ReadString(data, ref offset);
            info.Layout = ReadString(data, ref offset);
            info.Season = ReadString(data, ref offset);
            info.Weather = ReadString(data, ref offset);
            info.Session = ReadString(data, ref offset);
            info.GameMode = ReadString(data, ref offset);
            info.LayoutLength = BitConverter.ToSingle(data, offset); offset += 4;
            info.Duration = BitConverter.ToSingle(data, offset); offset += 4;
            info.Overtime = BitConverter.ToSingle(data, offset); offset += 4;
            info.AmbientTemperature = BitConverter.ToSingle(data, offset); offset += 4;
            info.TrackTemperature = BitConverter.ToSingle(data, offset); offset += 4;
            info.IsLaps = data[offset++] != 0;
            info.State = (UDPRaceSessionState)data[offset++];
            info.NumParticipants = data[offset++];
            return info;
        }

        private static string ReadString(byte[] data, ref int offset)
        {
            byte len = data[offset++];
            if (len == 0) return "";
            string result = Encoding.UTF8.GetString(data, offset, len);
            offset += len;
            return result;
        }
    }

    public class UDPParticipantRaceState
    {
        public ushort PacketVersion;
        public int VehicleId;
        public bool IsPlayer;
        public string VehicleName = "";
        public string DriverName = "";
        public string LiveryId = "";
        public string VehicleClass = "";
        public int RacePos;
        public int CurrentLap;
        public float CurrentLapTime;
        public float BestLapTime;
        public float LapProgress;
        public int CurrentSector;
        public List<float> CurrentSectorTimes = new List<float>();
        public List<float> BestSectorTimes = new List<float>();
        public bool InPits;
        public bool SessionFinished;
        public bool DQ;
        public uint Flags;

        public static UDPParticipantRaceState Decode(byte[] data, ref int offset)
        {
            var state = new UDPParticipantRaceState();
            state.PacketVersion = BitConverter.ToUInt16(data, offset); offset += 2;
            state.VehicleId = BitConverter.ToInt32(data, offset); offset += 4;
            state.IsPlayer = data[offset++] != 0;
            state.VehicleName = ReadString(data, ref offset);
            state.DriverName = ReadString(data, ref offset);
            state.LiveryId = ReadString(data, ref offset);
            state.VehicleClass = ReadString(data, ref offset);
            state.RacePos = BitConverter.ToInt32(data, offset); offset += 4;
            state.CurrentLap = BitConverter.ToInt32(data, offset); offset += 4;
            state.CurrentLapTime = BitConverter.ToSingle(data, offset); offset += 4;
            state.BestLapTime = BitConverter.ToSingle(data, offset); offset += 4;
            state.LapProgress = BitConverter.ToSingle(data, offset); offset += 4;
            state.CurrentSector = BitConverter.ToInt32(data, offset); offset += 4;
            
            byte numSectors = data[offset++];
            for (int i = 0; i < numSectors; i++)
            {
                state.CurrentSectorTimes.Add(BitConverter.ToSingle(data, offset));
                offset += 4;
            }
            
            numSectors = data[offset++];
            for (int i = 0; i < numSectors; i++)
            {
                state.BestSectorTimes.Add(BitConverter.ToSingle(data, offset));
                offset += 4;
            }
            
            state.InPits = data[offset++] != 0;
            state.SessionFinished = data[offset++] != 0;
            state.DQ = data[offset++] != 0;
            state.Flags = BitConverter.ToUInt32(data, offset); offset += 4;
            return state;
        }

        private static string ReadString(byte[] data, ref int offset)
        {
            byte len = data[offset++];
            if (len == 0) return "";
            string result = Encoding.UTF8.GetString(data, offset, len);
            offset += len;
            return result;
        }
    }

    public class UDPVehicleTelemetry
    {
        public ushort PacketVersion;
        public int VehicleId;
        public List<WheelData> Wheels = new List<WheelData>();
        public ChassisData Chassis = new ChassisData();
        public DrivetrainData Drivetrain = new DrivetrainData();
        public SuspensionData Suspension = new SuspensionData();
        public InputData Input = new InputData();
        public SetupData Setup = new SetupData();
        public GeneralData General = new GeneralData();
        public ConstantData Constant = new ConstantData();

        public class WheelData
        {
            public int ContactMaterialHash;
            public float AngularVelocity;
            public float LinearSpeed;
            public float[] SlideLS = new float[3];
            public float[] ForceLS = new float[3];
            public float[] MomentLS = new float[3];
            public float ContactRadius;
            public float Pressure;
            public float Inclination;
            public float SlipRatio;
            public float SlipAngle;
            public float[] TreadTemp = new float[3];
            public float CarcassTemp;
            public float InternalAirTemp;
            public float WellAirTemp;
            public float RimTemp;
            public float BrakeTemp;
            public float SpringStrain;
            public float DamperVelocity;
            public float HubTorque;
            public float HubPower;
            public float WheelTorque;
            public float WheelPower;
        }

        public class ChassisData
        {
            public float[] PosWS = new float[3];
            public float[] Quat = new float[4];
            public float[] AngularVelocityWS = new float[3];
            public float[] AngularVelocityLS = new float[3];
            public float[] VelocityWS = new float[3];
            public float[] VelocityLS = new float[3];
            public float[] AccelerationWS = new float[3];
            public float[] AccelerationLS = new float[3];
            public float OverallSpeed;
            public float ForwardSpeed;
            public float Sideslip;
        }

        public class DrivetrainData
        {
            public float EngineRPM;
            public float EngineRevRatio;
            public float EngineTorque;
            public float EnginePower;
            public float EngineLoad;
            public float EngineTurboRPM;
            public float EngineTurboBoostPressure;
            public float FuelRemaining;
            public float FuelUseRate;
            public float EngineOilPressure;
            public float EngineOilTemperature;
            public float EngineCoolantTemperature;
            public float ExhaustGasTemperature;
            public float MotorRPM;
            public float BatteryRemaining;
            public float BatteryUseRate;
            public float TransmissionRPM;
            public float GearboxInputRPM;
            public float GearboxOutputRPM;
            public float GearboxTorque;
            public float GearboxPower;
            public float GearboxLoadIn;
            public float GearboxLoadOut;
            public float TimeSinceShift;
            public float EstDrivenSpeed;
            public float OutputTorque;
            public float OutputPower;
            public float OutputEfficiency;
            public bool StarterActive;
            public bool EngineRunning;
            public bool EngineFanRunning;
            public bool RevLimiterActive;
            public bool TractionControlActive;
            public bool SpeedLimiterEnabled;
            public bool SpeedLimiterActive;
            public List<GearData> Gears = new List<GearData>();
        }

        public class GearData
        {
            public float UpshiftRPM;
            public float DownshiftRPM;
        }

        public class SuspensionData
        {
            public List<float> AvgLoads = new List<float>();
            public float LoadBias;
        }

        public class InputData
        {
            public float Steering;
            public float Accelerator;
            public float Brake;
            public float Clutch;
            public float Handbrake;
            public int Gear;
        }

        public class SetupData
        {
            public float BrakeBias;
            public float FrontAntiRollStiffness;
            public float RearAntiRollStiffness;
            public float RegenLimit;
            public float DeployLimit;
            public byte ABSLevel;
            public byte TCSLevel;
        }

        public class GeneralData
        {
            public float[] CenterOfGravity = new float[3];
            public float SteeringWheelAngle;
            public float TotalMass;
            public float DrivenWheelAngVel;
            public float NonDrivenWheelAngVel;
            public float EstRollingSpeed;
            public float EstLinearSpeed;
            public float TotalBrakeForce;
            public bool ABSActive;
        }

        public class ConstantData
        {
            public float[] ChassisBBMin = new float[3];
            public float[] ChassisBBMax = new float[3];
            public float StarterIdleRPM;
            public float EngineTorquePeakRPM;
            public float EnginePowerPeakRPM;
            public float EngineMaxRPM;
            public float EngineMaxTorque;
            public float EngineMaxPower;
            public float EngineMaxBoost;
            public float FuelCapacity;
            public float BatteryCapacity;
            public float TrackWidthFront;
            public float TrackWidthRear;
            public float Wheelbase;
            public byte NumberOfWheels;
            public byte NumberOfForwardGears;
            public byte NumberOfReverseGears;
            public bool IsHybrid;
        }

        public static UDPVehicleTelemetry Decode(byte[] data, ref int offset)
        {
            var telem = new UDPVehicleTelemetry();
            telem.PacketVersion = BitConverter.ToUInt16(data, offset); offset += 2;
            telem.VehicleId = BitConverter.ToInt32(data, offset); offset += 4;

            byte numWheels = data[offset++];
            for (int i = 0; i < numWheels; i++)
                telem.Wheels.Add(ReadWheel(data, ref offset));

            ReadChassis(data, ref offset, telem.Chassis);
            ReadDrivetrain(data, ref offset, telem.Drivetrain);
            ReadSuspension(data, ref offset, telem.Suspension);
            ReadInput(data, ref offset, telem.Input);
            ReadSetup(data, ref offset, telem.Setup);
            ReadGeneral(data, ref offset, telem.General);
            ReadConstant(data, ref offset, telem.Constant);

            return telem;
        }

        private static WheelData ReadWheel(byte[] data, ref int offset)
        {
            var wheel = new WheelData();
            wheel.ContactMaterialHash = BitConverter.ToInt32(data, offset); offset += 4;
            wheel.AngularVelocity = BitConverter.ToSingle(data, offset); offset += 4;
            wheel.LinearSpeed = BitConverter.ToSingle(data, offset); offset += 4;
            for (int i = 0; i < 3; i++) { wheel.SlideLS[i] = BitConverter.ToSingle(data, offset); offset += 4; }
            for (int i = 0; i < 3; i++) { wheel.ForceLS[i] = BitConverter.ToSingle(data, offset); offset += 4; }
            for (int i = 0; i < 3; i++) { wheel.MomentLS[i] = BitConverter.ToSingle(data, offset); offset += 4; }
            wheel.ContactRadius = BitConverter.ToSingle(data, offset); offset += 4;
            wheel.Pressure = BitConverter.ToSingle(data, offset); offset += 4;
            wheel.Inclination = BitConverter.ToSingle(data, offset); offset += 4;
            wheel.SlipRatio = BitConverter.ToSingle(data, offset); offset += 4;
            wheel.SlipAngle = BitConverter.ToSingle(data, offset); offset += 4;
            for (int i = 0; i < 3; i++) { wheel.TreadTemp[i] = BitConverter.ToSingle(data, offset); offset += 4; }
            wheel.CarcassTemp = BitConverter.ToSingle(data, offset); offset += 4;
            wheel.InternalAirTemp = BitConverter.ToSingle(data, offset); offset += 4;
            wheel.WellAirTemp = BitConverter.ToSingle(data, offset); offset += 4;
            wheel.RimTemp = BitConverter.ToSingle(data, offset); offset += 4;
            wheel.BrakeTemp = BitConverter.ToSingle(data, offset); offset += 4;
            wheel.SpringStrain = BitConverter.ToSingle(data, offset); offset += 4;
            wheel.DamperVelocity = BitConverter.ToSingle(data, offset); offset += 4;
            wheel.HubTorque = BitConverter.ToSingle(data, offset); offset += 4;
            wheel.HubPower = BitConverter.ToSingle(data, offset); offset += 4;
            wheel.WheelTorque = BitConverter.ToSingle(data, offset); offset += 4;
            wheel.WheelPower = BitConverter.ToSingle(data, offset); offset += 4;
            return wheel;
        }

        private static void ReadChassis(byte[] data, ref int offset, ChassisData chassis)
        {
            for (int i = 0; i < 3; i++) { chassis.PosWS[i] = BitConverter.ToSingle(data, offset); offset += 4; }
            for (int i = 0; i < 4; i++) { chassis.Quat[i] = BitConverter.ToSingle(data, offset); offset += 4; }
            for (int i = 0; i < 3; i++) { chassis.AngularVelocityWS[i] = BitConverter.ToSingle(data, offset); offset += 4; }
            for (int i = 0; i < 3; i++) { chassis.AngularVelocityLS[i] = BitConverter.ToSingle(data, offset); offset += 4; }
            for (int i = 0; i < 3; i++) { chassis.VelocityWS[i] = BitConverter.ToSingle(data, offset); offset += 4; }
            for (int i = 0; i < 3; i++) { chassis.VelocityLS[i] = BitConverter.ToSingle(data, offset); offset += 4; }
            for (int i = 0; i < 3; i++) { chassis.AccelerationWS[i] = BitConverter.ToSingle(data, offset); offset += 4; }
            for (int i = 0; i < 3; i++) { chassis.AccelerationLS[i] = BitConverter.ToSingle(data, offset); offset += 4; }
            chassis.OverallSpeed = BitConverter.ToSingle(data, offset); offset += 4;
            chassis.ForwardSpeed = BitConverter.ToSingle(data, offset); offset += 4;
            chassis.Sideslip = BitConverter.ToSingle(data, offset); offset += 4;
        }

        private static void ReadDrivetrain(byte[] data, ref int offset, DrivetrainData dt)
        {
            dt.EngineRPM = BitConverter.ToSingle(data, offset); offset += 4;
            dt.EngineRevRatio = BitConverter.ToSingle(data, offset); offset += 4;
            dt.EngineTorque = BitConverter.ToSingle(data, offset); offset += 4;
            dt.EnginePower = BitConverter.ToSingle(data, offset); offset += 4;
            dt.EngineLoad = BitConverter.ToSingle(data, offset); offset += 4;
            dt.EngineTurboRPM = BitConverter.ToSingle(data, offset); offset += 4;
            dt.EngineTurboBoostPressure = BitConverter.ToSingle(data, offset); offset += 4;
            dt.FuelRemaining = BitConverter.ToSingle(data, offset); offset += 4;
            dt.FuelUseRate = BitConverter.ToSingle(data, offset); offset += 4;
            dt.EngineOilPressure = BitConverter.ToSingle(data, offset); offset += 4;
            dt.EngineOilTemperature = BitConverter.ToSingle(data, offset); offset += 4;
            dt.EngineCoolantTemperature = BitConverter.ToSingle(data, offset); offset += 4;
            dt.ExhaustGasTemperature = BitConverter.ToSingle(data, offset); offset += 4;
            dt.MotorRPM = BitConverter.ToSingle(data, offset); offset += 4;
            dt.BatteryRemaining = BitConverter.ToSingle(data, offset); offset += 4;
            dt.BatteryUseRate = BitConverter.ToSingle(data, offset); offset += 4;
            dt.TransmissionRPM = BitConverter.ToSingle(data, offset); offset += 4;
            dt.GearboxInputRPM = BitConverter.ToSingle(data, offset); offset += 4;
            dt.GearboxOutputRPM = BitConverter.ToSingle(data, offset); offset += 4;
            dt.GearboxTorque = BitConverter.ToSingle(data, offset); offset += 4;
            dt.GearboxPower = BitConverter.ToSingle(data, offset); offset += 4;
            dt.GearboxLoadIn = BitConverter.ToSingle(data, offset); offset += 4;
            dt.GearboxLoadOut = BitConverter.ToSingle(data, offset); offset += 4;
            dt.TimeSinceShift = BitConverter.ToSingle(data, offset); offset += 4;
            dt.EstDrivenSpeed = BitConverter.ToSingle(data, offset); offset += 4;
            dt.OutputTorque = BitConverter.ToSingle(data, offset); offset += 4;
            dt.OutputPower = BitConverter.ToSingle(data, offset); offset += 4;
            dt.OutputEfficiency = BitConverter.ToSingle(data, offset); offset += 4;
            dt.StarterActive = data[offset++] != 0;
            dt.EngineRunning = data[offset++] != 0;
            dt.EngineFanRunning = data[offset++] != 0;
            dt.RevLimiterActive = data[offset++] != 0;
            dt.TractionControlActive = data[offset++] != 0;
            dt.SpeedLimiterEnabled = data[offset++] != 0;
            dt.SpeedLimiterActive = data[offset++] != 0;
            
            byte numGears = data[offset++];
            for (int i = 0; i < numGears; i++)
            {
                var gear = new GearData();
                gear.UpshiftRPM = BitConverter.ToSingle(data, offset); offset += 4;
                gear.DownshiftRPM = BitConverter.ToSingle(data, offset); offset += 4;
                dt.Gears.Add(gear);
            }
        }

        private static void ReadSuspension(byte[] data, ref int offset, SuspensionData susp)
        {
            byte numLoads = data[offset++];
            for (int i = 0; i < numLoads; i++)
            {
                susp.AvgLoads.Add(BitConverter.ToSingle(data, offset));
                offset += 4;
            }
            susp.LoadBias = BitConverter.ToSingle(data, offset); offset += 4;
        }

        private static void ReadInput(byte[] data, ref int offset, InputData input)
        {
            input.Steering = BitConverter.ToSingle(data, offset); offset += 4;
            input.Accelerator = BitConverter.ToSingle(data, offset); offset += 4;
            input.Brake = BitConverter.ToSingle(data, offset); offset += 4;
            input.Clutch = BitConverter.ToSingle(data, offset); offset += 4;
            input.Handbrake = BitConverter.ToSingle(data, offset); offset += 4;
            input.Gear = BitConverter.ToInt32(data, offset); offset += 4;
        }

        private static void ReadSetup(byte[] data, ref int offset, SetupData setup)
        {
            setup.BrakeBias = BitConverter.ToSingle(data, offset); offset += 4;
            setup.FrontAntiRollStiffness = BitConverter.ToSingle(data, offset); offset += 4;
            setup.RearAntiRollStiffness = BitConverter.ToSingle(data, offset); offset += 4;
            setup.RegenLimit = BitConverter.ToSingle(data, offset); offset += 4;
            setup.DeployLimit = BitConverter.ToSingle(data, offset); offset += 4;
            setup.ABSLevel = data[offset++];
            setup.TCSLevel = data[offset++];
        }

        private static void ReadGeneral(byte[] data, ref int offset, GeneralData gen)
        {
            for (int i = 0; i < 3; i++) { gen.CenterOfGravity[i] = BitConverter.ToSingle(data, offset); offset += 4; }
            gen.SteeringWheelAngle = BitConverter.ToSingle(data, offset); offset += 4;
            gen.TotalMass = BitConverter.ToSingle(data, offset); offset += 4;
            gen.DrivenWheelAngVel = BitConverter.ToSingle(data, offset); offset += 4;
            gen.NonDrivenWheelAngVel = BitConverter.ToSingle(data, offset); offset += 4;
            gen.EstRollingSpeed = BitConverter.ToSingle(data, offset); offset += 4;
            gen.EstLinearSpeed = BitConverter.ToSingle(data, offset); offset += 4;
            gen.TotalBrakeForce = BitConverter.ToSingle(data, offset); offset += 4;
            gen.ABSActive = data[offset++] != 0;
        }

        private static void ReadConstant(byte[] data, ref int offset, ConstantData constant)
        {
            for (int i = 0; i < 3; i++) { constant.ChassisBBMin[i] = BitConverter.ToSingle(data, offset); offset += 4; }
            for (int i = 0; i < 3; i++) { constant.ChassisBBMax[i] = BitConverter.ToSingle(data, offset); offset += 4; }
            constant.StarterIdleRPM = BitConverter.ToSingle(data, offset); offset += 4;
            constant.EngineTorquePeakRPM = BitConverter.ToSingle(data, offset); offset += 4;
            constant.EnginePowerPeakRPM = BitConverter.ToSingle(data, offset); offset += 4;
            constant.EngineMaxRPM = BitConverter.ToSingle(data, offset); offset += 4;
            constant.EngineMaxTorque = BitConverter.ToSingle(data, offset); offset += 4;
            constant.EngineMaxPower = BitConverter.ToSingle(data, offset); offset += 4;
            constant.EngineMaxBoost = BitConverter.ToSingle(data, offset); offset += 4;
            constant.FuelCapacity = BitConverter.ToSingle(data, offset); offset += 4;
            constant.BatteryCapacity = BitConverter.ToSingle(data, offset); offset += 4;
            constant.TrackWidthFront = BitConverter.ToSingle(data, offset); offset += 4;
            constant.TrackWidthRear = BitConverter.ToSingle(data, offset); offset += 4;
            constant.Wheelbase = BitConverter.ToSingle(data, offset); offset += 4;
            constant.NumberOfWheels = data[offset++];
            constant.NumberOfForwardGears = data[offset++];
            constant.NumberOfReverseGears = data[offset++];
            constant.IsHybrid = data[offset++] != 0;
        }
    }
}
