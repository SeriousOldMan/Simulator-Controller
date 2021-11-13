using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging;
using System;
using TeamServer.Model;
using TeamServer.Server;

namespace TeamServer.Controllers {
    [ApiController]
    [Route("[controller]")]
    public class TeamController : ControllerBase {
        private readonly ILogger<TeamController> _logger;

        public TeamController(ILogger<TeamController> logger) {
            _logger = logger;
        }

        [HttpGet]
        public String Get([FromQuery(Name = "token")] string token, [FromQuery(Name = "operation")] string operation,
                          [FromQuery(Name = "name")] string name, [FromQuery(Name = "identifier")] string identifier) {
            try {
                TeamManager teamManager = new TeamManager(Server.TeamServer.ObjectManager, Server.TeamServer.TokenIssuer.ValidateToken(token));

                switch (operation) {
                    case "CreateTeam":
                        return teamManager.CreateTeam(name).Identifier.ToString();
                    case "DeleteTeam":
                        teamManager.DeleteTeam(identifier);

                        return "Ok";
                    default:
                        return "Error: Bad request...";
                }
            }
            catch (AggregateException exception) {
                return "Error: " + exception.InnerException.Message;
            }
            catch (Exception exception) {
                return "Error: " + exception.Message;
            }
        }
    }
}