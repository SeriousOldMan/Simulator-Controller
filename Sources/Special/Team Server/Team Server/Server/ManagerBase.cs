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
        #endregion
    }
}