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

        public Task<List<Access.Token>> GetAccountTokensAsync(Access.Account account)
        {
            return Connection.Table<Access.Token>().Where(t => t.AccountID == account.ID).ToListAsync();
        }

        public Task<Access.Token> GetAccountDataTokenAsync(Access.Account account)
        {
            return Connection.Table<Access.Token>().Where(t => t.AccountID == account.ID &&
                                                               t.Type == Access.Token.TokenType.Data).FirstOrDefaultAsync();
        }

        public async void DoAccountTokensAsync(Access.Account account, Action<Access.Token> action)
        {
            foreach (Access.Token t in await GetAccountTokensAsync(account))
                action(t);
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

        public Task<List<Data.License>> GetAccountLicensesAsync(Access.Account account)
        {
            return Connection.Table<Data.License>().Where(t => t.AccountID == account.ID).ToListAsync();
        }

        public Task<List<Data.Electronics>> GetAccountElectronicsAsync(Access.Account account)
        {
            return Connection.Table<Data.Electronics>().Where(t => t.AccountID == account.ID).ToListAsync();
        }

        public Task<List<Data.Tyres>> GetAccountTyresAsync(Access.Account account)
        {
            return Connection.Table<Data.Tyres>().Where(t => t.AccountID == account.ID).ToListAsync();
        }

        public Task<List<Data.Brakes>> GetAccountBrakesAsync(Access.Account account)
        {
            return Connection.Table<Data.Brakes>().Where(t => t.AccountID == account.ID).ToListAsync();
        }

        public Task<List<Data.TyresPressures>> GetAccountTyresPressuresAsync(Access.Account account)
        {
            return Connection.Table<Data.TyresPressures>().Where(t => t.AccountID == account.ID).ToListAsync();
        }

        public Task<List<Data.TyresPressuresDistribution>> GetAccountTyresPressuresDistributionDataAsync(Access.Account account)
        {
            return Connection.Table<Data.TyresPressuresDistribution>().Where(t => t.AccountID == account.ID).ToListAsync();
        }

        public async void DoAccountDataAsync(Access.Account account, Action<Data.DataObject> action)
        {
            foreach (Data.DataObject data in await GetAccountLicensesAsync(account))
                action(data);

            foreach (Data.DataObject data in await GetAccountElectronicsAsync(account))
                action(data);

            foreach (Data.DataObject data in await GetAccountTyresAsync(account))
                action(data);

            foreach (Data.DataObject data in await GetAccountBrakesAsync(account))
                action(data);

            foreach (Data.DataObject data in await GetAccountTyresPressuresAsync(account))
                action(data);

            foreach (Data.DataObject data in await GetAccountTyresPressuresDistributionDataAsync(account))
                action(data);
        }
        
        public Task<List<Data.DataObject>> GetAccountDataAsync(Access.Account account)
        {
            return new Task<List<Data.DataObject>>(() =>
            {
                List<Data.DataObject> list = new List<Data.DataObject>();

                DoAccountDataAsync(account, (Data.DataObject data) => { list.Add(data); });

                return list;
            });
        }
        #endregion

        #region Access.Token
        public Task<Access.Token> GetTokenAsync(int id) {
            return Connection.Table<Access.Token>().Where(t => t.ID == id).FirstOrDefaultAsync();
        }

        public Task<Access.Token> GetTokenAsync(Guid identifier) {
            return Connection.Table<Access.Token>().Where(t => t.Identifier == identifier).FirstOrDefaultAsync();
        }

        public Task<Access.Token> GetTokenAsync(string identifier) {
            return GetTokenAsync(new Guid(identifier));
        }

        public Task<Access.Account> GetTokenAccountAsync(Access.Token token) {
            if (token.AccountID == 0)
            {
                if (token != Server.TeamServer.TokenIssuer.InternalToken)
                    throw new Exception("Corrupt token detected...");

                return null;
            }
            else
                return Connection.Table<Access.Account>().Where(a => a.ID == token.AccountID).FirstAsync();
        }

        public Task<Access.Connection> GetTokenConnectionAsync(Access.Token token, string client, string name,
                                                               Access.Connection.ConnectionType type,
                                                               Session session = null)
        {
            int theType = (int)type;

            Task<Access.Connection> task =
                (session != null) ?
                    Connection.Table<Access.Connection>().Where(c => c.TokenID == token.ID && c.Type == type &&
                                                                     c.Client == client && c.Name == name &&
                                                                     c.SessionID == session.ID).FirstOrDefaultAsync()
                :
                    Connection.Table<Access.Connection>().Where(c => c.TokenID == token.ID && c.Type == type &&
                                                                     c.Client == client && c.Name == name).FirstOrDefaultAsync();


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

        #region Data.Document
        public Task<Data.Document> GetDocumentAsync(int id)
        {
            return Connection.Table<Data.Document>().Where(d => d.ID == id).FirstOrDefaultAsync();
        }

        public Task<Data.Document> GetDocumentAsync(Guid identifier)
        {
            return Connection.Table<Data.Document>().Where(d => d.Identifier == identifier).FirstOrDefaultAsync();
        }

        public Task<Data.Document> GetDocumentAsync(string identifier)
        {
            return GetDocumentAsync(new Guid(identifier));
        }
        #endregion

        #region Data.License
        public Task<Data.License> GetLicenseAsync(int id)
        {
            return Connection.Table<Data.License>().Where(l => l.ID == id).FirstOrDefaultAsync();
        }

        public Task<Data.License> GetLicenseAsync(Guid identifier)
        {
            return Connection.Table<Data.License>().Where(l => l.Identifier == identifier).FirstOrDefaultAsync();
        }

        public Task<Data.License> GetLicenseAsync(string identifier)
        {
            return GetLicenseAsync(new Guid(identifier));
        }
        #endregion

        #region Data.Electronics
        public Task<Data.Electronics> GetElectronicsAsync(int id)
        {
            return Connection.Table<Data.Electronics>().Where(e => e.ID == id).FirstOrDefaultAsync();
        }

        public Task<Data.Electronics> GetElectronicsAsync(Guid identifier)
        {
            return Connection.Table<Data.Electronics>().Where(e => e.Identifier == identifier).FirstOrDefaultAsync();
        }

        public Task<Data.Electronics> GetElectronicsAsync(string identifier)
        {
            return GetElectronicsAsync(new Guid(identifier));
        }
        #endregion

        #region Data.Tyres
        public Task<Data.Tyres> GetTyresAsync(int id)
        {
            return Connection.Table<Data.Tyres>().Where(t => t.ID == id).FirstOrDefaultAsync();
        }

        public Task<Data.Tyres> GetTyresAsync(Guid identifier)
        {
            return Connection.Table<Data.Tyres>().Where(t => t.Identifier == identifier).FirstOrDefaultAsync();
        }

        public Task<Data.Tyres> GetTyresAsync(string identifier)
        {
            return GetTyresAsync(new Guid(identifier));
        }
        #endregion

        #region Data.Brakes
        public Task<Data.Brakes> GetBrakesAsync(int id)
        {
            return Connection.Table<Data.Brakes>().Where(t => t.ID == id).FirstOrDefaultAsync();
        }

        public Task<Data.Brakes> GetBrakesAsync(Guid identifier)
        {
            return Connection.Table<Data.Brakes>().Where(t => t.Identifier == identifier).FirstOrDefaultAsync();
        }

        public Task<Data.Brakes> GetBrakesAsync(string identifier)
        {
            return GetBrakesAsync(new Guid(identifier));
        }
        #endregion

        #region Data.TyresPressures
        public Task<Data.TyresPressures> GetTyresPressuresAsync(int id)
        {
            return Connection.Table<Data.TyresPressures>().Where(t => t.ID == id).FirstOrDefaultAsync();
        }

        public Task<Data.TyresPressures> GetTyresPressuresAsync(Guid identifier)
        {
            return Connection.Table<Data.TyresPressures>().Where(t => t.Identifier == identifier).FirstOrDefaultAsync();
        }

        public Task<Data.TyresPressures> GetTyresPressuresAsync(string identifier)
        {
            return GetTyresPressuresAsync(new Guid(identifier));
        }
        #endregion

        #region Data.TyresPressuresDistribution
        public Task<Data.TyresPressuresDistribution> GetTyresPressuresDistributionAsync(int id)
        {
            return Connection.Table<Data.TyresPressuresDistribution>().Where(t => t.ID == id).FirstOrDefaultAsync();
        }

        public Task<Data.TyresPressuresDistribution> GetTyresPressuresDistributionAsync(Guid identifier)
        {
            return Connection.Table<Data.TyresPressuresDistribution>().Where(t => t.Identifier == identifier).FirstOrDefaultAsync();
        }

        public Task<Data.TyresPressuresDistribution> GetTyresPressuresDistributionAsync(string identifier)
        {
            return GetTyresPressuresDistributionAsync(new Guid(identifier));
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