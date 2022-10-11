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


        [HttpGet("validatetoken")]
        public string ValidateToken([FromQuery(Name = "token")] string token)
        {
            try
            {
                new DataManager(Server.TeamServer.ObjectManager, token);

                return "Ok";
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


        [HttpGet("timestamp")]
        public string Timestamp([FromQuery(Name = "token")] string token)
        {
            try
            {
                new DataManager(Server.TeamServer.ObjectManager, token);

                return DateTime.Now.ToFileTimeUtc().ToString();
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

        [HttpPut("query/{table}")]
        public string QueryData([FromQuery(Name = "token")] string token, [FromBody] string where, string table)
        {
            try
            {
                DataManager dataManager = new DataManager(Server.TeamServer.ObjectManager, token);

                switch (table.ToLower())
                {
                    case "license":
                        return String.Join(";", dataManager.QueryLicenses(where));
                    case "electronics":
                        return String.Join(";", dataManager.QueryElectronics(where));
                    case "tyres":
                        return String.Join(";", dataManager.QueryTyres(where));
                    case "brakes":
                        return String.Join(";", dataManager.QueryBrakes(where));
                    case "tyrespressures":
                        return String.Join(";", dataManager.QueryTyresPressures(where));
                    case "tyrespressuresdistribution":
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

        [HttpPut("count/{table}")]
        public string CountData([FromQuery(Name = "token")] string token, [FromBody] string where, string table)
        {
            try
            {
                DataManager dataManager = new DataManager(Server.TeamServer.ObjectManager, token);

                switch (table.ToLower())
                {
                    case "license":
                        return dataManager.CountLicenses(where).ToString();
                    case "electronics":
                        return dataManager.CountElectronics(where).ToString();
                    case "tyres":
                        return dataManager.CountTyres(where).ToString();
                    case "brakes":
                        return dataManager.CountBrakes(where).ToString();
                    case "tyrespressures":
                        return dataManager.CountTyresPressures(where).ToString();
                    case "tyrespressuresdistribution":
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

        [HttpGet("license/{identifier}")]
        public string GetLicense([FromQuery(Name = "token")] string token, string table, string identifier)
        {
            return GetTable(token, "license", identifier);
        }

        [HttpGet("electronics/{identifier}")]
        public string GetElectronics([FromQuery(Name = "token")] string token, string table, string identifier)
        {
            return GetTable(token, "electronics", identifier);
        }

        [HttpGet("tyres/{identifier}")]
        public string GetTyres([FromQuery(Name = "token")] string token, string table, string identifier)
        {
            return GetTable(token, "tyres", identifier);
        }

        [HttpGet("brakes/{identifier}")]
        public string GetBrakes([FromQuery(Name = "token")] string token, string table, string identifier)
        {
            return GetTable(token, "brakes", identifier);
        }

        [HttpGet("tyrespressures/{identifier}")]
        public string GetTyresPressures([FromQuery(Name = "token")] string token, string table, string identifier)
        {
            return GetTable(token, "tyrespressures", identifier);
        }

        [HttpGet("tyrespressuresdistribution/{identifier}")]
        public string GetTyresPressuresDistribution([FromQuery(Name = "token")] string token, string table, string identifier)
        {
            return GetTable(token, "tyrespressuresdistribution", identifier);
        }

        public string GetTable(string token, string table, string identifier)
            {
                try
                {
                DataManager dataManager = new DataManager(Server.TeamServer.ObjectManager, token);

                switch (table.ToLower())
                {
                    case "license":
                        return ControllerUtils.SerializeObject(dataManager.LookupLicense(identifier),
                                                               new List<string>(new string[] { "Identifier", "Modified",
                                                                                               "Simulator", "Driver",
                                                                                               "Forname", "Surname", "Nickname" }));
                    case "electronics":
                        return ControllerUtils.SerializeObject(dataManager.LookupElectronics(identifier),
                                                               new List<string>(new string[] { "Identifier", "Modified",
                                                                                               "Driver", "Simulator", "Car", "Track",
                                                                                               "Weather", "AirTemperature",
                                                                                               "TrackTemperature",
                                                                                               "TyreCompound", "TyreCompoundColor",
                                                                                               "FuelRemaining", "FuelConsumption",
                                                                                               "LapTime",
                                                                                               "Map", "TC", "ABS" }));
                    case "tyres":
                        return ControllerUtils.SerializeObject(dataManager.LookupTyres(identifier),
                                                               new List<string>(new string[] { "Identifier", "Modified",
                                                                                               "Driver", "Simulator", "Car", "Track",
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
                    case "brakes":
                        return ControllerUtils.SerializeObject(dataManager.LookupBrakes(identifier),
                                                               new List<string>(new string[] { "Identifier", "Modified",
                                                                                               "Driver", "Simulator", "Car", "Track",
                                                                                               "Weather", "AirTemperature",
                                                                                               "TrackTemperature",
                                                                                               "TyreCompound", "TyreCompoundColor",
                                                                                               "FuelRemaining", "FuelConsumption",
                                                                                               "LapTime", "Laps",
                                                                                               "RotorWearFrontLeft", "RotorWearFrontRight",
                                                                                               "RotorWearRearLeft", "RotorWearRearRight",
                                                                                               "PadWearFrontLeft", "PadWearFrontRight",
                                                                                               "PadWearRearLeft", "PadWearRearRight" }));
                    case "tyrespressures":
                        return ControllerUtils.SerializeObject(dataManager.LookupTyresPressures(identifier),
                                                               new List<string>(new string[] { "Identifier", "Modified",
                                                                                               "Driver", "Simulator", "Car", "Track",
                                                                                               "Weather", "AirTemperature",
                                                                                               "TrackTemperature",
                                                                                               "TyreCompound", "TyreCompoundColor",
                                                                                               "HotPressureFrontLeft", "HotPressureFrontRight",
                                                                                               "HotPressureRearLeft", "HotPressureRearRight",
                                                                                               "ColdPressureFrontLeft", "ColdPressureFrontRight",
                                                                                               "ColdPressureRearLeft", "ColdPressureRearRight" }));
                    case "tyrespressuresdistribution":
                        return ControllerUtils.SerializeObject(dataManager.LookupTyresPressuresDistribution(identifier),
                                                               new List<string>(new string[] { "Identifier", "Modified",
                                                                                               "Driver", "Simulator", "Car", "Track",
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

        [HttpPut("license/{identifier}")]
        public string PutLicense([FromQuery(Name = "token")] string token, string table, string identifier,
                                 [FromBody] string keyValues)
        {
            return PutTable(token, "license", identifier, keyValues);
        }

        [HttpPut("electronics/{identifier}")]
        public string PutElectronics([FromQuery(Name = "token")] string token, string table, string identifier,
                                     [FromBody] string keyValues)
        {
            return PutTable(token, "electronics", identifier, keyValues);
        }

        [HttpPut("tyres/{identifier}")]
        public string PutTyres([FromQuery(Name = "token")] string token, string table, string identifier,
                               [FromBody] string keyValues)
        {
            return PutTable(token, "tyres", identifier, keyValues);
        }

        [HttpPut("brakes/{identifier}")]
        public string PutBrakes([FromQuery(Name = "token")] string token, string table, string identifier,
                                [FromBody] string keyValues)
        {
            return PutTable(token, "brakes", identifier, keyValues);
        }

        [HttpPut("tyrespressures/{identifier}")]
        public string PutTyresPressures([FromQuery(Name = "token")] string token, string table, string identifier,
                                        [FromBody] string keyValues)
        {
            return PutTable(token, "tyrespressures", identifier, keyValues);
        }

        [HttpPut("tyrespressuresdistribution/{identifier}")]
        public string PutTyresPressuresDistribution([FromQuery(Name = "token")] string token, string table, string identifier,
                                                    [FromBody] string keyValues)
        {
            return PutTable(token, "tyrespressuresdistribution", identifier, keyValues);
        }

        public string PutTable(string token, string table, string identifier,string keyValues)
        {
            try
            {
                DataManager dataManager = new DataManager(Server.TeamServer.ObjectManager, token);
                Dictionary<string, string> properties = ControllerUtils.ParseKeyValues(keyValues);

                switch (table.ToLower())
                {
                    case "license":
                        dataManager.UpdateLicense(dataManager.LookupLicense(identifier), properties);
                        return "Ok";
                    case "electronics":
                        dataManager.UpdateElectronics(dataManager.LookupElectronics(identifier), properties);
                        return "Ok";
                    case "tyres":
                        dataManager.UpdateTyres(dataManager.LookupTyres(identifier), properties);
                        return "Ok";
                    case "brakes":
                        dataManager.UpdateBrakes(dataManager.LookupBrakes(identifier), properties);
                        return "Ok";
                    case "tyrespressures":
                        dataManager.UpdateTyresPressures(dataManager.LookupTyresPressures(identifier), properties);
                        return "Ok";
                    case "tyrespressuresdistribution":
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

        [HttpPost("license")]
        public string PostLicense([FromQuery(Name = "token")] string token, string table,
                                 [FromBody] string keyValues)
        {
            return PostTable(token, "license", keyValues);
        }

        [HttpPost("electronics")]
        public string PostElectronics([FromQuery(Name = "token")] string token, string table,
                                     [FromBody] string keyValues)
        {
            return PostTable(token, "electronics", keyValues);
        }

        [HttpPost("tyres")]
        public string PostTyres([FromQuery(Name = "token")] string token, string table,
                               [FromBody] string keyValues)
        {
            return PostTable(token, "tyres", keyValues);
        }

        [HttpPost("brakes")]
        public string PostBrakes([FromQuery(Name = "token")] string token, string table,
                                [FromBody] string keyValues)
        {
            return PostTable(token, "brakes", keyValues);
        }

        [HttpPost("tyrespressures")]
        public string PostTyresPressures([FromQuery(Name = "token")] string token, string table,
                                        [FromBody] string keyValues)
        {
            return PostTable(token, "tyrespressures", keyValues);
        }

        [HttpPost("tyrespressuresdistribution")]
        public string PostTyresPressuresDistribution([FromQuery(Name = "token")] string token, string table,
                                                    [FromBody] string keyValues)
        {
            return PostTable(token, "tyrespressuresdistribution", keyValues);
        }

        public string PostTable(string token, string table, string keyValues)
        {
            DataManager dataManager = new DataManager(Server.TeamServer.ObjectManager, token);
            Dictionary<string, string> properties = ControllerUtils.ParseKeyValues(keyValues);

            try
            {
                switch (table.ToLower())
                {
                    case "license":
                        return dataManager.CreateLicense(properties).Identifier.ToString();
                    case "electronics":
                        return dataManager.CreateElectronics(properties).Identifier.ToString();
                    case "tyres":
                        return dataManager.CreateTyres(properties).Identifier.ToString();
                    case "brakes":
                        return dataManager.CreateBrakes(properties).Identifier.ToString();
                    case "tyrespressures":
                        return dataManager.CreateTyresPressures(properties).Identifier.ToString();
                    case "tyrespressuresdistribution":
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

        [HttpDelete("license/{identifier}")]
        public string DeleteLicense([FromQuery(Name = "token")] string token, string table, string identifier)
        {
            return DeleteTable(token, "license", identifier);
        }

        [HttpDelete("electronics/{identifier}")]
        public string DeleteElectronics([FromQuery(Name = "token")] string token, string table, string identifier)
        {
            return DeleteTable(token, "electronics", identifier);
        }

        [HttpDelete("tyres/{identifier}")]
        public string DeleteTyres([FromQuery(Name = "token")] string token, string table, string identifier)
        {
            return DeleteTable(token, "tyres", identifier);
        }

        [HttpDelete("brakes/{identifier}")]
        public string DeleteBrakes([FromQuery(Name = "token")] string token, string table, string identifier)
        {
            return DeleteTable(token, "brakes", identifier);
        }

        [HttpDelete("tyrespressures/{identifier}")]
        public string DeleteTyresPressures([FromQuery(Name = "token")] string token, string table, string identifier)
        {
            return DeleteTable(token, "tyrespressures", identifier);
        }

        [HttpDelete("tyrespressuresdistribution/{identifier}")]
        public string DeleteTyresPressuresDistribution([FromQuery(Name = "token")] string token, string table, string identifier)
        {
            return DeleteTable(token, "tyrespressuresdistribution", identifier);
        }

        [HttpDelete("{table}/{identifier}")]
        public string DeleteTable(string token, string table, string identifier)
        {
            DataManager dataManager = new DataManager(Server.TeamServer.ObjectManager, token);

            try
            {
                foreach(string theIdentifier in identifier.Split(";"))
                    switch (table.ToLower())
                    {
                        case "license":
                            dataManager.DeleteLicense(dataManager.LookupLicense(theIdentifier));
                            break;
                        case "electronics":
                            dataManager.DeleteElectronics(dataManager.LookupElectronics(theIdentifier));
                            break;
                        case "tyres":
                            dataManager.DeleteTyres(dataManager.LookupTyres(theIdentifier));
                            break;
                        case "brakes":
                            dataManager.DeleteBrakes(dataManager.LookupBrakes(theIdentifier));
                            break;
                        case "tyrespressures":
                            dataManager.DeleteTyresPressures(dataManager.LookupTyresPressures(theIdentifier));
                            break;
                        case "tyrespressuresdistribution":
                            dataManager.DeleteTyresPressuresDistribution(dataManager.LookupTyresPressuresDistribution(theIdentifier));
                            break;
                        default:
                            throw new Exception("Unknown table detected...");
                    }

                return "Ok";
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