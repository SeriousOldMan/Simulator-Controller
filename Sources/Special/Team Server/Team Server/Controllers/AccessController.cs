using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging;
using System;
using TeamServer.Model;

namespace TeamServer.Controllers {
    [ApiController]
    [Route("api/[controller]")]
    public class LoginController : ControllerBase {
        private readonly ILogger<LoginController> _logger;

        public LoginController(ILogger<LoginController> logger) {
            _logger = logger;
        }

        [HttpGet]
        public String Get([FromQuery(Name = "name")] string name, [FromQuery(Name = "password")] string password) {
            if (name == null)
                name = "";

            if (password == null)
                password = "";

            try {
                return Server.TeamServer.TokenIssuer.CreateToken(name, password).Identifier.ToString();
            }
            catch (AggregateException exception) {
                return "Error: " + exception.InnerException.Message;
            }
            catch (Exception exception) {
                return "Error: " + exception.Message;
            }
        }

        [HttpGet("accountminutesleft")]
        public String GetAccountMinutes([FromQuery(Name = "token")] string token) {
            return Server.TeamServer.TokenIssuer.ValidateToken(token).Account.MinutesLeft.ToString();
        }

        [HttpGet("tokenminutesleft")]
        public String GetTokenMinutes([FromQuery(Name = "token")] string token) {
            return Server.TeamServer.TokenIssuer.ValidateToken(token).GetRemainingMinutes().ToString();
        }
    }

    [ApiController]
    [Route("api/[controller]")]
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