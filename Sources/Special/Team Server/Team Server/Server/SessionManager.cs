using System;
using System.Collections.Generic;
using TeamServer.Model;

namespace TeamServer.Server {
    public class SessionManager : ManagerBase {
        public SessionManager(ObjectManager objectManager, Model.Access.Token token) : base(objectManager, token) {
        }

        #region Session
        #region Query
        public List<Session> GetAllSessions() {
            return Token.Account.Sessions;
        }

        public Session LookupSession(Guid identifier) {
            Session session = FindSession(identifier);

            ValidateSession(session);

            return session;
        }

        internal Session LookupSession(string identifier) {
            return LookupSession(new Guid(identifier));
        }

        public Session FindSession(Guid identifier) {
            return ObjectManager.GetSessionAsync(identifier).Result;
        }

        public Session FindSession(string identifier) {
            return FindSession(new Guid(identifier));
        }
        #endregion

        #region CRUD
        public Session CreateSession(Team team, string name, int duration, string car, string track, string raceNr) {
            Session session = new Session { TeamID = team.ID, Duration = duration, Track = track, Car = car, RaceNr = raceNr };

            ValidateSession(session);

            session.Save();

            return session;
        }

        public void DeleteSession(Session session) {
            if (session != null)
                session.Delete();
        }

        public void DeleteSession(Guid identifier) {
            DeleteSession(ObjectManager.GetSessionAsync(identifier).Result);
        }

        public void DeleteSession(string identifier) {
            DeleteSession(new Guid(identifier));
        }
        #endregion

        #region Operations
        public Session StartSession(Session session) {
            ValidateSession(session);

            session.Started = DateTime.Now;

            session.Save();

            return session;
        }

        public Session StartSession(Guid identifier) {
            return StartSession(ObjectManager.GetSessionAsync(identifier).Result);
        }

        public Session StartSession(string identifier) {
            return StartSession(new Guid(identifier));
        }

        public void FinishSession(Session session) {
            ValidateSession(session);

            Token.Account.MinutesLeft -= (int)Math.Round((DateTime.Now - session.Started).TotalSeconds * 60);
            session.Finished = true;

            session.Save();
        }

        public void FinishSession(Guid identifier) {
            FinishSession(ObjectManager.GetSessionAsync(identifier).Result);
        }

        public void FinishSession(string identifier) {
            FinishSession(new Guid(identifier));
        }
        #endregion
        #endregion

        #region Stint
        #region Query
        public Stint LookupStint(Guid identifier) {
            Stint stint = FindStint(identifier);

            ValidateStint(stint);

            return stint;
        }

        internal Stint LookupStint(string identifier) {
            return LookupStint(new Guid(identifier));
        }

        public Stint FindStint(Guid identifier) {
            return ObjectManager.GetStintAsync(identifier).Result;
        }

        public Stint FindStint(string identifier) {
            return FindStint(new Guid(identifier));
        }
        #endregion

        #region CRUD
        public Stint CreateStint(Session session, Driver driver, int lap, string pitstopData = "") {
            ValidateSession(session);
            ValidateDriver(driver);

            Stint lastStint = session.GetCurrentStint();
            int stintNr = (lastStint != null) ? lastStint.Nr + 1 : 1;

            Stint stint = new Stint { SessionID = session.ID, DriverID = driver.ID, Nr = stintNr, Lap = lap };

            if (!String.IsNullOrWhiteSpace(pitstopData))
                stint.PitstopData = pitstopData;

            stint.Save();

            return stint;
        }

        public void DeleteStint(Stint stint) {
            if (stint != null)
                stint.Delete();
        }

        public void DeleteStint(Guid identifier) {
            DeleteStint(ObjectManager.GetStintAsync(identifier).Result);
        }

        public void DeleteStint(string identifier) {
            DeleteStint(new Guid(identifier));
        }
        #endregion

        #region Operations
        public Stint UpdatePitstopData(Stint stint, string pitstopData) {
            ValidateStint(stint);

            stint.PitstopData = pitstopData;

            stint.Save();

            return stint;
        }

        public Stint UpdatePitstopData(Guid identifier, string pitstopData) {
            return UpdatePitstopData(ObjectManager.GetStintAsync(identifier).Result, pitstopData);
        }

        public Stint UpdatePitstopData(string identifier, string pitstopData) {
            return UpdatePitstopData(new Guid(identifier), pitstopData);
        }
        #endregion
        #endregion

        #region Lap
        #region Query
        public Lap LookupLap(Guid identifier) {
            Lap lap = FindLap(identifier);

            ValidateLap(lap);

            return lap;
        }

        internal Lap LookupLap(string identifier) {
            return LookupLap(new Guid(identifier));
        }

        public Lap FindLap(Guid identifier) {
            return ObjectManager.GetLapAsync(identifier).Result;
        }

        public Lap FindLap(string identifier) {
            return FindLap(new Guid(identifier));
        }
        #endregion

        #region CRUD
        public Lap CreateLap(Stint stint, int lap) {
            ValidateStint(stint);

            Lap lastLap = stint.GetCurrentLap();

            if ((lastLap != null) && (lastLap.Nr + 1 != lap))
                throw new Exception("Invalid lap number...");

            Lap theLap = new Lap { StintID = stint.ID, Nr = lap };

            theLap.Save();

            return theLap;
        }

        public void DeleteLap(Lap lap) {
            if (lap != null)
                lap.Delete();
        }

        public void DeleteLap(Guid identifier) {
            DeleteLap(ObjectManager.GetLapAsync(identifier).Result);
        }

        public void DeleteLap(string identifier) {
            DeleteLap(new Guid(identifier));
        }
        #endregion

        #region Operations
        public Lap UpdateTelemetryData(Lap lap, string telemetryData) {
            ValidateLap(lap);

            lap.TelemetryData = telemetryData;

            lap.Save();

            return lap;
        }

        public Lap UpdateTelemetryData(Guid identifier, string telemetryData) {
            return UpdateTelemetryData(ObjectManager.GetLapAsync(identifier).Result, telemetryData);
        }

        public Lap UpdateTelemetryData(string identifier, string telemetryData) {
            return UpdateTelemetryData(new Guid(identifier), telemetryData);
        }

        public Lap UpdatePositionData(Lap lap, string positionData) {
            ValidateLap(lap);

            lap.PositionData = positionData;

            lap.Save();

            return lap;
        }

        public Lap UpdatePositionData(Guid identifier, string positionData) {
            return UpdatePositionData(ObjectManager.GetLapAsync(identifier).Result, positionData);
        }

        public Lap UpdatePositionData(string identifier, string positionData) {
            return UpdatePositionData(new Guid(identifier), positionData);
        }
        #endregion
        #endregion
    }
}