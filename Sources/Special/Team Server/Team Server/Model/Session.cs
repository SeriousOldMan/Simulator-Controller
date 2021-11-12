using SQLite;
using System;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace TeamServer.Model {
    [Table("Sessions")]
    public class Session : ModelObject {
        [PrimaryKey, AutoIncrement]
        public int ID { get; set; }

        public int TokenID { get; set; }

        [Ignore]
        public Task<Access.Token> Token {
            get {
                return ObjectManager.GetSessionTokenAsync(this);
            }
        }

        public int TeamID { get; set; }

        [Ignore]
        public Task<Team> Team {
            get {
                return ObjectManager.GetSessionTeamAsync(this);
            }
        }

        public Guid Identifier { get; set; }

        public int Duration { get; set; }

        public bool Finished { get; set; }

        public string Track { get; set; }

        public string Car { get; set; }

        public string GridNr { get; set; }

        public Stint GetCurrentStint() {
            Task<List<Stint>> task = ObjectManager.Connection.QueryAsync<Stint>("Select * From Stints Where Nr = Max(Nr) And SessionID = ?", this.ID);

            try {
                return task.Result[0];
            }
            catch (AggregateException e) {
                throw e.InnerException;
            }
        }
    }

    [Table("Stints")]
    public class Stint : ModelObject {
        [PrimaryKey, AutoIncrement]
        public int ID { get; set; }

        public int SessionID { get; set; }

        [Ignore]
        public Task<Session> Session {
            get {
                return ObjectManager.GetStintSessionAsync(this);
            }
        }

        public int DriverID { get; set; }

        [Ignore]
        public Task<Driver> Driver {
            get {
                return ObjectManager.GetStintDriverAsync(this);
            }
        }

        public int Nr { get; set; }

        [Ignore]
        public Task<List<Lap>> Laps {
            get {
                return ObjectManager.GetStintLapsAsync(this);
            }
        }

        public Lap GetCurrentLap() {
            Task<List<Lap>> task = ObjectManager.Connection.QueryAsync<Lap>("Select * From Laps Where Nr = Max(Nr) And StintID = ?", this.ID);

            try {
                return task.Result[0];
            }
            catch (AggregateException e) {
                throw e.InnerException;
            }
        }
    }

    [Table("Laps")]
    public class Lap : ModelObject {
        [PrimaryKey, AutoIncrement]
        public int ID { get; set; }

        public int StintID { get; set; }

        [Ignore]
        public Task<Stint> Stint {
            get {
                return ObjectManager.GetLapStintAsync(this);
            }
        }

        public int Nr { get; set; }

        [MaxLength(2147483647)]
        public string TelemetryData { get; set; }

        [MaxLength(2147483647)]
        public string CarData { get; set; }
    }
}