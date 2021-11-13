using System;
using TeamServer.Model;
using TeamServer.Model.Access;

namespace TeamServer.Server {
    public class TeamManager : ManagerBase {
        public TeamManager(ObjectManager objectManager, Model.Access.Token token) : base(objectManager, token) {
        }

        public Team CreateTeam(string name) {
            Team team = new Team { Name = name };

            team.Save();

            return team;
        }

        public void DeleteTeam(Team team) {
            ValidateTeam(team);

            team.Delete();
        }

        public void DeleteTeam(Guid identifier) {
            DeleteTeam(ObjectManager.GetTeamAsync(identifier).Result);
        }

        public void DeleteTeam(string identifier) {
            DeleteTeam(new Guid(identifier));
        }
    }
}
