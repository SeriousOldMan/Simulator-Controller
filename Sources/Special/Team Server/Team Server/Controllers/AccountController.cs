using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging;
using System;
using System.Collections.Generic;
using System.Linq;
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

                return ControllerUtils.SerializeObject(account, new List<string>(new string[] { "Identifier", "Name", "EMail", "Virgin",
                                                                                                "SessionAccess", "DataAccess",
                                                                                                "Contract", "ContractMinutes", "AvailableMinutes" }));
            }
            catch (AggregateException exception)
            {
                return "Error: " + exception.InnerException.Message;
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

                Dictionary<string, string> properties = ControllerUtils.ParseKeyValues(keyValues);

                if (properties.ContainsKey("EMail")) {
                    account.EMail = properties["EMail"];

                    account.Save().Wait();
                }

                if (properties.ContainsKey("Password"))
                    accountManager.ChangePassword(account, properties["Password"]);

                if (properties.ContainsKey("Contract"))
                    accountManager.ChangeContract(account, (Account.ContractType)Enum.Parse(typeof(Account.ContractType), properties["Contract"]),
                                                           Int32.Parse(properties["ContractMinutes"]));

                if (properties.ContainsKey("AvailableMinutes"))
                    accountManager.SetMinutes(account, Int32.Parse(properties["AvailableMinutes"]));

                if (properties.ContainsKey("SessionAccess") || properties.ContainsKey("DataAccess"))
                {
                    if (properties.ContainsKey("SessionAccess"))
                        account.SessionAccess = (properties["SessionAccess"].ToLower() == "true");

                    if (properties.ContainsKey("DataAccess"))
                        account.DataAccess = (properties["DataAccess"].ToLower() == "true");

                    account.Save().Wait();
                }

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

        [HttpPut("{identifier}/password")]
        public string ChangePassword([FromQuery(Name = "token")] string token, string identifier, [FromBody] string password) {
            try {
                AccountManager accountManager = new AccountManager(Server.TeamServer.ObjectManager, Server.TeamServer.TokenIssuer.ElevateToken(token));
                Account account = accountManager.LookupAccount(identifier);

                account.Password = password;
                account.Virgin = false;

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

        [HttpPut("{identifier}/contract")]
        public string ChangeContract([FromQuery(Name = "token")] string token, string identifier, [FromBody] string keyValues) {
            try {
                AccountManager accountManager = new AccountManager(Server.TeamServer.ObjectManager, Server.TeamServer.TokenIssuer.ElevateToken(token));
                Account account = accountManager.LookupAccount(identifier);

                Dictionary<string, string> properties = ControllerUtils.ParseKeyValues(keyValues);

                accountManager.ChangeContract(account, (Account.ContractType)Enum.Parse(typeof(Account.ContractType), properties["Contract"]),
                                                       Int32.Parse(properties["ContractMinutes"]));

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

        [HttpPut("{identifier}/minutes")]
        public string SetMinutes([FromQuery(Name = "token")] string token, string identifier, [FromBody] string minutes) {
            try {
                AccountManager accountManager = new AccountManager(Server.TeamServer.ObjectManager, Server.TeamServer.TokenIssuer.ElevateToken(token));
                Account account = accountManager.LookupAccount(identifier);

                accountManager.SetMinutes(account, Int32.Parse(minutes));

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

        [HttpPost]
        public string Post([FromQuery(Name = "token")] string token, [FromBody] string keyValues) {
            try {
                AccountManager accountManager = new AccountManager(Server.TeamServer.ObjectManager, Server.TeamServer.TokenIssuer.ElevateToken(token));

                Dictionary<string, string> properties = ControllerUtils.ParseKeyValues(keyValues);

                Account account = accountManager.CreateAccount(properties["Name"]);

                if (properties.ContainsKey("EMail"))
                    account.EMail = properties["EMail"];

                if (properties.ContainsKey("Password"))
                    account.Password = properties["Password"];

                if (properties.ContainsKey("Contract"))
                    account.Contract = (Account.ContractType)Enum.Parse(typeof(Account.ContractType), properties["Contract"]);

                if (properties.ContainsKey("ContractMinutes"))
                    account.ContractMinutes = Int32.Parse(properties["ContractMinutes"]);

                if (properties.ContainsKey("AvailableMinutes"))
                    account.AvailableMinutes = Int32.Parse(properties["AvailableMinutes"]);

                if (properties.ContainsKey("SessionAccess"))
                    account.SessionAccess = properties["SessionAccess"].ToLower() == "true";

                if (properties.ContainsKey("DataAccess"))
                    account.DataAccess = properties["DataAccess"].ToLower() == "true";

                account.Save();
                
                return account.Identifier.ToString();
            }
            catch (AggregateException exception)
            {
                return "Error: " + exception.InnerException.Message;
            }
            catch (Exception exception) {
                return "Error: " + exception.Message;
            }
        }

        [HttpDelete("{identifier}")]
        public string Delete([FromQuery(Name = "token")] string token, string identifier) {
            try {
                AccountManager accountManager = new AccountManager(Server.TeamServer.ObjectManager, Server.TeamServer.TokenIssuer.ElevateToken(token));

                accountManager.DeleteAccount(identifier);

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
    }
}