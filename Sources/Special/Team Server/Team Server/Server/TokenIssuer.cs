using System;
using System.Collections.Generic;
using TeamServer.Model;
using TeamServer.Model.Access;

namespace TeamServer.Server {
    public class TokenIssuer {
        protected readonly ObjectManager ObjectManager = null;
        protected readonly int TokenLifeTime;

        public Token AdminToken = null;

        public TokenIssuer(ObjectManager objectManager, int tokenLifeTime) {
            ObjectManager = objectManager;
            TokenLifeTime = tokenLifeTime;

            AdminToken = new AdminToken { ID = -1, Identifier = Guid.NewGuid(), AccountID = 0, Until = DateTime.MaxValue };
        }

        #region Tokens
        #region CRUD
        public SessionToken CreateSessionToken(string name, string password) {
            Account account = ObjectManager.Instance.GetAccountAsync(name, password).Result;

            if (account == null)
                throw new Exception("Unknown account or password...");
            else if (!account.Administrator && (account.AvailableMinutes <= 0))
                throw new Exception("Not enough time available on account...");
            else {
                SessionToken token = new SessionToken { Identifier = Guid.NewGuid(), AccountID = account.ID,
                                                        Created = DateTime.Now, Until = DateTime.Now + new TimeSpan(0, 0, TokenLifeTime, 0) };

                token.Save();

                return token;
            }
        }

        public StoreToken CreateStoreToken(string name, string password)
        {
            Account account = ObjectManager.Instance.GetAccountAsync(name, password).Result;

            if (account == null)
                throw new Exception("Unknown account or password...");
            else
            {
                StoreToken token = ObjectManager.GetAccountStoreTokenAsync(account).Result;

                if (token == null)
                {
                    token = new StoreToken
                    {
                        Identifier = Guid.NewGuid(),
                        AccountID = account.ID,
                        Created = DateTime.Now,
                        Until = DateTime.MaxValue
                    };

                    token.Save();
                }

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

        #region Elevation
        public Token ElevateToken(Token token) {
            ValidateToken(token);

            if (token == AdminToken)
                return token;
            else if (!token.Account.Administrator)
                throw new Exception("Higher privileges required...");
            else
                return token;
        }

        public Token ElevateToken(Guid identifier) {
            return ElevateToken(ObjectManager.GetTokenAsync(identifier).Result);
        }

        public Token ElevateToken(string identifier) {
            return ElevateToken(new Guid(identifier));
        }
        #endregion
        #endregion

        #region Connections
        #region Connect
        public Connection Connect(Token token, string client, string name, ConnectionType type, Session session = null)
        {
            ValidateToken(token);

            Connection connection = ObjectManager.GetTokenConnectionAsync(token, client, name, type, session).Result;

            if (connection == null)
            {
                connection = new Connection
                {
                    Identifier = Guid.NewGuid(),
                    TokenID = token.ID,
                    Created = DateTime.Now,
                    Type = type,
                    Client = client,
                    Name = name
                };

                connection.Save();
            }
            
            connection.Renew();
            
            return connection;
        }

        public Connection Connect(Token token, string client, string name, ConnectionType type, string session = "")
        {
            ValidateToken(token);

            return Connect(token, client, name, type, ObjectManager.GetSessionAsync(session).Result);
        }

        public Connection Connect(Guid identifier, string client, string name, ConnectionType type, string session = "")
        {
            return Connect(ObjectManager.GetTokenAsync(identifier).Result, client, name, type, session);
        }

        public Connection Connect(string identifier, string client, string name, ConnectionType type, string session = "")
        {
            return Connect(new Guid(identifier), client, name, type, session);
        }
        #endregion

        #region Validation
        public void ValidateConnection(Connection connection)
        {
            if ((connection == null) || (!connection.IsConnected()))
                throw new Exception("Not a valid or active connection...");
        }
        #endregion

        #region Query
        public List<Connection> GetAllConnections()
        {
            return ObjectManager.GetAllConnectionsAsync().Result;
        }

        public Connection LookupConnection(Guid identifier)
        {
            Connection connection = FindConnection(identifier);

            ValidateConnection(connection);

            return connection;
        }

        public Connection LookupConnection(string identifier)
        {
            return LookupConnection(new Guid(identifier));
        }

        public Connection FindConnection(Guid identifier)
        {
            return ObjectManager.GetConnectionAsync(identifier).Result;
        }

        public Connection FindConnection(string identifier)
        {
            return FindConnection(new Guid(identifier));
        }
        #endregion

        #region CRUD
        public void DeleteConnection(Connection connection)
        {
            if (connection != null)
                connection.Delete();
        }

        public void DeleteConnection(Guid identifier)
        {
            DeleteConnection(ObjectManager.GetConnectionAsync(identifier).Result);
        }

        public void DeleteConnection(string identifier)
        {
            DeleteConnection(new Guid(identifier));
        }
        #endregion
        #endregion

        #region Operations
        public async void CleanupConnectionsAsync()
        {
            await ObjectManager.Connection.QueryAsync<Connection>(
                @"
                    Select * From Access_Connections
                ").ContinueWith(t => t.Result.ForEach(c => {
                    if (!c.IsConnected())
                        DeleteConnection(c);
                }));
        }

        public async void CleanupTokensAsync()
        {
            await ObjectManager.Connection.QueryAsync<SessionToken>(
                @"
                    Select * From Access_Session_Tokens Where Until < ?
                ", DateTime.Now).ContinueWith(t => t.Result.ForEach(t => {
                    if (!t.IsValid())
                        DeleteToken(t);
                }));

            await ObjectManager.Connection.QueryAsync<StoreToken>(
                @"
                    Select * From Access_Store_Tokens Where Until < ?
                ", DateTime.Now).ContinueWith(t => t.Result.ForEach(t => {
                    if (!t.IsValid())
                        DeleteToken(t);
                }));
        }
        #endregion
    }
}
