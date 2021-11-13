using SQLite;
using System;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace TeamServer.Model {
    [Table("Sessions")]
    public class Session : ModelObject {
        public int TeamID { get; set; }

        [Ignore]
        public Team Team {
            get {
                return ObjectManager.GetSessionTeamAsync(this).Result;
            }
        }

        public Guid Identifier { get; set; } = Guid.NewGuid();

        public int Duration { get; set; }

        public DateTime Started { get; set; } = DateTime.Now;

        public bool Finished { get; set; } = false;

        public string Track { get; set; }

        public string Car { get; set; }

        public string GridNr { get; set; }

        [Ignore]
        public List<Stint> Stints {
            get {
                return ObjectManager.GetSessionStintsAsync(this).Result;
            }
        }

        public override Task Delete() {
            foreach (Stint stint in Stints)
                stint.Delete();

            return base.Delete();
        }

        public Stint GetCurrentStint() {
            Task<List<Stint>> task = ObjectManager.Connection.QueryAsync<Stint>(
                @"
                    Select * From Stints Where SessionID = ? And Nr = (Select Max(Nr) From Stints Where SessionID = ?)
                ", this.ID, this.ID);

            if (task.Result.Count == 0)
                return null;
            else
                return task.Result[0];
        }
    }

    [Table("Stints")]
    public class Stint : ModelObject {
        public int SessionID { get; set; }

        [Ignore]
        public Session Session {
            get {
                return ObjectManager.GetStintSessionAsync(this).Result;
            }
        }

        public int DriverID { get; set; }

        [Ignore]
        public Driver Driver {
            get {
                return ObjectManager.GetStintDriverAsync(this).Result;
            }
        }

        public int Nr { get; set; }

        public int StartLap { get; set; }

        [MaxLength(2147483647)]
        public string PitstopData { get; set; } = "";

        [Ignore]
        public List<Lap> Laps {
            get {
                return ObjectManager.GetStintLapsAsync(this).Result;
            }
        }

        public override Task Delete() {
            foreach (Lap lap in Laps)
                lap.Delete();

            return base.Delete();
        }

        public Lap GetCurrentLap() {
            Task<List<Lap>> task = ObjectManager.Connection.QueryAsync<Lap>(
                @"
                    Select * From Laps Where StintID = ? And Nr = (Select Max(Nr) From Laps Where StintID = ?)
                ", this.ID, this.ID);

            if (task.Result.Count == 0)
                return null;
            else
                return task.Result[0];
        }
    }

    [Table("Laps")]
    public class Lap : ModelObject {
        public int StintID { get; set; }

        [Ignore]
        public Stint Stint {
            get {
                return ObjectManager.GetLapStintAsync(this).Result;
            }
        }

        public int Nr { get; set; }

        [MaxLength(2147483647)]
        public string TelemetryData { get; set; } = "";

        [MaxLength(2147483647)]
        public string PositionData { get; set; } = "";
    }
}