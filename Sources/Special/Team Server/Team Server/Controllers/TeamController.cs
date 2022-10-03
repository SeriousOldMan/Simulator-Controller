using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging;
using System;
using System.Collections.Generic;
using System.Linq;
using TeamServer.Model;
using TeamServer.Model.Access;
using TeamServer.Server;

namespace TeamServer.Controllers {
    [ApiController]
    [Route("api/[controller]")]
    public class TeamController : ControllerBase {
        private readonly ILogger<TeamController> _logger;

        public TeamController(ILogger<TeamController> logger) {
            _logger = logger;
        }

        [HttpGet("allteams")]
        public string GetTeams([FromQuery(Name = "token")] string token) {
            try {
                TeamManager teamManager = new TeamManager(Server.TeamServer.ObjectManager,
                                                          (SessionToken)Server.TeamServer.TokenIssuer.ValidateToken(token));
                
                return String.Join(";", teamManager.GetAllTeams().Select(d => d.Identifier));
            }
            catch (AggregateException exception) {
                return "Error: " + exception.InnerException.Message;
            }
            catch (Exception exception) {
                return "Error: " + exception.Message;
            }
        }

        [HttpGet("{identifier}")]
        public string Get([FromQuery(Name = "token")] string token, string identifier) {
            try {
                TeamManager teamManager = new TeamManager(Server.TeamServer.ObjectManager,
                                                          (SessionToken)Server.TeamServer.TokenIssuer.ValidateToken(token));
                Team team = teamManager.LookupTeam(identifier);

                return ControllerUtils.SerializeObject(team, new List<string>(new string[] { "Identifier", "Name" }));
            }
            catch (AggregateException exception)
            {
                return "Error: " + exception.InnerException.Message;
            }
            catch (Exception exception) {
                return "Error: " + exception.Message;
            }
        }

        [HttpGet("{identifier}/drivers")]
        public string GetDrivers([FromQuery(Name = "token")] string token, string identifier) {
            try {
                TeamManager teamManager = new TeamManager(Server.TeamServer.ObjectManager,
                                                          (SessionToken)Server.TeamServer.TokenIssuer.ValidateToken(token));

                return String.Join(";", teamManager.LookupTeam(identifier).Drivers.Select(d => d.Identifier));
            }
            catch (AggregateException exception)
            {
                return "Error: " + exception.InnerException.Message;
            }
            catch (Exception exception) {
                return "Error: " + exception.Message;
            }
        }

        [HttpGet("{identifier}/sessions")]
        public string GetSessions([FromQuery(Name = "token")] string token, string identifier) {
            try {
                TeamManager teamManager = new TeamManager(Server.TeamServer.ObjectManager,
                                                          (SessionToken)Server.TeamServer.TokenIssuer.ValidateToken(token));

                return String.Join(";", teamManager.LookupTeam(identifier).Sessions.Select(s => s.Identifier));
            }
            catch (AggregateException exception) {
                return "Error: " + exception.InnerException.Message;
            }
            catch (Exception exception) {
                return "Error: " + exception.Message;
            }
        }

        [HttpPut("{identifier}")]
        public string Put([FromQuery(Name = "token")] string token, string identifier, [FromBody] string keyValues) {
            try {
                TeamManager teamManager = new TeamManager(Server.TeamServer.ObjectManager,
                                                          (SessionToken)Server.TeamServer.TokenIssuer.ValidateToken(token));
                Team team = teamManager.LookupTeam(identifier);

                ControllerUtils.DeserializeObject(team, keyValues);

                team.Save();

                return "Ok";
            }
            catch (AggregateException exception)
            {
                return "Error: " + exception.InnerException.Message;
            }
            catch (Exception exception) {
                return "Error: " + exception.Message;
            }
        }

