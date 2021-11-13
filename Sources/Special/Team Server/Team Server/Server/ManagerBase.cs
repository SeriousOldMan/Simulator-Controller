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

        protected void ValidateToken(Token token) {
            TeamServer.TokenIssuer.ValidateToken(token);
        }

        protected void ValidateToken(Guid token) {
            TeamServer.TokenIssuer.ValidateToken(token);
        }

        protected void ValidateContract(int duration) {
            if (Token.Contract.MinutesLeft < duration)
                throw new Exception("Not enough time left on contract...");
        }

        protected void ValidateContract(Contract contract) {
            if (contract == null)
                throw new Exception("Not a valid contract...");
        }

        protected void ValidateTeam(Team team) {
            if (team == null)
                throw new Exception("Not a known team...");
        }

        protected void ValidateDriver(Session session, Driver driver) {
            if (driver.Team.Identifier != session.Team.Identifier)
                throw new Exception("Driver not part of the team...");
        }

        protected void ValidateSession(Session session) {
            if ((session == null) || session.Finished)
                throw new Exception("Not a valid or active session...");
            else
                ValidateContract(session.Duration);
        }

        protected void ValidateStint(Session session, Stint stint) {
            ValidateSession(session);

            if (stint == null)
                throw new Exception("Not a valid or active stint...");
        }
    }
}