using SQLite;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace TeamServer.Model {
    public class ObjectManager {
        public static ObjectManager Instance { get; private set; } = null;

        public SQLiteAsyncConnection Connection { get; private set; }

        public ObjectManager(SQLiteAsyncConnection connection) {
            Connection = connection;

            if (Instance == null)
                Instance = this;
        }

        #region Generic
        public System.Threading.Tasks.Task DeleteAsync(ModelObject modelObject) {
            return Connection.DeleteAsync(modelObject);
        }

        public Task<int> SaveAsync(ModelObject modelObject) {
            if (modelObject.ID != 0)
                return Connection.UpdateAsync(modelObject);
            else
                return Connection.InsertAsync(modelObject);
        }

        public Task<List<Attribute>> GetAttributesAsync(ModelObject modelObject) {
            return Connection.Table<Attribute>().Where(a => a.Owner == modelObject.Identifier).ToListAsync();
        }

        public string GetAttribute(ModelObject modelObject, string name, string defaultValue = "") {
            Attribute attribute = Connection.Table<Attribute>().Where(a => a.Owner == modelObject.Identifier && a.Name == name).FirstOrDefaultAsync().Result;

            return (attribute != null) ? attribute.Value : defaultValue;
        }

        public void SetAttribute(ModelObject modelObject, string name, string value) {
            Attribute attribute = Connection.Table<Attribute>().Where(a => a.Owner == modelObject.Identifier && a.Name == name).FirstOrDefaultAsync().Result;

            if (attribute == null)
                attribute = new Attribute { Owner = modelObject.Identifier, Name = name, Value = value };
            else
                attribute.Value = value;

            attribute.Save();
        }

        public void DeleteAttribute(ModelObject modelObject, string name) {
            Attribute attribute = Connection.Table<Attribute>().Where(a => a.Owner == modelObject.Identifier && a.Name == name).FirstOrDefaultAsync().Result;

            if (attribute != null)
                attribute.Delete();
        }
        #endregion

        #region Access.Account
        public Task<Access.Account> GetAccountAsync(int id) {
            return Connection.Table<Access.Account>().Where(a => a.ID == id).FirstOrDefaultAsync();
        }

        public Task<Access.Account> GetAccountAsync(Guid identifier) {
            return Connection.Table<Access.Account>().Where(a => a.Identifier == identifier).FirstOrDefaultAsync();
        }

        public Task<Access.Account> GetAccountAsync(string identifier) {
            Guid guid;

            try {
                guid = new Guid(identifier);
            }
            catch {
                guid = Guid.Empty;
            }

            return Connection.Table<Access.Account>().Where(a => a.Name == identifier || a.EMail == identifier || a.Identifier == guid).FirstOrDefaultAsync();
        }

        public Task<Access.Account> GetAccountAsync(string account, string password) {
            return Connection.Table<Access.Account>().Where(c => c.Name == account && c.Password == password).FirstOrDefaultAsync();
        }

        public Task<List<Access.SessionToken>> GetAccountSessionTokensAsync(Access.Account account)
        {
            return Connection.Table<Access.SessionToken>().Where(t => t.AccountID == account.ID).ToListAsync();
        }

        public Task<Access.StoreToken> GetAccountStoreTokenAsync(Access.Account account)
        {
            return Connection.Table<Access.StoreToken>().Where(t => t.AccountID == account.ID).FirstOrDefaultAsync();
        }

        public async void DoAccountTokensAsync(Access.Account account, Action<Access.Token> action)
        {
            foreach (Access.Token t in await GetAccountSessionTokensAsync(account))
                action(t);

            Access.Token token = await GetAccountStoreTokenAsync(account);
                
            if (token != null)
                action(token);
        }

        public Task<List<Team>> GetAccountTeamsAsync(Access.Account account) {
            return Connection.Table<Team>().Where(t => t.AccountID == account.ID).ToListAsync();
        }

        public Task<List<Session>> GetAccountSessionsAsync(Access.Account account) {
            return Connection.QueryAsync<Session>(
                @"
                    Select * From Sessions Where TeamID In (Select ID From Teams Where AccountID = ?)
                ", account.ID);
        }

        public Task<List<Store.ElectronicsData>> GetAccountElectronicsDataAsync(Access.Account account)
        {
            return Connection.Table<Store.ElectronicsData>().Where(t => t.AccountID == account.ID).ToListAsync();
        }

        public Task<List<Store.TyresData>> GetAccountTyresDataAsync(Access.Account account)
        {
            return Connection.Table<Store.TyresData>().Where(t => t.AccountID == account.ID).ToListAsync();
        }

        public Task<List<Store.BrakesData>> GetAccountBrakesDataAsync(Access.Account account)
        {
            return Connection.Table<Store.BrakesData>().Where(t => t.AccountID == account.ID).ToListAsync();
        }

        public Task<List<Store.TyresPressuresData>> GetAccountTyresPressuresDataAsync(Access.Account account)
        {
            return Connection.Table<Store.TyresPressuresData>().Where(t => t.AccountID == account.ID).ToListAsync();
        }

        public Task<List<Store.TyresPressuresDistributionData>> GetAccountTyresPressuresDistributionDataAsync(Access.Account account)
        {
            return Connection.Table<Store.TyresPressuresDistributionData>().Where(t => t.AccountID == account.ID).ToListAsync();
        }

        public async void DoAccountStoreDataAsync(Access.Account account, Action<Store.StoreData> action)
        {
            foreach (Store.StoreData data in await GetAccountElectronicsDataAsync(account))
                action(data);

            foreach (Store.StoreData data in await GetAccountTyresDataAsync(account))
                action(data);

            foreach (Store.StoreData data in await GetAccountBrakesDataAsync(account))
                action(data);

            foreach (Store.StoreData data in await GetAccountTyresPressuresDataAsync(account))
                action(data);

            foreach (Store.StoreData data in await GetAccountTyresPressuresDistributionDataAsync(account))
                action(data);
        }
        
        public Task<List<Store.StoreData>> GetAccountStoreDataAsync(Access.Account account)
        {
            return new Task<List<Store.StoreData>>(() =>
            {
                List<Store.StoreData> list = new List<Store.StoreData>();

                DoAccountStoreDataAsync(account, (Store.StoreData data) => { list.Add(data); });

                return list;
            });
        }
        #endregion

        #region Access.Token
        public Task<Access.Token> GetTokenAsync(int id) {
            return new Task<Access.Token>(() => {
                Access.Token token = Connection.Table<Access.SessionToken>().Where(t => t.ID == id).FirstOrDefaultAsync().Result;

                if (token == null)
                    return Connection.Table<Access.StoreToken>().Where(t => t.ID == id).FirstOrDefaultAsync().Result;
                else
                    return token;
            });
        }

        public Task<Access.Token> GetTokenAsync(Guid identifier) {
            return new Task<Access.Token>(() => {
                Access.Token token = Connection.Table<Access.SessionToken>().Where(t => t.Identifier == identifier).FirstOrDefaultAsync().Result;

                if (token == null)
                    return Connection.Table<Access.StoreToken>().Where(t => t.Identifier == identifier).FirstOrDefaultAsync().Result;
                else
                    return token;
            });
        }

        public Task<Access.Token> GetTokenAsync(string identifier) {
            return GetTokenAsync(new Guid(identifier));
        }

        public Task<Access.Account> GetTokenAccountAsync(Access.Token token) {
            return Connection.Table<Access.Account>().Where(a => a.ID == token.AccountID).FirstAsync();
        }

        public Task<Access.Connection> GetTokenConnectionAsync(Access.Token token, string client, string name,
                                                               Access.ConnectionType type, Session session = null)
        {
            Task<Access.Connection> task =
                (session != null) ?
                    Connection.Table<Access.Connection>().Where(c => c.TokenID == token.ID && c.Type == type &&
                                                                     c.Client == client && c.Name == name &&
                                                                     c.SessionID == session.ID).FirstAsync()
                :
                    Connection.Table<Access.Connection>().Where(c => c.TokenID == token.ID && c.Type == type &&
                                                                     c.Client == client && c.Name == name).FirstAsync();


            return task.ContinueWith(t =>
                {
                    if (t.Result != null)
                    {
                        if (t.Result.IsConnected())
                            return t.Result;
                        else
                        {
                            t.Result.Delete();

                            return null;
                        }
                    }
                    else
                        return null;
                });
        }

        public Task<List<Access.Connection>> GetAllConnectionsAsync()
        {
            return Connection.Table<Access.Connection>().ToListAsync().
                ContinueWith(t => t.Result.FindAll(c =>
                {
                    if (c.IsConnected())
                        return true;
                    else
                    {
                        c.Delete();

                        return false;
                    }
                }));
        }

        public Task<List<Access.Connection>> GetTokenConnectionsAsync(Access.Token token)
        {
            return Connection.Table<Access.Connection>().Where(t => t.TokenID == token.ID).ToListAsync().
                ContinueWith(t => t.Result.FindAll(c =>
                {
                    if (c.IsConnected())
                        return true;
                    else
                    {
                        c.Delete();

                        return false;
                    }
                }));
        }
        #endregion

        #region Access.Connection
        public Task<Access.Connection> GetConnectionAsync(int id)
        {
            return Connection.Table<Access.Connection>().Where(c => c.ID == id).FirstOrDefaultAsync();
        }

        public Task<Access.Connection> GetConnectionAsync(Guid identifier)
        {
            return Connection.Table<Access.Connection>().Where(c => c.Identifier == identifier).FirstOrDefaultAsync();
        }

        public Task<Access.Connection> GetConnectionAsync(string identifier)
        {
            return GetConnectionAsync(new Guid(identifier));
        }
        #endregion

        #region Team
        public Task<Team> GetTeamAsync(int id) {
            return Connection.Table<Team>().Where(t => t.ID == id).FirstOrDefaultAsync();
        }

        public Task<Team> GetTeamAsync(Guid identifier) {
            return Connection.Table<Team>().Where(t => t.Identifier == identifier).FirstOrDefaultAsync();
        }

        public Task<Team> GetTeamAsync(Access.Account account, string name) {
            return Connection.Table<Team>().Where(t => t.AccountID == account.ID && t.Name == name).FirstOrDefaultAsync();
        }

        public Task<Team> GetTeamAsync(string identifier) {
            return GetTeamAsync(new Guid(identifier));
        }

        public Task<Access.Account> GetTeamAccountAsync(Team team) {
            return Connection.Table<Access.Account>().Where(a => a.ID == team.AccountID).FirstAsync();
        }

        public Task<List<Driver>> GetTeamDriversAsync(Team team) {
            return Connection.Table<Driver>().Where(d => d.TeamID == team.ID).ToListAsync();
        }

        public Task<List<Session>> GetTeamSessionsAsync(Team team) {
            return Connection.Table<Session>().Where(s => s.TeamID == team.ID).ToListAsync();
        }
        #endregion

        #region Driver
        public Task<Driver> GetDriverAsync(int id) {
            return Connection.Table<Driver>().Where(d => d.ID == id).FirstOrDefaultAsync();
        }
        public Task<Driver> GetDriverAsync(Guid identifier) {
            return Connection.Table<Driver>().Where(d => d.Identifier == identifier).FirstOrDefaultAsync();
        }

        public Task<int> SaveDriverAsync(Driver driver) {
            if (driver.ID != 0)
                return Connection.UpdateAsync(driver);
            else
                return Connection.InsertAsync(driver);
        }

        public Task<Team> GetDriverTeamAsync(Driver driver) {
            return Connection.Table<Team>().Where(t => t.ID == driver.TeamID).FirstAsync();
        }

        public Task<List<Stint>> GetDriverStintsAsync(Driver driver) {
            return Connection.Table<Stint>().Where(s => s.DriverID == driver.ID).ToListAsync();
        }
        #endregion

        #region Session
        public Task<List<Session>> GetAllSessionsAsync()
        {
            return Connection.Table<Session>().ToListAsync();
        }

        public Task<Session> GetSessionAsync(int id) {
            return Connection.Table<Session>().Where(s => s.ID == id).FirstOrDefaultAsync();
        }

        public Task<Session> GetSessionAsync(Guid identifier) {
            return Connection.Table<Session>().Where(s => s.Identifier == identifier).FirstOrDefaultAsync();
        }

        public Task<Session> GetSessionAsync(string identifier) {
            return GetSessionAsync(new Guid(identifier));
        }

        public Task<Team> GetSessionTeamAsync(Session session) {
            return Connection.Table<Team>().Where(t => t.ID == session.TeamID).FirstAsync();
        }

        public Task<List<Access.Connection>> GetSessionConnectionsAsync(Session session) {
            return Connection.Table<Access.Connection>().Where(c => c.SessionID == session.ID).ToListAsync().
                ContinueWith(t => t.Result.FindAll(c =>
                {
                    if (c.IsConnected())
                        return true;
                    else
                    {
                        c.Delete();

                        return false;
                    }
                }));
        }

        public Task<List<Stint>> GetSessionStintsAsync(Session session) {
            return Connection.Table<Stint>().Where(s => s.SessionID == session.ID).ToListAsync();
        }

        public Task<List<Lap>> GetSessionLapsAsync(Session session) {
            return Connection.Table<Lap>().Where(l => l.SessionID == session.ID).ToListAsync();
        }
        #endregion

        #region Stint
        public Task<Stint> GetStintAsync(int id) {
            return Connection.Table<Stint>().Where(s => s.ID == id).FirstOrDefaultAsync();
        }

        public Task<Stint> GetStintAsync(Guid identifier) {
            return Connection.Table<Stint>().Where(s => s.Identifier == identifier).FirstOrDefaultAsync();
        }

        public Task<Session> GetStintSessionAsync(Stint stint) {
            return Connection.Table<Session>().Where(s => s.ID == stint.SessionID).FirstAsync();
        }

        public Task<Driver> GetStintDriverAsync(Stint stint) {
            return Connection.Table<Driver>().Where(d => d.ID == stint.DriverID).FirstAsync();
        }

        public Task<List<Lap>> GetStintLapsAsync(Stint stint) {
            return Connection.Table<Lap>().Where(l => l.StintID == stint.ID).ToListAsync();
        }
        #endregion

        #region Lap
        public Task<Lap> GetLapAsync(int id) {
            return Connection.Table<Lap>().Where(i => i.ID == id).FirstOrDefaultAsync();
        }

        public Task<Lap> GetLapAsync(Guid identifier) {
            return Connection.Table<Lap>().Where(i => i.Identifier == identifier).FirstOrDefaultAsync();
        }

        public Task<Session> GetLapSessionAsync(Lap lap) {
            return Connection.Table<Session>().Where(s => s.ID == lap.SessionID).FirstAsync();
        }

        public Task<Stint> GetLapStintAsync(Lap lap) {
            return Connection.Table<Stint>().Where(s => s.ID == lap.StintID).FirstAsync();
        }
        #endregion

        #region Task.Task
        public Task<Task.Task> GetTaskAsync(int id) {
            return Connection.Table<Task.Task>().Where(t => t.ID == id).FirstOrDefaultAsync();
        }

        public Task<Task.Task> GetTaskAsync(Guid identifier) {
            return Connection.Table<Task.Task>().Where(t => t.Identifier == identifier).FirstOrDefaultAsync();
        }

        public Task<Task.Task> GetTaskAsync(string identifier) {
            return GetTaskAsync(new Guid(identifier));
        }
        #endregion
    }

    public abstract class ModelObject {
        [PrimaryKey, AutoIncrement]
        public int ID { get; set; }

        [Indexed]
        public Guid Identifier { get; set; } = Guid.NewGuid();

        [Ignore]
        public ObjectManager ObjectManager {
            get { return ObjectManager.Instance; }
        }

        [Ignore]
        public List<Attribute> Attributes {
            get {
                return ObjectManager.GetAttributesAsync(this).Result;
            }
        }

        public virtual System.Threading.Tasks.Task Save() {
            return ObjectManager.SaveAsync(this);
        }

        public virtual System.Threading.Tasks.Task Delete() {
            Task<List<Attribute>> task = ObjectManager.Connection.QueryAsync<Attribute>(
                @"
                    Select * From Attributes Where Owner = ?
                ", this.Identifier);

            task.ContinueWith(t => {
                foreach (Attribute attribute in t.Result)
                    attribute.Delete();
            });

            return ObjectManager.DeleteAsync(this);
        }
    }

    [Table("Attributes")]
    public class Attribute : ModelObject {
        [Indexed]
        public Guid Owner { get; set; }

        [Indexed]
        public string Name { get; set; }

        [MaxLength(2147483647)]
        public string Value { get; set; }
    }
}