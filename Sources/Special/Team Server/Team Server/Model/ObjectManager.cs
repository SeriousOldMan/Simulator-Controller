using SQLite;
using System;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace TeamServer.Model {
    public class ObjectManager {
        public static ObjectManager Instance = null;

        public SQLiteAsyncConnection Connection { get; private set; }

        public ObjectManager(SQLiteAsyncConnection connection) {
            Connection = connection;

            if (Instance == null)
                Instance = this;
        }

        public Task DeleteAsync(ModelObject modelObject) {
            return Connection.DeleteAsync(modelObject);
        }

        public Task<int> SaveAsync(ModelObject modelObject) {
            if (modelObject.ID != 0)
                return Connection.UpdateAsync(modelObject);
            else
                return Connection.InsertAsync(modelObject);
        }

        #region Access.Contract
        public Task<Access.Contract> GetContractAsync(int id) {
            return Connection.Table<Access.Contract>().Where(c => c.ID == id).FirstOrDefaultAsync();
        }

        public Task<Access.Contract> GetContractAsync(string account, string password) {
            return Connection.Table<Access.Contract>().Where(c => c.Account == account && c.Password == password).FirstOrDefaultAsync();
        }

        public Task<List<Access.Token>> GetContractTokensAsync(Access.Contract contract) {
            return Connection.Table<Access.Token>().Where(t => t.ContractID == contract.ID).ToListAsync();
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

        public Task<Access.Contract> GetTokenContractAsync(Access.Token token) {
            return Connection.Table<Access.Contract>().Where(c => c.ID == token.ContractID).FirstAsync();
        }
        #endregion

        #region Team
        public Task<Team> GetTeamAsync(int id) {
            return Connection.Table<Team>().Where(t => t.ID == id).FirstOrDefaultAsync();
        }

        public Task<Team> GetTeamAsync(Guid identifier) {
            return Connection.Table<Team>().Where(t => t.Identifier == identifier).FirstOrDefaultAsync();
        }

        public Task<Team> GetTeamAsync(string identifier) {
            return GetTeamAsync(new Guid(identifier));
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

        public Task<List<Stint>> GetSessionStintsAsync(Session session) {
            return Connection.Table<Stint>().Where(s => s.SessionID == session.ID).ToListAsync();
        }
        #endregion

        #region Stint
        public Task<Stint> GetStintAsync(int id) {
            return Connection.Table<Stint>().Where(s => s.ID == id).FirstOrDefaultAsync();
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

        public Task<Stint> GetLapStintAsync(Lap lap) {
            return Connection.Table<Stint>().Where(s => s.ID == lap.StintID).FirstAsync();
        }
        #endregion
    }

    public class ModelObject {
        [PrimaryKey, AutoIncrement]
        public int ID { get; set; }

        [Ignore]
        public ObjectManager ObjectManager {
            get { return ObjectManager.Instance; }
        }

        public virtual Task Save() {
            return ObjectManager.SaveAsync(this);
        }

        public virtual Task Delete() {
            return ObjectManager.DeleteAsync(this);
        }
    }
}