        [HttpPost]
        public string Post([FromQuery(Name = "token")] string token, [FromBody] string keyValues) {
            try {
                SessionToken theToken = (SessionToken)Server.TeamServer.TokenIssuer.ValidateToken(token);
                TeamManager teamManager = new TeamManager(Server.TeamServer.ObjectManager, theToken);

                Dictionary<string, string> properties = ControllerUtils.ParseKeyValues(keyValues);
                
                return teamManager.CreateTeam(theToken.Account, properties["Name"]).Identifier.ToString();
            }
            catch (AggregateException exception)
            {
                return "Error: " + exception.InnerException.Message;
            }
            catch (Exception exception) {
                return "Error: " + exception.Message;
            }
        }

        [HttpDelete("{identifier}")]
        public string Delete([FromQuery(Name = "token")] string token, string identifier) {
            try {
                TeamManager teamManager = new TeamManager(Server.TeamServer.ObjectManager,
                                                          (SessionToken)Server.TeamServer.TokenIssuer.ValidateToken(token));

                teamManager.DeleteTeam(identifier);

                return "Ok";
            }
            catch (AggregateException exception)
            {
                return "Error: " + exception.InnerException.Message;
            }
            catch (Exception exception) {
                return "Error: " + exception.Message;
            }
        }
    }

    [ApiController]
    [Route("api/[controller]")]
    public class DriverController : ControllerBase {
        private readonly ILogger<DriverController> _logger;

        public DriverController(ILogger<DriverController> logger) {
            _logger = logger;
        }

        [HttpGet("{identifier}")]
        public string Get([FromQuery(Name = "token")] string token, string identifier) {
            try {

                TeamManager teamManager = new TeamManager(Server.TeamServer.ObjectManager,
                                                          (SessionToken)Server.TeamServer.TokenIssuer.ValidateToken(token));
                Driver driver = teamManager.LookupDriver(identifier);

                return ControllerUtils.SerializeObject(driver, new List<string>(new string[] { "Identifier", "ForName", "SurName", "NickName" }));
            }
            catch (AggregateException exception)
            {
                return "Error: " + exception.InnerException.Message;
            }
            catch (Exception exception) {
                return "Error: " + exception.Message;
            }
        }

        [HttpPut("{identifier}")]
        public string Put([FromQuery(Name = "token")] string token, string identifier, [FromBody] string keyValues) {
            try {
                TeamManager teamManager = new TeamManager(Server.TeamServer.ObjectManager,
                                                          (SessionToken)Server.TeamServer.TokenIssuer.ValidateToken(token));
                Driver driver = teamManager.LookupDriver(identifier);

                ControllerUtils.DeserializeObject(driver, keyValues);

                driver.Save();

                return "Ok";
            }
            catch (AggregateException exception)
            {
                return "Error: " + exception.InnerException.Message;
            }
            catch (Exception exception) {
                return "Error: " + exception.Message;
            }
        }

        [HttpPost]
        public string Post([FromQuery(Name = "token")] string token, [FromQuery(Name = "team")] string team, [FromBody] string keyValues) {
            try {
                SessionToken theToken = (SessionToken)Server.TeamServer.TokenIssuer.ValidateToken(token);
                TeamManager teamManager = new TeamManager(Server.TeamServer.ObjectManager, theToken);
                Team theTeam = teamManager.LookupTeam(team);

                Dictionary<string, string> properties = ControllerUtils.ParseKeyValues(keyValues);

                return teamManager.CreateDriver(theTeam, properties["ForName"], properties["SurName"], properties["NickName"]).Identifier.ToString();
            }
            catch (AggregateException exception)
            {
                return "Error: " + exception.InnerException.Message;
            }
            catch (Exception exception) {
                return "Error: " + exception.Message;
            }
        }

        [HttpDelete("{identifier}")]
        public string Delete([FromQuery(Name = "token")] string token, string identifier) {
            try {
                TeamManager teamManager = new TeamManager(Server.TeamServer.ObjectManager,
                                                          (SessionToken)Server.TeamServer.TokenIssuer.ValidateToken(token));

                teamManager.DeleteDriver(identifier);

                return "Ok";
            }
            catch (AggregateException exception)
            {
                return "Error: " + exception.InnerException.Message;
            }
            catch (Exception exception) {
                return "Error: " + exception.Message;
            }
        }
    }
}