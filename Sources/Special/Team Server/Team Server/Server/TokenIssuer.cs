using System;
using TeamServer.Model;
using TeamServer.Model.Access;

namespace TeamServer.Server {
    public class TokenIssuer {
        protected readonly ObjectManager ObjectManager = null;

        public TokenIssuer(ObjectManager objectManager) {
            ObjectManager = objectManager;
        }

        public Model.Access.Token CreateToken(string account, string password) {
            Contract contract = ObjectManager.Instance.GetContractAsync(account, password).Result;

            if (contract == null)
                throw new Exception("Unknown account or password...");
            else if (contract.MinutesLeft <= 0)
                throw new Exception("No time left...");
            else {
                Token token = new Token { Identifier = Guid.NewGuid(), ContractID = contract.ID, Created = DateTime.Now };

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

        public Token ValidateToken(Token token) {
            if ((token == null) || !token.IsValid())
                throw new Exception("Token expired...");
            else
                return token;
        }

        public Token ValidateToken(Guid identifier) {
            return ValidateToken(ObjectManager.GetTokenAsync(identifier).Result);
        }

        public Token ValidateToken(string identifier) {
            return ValidateToken(new Guid(identifier));
        }
    }
}
