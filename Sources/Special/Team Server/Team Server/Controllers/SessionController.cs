using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using TeamServer.Model;

namespace TeamServer.Controllers {
    [ApiController]
    [Route("[controller]")]
    public class SessionController : ControllerBase {
        private readonly ILogger<SessionController> _logger;

        public Model.Access.Token Token = null;

        public SessionController(ILogger<SessionController> logger) {
            _logger = logger;
        }

        void CheckToken(Guid token, string password) {
            Token = ObjectManager.Instance.GetAccessTokenAsync(token, password).Result;

            if (Token == null)
                throw new Exception("Unknown token or password...");
        }

        void CheckToken(Model.Access.Token token) {
            if (token == null)
                throw new Exception("Not a valid token...");
        }

        void CheckToken() {
            if (Token == null)
                throw new Exception("Not a valid token...");
        }

        void CheckSession(Session session) {
            if ((session == null) || session.Finished)
                throw new Exception("Not a valid or active session...");
        }

        void CheckDuration(int duration) {
            if (Token.TimeLeft < duration)
                throw new Exception("Not enough time left for session...");
        }

        public string StartSession(Team team, int duration, string track, string car, string gridNr) {
            CheckToken();
            CheckDuration(duration);

            Guid identifier = new Guid();

            Session session = new Session { TeamID = team.ID, Identifier = identifier, Duration = duration, Finished = false,
                                            Track = track, Car = car, GridNr = gridNr };

            ObjectManager.Instance.SaveSessionAsync(session);

            return identifier.ToString();
        }

        public string StartSession(int teamID, int duration, string track, string car, string gridNr) {
            return StartSession(ObjectManager.Instance.GetTeamAsync(teamID).Result, duration, track, car, gridNr);
        }

        public void EndSession(Guid identifier, int sessionDuration) {
            CheckToken();
            
            Session session = ObjectManager.Instance.GetSessionAsync(identifier).Result;

            CheckSession(session);

            Token.TimeLeft -= sessionDuration;
            session.Finished = true;

            ObjectManager.Instance.SaveAccessTokenAsync(Token);
            ObjectManager.Instance.SaveSessionAsync(session);
        }

        public void EndSession(string identifier, int sessionDuration) {
            EndSession(new Guid(identifier), sessionDuration);
        }
    }
}