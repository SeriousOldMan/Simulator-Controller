using SQLite;

namespace TeamServer.Model {
    public class ModelManager {
        public SQLiteAsyncConnection Connection { get; private set; }

        public ModelManager(SQLiteAsyncConnection connection) {
            Connection = connection;
        }

        public void CreateTables() {
            CreateTeamTable();
            CreateDriverTable();
            CreateSessionTable();
            CreateStintTable();
            CreateLapTable();
        }

        protected void CreateTeamTable() {
            Connection.CreateTableAsync<Team>().Wait();
        }

        protected void CreateDriverTable() {
            Connection.CreateTableAsync<Driver>().Wait();
        }

        protected void CreateSessionTable() {
            Connection.CreateTableAsync<Session>().Wait();
        }

        protected void CreateStintTable() {
            Connection.CreateTableAsync<Stint>().Wait();
        }

        protected void CreateLapTable() {
            Connection.CreateTableAsync<Lap>().Wait();
        }
    }
}