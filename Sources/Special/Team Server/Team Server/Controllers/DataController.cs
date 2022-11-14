using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Security.Cryptography.Xml;
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
                    case "document":
                        return String.Join(";", dataManager.QueryDocuments(where));
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
                    case "document":
                        return dataManager.CountDocuments(where).ToString();
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

        [HttpGet("document/{identifier}")]
        public string GetDocument([FromQuery(Name = "token")] string token, string table, string identifier)
        {
            return GetTable(token, "document", identifier);
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
                    case "document":
                        return ControllerUtils.SerializeObject(dataManager.LookupDocument(identifier),
                                                               new List<string>(new string[] { "Identifier", "Modified", "Type",
                                                                                               "Driver", "Simulator", "Car", "Track" }));
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

        [HttpPut("document/{identifier}")]
        public string PutDocument([FromQuery(Name = "token")] string token, string table, string identifier,
                                  [FromBody] string keyValues)
        {
            return PutTable(token, "document", identifier, keyValues);
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
                    case "document":
                        dataManager.UpdateDocument(dataManager.LookupDocument(identifier), properties);
                        return "Ok";
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

        [HttpPost("document")]
        public string PostDocument([FromQuery(Name = "token")] string token, string table,
                                   [FromBody] string keyValues)
        {
            return PostTable(token, "document", keyValues);
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
                    case "document":
                        return dataManager.CreateDocument(properties).Identifier.ToString();
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

        [HttpDelete("document/{identifier}")]
        public string DeleteDocument([FromQuery(Name = "token")] string token, string identifier)
        {
            return DeleteTable(token, "license", identifier);
        }

        [HttpDelete("license/{identifier}")]
        public string DeleteLicense([FromQuery(Name = "token")] string token, string identifier)
        {
            return DeleteTable(token, "license", identifier);
        }

        [HttpDelete("electronics/{identifier}")]
        public string DeleteElectronics([FromQuery(Name = "token")] string token, string identifier)
        {
            return DeleteTable(token, "electronics", identifier);
        }

        [HttpDelete("tyres/{identifier}")]
        public string DeleteTyres([FromQuery(Name = "token")] string token, string identifier)
        {
            return DeleteTable(token, "tyres", identifier);
        }

        [HttpDelete("brakes/{identifier}")]
        public string DeleteBrakes([FromQuery(Name = "token")] string token, string identifier)
        {
            return DeleteTable(token, "brakes", identifier);
        }

        [HttpDelete("tyrespressures/{identifier}")]
        public string DeleteTyresPressures([FromQuery(Name = "token")] string token, string identifier)
        {
            return DeleteTable(token, "tyrespressures", identifier);
        }

        [HttpDelete("tyrespressuresdistribution/{identifier}")]
        public string DeleteTyresPressuresDistribution([FromQuery(Name = "token")] string token, string identifier)
        {
            return DeleteTable(token, "tyrespressuresdistribution", identifier);
        }

        [HttpDelete("{table}/{identifier}")]
        public string DeleteTable(string token, string table, string identifier)
        {
            DataManager dataManager = new DataManager(Server.TeamServer.ObjectManager, token);

            try
            {
                switch (table.ToLower())
                {
                    case "license":
                        dataManager.DeleteLicense(dataManager.LookupLicense(identifier));
                        break;
                    case "electronics":
                        dataManager.DeleteElectronics(dataManager.LookupElectronics(identifier));
                        break;
                    case "tyres":
                        dataManager.DeleteTyres(dataManager.LookupTyres(identifier));
                        break;
                    case "brakes":
                        dataManager.DeleteBrakes(dataManager.LookupBrakes(identifier));
                        break;
                    case "tyrespressures":
                        dataManager.DeleteTyresPressures(dataManager.LookupTyresPressures(identifier));
                        break;
                    case "tyrespressuresdistribution":
                        dataManager.DeleteTyresPressuresDistribution(dataManager.LookupTyresPressuresDistribution(identifier));
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

        [HttpGet("document/{identifier}/value")]
        public string GetDocumentValue([FromQuery(Name = "token")] string token, string identifier, [FromQuery(Name = "name")] string name)
        {
            return GetTableValue(token, "document", identifier, name);
        }

        [HttpGet("electronics/{identifier}/value")]
        public string GetElectronicsValue([FromQuery(Name = "token")] string token, string identifier, [FromQuery(Name = "name")] string name)
        {
            return GetTableValue(token, "electronics", identifier, name);
        }

        [HttpGet("tyres/{identifier}/value")]
        public string GetTyresValue([FromQuery(Name = "token")] string token, string identifier, [FromQuery(Name = "name")] string name)
        {
            return GetTableValue(token, "tyres", identifier, name);
        }

        [HttpGet("brakes/{identifier}/value")]
        public string GetBrakesValue([FromQuery(Name = "token")] string token, string identifier, [FromQuery(Name = "name")] string name)
        {
            return GetTableValue(token, "brakes", identifier, name);
        }

        [HttpGet("tyrespressures/{identifier}/value")]
        public string GetTyresPressuresValue([FromQuery(Name = "token")] string token, string identifier, [FromQuery(Name = "name")] string name)
        {
            return GetTableValue(token, "tyrespressures", identifier, name);
        }

        [HttpGet("tyrespressuresdistribution/{identifier}/value")]
        public string GetTyresPressuresDistributionValue([FromQuery(Name = "token")] string token, string identifier,
                                                         [FromQuery(Name = "name")] string name)
        {
            return GetTableValue(token, "tyrespressuresdistribution", identifier, name);
        }

        public string GetTableValue(string token, string table, string identifier, string name)
        {
            DataManager dataManager = new DataManager(Server.TeamServer.ObjectManager, token);

            try
            {
                Model.Data.CarObject dataObject;

                switch (table.ToLower())
                {
                    case "document":
                        dataObject = dataManager.LookupDocument(identifier);
                        break;
                        break;
                    case "electronics":
                        dataObject = dataManager.LookupElectronics(identifier);
                        break;
                    case "tyres":
                        dataObject = dataManager.LookupTyres(identifier);
                        break;
                    case "brakes":
                        dataObject = dataManager.LookupBrakes(identifier);
                        break;
                    case "tyrespressures":
                        dataObject = dataManager.LookupTyresPressures(identifier);
                        break;
                    case "tyrespressuresdistribution":
                        dataObject = dataManager.LookupTyresPressuresDistribution(identifier);
                        break;
                    default:
                        throw new Exception("Unknown table detected...");
                }

                return dataManager.GetDataValue(dataObject, name);
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

        [HttpPut("document/{identifier}/value")]
        public string PutDocumentValue([FromQuery(Name = "token")] string token, string identifier,
                                       [FromQuery(Name = "name")] string name, [FromBody] string value)
        {
            return PutTableValue(token, "document", identifier, name, value);
        }

        [HttpPut("electronics/{identifier}/value")]
        public string PutElectronicsValue([FromQuery(Name = "token")] string token, string identifier,
                                          [FromQuery(Name = "name")] string name, [FromBody] string value)
        {
            return PutTableValue(token, "electronics", identifier, name, value);
        }

        [HttpPut("tyres/{identifier}/value")]
        public string PutTyresValue([FromQuery(Name = "token")] string token, string identifier,
                                    [FromQuery(Name = "name")] string name, [FromBody] string value)
        {
            return PutTableValue(token, "tyres", identifier, name, value);
        }

        [HttpPut("brakes/{identifier}/value")]
        public string PutBrakesValue([FromQuery(Name = "token")] string token, string identifier,
                                     [FromQuery(Name = "name")] string name, [FromBody] string value)
        {
            return PutTableValue(token, "brakes", identifier, name, value);
        }

        [HttpPut("tyrespressures/{identifier}/value")]
        public string PutTyresPressuresValue([FromQuery(Name = "token")] string token, string identifier,
                                             [FromQuery(Name = "name")] string name, [FromBody] string value)
        {
            return PutTableValue(token, "tyrespressures", identifier, name, value);
        }

        [HttpPut("tyrespressuresdistribution/{identifier}/value")]
        public string PutTyresPressuresDistributionValue([FromQuery(Name = "token")] string token, string identifier,
                                                         [FromQuery(Name = "name")] string name, [FromBody] string value)
        {
            return PutTableValue(token, "tyrespressuresdistribution", identifier, name, value);
        }

        public string PutTableValue(string token, string table, string identifier, string name, string value)
        {
            DataManager dataManager = new DataManager(Server.TeamServer.ObjectManager, token);

            try
            {
                Model.Data.CarObject dataObject;

                switch (table.ToLower())
                {
                    case "document":
                        dataObject = dataManager.LookupDocument(identifier);
                        break;
                        break;
                    case "electronics":
                        dataObject = dataManager.LookupElectronics(identifier);
                        break;
                    case "tyres":
                        dataObject = dataManager.LookupTyres(identifier);
                        break;
                    case "brakes":
                        dataObject = dataManager.LookupBrakes(identifier);
                        break;
                    case "tyrespressures":
                        dataObject = dataManager.LookupTyresPressures(identifier);
                        break;
                    case "tyrespressuresdistribution":
                        dataObject = dataManager.LookupTyresPressuresDistribution(identifier);
                        break;
                    default:
                        throw new Exception("Unknown table detected...");
                }

                dataManager.SetDataValue(dataObject, name, value);

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

        [HttpDelete("document/{identifier}/value")]
        public string DeleteDocumentValue([FromQuery(Name = "token")] string token, string identifier,
                                          [FromQuery(Name = "name")] string name)
        {
            return DeleteTableValue(token, "document", identifier, name);
        }

        [HttpDelete("electronics/{identifier}/value")]
        public string DeleteElectronicsValue([FromQuery(Name = "token")] string token, string identifier,
                                             [FromQuery(Name = "name")] string name)
        {
            return DeleteTableValue(token, "electronics", identifier, name);
        }

        [HttpDelete("tyres/{identifier}/value")]
        public string DeleteTyresValue([FromQuery(Name = "token")] string token, string identifier,
                                       [FromQuery(Name = "name")] string name)
        {
            return DeleteTableValue(token, "tyres", identifier, name);
        }

        [HttpDelete("brakes/{identifier}/value")]
        public string DeleteBrakesValue([FromQuery(Name = "token")] string token, string identifier,
                                        [FromQuery(Name = "name")] string name)
        {
            return DeleteTableValue(token, "brakes", identifier, name);
        }

        [HttpDelete("tyrespressures/{identifier}/value")]
        public string DeleteTyresPressuresValue([FromQuery(Name = "token")] string token, string identifier,
                                             [FromQuery(Name = "name")] string name, [FromBody] string value)
        {
            return DeleteTableValue(token, "tyrespressures", identifier, name);
        }

        [HttpDelete("tyrespressuresdistribution/{identifier}/value")]
        public string DeleteTyresPressuresDistributionValue([FromQuery(Name = "token")] string token, string identifier,
                                                            [FromQuery(Name = "name")] string name)
        {
            return DeleteTableValue(token, "tyrespressuresdistribution", identifier, name);
        }

        public string DeleteTableValue(string token, string table, string identifier, string name)
        {
            DataManager dataManager = new DataManager(Server.TeamServer.ObjectManager, token);

            try
            {
                Model.Data.CarObject dataObject;

                switch (table.ToLower())
                {
                    case "document":
                        dataObject = dataManager.LookupDocument(identifier);
                        break;
                        break;
                    case "electronics":
                        dataObject = dataManager.LookupElectronics(identifier);
                        break;
                    case "tyres":
                        dataObject = dataManager.LookupTyres(identifier);
                        break;
                    case "brakes":
                        dataObject = dataManager.LookupBrakes(identifier);
                        break;
                    case "tyrespressures":
                        dataObject = dataManager.LookupTyresPressures(identifier);
                        break;
                    case "tyrespressuresdistribution":
                        dataObject = dataManager.LookupTyresPressuresDistribution(identifier);
                        break;
                    default:
                        throw new Exception("Unknown table detected...");
                }

                dataManager.DeleteDataValue(dataObject, name);

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