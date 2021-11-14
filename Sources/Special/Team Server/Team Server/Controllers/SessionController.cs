using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging;
using System;
using System.Threading.Tasks;
using TeamServer.Model;
using TeamServer.Server;

namespace TeamServer.Controllers {
    [ApiController]
    [Route("[controller]")]
    public class SessionController : ControllerBase {
        private readonly ILogger<SessionController> _logger;

        public SessionController(ILogger<SessionController> logger) {
            _logger = logger;
        }

        [HttpGet]
        public String Get([FromQuery(Name = "token")] string token, [FromQuery(Name = "operation")] string operation,
                          [FromQuery(Name = "team")] string teamIdentifier, [FromQuery(Name = "session")] string sessionIdentifier,
                          [FromQuery(Name = "duration")] string duration,
                          [FromQuery(Name = "driverForName")] string driverForName, [FromQuery(Name = "driverSurName")] string driverSurName,
                          [FromQuery(Name = "lap")] string lap, [FromBody] string body) {
            try {
                ObjectManager objectManager = Server.TeamServer.ObjectManager;
                SessionManager sessionManager = new SessionManager(objectManager, Server.TeamServer.TokenIssuer.ValidateToken(token));

                switch (operation) {
                    case "StartSession":
                        Team team = objectManager.GetTeamAsync(teamIdentifier).Result;
                        
                        return sessionManager.StartSession(team, int.Parse(duration)).Identifier.ToString();
                    case "EndSession":
                        sessionManager.EndSession(sessionIdentifier);

                        return "Ok";
                    case "DeleteSession":
                        sessionManager.DeleteSession(sessionIdentifier);

                        return "Ok";
                    case "StartStint":
                        sessionManager.AddStint(sessionIdentifier, driverForName, driverSurName, int.Parse(lap));

                        return "Ok";
                    case "StartLap":
                        sessionManager.AddLap(sessionIdentifier, int.Parse(lap));

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