using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging;
using System;
using System.Collections.Generic;
using System.Linq;
using TeamServer.Model;
using TeamServer.Model.Access;
using TeamServer.Server;

namespace TeamServer.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class DataController : ControllerBase
    {
        private readonly ILogger<DataController> _logger;

        public DataController(ILogger<DataController> logger)
        {
            _logger = logger;
        }

        [HttpGet("query/{table:string}")]
        public string QueryData([FromQuery(Name = "token")] string token, [FromBody] string where, string table)
        {
            try
            {
                DataManager dataManager = new DataManager(Server.TeamServer.ObjectManager,
                                                          (DataToken)Server.TeamServer.TokenIssuer.ValidateToken(token));

                switch (table)
                {
                    case "License":
                        return String.Join(";", dataManager.QueryLicenses(where));
                    case "Electronics":
                        return String.Join(";", dataManager.QueryElectronics(where));
                    case "Tyres":
                        return String.Join(";", dataManager.QueryTyres(where));
                    case "Brakes":
                        return String.Join(";", dataManager.QueryBrakes(where));
                    case "TyresPressures":
                        return String.Join(";", dataManager.QueryTyresPressures(where));
                    case "TyresPressuresDistribution":
                        return String.Join(";", dataManager.QueryTyresPressuresDistribution(where));
                    default:
                        throw new Exception("Unknown table detected...");
                }
            }
            catch (AggregateException exception)
            {
                return "Error: " + exception.InnerException.Message;
            }
            catch (Exception exception)
            {
                return "Error: " + exception.Message;
            }
        }

        [HttpGet("count/{table:string}")]
        public string CountData([FromQuery(Name = "token")] string token, [FromBody] string where, string table)
        {
            try
            {
                DataManager dataManager = new DataManager(Server.TeamServer.ObjectManager,
                                                          (DataToken)Server.TeamServer.TokenIssuer.ValidateToken(token));

                switch (table)
                {
                    case "License":
                        return dataManager.CountLicenses(where).ToString();
                    case "Electronics":
                        return dataManager.CountElectronics(where).ToString();
                    case "Tyres":
                        return dataManager.CountTyres(where).ToString();
                    case "Brakes":
                        return dataManager.CountBrakes(where).ToString();
                    case "TyresPressures":
                        return dataManager.CountTyresPressures(where).ToString();
                    case "TyresPressuresDistribution":
                        return dataManager.CountTyresPressuresDistribution(where).ToString();
                    default:
                        throw new Exception("Unknown table detected...");
                }
            }
            catch (AggregateException exception)
            {
                return "Error: " + exception.InnerException.Message;
            }
            catch (Exception exception)
            {
                return "Error: " + exception.Message;
            }
        }

        [HttpGet("{table:string}/{identifier:string}")]
        public string Get([FromQuery(Name = "token")] string token, string table, string identifier)
        {
            try
            {
                DataManager dataManager = new DataManager(Server.TeamServer.ObjectManager,
                                                          (DataToken)Server.TeamServer.TokenIssuer.ValidateToken(token));

                switch (table)
                {
                    case "License":
                        return ControllerUtils.SerializeObject(dataManager.LookupLicense(identifier),
                                                               new List<string>(new string[] { "Identifier", "Driver",
                                                                                               "Forname", "Surname",
                                                                                               "Nickname" }));
                    case "Electronics":
                        return ControllerUtils.SerializeObject(dataManager.LookupElectronics(identifier),
                                                               new List<string>(new string[] { "Identifier", "Driver",
                                                                                               "Simulator", "Car", "Track",
                                                                                               "Weather", "AirTemperature",
                                                                                               "TrackTemperature",
                                                                                               "TyreCompound", "TyreCompoundColor",
                                                                                               "FuelRemaining", "FuelConsumption",
                                                                                               "LapTime",
                                                                                               "Map", "TC", "ABS" }));
                    case "Tyres":
                        return ControllerUtils.SerializeObject(dataManager.LookupTyres(identifier),
                                                               new List<string>(new string[] { "Identifier", "Driver",
                                                                                               "Simulator", "Car", "Track",
                                                                                               "Weather", "AirTemperature",
                                                                                               "TrackTemperature",
                                                                                               "TyreCompound", "TyreCompoundColor",
                                                                                               "FuelRemaining", "FuelConsumption",
                                                                                               "LapTime", "Laps",
                                                                                               "PressureFrontLeft", "PressureFrontRight",
                                                                                               "PressureRearLeft", "PressureRearRight",
                                                                                               "TemperatureFrontLeft", "TemperatureFrontRight",
                                                                                               "TemperatureRearLeft", "TemperatureRearRight",
                                                                                               "WearFrontLeft", "WearFrontRight",
                                                                                               "WearRearLeft", "WearRearRight" }));
                    case "Brakes":
                        return ControllerUtils.SerializeObject(dataManager.LookupBrakes(identifier),
                                                               new List<string>(new string[] { "Identifier", "Driver",
                                                                                               "Simulator", "Car", "Track",
                                                                                               "Weather", "AirTemperature",
                                                                                               "TrackTemperature",
                                                                                               "TyreCompound", "TyreCompoundColor",
                                                                                               "FuelRemaining", "FuelConsumption",
                                                                                               "LapTime", "Laps",
                                                                                               "RotorWearFrontLeft", "RotorWearFrontRight",
                                                                                               "RotorWearRearLeft", "RotorWearRearRight",
                                                                                               "PadWearFrontLeft", "PadWearFrontRight",
                                                                                               "PadWearRearLeft", "PadWearRearRight" }));
                    case "TyresPressures":
                        return ControllerUtils.SerializeObject(dataManager.LookupTyresPressures(identifier),
                                                               new List<string>(new string[] { "Identifier", "Driver",
                                                                                               "Simulator", "Car", "Track",
                                                                                               "Weather", "AirTemperature",
                                                                                               "TrackTemperature",
                                                                                               "TyreCompound", "TyreCompoundColor",
                                                                                               "HotPressureFrontLeft", "HotPressureFrontRight",
                                                                                               "HotPressureRearLeft", "HotPressureRearRight",
                                                                                               "ColdPressureFrontLeft", "ColdPressureFrontRight",
                                                                                               "ColdPressureRearLeft", "ColdPressureRearRight" }));
                    case "TyresPressuresDistribution":
                        return ControllerUtils.SerializeObject(dataManager.LookupTyresPressuresDistribution(identifier),
                                                               new List<string>(new string[] { "Identifier", "Driver",
                                                                                               "Simulator", "Car", "Track",
                                                                                               "Weather", "AirTemperature",
                                                                                               "TrackTemperature",
                                                                                               "TyreCompound", "TyreCompoundColor",
                                                                                               "Type", "Tyre", "Pressure", "Count" }));
                    default:
                        throw new Exception("Unknown table detected...");
                }
            }
            catch (AggregateException exception)
            {
                return "Error: " + exception.InnerException.Message;
            }
            catch (Exception exception)
            {
                return "Error: " + exception.Message;
            }
        }

        [HttpPut("{table:string}/{identifier:string}")]
        public string Put([FromQuery(Name = "token")] string token, string table, string identifier,
                          [FromBody] string keyValues)
        {
            try
            {
                DataManager dataManager = new DataManager(Server.TeamServer.ObjectManager,
                                                          (DataToken)Server.TeamServer.TokenIssuer.ValidateToken(token));
                Dictionary<string, string> properties = ControllerUtils.ParseKeyValues(keyValues);

                switch (table)
                {
                    case "License":
                        dataManager.UpdateLicense(dataManager.LookupLicense(identifier), properties);
                        return "Ok";
                    case "Electronics":
                        dataManager.UpdateElectronics(dataManager.LookupElectronics(identifier), properties);
                        return "Ok";
                    case "Tyres":
                        dataManager.UpdateTyres(dataManager.LookupTyres(identifier), properties);
                        return "Ok";
                    case "Brakes":
                        dataManager.UpdateBrakes(dataManager.LookupBrakes(identifier), properties);
                        return "Ok";
                    case "TyresPressures":
                        dataManager.UpdateTyresPressures(dataManager.LookupTyresPressures(identifier), properties);
                        return "Ok";
                    case "TyresPressuresDistribution":
                        dataManager.UpdateTyresPressuresDistribution(dataManager.LookupTyresPressuresDistribution(identifier),
                                                                     properties);
                        return "Ok";
                    default:
                        throw new Exception("Unknown table detected...");
                }
            }
            catch (AggregateException exception)
            {
                return "Error: " + exception.InnerException.Message;
            }
            catch (Exception exception)
            {
                return "Error: " + exception.Message;
            }
        }

        [HttpPost("{table:string}")]
        public string Post([FromQuery(Name = "token")] string token, string table, [FromBody] string keyValues)
        {
            DataManager dataManager = new DataManager(Server.TeamServer.ObjectManager,
                                                      (DataToken)Server.TeamServer.TokenIssuer.ValidateToken(token));
            Dictionary<string, string> properties = ControllerUtils.ParseKeyValues(keyValues);

            try
            {
                switch (table)
                {
                    case "License":
                        return dataManager.CreateLicense(properties).Identifier.ToString();
                    case "Electronics":
                        return dataManager.CreateElectronics(properties).Identifier.ToString();
                    case "Tyres":
                        return dataManager.CreateTyres(properties).Identifier.ToString();
                    case "Brakes":
                        return dataManager.CreateBrakes(properties).Identifier.ToString();
                    case "TyresPressures":
                        return dataManager.CreateTyresPressures(properties).Identifier.ToString();
                    case "TyresPressuresDistribution":
                        return dataManager.CreateTyresPressuresDistribution(properties).Identifier.ToString();
                    default:
                        throw new Exception("Unknown table detected...");
                }
            }
            catch (AggregateException exception)
            {
                return "Error: " + exception.InnerException.Message;
            }
            catch (Exception exception)
            {
                return "Error: " + exception.Message;
            }
        }

        [HttpDelete("{table:string}/{identifier:string}")]
        public string Delete([FromQuery(Name = "token")] string token, string table, string identifier)
        {
            DataManager dataManager = new DataManager(Server.TeamServer.ObjectManager,
                                                      (DataToken)Server.TeamServer.TokenIssuer.ValidateToken(token));

            try
            {
                switch (table)
                {
                    case "License":
                        dataManager.DeleteLicense(dataManager.LookupLicense(identifier));
                        return "Ok";
                    case "Electronics":
                        dataManager.DeleteElectronics(dataManager.LookupElectronics(identifier));
                        return "Ok";
                    case "Tyres":
                        dataManager.DeleteTyres(dataManager.LookupTyres(identifier));
                        return "Ok";
                    case "Brakes":
                        dataManager.DeleteBrakes(dataManager.LookupBrakes(identifier));
                        return "Ok";
                    case "TyresPressures":
                        dataManager.DeleteTyresPressures(dataManager.LookupTyresPressures(identifier));
                        return "Ok";
                    case "TyresPressuresDistribution":
                        dataManager.DeleteTyresPressuresDistribution(dataManager.LookupTyresPressuresDistribution(identifier));
                        return "Ok";
                    default:
                        throw new Exception("Unknown table detected...");
                }
            }
            catch (AggregateException exception)
            {
                return "Error: " + exception.InnerException.Message;
            }
            catch (Exception exception)
            {
                return "Error: " + exception.Message;
            }
        }
    }
}