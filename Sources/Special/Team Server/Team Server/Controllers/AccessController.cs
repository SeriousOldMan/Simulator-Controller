using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging;
using System;
using TeamServer.Model;
using TeamServer.Model.Access;

namespace TeamServer.Controllers {
    [ApiController]
    [Route("[controller]")]
    public class AccessController : ControllerBase {
        private readonly ILogger<AccessController> _logger;

        public AccessController(ILogger<AccessController> logger) {
            _logger = logger;
        }

        [HttpGet]
        public String Get([FromQuery(Name = "operation")] string operation, [FromQuery(Name = "token")] string token,
                          [FromQuery(Name = "account")] string account, [FromQuery(Name = "password")] string password) {
            try {
                switch (operation) {
                    case "Login":
                        return Server.TeamServer.TokenIssuer.CreateToken(account, password).Identifier.ToString();
                    case "Logout":
                        Server.TeamServer.TokenIssuer.DeleteToken(token);

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