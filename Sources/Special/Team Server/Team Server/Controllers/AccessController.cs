using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging;
using System;
using TeamServer.Model;

namespace TeamServer.Controllers {
    [ApiController]
    [Route("teamserver/[controller]")]
    public class LoginController : ControllerBase {
        private readonly ILogger<LoginController> _logger;

        public LoginController(ILogger<LoginController> logger) {
            _logger = logger;
        }

        [HttpGet]
        public String Get([FromQuery(Name = "name")] string account, [FromQuery(Name = "password")] string password) {
            try {
                return Server.TeamServer.TokenIssuer.CreateToken(account, password).Identifier.ToString();
            }
            catch (AggregateException exception) {
                return "Error: " + exception.InnerException.Message;
            }
            catch (Exception exception) {
                return "Error: " + exception.Message;
            }
        }
    }

    [ApiController]
    [Route("teamserver/[controller]")]
    public class LogoutController : ControllerBase {
        private readonly ILogger<LogoutController> _logger;

        public LogoutController(ILogger<LogoutController> logger) {
            _logger = logger;
        }

        [HttpGet]
        public String Get([FromQuery(Name = "token")] string token) {
            Server.TeamServer.TokenIssuer.DeleteToken(token);

            return "Ok";
        }
    }
}