using System;
using TeamServer.Model;

namespace TeamServer.Server {
    public class SessionManager : ManagerBase {
        public SessionManager(ObjectManager objectManager, Model.Access.Token token) : base(objectManager, token) {
        }

        public Session StartSession(Team team, int duration, string track = "Unknown", string car = "Unknown", string gridNr = "Unknown") {
            Session session = new Session { TeamID = team.ID, Duration = duration, Track = track, Car = car, GridNr = gridNr };

            ValidateSession(session);

            session.Save();

            return session;
        }

        public Session StartSession(int teamID, int duration, string track, string car, string gridNr) {
            return StartSession(ObjectManager.GetTeamAsync(teamID).Result, duration, track, car, gridNr);
        }

        public Session StartSession(Guid identifier, int duration, string track, string car, string gridNr) {
            return StartSession(ObjectManager.GetTeamAsync(identifier).Result, duration, track, car, gridNr);
        }

        public Session StartSession(string identifier, int duration, string track, string car, string gridNr) {
            return StartSession(ObjectManager.GetTeamAsync(new Guid(identifier)).Result, duration, track, car, gridNr);
        }

        public void EndSession(Session session) {
            ValidateSession(session);

            Token.Contract.MinutesLeft -= (int)Math.Round((DateTime.Now - session.Started).TotalSeconds * 60);
            session.Finished = true;

            session.Save();
        }

        public void EndSession(Guid identifier) {
            EndSession(ObjectManager.GetSessionAsync(identifier).Result);
        }

        public void EndSession(string identifier) {
            EndSession(new Guid(identifier));
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

        public Driver FindDriver(Session session, string driverForName, string driverSurName) {
            foreach (Driver driver in session.Team.Drivers) {
                if ((driver.ForName == driverForName) && (driver.SurName == driverSurName)) {
                    return driver;
                }
            }

            return null;
        }

        public Stint AddStint(Session session, Driver driver, int lapNr, string pitstopData = "") {
            ValidateSession(session);
            ValidateDriver(session, driver);

            Stint stint = session.GetCurrentStint();
            int stintNr = ((stint != null) ? stint.Nr + 1 : 1);

            stint = new Stint { SessionID = session.ID, DriverID = driver.ID, Nr = stintNr, StartLap = lapNr, PitstopData = pitstopData };

            stint.Save();

            return stint;
        }

        public Stint AddStint(Session session, string driverForName, string driverSurName, int lapNr, string pitstopData = "") {
            ValidateSession(session);

            Driver driver = FindDriver(session, driverForName, driverSurName);

            if (driver != null)
                return AddStint(session, driver, lapNr, pitstopData);
            else
                throw new Exception("Unknown driver...");
        }

        public Stint AddStint(Guid identifier, string driverForName, string driverSurName, int lapNr, string pitstopData = "") {
            return AddStint(ObjectManager.GetSessionAsync(identifier).Result, driverForName, driverSurName, lapNr, pitstopData);
        }

        public Stint AddStint(string identifier, string driverForName, string driverSurName, int lapNr, string pitstopData = "") {
            return AddStint(new Guid(identifier), driverForName, driverSurName, lapNr, pitstopData);
        }

        public Lap AddLap(Session session, Stint stint, int lapNr, string telemetryData, string positionData) {
            ValidateSession(session);
            ValidateStint(session, stint);

            Lap lastLap = stint.GetCurrentLap();

            if (((lastLap == null) ? stint.StartLap : lastLap.Nr + 1) != lapNr)
                throw new Exception("Invalid lap number...");
            else {
                Lap lap = new Lap { StintID = stint.ID, Nr = lapNr, TelemetryData = telemetryData, PositionData = positionData };

                lap.Save();

                return lap;
            }
        }
        
        public Lap AddLap(Session session, Driver driver, int lapNr, string telemetryData, string positionData) {
            ValidateSession(session);
            ValidateDriver(session, driver);

            Stint stint = session.GetCurrentStint();
            Driver stintDriver = stint.Driver;

            if ((stintDriver.ForName != driver.ForName) || (stintDriver.SurName != driver.SurName))
                stint = AddStint(session, driver, lapNr);

            return AddLap(session, stint, lapNr, telemetryData, positionData);
        }

        public Lap AddLap(Session session, string driverForName, string driverSurName, int lapNr, string telemetryData, string positionData) {
            ValidateSession(session);

            Driver driver = FindDriver(session, driverForName, driverSurName);

            if (driver != null)
                return AddLap(session, driver, lapNr, telemetryData, positionData);
            else
                throw new Exception("Unknown driver...");
        }

        public Lap AddLap(Guid identifier, string driverForName, string driverSurName, int lapNr, string telemetryData, string positionData) {
            return AddLap(ObjectManager.GetSessionAsync(identifier).Result, driverForName, driverSurName, lapNr, telemetryData, positionData);
        }

        public Lap AddLap(string identifier, string driverForName, string driverSurName, int lapNr, string telemetryData, string positionData) {
            return AddLap(new Guid(identifier), driverForName, driverSurName, lapNr, telemetryData, positionData);
        }
    }
}