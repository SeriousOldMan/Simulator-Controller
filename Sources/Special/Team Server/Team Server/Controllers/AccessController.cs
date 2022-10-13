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

        public Token ValidateToken(Token token)
        {
            Token theToken = Server.TeamServer.TokenIssuer.ValidateToken(token);

            if (!theToken.HasAccess(Token.TokenType.Account))
                throw new Exception("Invalid token type...");
            else
                return theToken;
        }

        [HttpGet]
        public string Login([FromQuery(Name = "name")] string name, [FromQuery(Name = "password")] string password) {
            if (name == null)
                name = "";

            if (password == null)
                password = "";

            try {
                return Server.TeamServer.TokenIssuer.CreateAccountToken(name, password).Identifier.ToString();
            }
            catch (AggregateException exception) {
                return "Error: " + exception.InnerException.Message;
            }
            catch (Exception exception) {
                return "Error: " + exception.Message;
            }
        }

        [HttpGet("token/{type}")]
        public string IssueToken([FromQuery(Name = "token")] string token, string type)
        {
            if ((type == null) || (type == ""))
                return "Error: Invalid token request...";
            else
                type = type.ToLower();

            TokenIssuer tokenIssuer = Server.TeamServer.TokenIssuer;

            try {
                Token theToken = tokenIssuer.ValidateToken(token);

                ValidateToken(theToken);

                if (type == "session")
                    return tokenIssuer.IssueSessionToken(theToken).Identifier.ToString();
                else if (type == "data")
                    return tokenIssuer.IssueDataToken(theToken).Identifier.ToString();
                else
                    return "Error: Invalid token type...";
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

        [HttpGet("connect/{category}")]
        public string Connect([FromQuery(Name = "token")] string token,
                              [FromQuery(Name = "client")] string client, [FromQuery(Name = "name")] string name,
                              [FromQuery(Name = "type")] string type, [FromQuery(Name = "session")] string session,
                              string category)
        {
            if (client == null)
                client = "";

            if (name == null)
                name = "";

            if (session == null)
                session = "";

            if (type == null)
                type = "";

            category = category.ToLower();

            if (category == "session")
            {
                if (session == "")
                    throw new Exception("Not a valid or active session...");
            }
            else if (category == "data")
            {
                if (type.ToLower() != "internal")
                    throw new Exception("Not a valid connection type...");

            }
            else if (category != "admin")
                throw new Exception("Unknown access type...");

            Connection.ConnectionType theType = Connection.ConnectionType.Unknown;

            try {
                if (!Enum.TryParse(type, out theType))
                    throw new Exception("Unknown connection type...");

                if (category == "data")
                    new DataManager(Server.TeamServer.ObjectManager, token);
                else if (category == "session")
                    new SessionManager(Server.TeamServer.ObjectManager, token);

                return Server.TeamServer.TokenIssuer.Connect(token, client, name, theType, session).Identifier.ToString();
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


        [HttpGet("validatetoken")]
        public string ValidateToken([FromQuery(Name = "token")] string token)
        {
            try
            {
                Token theToken = Server.TeamServer.TokenIssuer.ValidateToken(token);

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

        [HttpGet("accountavailableminutes")]
        public string GetAccountMinutes([FromQuery(Name = "token")] string token)
        {
            return Server.TeamServer.TokenIssuer.ValidateToken(token).Account.AvailableMinutes.ToString();
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
            catch (AggregateException exception)
            {
                return "Error: " + exception.InnerException.Message;
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
                                                                   Server.TeamServer.TokenIssuer.ElevateToken(token));

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
        public string Get([FromQuery(Name = "token")] string token, string identifier, [FromQuery(Name = "keepalive")] string keepAlive) {
            try {
                Server.TeamServer.TokenIssuer.ValidateToken(token);
                
                Connection connection = Server.TeamServer.TokenIssuer.FindConnection(identifier);

                if (connection != null)
                {
                    if ((keepAlive != null) && (keepAlive.ToLower() == "true"))
                        connection.Renew();

                    string result = ControllerUtils.SerializeObject(connection,
                                                                    new List<string>(new string[] { "Identifier", "Client", "Name", "Type", "Created" }));

                    result += "\nSession=" + (connection.Session == null ? "" : connection.Session.Identifier.ToString());

                    return result;
                }
                else
                    return Server.TeamServer.TokenIssuer.ValidateConnection(null).ToString();
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