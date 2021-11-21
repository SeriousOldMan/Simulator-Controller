using System;
using TeamServer.Model;
using TeamServer.Model.Access;

namespace TeamServer.Server {
    public abstract class ManagerBase {
        protected readonly Model.Access.Token Token = null;
        protected readonly ObjectManager ObjectManager = null;

        public ManagerBase(ObjectManager objectManager, Model.Access.Token token) {
            ObjectManager = objectManager;
            Token = token;

            ValidateToken(token);
        }

        #region Validation
        public void ValidateToken(Token token) {
            TeamServer.TokenIssuer.ValidateToken(token);
        }

        public void ValidateToken(Guid token) {
            TeamServer.TokenIssuer.ValidateToken(token);
        }

        public void ValidateAccount(int duration) {
            if (Token.Account.MinutesLeft < duration)
                throw new Exception("Not enough time left on account...");
        }

        public void ValidateAccount(Account account) {
            if (account == null)
                throw new Exception("Not a valid account...");
        }

        public void ValidateTeam(Team team) {
            if (team == null)
                throw new Exception("Not a known team...");
        }

        public void ValidateDriver(Driver driver) {
            if (driver == null)
                throw new Exception("Not a known driver...");
        }

        public void ValidateDriver(Team team, Driver driver) {
            if (driver.Team.Identifier != team.Identifier)
                throw new Exception("Driver not part of the team...");
        }

        public void ValidateDriver(Session session, Driver driver) {
            ValidateDriver(session.Team, driver);
        }

        public void ValidateSession(Session session) {
            if (session == null)
                throw new Exception("Not a valid or active session...");
            else
                ValidateAccount(session.Duration);
        }

        public void ValidateStint(Stint stint) {
            if (stint == null)
                throw new Exception("Not a valid stint...");
        }

        public void ValidateStint(Session session, Stint stint) {
            ValidateSession(session);

            if (stint == null)
                throw new Exception("Not a valid stint...");
        }

        public void ValidateLap(Lap lap) {
            if (lap == null)
                throw new Exception("Not a valid lap...");
        }

        public void ValidateLap(Stint stint, Lap lap) {
            ValidateStint(stint);

            if (lap == null)
                throw new Exception("Not a valid lap...");
        }
        #endregion
    }
}