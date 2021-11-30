using System;
using TeamServer.Model;
using TeamServer.Model.Access;

namespace TeamServer.Server {
    public class TokenIssuer {
        protected readonly ObjectManager ObjectManager = null;
        protected readonly int TokenLifeTime;

        public TokenIssuer(ObjectManager objectManager, int tokenLifeTime) {
            ObjectManager = objectManager;
            TokenLifeTime = tokenLifeTime;
        }

        #region CRUD
        public Token CreateToken(string name, string password) {
            Account account = ObjectManager.Instance.GetAccountAsync(name, password).Result;

            if (account == null)
                throw new Exception("Unknown account or password...");
            else if (account.MinutesLeft <= 0)
                throw new Exception("Not enough time left on account...");
            else {
                Token token = new Token { Identifier = Guid.NewGuid(), AccountID = account.ID,
                                          Created = DateTime.Now, Until = DateTime.Now + new TimeSpan(0, 0, TokenLifeTime, 0) };

                token.Save();

                return token;
            }
        }

        public void DeleteToken(Token token) {
            if (token != null)
                token.Delete();
        }

        public void DeleteToken(Guid identifier) {
            DeleteToken(ObjectManager.GetTokenAsync(identifier).Result);
        }

        public void DeleteToken(string identifier) {
            DeleteToken(new Guid(identifier));
        }
        #endregion

        #region Validation
        public Token ValidateToken(Token token) {
            if ((token == null) || !token.IsValid())
                throw new Exception("Token expired...");
            else {
                if ((token.Used == null) || (DateTime.Now > token.Used + new TimeSpan(0, 1, 0))) {
                    token.Used = DateTime.Now;

                    token.Save();
                }

                return token;
            }
        }

        public Token ValidateToken(Guid identifier) {
            return ValidateToken(ObjectManager.GetTokenAsync(identifier).Result);
        }

        public Token ValidateToken(string identifier) {
            return ValidateToken(new Guid(identifier));
        }
        #endregion
    }
}
