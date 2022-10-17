using System;
using TeamServer.Model;
using TeamServer.Model.Access;

namespace TeamServer.Server {
    public abstract class ManagerBase {
        internal readonly Token Token = null;
        internal readonly ObjectManager ObjectManager = null;

        public ManagerBase(ObjectManager objectManager, Model.Access.Token token) {
            ObjectManager = objectManager;
            Token = ValidateToken(token);
        }

        public ManagerBase(ObjectManager objectManager, Guid token)
        {
            ObjectManager = objectManager;
            Token = ValidateToken(token);
        }

        public ManagerBase(ObjectManager objectManager, string token)
        {
            ObjectManager = objectManager;
            Token = ValidateToken(token);
        }

        #region Validation
        public virtual Token ValidateToken(Token token) {
            return TeamServer.TokenIssuer.ValidateToken(token);
        }

        public Token ValidateToken(Guid token)
        {
            return ValidateToken(ObjectManager.GetTokenAsync(token).Result);
        }

        public Token ValidateToken(string token)
        {
            return ValidateToken(new Guid(token));
        }
        #endregion
    }
}