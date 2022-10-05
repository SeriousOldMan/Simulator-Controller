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
    public class TaskController : ControllerBase {
        private readonly ILogger<TaskController> _logger;

        public TaskController(ILogger<TaskController> logger) {
            _logger = logger;
        }

        [HttpGet("alltasks")]
        public string GetTasks([FromQuery(Name = "token")] string token) {
            try {
                TaskManager taskManager = new TaskManager(Server.TeamServer.ObjectManager, Server.TeamServer.TokenIssuer.ElevateToken(token));
                
                return String.Join(";", taskManager.GetAllTasks().Select(a => a.Identifier));
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
                TaskManager taskManager = new TaskManager(Server.TeamServer.ObjectManager, Server.TeamServer.TokenIssuer.ElevateToken(token));
                Model.Task.Task task = taskManager.LookupTask(identifier);

                return ControllerUtils.SerializeObject(task, new List<string>(new string[] { "Identifier", "Which", "What", "When", "Active" }));
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
                TaskManager taskManager = new TaskManager(Server.TeamServer.ObjectManager, Server.TeamServer.TokenIssuer.ElevateToken(token));
                Model.Task.Task task = taskManager.LookupTask(identifier);

                Dictionary<string, string> properties = ControllerUtils.ParseKeyValues(keyValues);

                if (properties.ContainsKey("Which"))
                    task.Which = (Model.Task.Task.Type)Enum.Parse(typeof(Model.Task.Task.Type), properties["Which"]);

                if (properties.ContainsKey("What"))
                    task.What = (Model.Task.Task.Operation)Enum.Parse(typeof(Model.Task.Task.Operation), properties["What"]);

                if (properties.ContainsKey("When"))
                    task.When = (Model.Task.Task.Frequency)Enum.Parse(typeof(Model.Task.Task.Frequency), properties["When"]);

                if (properties.ContainsKey("Active"))
                    task.Active = (properties["Active"].ToLower() == "true");

                task.Save();

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
                TaskManager taskManager = new TaskManager(Server.TeamServer.ObjectManager, Server.TeamServer.TokenIssuer.ElevateToken(token));
                
                Dictionary<string, string> properties = ControllerUtils.ParseKeyValues(keyValues);

                Model.Task.Task task = taskManager.CreateTask((Model.Task.Task.Type)Enum.Parse(typeof(Model.Task.Task.Type), properties["Which"]),
                                                              (Model.Task.Task.Operation)Enum.Parse(typeof(Model.Task.Task.Operation), properties["What"]),
                                                              (Model.Task.Task.Frequency)Enum.Parse(typeof(Model.Task.Task.Frequency), properties["When"]));

                return task.Identifier.ToString();
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
                TaskManager taskManager = new TaskManager(Server.TeamServer.ObjectManager, Server.TeamServer.TokenIssuer.ElevateToken(token));
                
                taskManager.DeleteTask(identifier);

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