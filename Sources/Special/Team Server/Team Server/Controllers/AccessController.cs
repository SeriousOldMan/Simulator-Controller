using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging;
using System;
using TeamServer.Model;
using TeamServer.Model.Access;
using TeamServer.Server;

namespace TeamServer.Controllers {
    [ApiController]
    [Route("api/[controller]")]
    public class LoginController : ControllerBase {
        private readonly ILogger<LoginController> _logger;

        public LoginController(ILogger<LoginController> logger) {
            _logger = logger;
        }

        [HttpGet]
        public string Login([FromQuery(Name = "name")] string name, [FromQuery(Name = "password")] string password,
                            [FromQuery(Name = "type")] string type) {
            if (name == null)
                name = "";

            if (password == null)
                password = "";

            if (type == null)
                type = "";

            if (type == "")
                type = "Session";

            try {
                if (type == "Session")
                    return Server.TeamServer.TokenIssuer.CreateSessionToken(name, password).Identifier.ToString();
                else if (type == "Store")
                    return Server.TeamServer.TokenIssuer.CreateStoreToken(name, password).Identifier.ToString();
                else
                    throw new Exception("Unknown login type...");
            }
            catch (AggregateException exception) {
                return "Error: " + exception.InnerException.Message;
            }
            catch (Exception exception) {
                return "Error: " + exception.Message;
            }
        }

        [HttpGet("accountavailableminutes")]
        public string GetAccountMinutes([FromQuery(Name = "token")] string token) {
            return Server.TeamServer.TokenIssuer.ValidateToken(token).Account.AvailableMinutes.ToString();
        }

        [HttpGet("tokenavailableminutes")]
        public string GetTokenMinutes([FromQuery(Name = "token")] string token) {
            return Math.Max(0, Server.TeamServer.TokenIssuer.ValidateToken(token).GetRemainingMinutes()).ToString();
        }

        [HttpGet("validatestoretoken")]
        public string ValidateStoreToken([FromQuery(Name = "token")] string token)
        {
            try
            {
                StoreToken theToken = (StoreToken)Server.TeamServer.TokenIssuer.ValidateToken(token);

                return "Ok";
            }
            catch (Exception exception)
            {
                return "Error: " + exception.Message;
            }
        }

        [HttpPut("password")]
        public string ChangePassword([FromQuery(Name = "token")] string token, [FromBody] string password) {
            try {
                Token theToken = Server.TeamServer.TokenIssuer.ValidateToken(token);

                AccountManager accountManager = new AccountManager(Server.TeamServer.ObjectManager, theToken);
                var account = theToken.Account;

                account.Password = password;

                account.Save();

                return "Ok";
            }
            catch (Exception exception) {
                return "Error: " + exception.Message;
            }
        }
    }

    [ApiController]
    [Route("api/[controller]")]
    public class LogoutController : ControllerBase {
        private readonly ILogger<LogoutController> _logger;

        public LogoutController(ILogger<LogoutController> logger) {
            _logger = logger;
        }

        [HttpDelete]
        public string Logout([FromQuery(Name = "token")] string token) {
            Server.TeamServer.TokenIssuer.DeleteToken(token);

            return "Ok";
        }
    }
}