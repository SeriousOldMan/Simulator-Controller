using SQLite;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace TeamServer.Model {
    [Table("Teams")]
    public class Team : ModelObject {
        [PrimaryKey, AutoIncrement]
        public int ID { get; set; }

        public string Name { get; set; }

        [Ignore]
        public Task<List<Driver>> Drivers {
            get {
                return ObjectManager.GetTeamDriversAsync(this);
            }
        }

        [Ignore]
        public Task<List<Session>> Sessions {
            get {
                return ObjectManager.GetTeamSessionsAsync(this);
            }
        }
    }

    [Table("Drivers")]
    public class Driver : ModelObject {
        [PrimaryKey, AutoIncrement]
        public int ID { get; set; }

        public int TeamID { get; set; }

        [Ignore]
        public Task<Team> Team {
            get {
                return ObjectManager.GetDriverTeamAsync(this);
            }
        }

        public string ForName { get; set; }

        public string SurName { get; set; }

        public string NickName { get; set; }

        [Ignore]
        public Task<List<Stint>> Stints {
            get {
                return ObjectManager.GetDriverStintsAsync(this);
            }
        }
    }
}