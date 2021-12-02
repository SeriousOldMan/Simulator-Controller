using SQLite;
using System;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace TeamServer.Model {
    [Table("Teams")]
    public class Team : ModelObject {
[Indexed]
        public int AccountID { get; set; }

        [Ignore]
        public Access.Account Account {
            get {
                return ObjectManager.GetTeamAccountAsync(this).Result;
            }
        }

        public string Name { get; set; }

        [Ignore]
        public List<Driver> Drivers {
            get {
                return ObjectManager.GetTeamDriversAsync(this).Result;
            }
        }

        [Ignore]
        public List<Session> Sessions {
            get {
                return ObjectManager.GetTeamSessionsAsync(this).Result;
            }
        }

        public override System.Threading.Tasks.Task Delete() {
            foreach (Session session in Sessions)
                session.Delete();

            foreach (Driver driver in Drivers)
                driver.Delete();

            return base.Delete();
        }
    }

    [Table("Drivers")]
    public class Driver : ModelObject {
        [Indexed]
        public int TeamID { get; set; }

        [Ignore]
        public Team Team {
            get {
                return ObjectManager.GetDriverTeamAsync(this).Result;
            }
        }

        public string ForName { get; set; }

        public string SurName { get; set; }

        public string NickName { get; set; }

        [Ignore]
        public List<Stint> Stints {
            get {
                return ObjectManager.GetDriverStintsAsync(this).Result;
            }
        }

        public override System.Threading.Tasks.Task Delete() {
            foreach (Stint stint in Stints)
                stint.Delete();

            return base.Delete();
        }
    }
}