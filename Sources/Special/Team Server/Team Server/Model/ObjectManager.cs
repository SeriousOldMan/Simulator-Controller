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

        #region Access.Token
        public Task<Access.Token> GetAccessTokenAsync(int id) {
            return Connection.Table<Access.Token>().Where(t => t.ID == id).FirstOrDefaultAsync();
        }

        public Task<Access.Token> GetAccessTokenAsync(Guid guid, string password) {
            return Connection.Table<Access.Token>().Where(t => t.GUID == guid && t.Password == password).FirstOrDefaultAsync();
        }

        public Task<int> SaveAccessTokenAsync(Access.Token token) {
            if (token.ID != 0)
                return Connection.UpdateAsync(token);
            else
                return Connection.InsertAsync(token);
        }

        public Task<List<Session>> GetTokenSessionsAsync(Access.Token token) {
            return Connection.Table<Session>().Where(s => s.TokenID == token.ID).ToListAsync();
        }
        #endregion

        #region Team
        public Task<Team> GetTeamAsync(int id) {
            return Connection.Table<Team>().Where(t => t.ID == id).FirstOrDefaultAsync();
        }

        public Task<int> SaveTeamAsync(Team team) {
            if (team.ID != 0)
                return Connection.UpdateAsync(team);
            else
                return Connection.InsertAsync(team);
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

        public Task<int> SaveSessionAsync(Session session) {
            if (session.ID != 0)
                return Connection.UpdateAsync(session);
            else
                return Connection.InsertAsync(session);
        }

        public Task<Access.Token> GetSessionTokenAsync(Session session) {
            return Connection.Table<Access.Token>().Where(t => t.ID == session.TokenID).FirstOrDefaultAsync();
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

        public Task<int> SaveStintAsync(Stint stint) {
            if (stint.ID != 0)
                return Connection.UpdateAsync(stint);
            else
                return Connection.InsertAsync(stint);
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

        public Task<int> SaveLapAsync(Lap lap) {
            if (lap.ID != 0)
                return Connection.UpdateAsync(lap);
            else
                return Connection.InsertAsync(lap);
        }

        public Task<Stint> GetLapStintAsync(Lap lap) {
            return Connection.Table<Stint>().Where(s => s.ID == lap.StintID).FirstAsync();
        }
        #endregion
    }

    public class ModelObject {
        [Ignore]
        public ObjectManager ObjectManager {
            get { return ObjectManager.Instance; }
        }
    }
}