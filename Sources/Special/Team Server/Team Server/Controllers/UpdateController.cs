using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging;
using System;
using TeamServer.Model;
using TeamServer.Server;

namespace TeamServer.Controllers {
    [ApiController]
    [Route("[controller]")]
    public class UpdateController : ControllerBase {
        private readonly ILogger<UpdateController> _logger;

        public UpdateController(ILogger<UpdateController> logger) {
            _logger = logger;
        }

        [HttpGet]
        public string Get([FromQuery(Name = "token")] string token, [FromQuery(Name = "session")] string session, [FromQuery(Name = "operation")] string operation) {
            try {
                UpdateManager updateManager = new UpdateManager(Server.TeamServer.ObjectManager, Server.TeamServer.TokenIssuer.ValidateToken(token));

                switch (operation) {
                    case "GetCurrentLap":
                        Lap lap = updateManager.GetCurrentLap(session);

                        if (lap != null)
                            return lap.Nr.ToString();
                        else
                            return "0";
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