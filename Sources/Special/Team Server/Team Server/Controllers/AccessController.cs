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

        [HttpGet("connect")]
        public string Connect([FromQuery(Name = "token")] string token,
                              [FromQuery(Name = "client")] string client, [FromQuery(Name = "name")] string name,
                              [FromQuery(Name = "type")] string type, [FromQuery(Name = "session")] string session)
        {
            if (client == null)
                client = "";

            if (name == null)
                name = "";

            if (session == null)
                session = "";

            if (type == null)
                type = "";

            ConnectionType theType = ConnectionType.Unknown;

            try {
                if (!Enum.TryParse(type, out theType))
                    throw new Exception("Unknown connection type...");

                Server.TeamServer.TokenIssuer.Connect(token, client, name, theType, session);

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

        [HttpGet("validatesessiontoken")]
        public string ValidateSessionToken([FromQuery(Name = "token")] string token)
        {
            try
            {
                SessionToken theToken = (SessionToken)Server.TeamServer.TokenIssuer.ValidateToken(token);

                return "Ok";
            }
            catch (Exception exception)
            {
                return "Error: " + exception.Message;
            }
        }

        [HttpGet("accountavailableminutes")]
        public string GetAccountMinutes([FromQuery(Name = "token")] string token)
        {
            return Server.TeamServer.TokenIssuer.ValidateToken(token).Account.AvailableMinutes.ToString();
        }

        [HttpGet("tokenavailableminutes")]
        public string GetTokenMinutes([FromQuery(Name = "token")] string token)
        {
            return Math.Max(0, Server.TeamServer.TokenIssuer.ValidateToken(token).GetRemainingMinutes()).ToString();
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

        [HttpGet("allconnections")]
        public string GetConnections([FromQuery(Name = "token")] string token)
        {
            try
            {
                Server.TeamServer.TokenIssuer.ElevateToken(token);

                return String.Join(";", Server.TeamServer.TokenIssuer.GetAllConnections().Select(c => c.Identifier));
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

        [HttpGet("allsessions")]
        public string GetSessions([FromQuery(Name = "token")] string token)
        {
            try
            {
                SessionManager sessionManager = new SessionManager(Server.TeamServer.ObjectManager,
                                                                   (SessionToken)Server.TeamServer.TokenIssuer.ElevateToken(token));

                return String.Join(";", sessionManager.GetAllSessions().Select(c => c.Identifier));
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

        [HttpGet("{identifier}")]
        public string Get([FromQuery(Name = "token")] string token, string identifier) {
            try {
                Server.TeamServer.TokenIssuer.ValidateToken(token);
                
                Connection connection = Server.TeamServer.TokenIssuer.LookupConnection(identifier);

                connection.Renew();

                return ControllerUtils.SerializeObject(connection,
                                                       new List<string>(new string[] { "Identifier", "Client", "Name", "Type", "Session" }));
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