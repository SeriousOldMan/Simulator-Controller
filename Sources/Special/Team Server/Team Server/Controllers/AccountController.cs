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
    public class AccountController : ControllerBase {
        private readonly ILogger<AccountController> _logger;

        public AccountController(ILogger<AccountController> logger) {
            _logger = logger;
        }

        [HttpGet("allaccounts")]
        public string GetAccounts([FromQuery(Name = "token")] string token) {
            try {
                AccountManager accountManager = new AccountManager(Server.TeamServer.ObjectManager, Server.TeamServer.TokenIssuer.ElevateToken(token));
                
                return String.Join(";", accountManager.GetAllAccounts().Select(a => a.Identifier));
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
                AccountManager accountManager = new AccountManager(Server.TeamServer.ObjectManager, Server.TeamServer.TokenIssuer.ElevateToken(token));
                Account account = accountManager.LookupAccount(identifier);

                return ControllerUtils.SerializeObject(account, new List<string>(new string[] { "Identifier", "Name", "Virgin", "MinutesLeft" }));
            }
            catch (Exception exception) {
                return "Error: " + exception.Message;
            }
        }

        [HttpPut("{identifier}")]
        public string Put([FromQuery(Name = "token")] string token, string identifier, [FromBody] string keyValues) {
            try {
                AccountManager accountManager = new AccountManager(Server.TeamServer.ObjectManager, Server.TeamServer.TokenIssuer.ElevateToken(token));
                Account account = accountManager.LookupAccount(identifier);

                ControllerUtils.DeserializeObject(account, keyValues);

                account.Save();

                return "Ok";
            }
            catch (Exception exception) {
                return "Error: " + exception.Message;
            }
        }

        [HttpPut("{identifier}/password")]
        public string SetPassword([FromQuery(Name = "token")] string token, string identifier, [FromBody] string password) {
            try {
                AccountManager accountManager = new AccountManager(Server.TeamServer.ObjectManager, Server.TeamServer.TokenIssuer.ValidateToken(token));
                Account account = accountManager.LookupAccount(identifier);

                account.Password = password;

                account.Save();

                return "Ok";
            }
            catch (Exception exception) {
                return "Error: " + exception.Message;
            }
        }

        [HttpPost]
        public string Post([FromQuery(Name = "token")] string token, [FromBody] string keyValues) {
            try {
                AccountManager accountManager = new AccountManager(Server.TeamServer.ObjectManager, Server.TeamServer.TokenIssuer.ElevateToken(token));

                Dictionary<string, string> properties = ControllerUtils.ParseKeyValues(keyValues);

                Account account = accountManager.CreateAccount(properties["Name"]);

                if (properties.ContainsKey("Password")) {
                    account.Password = properties["Password"];
                    account.Virgin = false;
                }

                if (properties.ContainsKey("Minutes"))
                    account.MinutesLeft = Int32.Parse(properties["Minutes"]);

                account.Save();
                
                return account.Identifier.ToString();
            }
            catch (Exception exception) {
                return "Error: " + exception.Message;
            }
        }

        [HttpDelete("{identifier}")]
        public string Delete([FromQuery(Name = "token")] string token, string identifier) {
            try {
                AccountManager accountManager = new AccountManager(Server.TeamServer.ObjectManager, Server.TeamServer.TokenIssuer.ValidateToken(token));

                accountManager.DeleteAccount(identifier);

                return "Ok";
            }
            catch (Exception exception) {
                return "Error: " + exception.Message;
            }
        }
    }
}