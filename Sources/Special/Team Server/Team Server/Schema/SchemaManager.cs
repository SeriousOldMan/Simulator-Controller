using Microsoft.Data.Sqlite;

namespace TeamServer.Schema {
    public class SchemaManager {
        public SqliteConnection Connection {
            get;
            private set;
        }

        public SchemaManager(SqliteConnection connection) {
            Connection = connection;
        }

        public void CreateTables() {
            CreateTeamsTable();
            CreateDriversTable();
            CreateSessionsTable();
            CreateStintsTable();
            CreateLapsTable();
        }

        protected void CreateTeamsTable() {
            using (var command = Connection.CreateCommand()) {
                command.CommandText =
                    @"
                    CREATE TABLE IF NOT EXISTS Teams (
                        [TeamId] INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
                        [Name] NVARCHAR(128) NOT NULL
                    )";

                // Create table if not exist    
                command.ExecuteNonQuery();
            }
        }

        protected void CreateDriversTable() {
            using (var command = Connection.CreateCommand()) {
                command.CommandText =
                    @"CREATE TABLE IF NOT EXISTS Drivers (
                        [DriverId] INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
                        [ForName] NVARCHAR(128) NOT NULL,
                        [SurName] NVARCHAR(128) NOT NULL,
                        [NickName] NVARCHAR(128) NOT NULL
                    )";

                // Create table if not exist    
                command.ExecuteNonQuery();
            }
        }

        protected void CreateSessionsTable() {
            using (var command = Connection.CreateCommand()) {
                command.CommandText =
                    @"CREATE TABLE IF NOT EXISTS Sessions (
                        [SessionId] INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
                        [TeamId] INTEGER NOT NULL,
                        [Track] NVARCHAR(128) NOT NULL,
                        [Car] NVARCHAR(128) NOT NULL,
                        [GridNr] NVARCHAR(32) NOT NULL
                    )";

                // Create table if not exist    
                command.ExecuteNonQuery();
            }
        }

        protected void CreateStintsTable() {
            using (var command = Connection.CreateCommand()) {
                command.CommandText =
                    @"CREATE TABLE IF NOT EXISTS Sessions (
                        [StintId] INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
                        [SessionId] INTEGER NOT NULL,
                        [DriverId] INTEGER NOT NULL,
                        [Nr] INTEGER NOT NULL
                    )";

                // Create table if not exist    
                command.ExecuteNonQuery();
            }
        }

        protected void CreateLapsTable() {
            using (var command = Connection.CreateCommand()) {
                command.CommandText =
                    @"CREATE TABLE IF NOT EXISTS Laps (
                        [LapId] INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
                        [StintId] INTEGER NOT NULL,
                        [Nr] INTEGER NOT NULL,
                        [TelemetryData] TEXT,
                        [CarData] TEXT
                    )";

                // Create table if not exist    
                command.ExecuteNonQuery();
            }
        }
    }
}