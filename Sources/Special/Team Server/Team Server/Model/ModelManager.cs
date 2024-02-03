using SQLite;
using System.Collections.Generic;

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

            CreateDataTables();
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
            Connection.CreateTableAsync<Access.Token>().Wait();
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

        protected void CreateDataTables()
        {
            Connection.CreateTableAsync<Data.Document>().Wait();
            Connection.CreateTableAsync<Data.License>().Wait();
            Connection.CreateTableAsync<Data.Electronics>().Wait();
            Connection.CreateTableAsync<Data.Tyres>().Wait();
            Connection.CreateTableAsync<Data.Brakes>().Wait();
            Connection.CreateTableAsync<Data.TyresPressures>().Wait();
            Connection.CreateTableAsync<Data.TyresPressuresDistribution>().Wait();
        }

        public Dictionary<string, long> GetObjectCounts()
        {
            ObjectManager objectManager = new ObjectManager(Connection);
            Dictionary<string, long> result = new Dictionary<string, long>();

            result["Accounts"] = objectManager.GetCount(typeof(Access.Account));
            result["Tokens"] = objectManager.GetCount(typeof(Access.Token));
            result["Connections"] = objectManager.GetCount(typeof(Access.Connection));

            result["Teams"] = objectManager.GetCount(typeof(Team));
            result["Drivers"] = objectManager.GetCount(typeof(Driver));
            result["Sessions"] = objectManager.GetCount(typeof(Session));
            result["Stints"] = objectManager.GetCount(typeof(Stint));
            result["Laps"] = objectManager.GetCount(typeof(Lap));

            result["Documents"] = objectManager.GetCount(typeof(Data.Document));
            result["Attributes"] = objectManager.GetCount(typeof(Attribute));

            result["Licenses"] = objectManager.GetCount(typeof(Data.License));
            result["Electronics"] = objectManager.GetCount(typeof(Data.Electronics));
            result["Tyres"] = objectManager.GetCount(typeof(Data.Tyres));
            result["Brakes"] = objectManager.GetCount(typeof(Data.Brakes));
            result["TyresPressures"] = objectManager.GetCount(typeof(Data.TyresPressures));
            result["TyresPressuresDistribution"] = objectManager.GetCount(typeof(Data.TyresPressuresDistribution));

            return result;
        }
    }
}