using SQLite;

namespace TeamServer.Model {
    public class ModelManager {
        public SQLiteAsyncConnection Connection { get; private set; }

        public ModelManager(SQLiteAsyncConnection connection) {
            Connection = connection;
        }

        public void CreateTables()
        {
            CreateAttributeTable();
            CreateTaskTable();

            CreateAccountTable();
            CreateAccessTables();
            CreateTeamTables();
            CreateSessionTables();

            CreateStoreTables();
        }

        protected void CreateAttributeTable()
        {
            Connection.CreateTableAsync<Attribute>().Wait();
        }

        protected void CreateTaskTable()
        {
            Connection.CreateTableAsync<Model.Task.Task>().Wait();
        }

        protected void CreateAccountTable() {
            Connection.CreateTableAsync<Access.Account>().Wait();
        }

        protected void CreateAccessTables()
        {
            Connection.CreateTableAsync<Access.SessionToken>().Wait();
            Connection.CreateTableAsync<Access.StoreToken>().Wait();
            Connection.CreateTableAsync<Access.Connection>().Wait();
        }

        protected void CreateTeamTables() {
            Connection.CreateTableAsync<Team>().Wait();
            Connection.CreateTableAsync<Driver>().Wait();
        }

        protected void CreateSessionTables() {
            Connection.CreateTableAsync<Session>().Wait();
            Connection.CreateTableAsync<Stint>().Wait();
            Connection.CreateTableAsync<Lap>().Wait();
        }

        protected void CreateStoreTables()
        {
            Connection.CreateTableAsync<Model.Store.Electronics>().Wait();
            Connection.CreateTableAsync<Model.Store.Tyres>().Wait();
            Connection.CreateTableAsync<Model.Store.TyresPressures>().Wait();
            Connection.CreateTableAsync<Model.Store.TyresPressuresDistribution>().Wait();
        }
    }
}