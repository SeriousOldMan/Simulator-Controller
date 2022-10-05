using System;
using TeamServer.Model;
using TeamServer.Model.Access;

namespace TeamServer.Server {
    public abstract class ManagerBase {
        protected readonly Model.Access.Token Token = null;
        protected readonly ObjectManager ObjectManager = null;

        public ManagerBase(ObjectManager objectManager, Model.Access.Token token) {
            ObjectManager = objectManager;
            Token = ValidateToken(token);
        }

        #region Validation
        public virtual Token ValidateToken(Token token) {
            return TeamServer.TokenIssuer.ValidateToken(token);
        }

        public Token ValidateToken(Guid token)
        {
            return ValidateToken(token);
        }

        public Token ValidateToken(string token)
        {
            return ValidateToken(new Guid(token));
        }
        #endregion
    }
}